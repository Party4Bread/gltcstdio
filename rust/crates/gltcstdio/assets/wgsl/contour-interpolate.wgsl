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
    let _e65 = textureSample(t_source, samp, ((vec2<f32>((_e49.x / _e53.x), _e56.y) / vec2(2f)) + vec2(0.5f)));
    col = _e65;
    let _e67 = col;
    let _e69 = col;
    let _e72 = col;
    gPos = ((_e67.x + _e69.y) + _e72.z);
    let _e76 = gPos;
    gLightest = _e76;
    let _e78 = gPos;
    gDarkest = _e78;
    let _e80 = gPos;
    let _e81 = count_5;
    let _e82 = sampleVal(_e80, _e81);
    s = _e82;
    let _e84 = mode_1;
    if (_e84 == 0i) {
        {
            let _e87 = col;
            lightest = _e87;
            let _e89 = col;
            darkest = _e89;
            let _e93 = pos_3;
            pos1_ = _e93;
            let _e95 = pos_3;
            pos2_ = _e95;
            loop {
                {
                    let _e97 = pos1_;
                    let _e98 = d;
                    next = (_e97 + _e98);
                    let _e101 = next;
                    let _e105 = global.U[0];
                    let _e108 = next;
                    let _e117 = textureSample(t_source, samp, ((vec2<f32>((_e101.x / _e105.x), _e108.y) / vec2(2f)) + vec2(0.5f)));
                    cNext = _e117;
                    let _e119 = cNext;
                    let _e121 = cNext;
                    let _e124 = cNext;
                    gNext = ((_e119.x + _e121.y) + _e124.z);
                    let _e128 = gNext;
                    let _e129 = count_5;
                    let _e130 = sampleVal(_e128, _e129);
                    sNext = _e130;
                    let _e132 = sNext;
                    let _e133 = s;
                    let _e135 = next;
                    let _e136 = X_2;
                    let _e137 = Y_2;
                    let _e138 = inside(_e135, _e136, _e137);
                    advance = ((_e132 == _e133) && _e138);
                    let _e140 = advance;
                    if _e140 {
                        {
                            let _e141 = next;
                            pos1_ = _e141;
                            let _e142 = gNext;
                            let _e143 = gLightest;
                            if (_e142 > _e143) {
                                {
                                    let _e145 = cNext;
                                    lightest = _e145;
                                    let _e146 = gNext;
                                    gLightest = _e146;
                                }
                            }
                            let _e147 = gNext;
                            let _e148 = gDarkest;
                            if (_e147 < _e148) {
                                {
                                    let _e150 = cNext;
                                    darkest = _e150;
                                    let _e151 = gNext;
                                    gDarkest = _e151;
                                }
                            }
                        }
                    }
                }
                let _e152 = advance;
                if !(_e152) {
                    break;
                }
            }
            loop {
                {
                    let _e154 = pos2_;
                    let _e155 = d;
                    next_1 = (_e154 - _e155);
                    let _e158 = next_1;
                    let _e162 = global.U[0];
                    let _e165 = next_1;
                    let _e174 = textureSample(t_source, samp, ((vec2<f32>((_e158.x / _e162.x), _e165.y) / vec2(2f)) + vec2(0.5f)));
                    cNext_1 = _e174;
                    let _e176 = cNext_1;
                    let _e178 = cNext_1;
                    let _e181 = cNext_1;
                    gNext_1 = ((_e176.x + _e178.y) + _e181.z);
                    let _e185 = gNext_1;
                    let _e186 = count_5;
                    let _e187 = sampleVal(_e185, _e186);
                    sNext_1 = _e187;
                    let _e189 = sNext_1;
                    let _e190 = s;
                    let _e192 = next_1;
                    let _e193 = X_2;
                    let _e194 = Y_2;
                    let _e195 = inside(_e192, _e193, _e194);
                    advance = ((_e189 == _e190) && _e195);
                    let _e197 = advance;
                    if _e197 {
                        {
                            let _e198 = next_1;
                            pos2_ = _e198;
                            let _e199 = gNext_1;
                            let _e200 = gLightest;
                            if (_e199 > _e200) {
                                {
                                    let _e202 = cNext_1;
                                    lightest = _e202;
                                    let _e203 = gNext_1;
                                    gLightest = _e203;
                                }
                            }
                            let _e204 = gNext_1;
                            let _e205 = gDarkest;
                            if (_e204 < _e205) {
                                {
                                    let _e207 = cNext_1;
                                    darkest = _e207;
                                    let _e208 = gNext_1;
                                    gDarkest = _e208;
                                }
                            }
                        }
                    }
                }
                let _e209 = advance;
                if !(_e209) {
                    break;
                }
            }
            let _e211 = pos2_;
            let _e212 = pos1_;
            dd = (_e211 - _e212);
            let _e215 = dd;
            len = length(_e215);
            let _e218 = len;
            if (_e218 == 0f) {
                let _e221 = col;
                return _e221;
            }
            let _e222 = darkest;
            let _e223 = lightest;
            let _e224 = pos_3;
            let _e225 = pos1_;
            let _e227 = len;
            let _e230 = pos2_;
            let _e231 = pos1_;
            let _e233 = len;
            outCol = mix(_e222, _e223, vec4(dot(((_e224 - _e225) / vec2(_e227)), ((_e230 - _e231) / vec2(_e233)))));
            let _e240 = outCol;
            return _e240;
        }
    } else {
        {
            let _e241 = pos_3;
            pos1_1 = _e241;
            loop {
                let _e243 = pos1_1;
                let _e244 = d;
                let _e249 = global.U[0];
                let _e252 = pos1_1;
                let _e253 = d;
                let _e263 = textureSample(t_source, samp, ((vec2<f32>(((_e243 + _e244).x / _e249.x), (_e252 + _e253).y) / vec2(2f)) + vec2(0.5f)));
                let _e264 = count_5;
                let _e265 = sampleCol(_e263, _e264);
                let _e266 = s;
                let _e268 = pos1_1;
                let _e269 = d;
                let _e271 = X_2;
                let _e272 = Y_2;
                let _e273 = inside((_e268 + _e269), _e271, _e272);
                if !(((_e265 == _e266) && _e273)) {
                    break;
                }
                {
                    let _e276 = pos1_1;
                    let _e277 = d;
                    pos1_1 = (_e276 + _e277);
                }
            }
            let _e279 = pos1_1;
            let _e283 = global.U[0];
            let _e286 = pos1_1;
            let _e295 = textureSample(t_source, samp, ((vec2<f32>((_e279.x / _e283.x), _e286.y) / vec2(2f)) + vec2(0.5f)));
            col1_ = _e295;
            let _e297 = pos_3;
            pos2_1 = _e297;
            loop {
                let _e299 = pos2_1;
                let _e300 = d;
                let _e305 = global.U[0];
                let _e308 = pos2_1;
                let _e309 = d;
                let _e319 = textureSample(t_source, samp, ((vec2<f32>(((_e299 - _e300).x / _e305.x), (_e308 - _e309).y) / vec2(2f)) + vec2(0.5f)));
                let _e320 = count_5;
                let _e321 = sampleCol(_e319, _e320);
                let _e322 = s;
                let _e324 = pos2_1;
                let _e325 = d;
                let _e327 = X_2;
                let _e328 = Y_2;
                let _e329 = inside((_e324 - _e325), _e327, _e328);
                if !(((_e321 == _e322) && _e329)) {
                    break;
                }
                {
                    let _e332 = pos2_1;
                    let _e333 = d;
                    pos2_1 = (_e332 - _e333);
                }
            }
            let _e335 = pos2_1;
            let _e339 = global.U[0];
            let _e342 = pos2_1;
            let _e351 = textureSample(t_source, samp, ((vec2<f32>((_e335.x / _e339.x), _e342.y) / vec2(2f)) + vec2(0.5f)));
            col2_ = _e351;
            let _e353 = pos2_1;
            let _e354 = pos1_1;
            dd_1 = (_e353 - _e354);
            let _e357 = dd_1;
            len_1 = length(_e357);
            let _e360 = len_1;
            if (_e360 == 0f) {
                let _e363 = col;
                return _e363;
            }
            let _e364 = col1_;
            let _e365 = col2_;
            let _e366 = pos_3;
            let _e367 = pos1_1;
            let _e369 = len_1;
            let _e372 = pos2_1;
            let _e373 = pos1_1;
            let _e375 = len_1;
            outCol_1 = mix(_e364, _e365, vec4(dot(((_e366 - _e367) / vec2(_e369)), ((_e372 - _e373) / vec2(_e375)))));
            let _e382 = outCol_1;
            return _e382;
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
