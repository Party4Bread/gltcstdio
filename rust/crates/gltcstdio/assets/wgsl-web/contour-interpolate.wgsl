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

fn inside(pos: vec2<f32>, X: f32, Y: f32) -> bool {
    var pos_1: vec2<f32>;
    var X_1: f32;
    var Y_1: f32;

    pos_1 = pos;
    X_1 = X;
    Y_1 = Y;
    let _e12 = pos_1;
    let _e15 = Y_1;
    let _e17 = pos_1;
    let _e20 = X_1;
    return ((abs(_e12.y) <= _e15) && (abs(_e17.x) <= _e20));
}

fn sampleCol(color: vec4<f32>, count: i32) -> f32 {
    var color_1: vec4<f32>;
    var count_1: i32;

    color_1 = color;
    count_1 = count;
    let _e10 = color_1;
    let _e12 = color_1;
    let _e15 = color_1;
    let _e18 = count_1;
    return floor((((((_e10.x + _e12.y) + _e15.z) * (f32(_e18) - 1f)) / 3f) + 0.5f));
}

fn sampleVal(val: f32, count_2: i32) -> f32 {
    var val_1: f32;
    var count_3: i32;

    val_1 = val;
    count_3 = count_2;
    let _e10 = val_1;
    let _e11 = count_3;
    return floor((((_e10 * (f32(_e11) - 1f)) / 3f) + 0.5f));
}

