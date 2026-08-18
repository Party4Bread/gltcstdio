struct Params {
    U: array<vec4<f32>, 15>,
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

fn triangleKaleidoscope(pos: vec2<f32>, outPos: vec2<f32>, offset: f32, modelTransform: mat3x3<f32>) -> vec4<f32> {
    var pos_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var offset_1: f32;
    var modelTransform_1: mat3x3<f32>;
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
    var px: f32;
    var py: f32;
    var coord: vec2<f32>;

    pos_1 = pos;
    outPos_1 = outPos;
    offset_1 = offset;
    modelTransform_1 = modelTransform;
    let _e14 = modelTransform_1;
    let _e15 = pos_1;
    u = (_e14 * vec3<f32>(_e15.x, _e15.y, 1f)).xy;
    let _e25 = tileWidth;
    halfTileWidth = (_e25 / 2f);
    let _e29 = tileWidth;
    tileHeight = (_e29 * 0.8660254f);
    let _e33 = tileWidth;
    centerHeight = (_e33 / 3.4641016f);
    let _e39 = u;
    X = _e39.x;
    let _e42 = u;
    Y = _e42.y;
    let _e45 = Y;
    let _e46 = tileHeight;
    row = floor((_e45 / _e46));
    let _e50 = X;
    let _e51 = halfTileWidth;
    column = floor((_e50 / _e51));
    let _e55 = X;
    let _e56 = column;
    let _e57 = halfTileWidth;
    dx = (_e55 - (_e56 * _e57));
    let _e61 = Y;
    let _e62 = row;
    let _e63 = tileHeight;
    dy = (_e61 - (_e62 * _e63));
    let _e67 = row;
    let _e68 = column;
    let _e69 = (_e67 + _e68);
    down = ((_e69 - (floor((_e69 / 2f)) * 2f)) == 0f);
    let _e80 = down;
    if _e80 {
        {
            let _e81 = dy;
            let _e82 = tileHeight;
            let _e83 = dx;
            if (_e81 > (_e82 - (_e83 * 1.7320508f))) {
                {
                    let _e88 = row;
                    let _e91 = tileHeight;
                    let _e93 = centerHeight;
                    cy = (((_e88 + 1f) * _e91) - _e93);
                    let _e95 = column;
                    let _e98 = halfTileWidth;
                    cx = ((_e95 + 1f) * _e98);
                    down = true;
                }
            } else {
                {
                    let _e101 = row;
                    let _e102 = tileHeight;
                    let _e104 = centerHeight;
                    cy = ((_e101 * _e102) + _e104);
                    let _e106 = column;
                    let _e107 = halfTileWidth;
                    cx = (_e106 * _e107);
                    down = false;
                }
            }
        }
    } else {
        {
            let _e110 = dy;
            let _e111 = dx;
            if (_e110 > (_e111 * 1.7320508f)) {
                {
                    let _e115 = row;
                    let _e118 = tileHeight;
                    let _e120 = centerHeight;
                    cy = (((_e115 + 1f) * _e118) - _e120);
                    let _e122 = column;
                    let _e123 = halfTileWidth;
                    cx = (_e122 * _e123);
                    down = true;
                }
            } else {
                {
                    let _e126 = row;
                    let _e127 = tileHeight;
                    let _e129 = centerHeight;
                    cy = ((_e126 * _e127) + _e129);
                    let _e131 = column;
                    let _e134 = halfTileWidth;
                    cx = ((_e131 + 1f) * _e134);
                    down = false;
                }
            }
        }
    }
    let _e139 = column;
    let _e141 = row;
    let _e143 = (_e139 + (3f * _e141));
    tripos = i32((_e143 - (floor((_e143 / 6f)) * 6f)));
    let _e151 = tripos;
    if (_e151 == 2i) {
        {
            let _e154 = column;
            let _e155 = halfTileWidth;
            hcx = (_e154 * _e155);
            let _e157 = row;
            let _e160 = tileHeight;
            hcy = ((_e157 + 1f) * _e160);
        }
    } else {
        let _e162 = tripos;
        if (_e162 == 1i) {
            {
                let _e165 = column;
                let _e168 = halfTileWidth;
                hcx = ((_e165 + 1f) * _e168);
                let _e170 = row;
                let _e173 = tileHeight;
                hcy = ((_e170 + 1f) * _e173);
            }
        } else {
            let _e175 = tripos;
            if (_e175 == 0i) {
                {
                    let _e178 = down;
                    if _e178 {
                        {
                            let _e179 = column;
                            let _e182 = halfTileWidth;
                            hcx = ((_e179 + 2f) * _e182);
                            let _e184 = row;
                            let _e187 = tileHeight;
                            hcy = ((_e184 + 1f) * _e187);
                        }
                    } else {
                        {
                            let _e189 = column;
                            let _e192 = halfTileWidth;
                            hcx = ((_e189 - 1f) * _e192);
                            let _e194 = row;
                            let _e195 = tileHeight;
                            hcy = (_e194 * _e195);
                        }
                    }
                }
            } else {
                let _e197 = tripos;
                if (_e197 == 5i) {
                    {
                        let _e200 = column;
                        let _e201 = halfTileWidth;
                        hcx = (_e200 * _e201);
                        let _e203 = row;
                        let _e204 = tileHeight;
                        hcy = (_e203 * _e204);
                    }
                } else {
                    let _e206 = tripos;
                    if (_e206 == 4i) {
                        {
                            let _e209 = column;
                            let _e212 = halfTileWidth;
                            hcx = ((_e209 + 1f) * _e212);
                            let _e214 = row;
                            let _e215 = tileHeight;
                            hcy = (_e214 * _e215);
                        }
                    } else {
                        {
                            let _e217 = down;
                            if _e217 {
                                {
                                    let _e218 = column;
                                    let _e221 = halfTileWidth;
                                    hcx = ((_e218 - 1f) * _e221);
                                    let _e223 = row;
                                    let _e226 = tileHeight;
                                    hcy = ((_e223 + 1f) * _e226);
                                }
                            } else {
                                {
                                    let _e228 = column;
                                    let _e231 = halfTileWidth;
                                    hcx = ((_e228 + 2f) * _e231);
                                    let _e233 = row;
                                    let _e234 = tileHeight;
                                    hcy = (_e233 * _e234);
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    let _e236 = X;
    let _e237 = cx;
    dx = (_e236 - _e237);
    let _e239 = Y;
    let _e240 = cy;
    dy = (_e239 - _e240);
    let _e242 = cx;
    let _e243 = hcx;
    cx = (_e242 - _e243);
    let _e245 = cy;
    let _e246 = hcy;
    cy = (_e245 - _e246);
    let _e248 = cx;
    let _e249 = tileHeight;
    let _e250 = centerHeight;
    cx = (_e248 / (_e249 - _e250));
    let _e253 = cy;
    let _e254 = tileHeight;
    let _e255 = centerHeight;
    cy = (_e253 / (_e254 - _e255));
    let _e258 = cy;
    let _e259 = dx;
    let _e261 = cx;
    let _e262 = dy;
    px = ((_e258 * _e259) - (_e261 * _e262));
    let _e266 = cx;
    let _e267 = dx;
    let _e269 = cy;
    let _e270 = dy;
    py = ((_e266 * _e267) + (_e269 * _e270));
    let _e274 = px;
    let _e275 = py;
    let _e277 = offset_1;
    let _e278 = offset_1;
    let _e282 = u;
    coord = (vec2<f32>(_e274, _e275) + (((_e277 * _e278) * 0.0001f) * _e282));
    let _e286 = coord;
    let _e290 = global.U[0];
    let _e293 = coord;
    let _e302 = _mirror_wrap(((vec2<f32>((_e286.x / _e290.x), _e293.y) / vec2(2f)) + vec2(0.5f)));
    let _e303 = textureSample(t_source, samp, _e302);
    return _e303;
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
    let _e66 = global.U[11];
    let _e70 = global.U[12];
    let _e71 = _e70.xyz;
    let _e74 = global.U[13];
    let _e75 = _e74.xyz;
    let _e78 = global.U[14];
    let _e79 = _e78.xyz;
    let _e93 = triangleKaleidoscope((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e9.x, _e9.y, _e9.z), vec3<f32>(_e13.x, _e13.y, _e13.z), vec3<f32>(_e17.x, _e17.y, _e17.z))) * vec3<f32>(_e44.x, _e44.y, 1f)).xy, (((_e51 - vec2(0.5f)) * 2f) * vec2<f32>(_e59.x, 1f)), _e66.x, mat3x3<f32>(vec3<f32>(_e71.x, _e71.y, _e71.z), vec3<f32>(_e75.x, _e75.y, _e75.z), vec3<f32>(_e79.x, _e79.y, _e79.z)));
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
