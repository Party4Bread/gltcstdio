struct Params {
    U: array<vec4<f32>, 19>,
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

fn iteratedRectTilesGL(pos: vec2<f32>, outPos: vec2<f32>, intensity: f32, iterations: i32, shapeAspectRatio: f32, distortion: f32, pixelation: f32, modelTransform: mat3x3<f32>) -> vec4<f32> {
    var pos_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var intensity_1: f32;
    var iterations_1: i32;
    var shapeAspectRatio_1: f32;
    var distortion_1: f32;
    var pixelation_1: f32;
    var modelTransform_1: mat3x3<f32>;
    var invM: mat3x3<f32>;
    var u: vec2<f32>;
    var tileWidth: f32 = 2f;
    var tileHeight: f32;
    var tileSize: vec2<f32>;
    var locusStrength: f32 = 1f;
    var intEff: f32;
    var s: f32;
    var tileCenter: vec2<f32> = vec2<f32>(0f, 0f);
    var p: vec2<f32> = vec2<f32>(0f, 0f);
    var i: i32 = 0i;
    var row: f32;
    var column: f32;
    var v: vec2<f32>;
    var r: vec2<f32>;
    var borderX: bool;
    var borderY: bool;
    var d: f32;
    var outColor: vec4<f32>;
    var tileCenterTexSpace: vec2<f32>;
    var pixelColor: vec4<f32>;

    pos_1 = pos;
    outPos_1 = outPos;
    intensity_1 = intensity;
    iterations_1 = iterations;
    shapeAspectRatio_1 = shapeAspectRatio;
    distortion_1 = distortion;
    pixelation_1 = pixelation;
    modelTransform_1 = modelTransform;
    let _e22 = modelTransform_1;
    invM = _naga_inverse_3x3_f32(_e22);
    let _e25 = modelTransform_1;
    let _e26 = pos_1;
    u = (_e25 * vec3<f32>(_e26.x, _e26.y, 1f)).xy;
    let _e37 = shapeAspectRatio_1;
    tileHeight = (2f * _e37);
    let _e44 = invM[0][0];
    let _e49 = invM[1][0];
    let _e52 = tileWidth;
    let _e58 = invM[0][1];
    let _e63 = invM[1][1];
    let _e66 = tileHeight;
    tileSize = vec2<f32>((length(vec2<f32>(_e44, _e49)) * _e52), (length(vec2<f32>(_e58, _e63)) * _e66));
    let _e72 = intensity_1;
    intEff = (_e72 * 0.1f);
    let _e77 = intEff;
    let _e78 = locusStrength;
    let _e81 = tileSize;
    let _e85 = tileSize;
    s = (1f + ((_e77 * _e78) * (max((2f / _e81.x), (2f / _e85.y)) - 1f)));
    loop {
        let _e104 = i;
        let _e105 = iterations_1;
        if !((_e104 < _e105)) {
            break;
        }
        {
            let _e111 = u;
            let _e113 = tileHeight;
            row = floor((_e111.y / _e113));
            let _e117 = u;
            let _e119 = tileWidth;
            column = floor((_e117.x / _e119));
            let _e123 = column;
            let _e126 = tileWidth;
            let _e128 = row;
            let _e131 = tileHeight;
            tileCenter = vec2<f32>(((_e123 + 0.5f) * _e126), ((_e128 + 0.5f) * _e131));
            let _e134 = u;
            let _e135 = tileCenter;
            v = (_e134 - _e135);
            let _e138 = invM;
            let _e139 = v;
            let _e140 = s;
            let _e142 = tileCenter;
            let _e143 = ((_e139 * _e140) + _e142);
            p = (_e138 * vec3<f32>(_e143.x, _e143.y, 1f)).xy;
            borderX = false;
            borderY = false;
            let _e155 = distortion_1;
            if (_e155 > 0f) {
                {
                    let _e158 = distortion_1;
                    d = _e158;
                    let _e160 = v;
                    let _e161 = tileWidth;
                    let _e162 = tileHeight;
                    r = ((_e160 / vec2<f32>(_e161, _e162)) + vec2<f32>(0.5f, 0.5f));
                    let _e169 = r;
                    let _e171 = d;
                    if (_e169.x < (_e171 / 2f)) {
                        {
                            let _e177 = r;
                            let _e180 = d;
                            r.x = ((2f * _e177.x) / _e180);
                            borderX = true;
                            let _e184 = p;
                            let _e186 = tileSize;
                            let _e189 = r;
                            let _e194 = r;
                            p.x = (_e184.x - ((_e186.x * (1f - _e189.x)) / (0.5f + _e194.x)));
                        }
                    } else {
                        let _e199 = r;
                        let _e202 = d;
                        if (_e199.x > (1f - (_e202 / 2f))) {
                            {
                                let _e210 = r;
                                let _e214 = d;
                                r.x = ((2f * (1f - _e210.x)) / _e214);
                                borderX = true;
                                let _e218 = p;
                                let _e220 = tileSize;
                                let _e223 = r;
                                let _e228 = r;
                                p.x = (_e218.x + ((_e220.x * (1f - _e223.x)) / (0.5f + _e228.x)));
                            }
                        }
                    }
                    let _e233 = r;
                    let _e235 = d;
                    if (_e233.y < (_e235 / 2f)) {
                        {
                            let _e241 = r;
                            let _e244 = d;
                            r.y = ((2f * _e241.y) / _e244);
                            borderY = true;
                            let _e248 = p;
                            let _e250 = tileSize;
                            let _e253 = r;
                            let _e258 = r;
                            p.y = (_e248.y - ((_e250.y * (1f - _e253.y)) / (0.5f + _e258.y)));
                        }
                    } else {
                        let _e263 = r;
                        let _e266 = d;
                        if (_e263.y > (1f - (_e266 / 2f))) {
                            {
                                let _e274 = r;
                                let _e278 = d;
                                r.y = ((2f * (1f - _e274.y)) / _e278);
                                borderY = true;
                                let _e282 = p;
                                let _e284 = tileSize;
                                let _e287 = r;
                                let _e292 = r;
                                p.y = (_e282.y + ((_e284.y * (1f - _e287.y)) / (0.5f + _e292.y)));
                            }
                        }
                    }
                }
            }
            let _e297 = modelTransform_1;
            let _e298 = p;
            u = (_e297 * vec3<f32>(_e298.x, _e298.y, 1f)).xy;
        }
        continuing {
            let _e108 = i;
            i = (_e108 + 1i);
        }
    }
    let _e305 = p;
    let _e309 = global.U[0];
    let _e312 = p;
    let _e321 = textureSample(t_source, samp, ((vec2<f32>((_e305.x / _e309.x), _e312.y) / vec2(2f)) + vec2(0.5f)));
    outColor = _e321;
    let _e323 = pixelation_1;
    if (_e323 != 0f) {
        {
            let _e326 = invM;
            let _e327 = tileCenter;
            tileCenterTexSpace = (_e326 * vec3<f32>(_e327.x, _e327.y, 1f)).xy;
            let _e335 = tileCenterTexSpace;
            let _e339 = global.U[0];
            let _e342 = tileCenterTexSpace;
            let _e351 = textureSample(t_source, samp, ((vec2<f32>((_e335.x / _e339.x), _e342.y) / vec2(2f)) + vec2(0.5f)));
            pixelColor = _e351;
            let _e353 = outColor;
            let _e354 = pixelColor;
            let _e355 = pixelation_1;
            outColor = mix(_e353, _e354, vec4(_e355));
        }
    }
    let _e358 = outColor;
    return _e358;
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
    let _e75 = global.U[13];
    let _e79 = global.U[14];
    let _e83 = global.U[15];
    let _e87 = global.U[16];
    let _e88 = _e87.xyz;
    let _e91 = global.U[17];
    let _e92 = _e91.xyz;
    let _e95 = global.U[18];
    let _e96 = _e95.xyz;
    let _e110 = iteratedRectTilesGL((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e9.x, _e9.y, _e9.z), vec3<f32>(_e13.x, _e13.y, _e13.z), vec3<f32>(_e17.x, _e17.y, _e17.z))) * vec3<f32>(_e44.x, _e44.y, 1f)).xy, (((_e51 - vec2(0.5f)) * 2f) * vec2<f32>(_e59.x, 1f)), _e66.x, i32(_e70.x), _e75.x, _e79.x, _e83.x, mat3x3<f32>(vec3<f32>(_e88.x, _e88.y, _e88.z), vec3<f32>(_e92.x, _e92.y, _e92.z), vec3<f32>(_e96.x, _e96.y, _e96.z)));
    fragColor = _e110;
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