fn contourInterpolate(pos_2: vec2<f32>, outPos: vec2<f32>, sourceDim: vec2<f32>, mode: i32, count_4: i32, modelTransform: mat3x3<f32>) -> vec4<f32> {
    var pos_3: vec2<f32>;
    var outPos_1: vec2<f32>;
    var sourceDim_1: vec2<f32>;
    var mode_1: i32;
    var count_5: i32;
    var modelTransform_1: mat3x3<f32>;
    var pixel: f32;
    var X_2: f32;
    var Y_2: f32 = 1f;
    var p: vec2<f32>;
    var d: vec2<f32>;
    var col: vec4<f32>;
    var gPos: f32;
    var gLightest: f32;
    var gDarkest: f32;
    var s: f32;
    var lightest: vec4<f32>;
    var darkest: vec4<f32>;
    var advance: bool = false;
    var pos1_: vec2<f32>;
    var pos2_: vec2<f32>;
    var next: vec2<f32>;
    var cNext: vec4<f32>;
    var gNext: f32;
    var sNext: f32;
    var next_1: vec2<f32>;
    var cNext_1: vec4<f32>;
    var gNext_1: f32;
    var sNext_1: f32;
    var dd: vec2<f32>;
    var len: f32;
    var outCol: vec4<f32>;
    var pos1_1: vec2<f32>;
    var col1_: vec4<f32>;
    var pos2_1: vec2<f32>;
    var col2_: vec4<f32>;
    var dd_1: vec2<f32>;
    var len_1: f32;
    var outCol_1: vec4<f32>;

    pos_3 = pos_2;
    outPos_1 = outPos;
    sourceDim_1 = sourceDim;
    mode_1 = mode;
    count_5 = count_4;
    modelTransform_1 = modelTransform;
    let _e19 = sourceDim_1;
    pixel = (2f / _e19.y);
    let _e23 = sourceDim_1;
    let _e25 = sourceDim_1;
    X_2 = (_e23.x / _e25.y);
    let _e31 = pixel;
    p = vec2<f32>(_e31, 0f);
    let _e35 = pixel;
    let _e36 = modelTransform_1;
    let _e44 = p;
    d = (_e35 * normalize((mat2x2<f32>(_e36[0].xy, _e36[1].xy) * _e44)));
    let _e49 = pos_3;
    let _e53 = global.U[0];
    let _e56 = pos_3;
    let _e66 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e49.x / _e53.x), _e56.y) / vec2(2f)) + vec2(0.5f)), 0f);
    col = _e66;
    let _e68 = col;
    let _e70 = col;
    let _e73 = col;
    gPos = ((_e68.x + _e70.y) + _e73.z);
    let _e77 = gPos;
    gLightest = _e77;
    let _e79 = gPos;
    gDarkest = _e79;
    let _e81 = gPos;
    let _e82 = count_5;
    let _e83 = sampleVal(_e81, _e82);
    s = _e83;
    let _e85 = mode_1;
    if (_e85 == 0i) {
        {
            let _e88 = col;
            lightest = _e88;
            let _e90 = col;
            darkest = _e90;
            let _e94 = pos_3;
            pos1_ = _e94;
            let _e96 = pos_3;
            pos2_ = _e96;
            loop {
                {
                    let _e98 = pos1_;
                    let _e99 = d;
                    next = (_e98 + _e99);
                    let _e102 = next;
                    let _e106 = global.U[0];
                    let _e109 = next;
                    let _e119 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e102.x / _e106.x), _e109.y) / vec2(2f)) + vec2(0.5f)), 0f);
                    cNext = _e119;
                    let _e121 = cNext;
                    let _e123 = cNext;
                    let _e126 = cNext;
                    gNext = ((_e121.x + _e123.y) + _e126.z);
                    let _e130 = gNext;
                    let _e131 = count_5;
                    let _e132 = sampleVal(_e130, _e131);
                    sNext = _e132;
                    let _e134 = sNext;
                    let _e135 = s;
                    let _e137 = next;
                    let _e138 = X_2;
                    let _e139 = Y_2;
                    let _e140 = inside(_e137, _e138, _e139);
                    advance = ((_e134 == _e135) && _e140);
                    let _e142 = advance;
                    if _e142 {
                        {
                            let _e143 = next;
                            pos1_ = _e143;
                            let _e144 = gNext;
                            let _e145 = gLightest;
                            if (_e144 > _e145) {
                                {
                                    let _e147 = cNext;
                                    lightest = _e147;
                                    let _e148 = gNext;
                                    gLightest = _e148;
                                }
                            }
                            let _e149 = gNext;
                            let _e150 = gDarkest;
                            if (_e149 < _e150) {
                                {
                                    let _e152 = cNext;
                                    darkest = _e152;
                                    let _e153 = gNext;
                                    gDarkest = _e153;
                                }
                            }
                        }
                    }
                }
                let _e154 = advance;
                if !(_e154) {
                    break;
                }
            }
            loop {
                {
                    let _e156 = pos2_;
                    let _e157 = d;
                    next_1 = (_e156 - _e157);
                    let _e160 = next_1;
                    let _e164 = global.U[0];
                    let _e167 = next_1;
                    let _e177 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e160.x / _e164.x), _e167.y) / vec2(2f)) + vec2(0.5f)), 0f);
                    cNext_1 = _e177;
                    let _e179 = cNext_1;
                    let _e181 = cNext_1;
                    let _e184 = cNext_1;
                    gNext_1 = ((_e179.x + _e181.y) + _e184.z);
                    let _e188 = gNext_1;
                    let _e189 = count_5;
                    let _e190 = sampleVal(_e188, _e189);
                    sNext_1 = _e190;
                    let _e192 = sNext_1;
                    let _e193 = s;
                    let _e195 = next_1;
                    let _e196 = X_2;
                    let _e197 = Y_2;
                    let _e198 = inside(_e195, _e196, _e197);
                    advance = ((_e192 == _e193) && _e198);
                    let _e200 = advance;
                    if _e200 {
                        {
                            let _e201 = next_1;
                            pos2_ = _e201;
                            let _e202 = gNext_1;
                            let _e203 = gLightest;
                            if (_e202 > _e203) {
                                {
                                    let _e205 = cNext_1;
                                    lightest = _e205;
                                    let _e206 = gNext_1;
                                    gLightest = _e206;
                                }
                            }
                            let _e207 = gNext_1;
                            let _e208 = gDarkest;
                            if (_e207 < _e208) {
                                {
                                    let _e210 = cNext_1;
                                    darkest = _e210;
                                    let _e211 = gNext_1;
                                    gDarkest = _e211;
                                }
                            }
                        }
                    }
                }
                let _e212 = advance;
                if !(_e212) {
                    break;
                }
            }
            let _e214 = pos2_;
            let _e215 = pos1_;
            dd = (_e214 - _e215);
            let _e218 = dd;
            len = length(_e218);
            let _e221 = len;
            if (_e221 == 0f) {
                let _e224 = col;
                return _e224;
            }
            let _e225 = darkest;
            let _e226 = lightest;
            let _e227 = pos_3;
            let _e228 = pos1_;
            let _e230 = len;
            let _e233 = pos2_;
            let _e234 = pos1_;
            let _e236 = len;
            outCol = mix(_e225, _e226, vec4(dot(((_e227 - _e228) / vec2(_e230)), ((_e233 - _e234) / vec2(_e236)))));
            let _e243 = outCol;
            return _e243;
        }
    } else {
        {
            let _e244 = pos_3;
            pos1_1 = _e244;
            loop {
                let _e246 = pos1_1;
                let _e247 = d;
                let _e252 = global.U[0];
                let _e255 = pos1_1;
                let _e256 = d;
                let _e267 = textureSampleLevel(t_source, samp, ((vec2<f32>(((_e246 + _e247).x / _e252.x), (_e255 + _e256).y) / vec2(2f)) + vec2(0.5f)), 0f);
                let _e268 = count_5;
                let _e269 = sampleCol(_e267, _e268);
                let _e270 = s;
                let _e272 = pos1_1;
                let _e273 = d;
                let _e275 = X_2;
                let _e276 = Y_2;
                let _e277 = inside((_e272 + _e273), _e275, _e276);
                if !(((_e269 == _e270) && _e277)) {
                    break;
                }
                {
                    let _e280 = pos1_1;
                    let _e281 = d;
                    pos1_1 = (_e280 + _e281);
                }
            }
            let _e283 = pos1_1;
            let _e287 = global.U[0];
            let _e290 = pos1_1;
            let _e300 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e283.x / _e287.x), _e290.y) / vec2(2f)) + vec2(0.5f)), 0f);
            col1_ = _e300;
            let _e302 = pos_3;
            pos2_1 = _e302;
            loop {
                let _e304 = pos2_1;
                let _e305 = d;
                let _e310 = global.U[0];
                let _e313 = pos2_1;
                let _e314 = d;
                let _e325 = textureSampleLevel(t_source, samp, ((vec2<f32>(((_e304 - _e305).x / _e310.x), (_e313 - _e314).y) / vec2(2f)) + vec2(0.5f)), 0f);
                let _e326 = count_5;
                let _e327 = sampleCol(_e325, _e326);
                let _e328 = s;
                let _e330 = pos2_1;
                let _e331 = d;
                let _e333 = X_2;
                let _e334 = Y_2;
                let _e335 = inside((_e330 - _e331), _e333, _e334);
                if !(((_e327 == _e328) && _e335)) {
                    break;
                }
                {
                    let _e338 = pos2_1;
                    let _e339 = d;
                    pos2_1 = (_e338 - _e339);
                }
            }
            let _e341 = pos2_1;
            let _e345 = global.U[0];
            let _e348 = pos2_1;
            let _e358 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e341.x / _e345.x), _e348.y) / vec2(2f)) + vec2(0.5f)), 0f);
            col2_ = _e358;
            let _e360 = pos2_1;
            let _e361 = pos1_1;
            dd_1 = (_e360 - _e361);
            let _e364 = dd_1;
            len_1 = length(_e364);
            let _e367 = len_1;
            if (_e367 == 0f) {
                let _e370 = col;
                return _e370;
            }
            let _e371 = col1_;
            let _e372 = col2_;
            let _e373 = pos_3;
            let _e374 = pos1_1;
            let _e376 = len_1;
            let _e379 = pos2_1;
            let _e380 = pos1_1;
            let _e382 = len_1;
            outCol_1 = mix(_e371, _e372, vec4(dot(((_e373 - _e374) / vec2(_e376)), ((_e379 - _e380) / vec2(_e382)))));
            let _e389 = outCol_1;
            return _e389;
        }
    }
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
    let _e66 = global.U[4];
    let _e70 = global.U[6];
    let _e75 = global.U[7];
    let _e80 = global.U[8];
    let _e81 = _e80.xyz;
    let _e84 = global.U[9];
    let _e85 = _e84.xyz;
    let _e88 = global.U[10];
    let _e89 = _e88.xyz;
    let _e103 = contourInterpolate((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e9.x, _e9.y, _e9.z), vec3<f32>(_e13.x, _e13.y, _e13.z), vec3<f32>(_e17.x, _e17.y, _e17.z))) * vec3<f32>(_e44.x, _e44.y, 1f)).xy, (((_e51 - vec2(0.5f)) * 2f) * vec2<f32>(_e59.x, 1f)), _e66.xy, i32(_e70.x), i32(_e75.x), mat3x3<f32>(vec3<f32>(_e81.x, _e81.y, _e81.z), vec3<f32>(_e85.x, _e85.y, _e85.z), vec3<f32>(_e89.x, _e89.y, _e89.z)));
    fragColor = _e103;
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
