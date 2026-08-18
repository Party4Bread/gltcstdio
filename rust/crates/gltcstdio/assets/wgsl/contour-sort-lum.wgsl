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

fn contourInterpolate(pos_2: vec2<f32>, outPos: vec2<f32>, sourceDim: vec2<f32>, count: i32, contrast: f32, modelTransform: mat3x3<f32>) -> vec4<f32> {
    var pos_3: vec2<f32>;
    var outPos_1: vec2<f32>;
    var sourceDim_1: vec2<f32>;
    var count_1: i32;
    var contrast_1: f32;
    var modelTransform_1: mat3x3<f32>;
    var pixel: f32;
    var X_2: f32;
    var Y_2: f32 = 1f;
    var sC: f32;
    var p: vec2<f32>;
    var d: vec2<f32>;
    var col: vec4<f32>;
    var grey: f32;
    var s: i32;
    var N: i32 = 256i;
    var sN: f32;
    var buckets: array<i32, 256>;
    var i: i32 = 0i;
    var g: i32;
    var advance: bool = false;
    var pos1_: vec2<f32>;
    var preCount: i32 = 0i;
    var next: vec2<f32>;
    var cNext: vec4<f32>;
    var gNext: f32;
    var scNext: i32;
    var pos2_: vec2<f32>;
    var postCount: i32 = 0i;
    var next_1: vec2<f32>;
    var cNext_1: vec4<f32>;
    var gNext_1: f32;
    var scNext_1: i32;
    var bucketIndex: i32 = 0i;
    var total: i32 = 0i;
    var lum: f32 = 1f;
    var fractLum: f32;
    var avgLum: f32;
    var deltaLum: f32;
    var outCol: vec4<f32>;

    pos_3 = pos_2;
    outPos_1 = outPos;
    sourceDim_1 = sourceDim;
    count_1 = count;
    contrast_1 = contrast;
    modelTransform_1 = modelTransform;
    let _e19 = sourceDim_1;
    pixel = (2f / _e19.y);
    let _e23 = sourceDim_1;
    let _e25 = sourceDim_1;
    X_2 = (_e23.x / _e25.y);
    let _e31 = count_1;
    sC = (f32(_e31) / 3f);
    let _e36 = pixel;
    p = vec2<f32>(_e36, 0f);
    let _e40 = modelTransform_1;
    let _e48 = p;
    d = (mat2x2<f32>(_e40[0].xy, _e40[1].xy) * _e48);
    let _e51 = pos_3;
    let _e55 = global.U[0];
    let _e58 = pos_3;
    let _e67 = textureSample(t_source, samp, ((vec2<f32>((_e51.x / _e55.x), _e58.y) / vec2(2f)) + vec2(0.5f)));
    col = _e67;
    let _e69 = col;
    let _e71 = col;
    let _e74 = col;
    grey = clamp(((_e69.x + _e71.y) + _e74.z), 0f, 3f);
    let _e81 = grey;
    let _e82 = sC;
    let _e85 = count_1;
    s = min(i32((_e81 * _e82)), (_e85 - 1i));
    let _e92 = N;
    sN = (f32(_e92) / 3f);
    loop {
        let _e100 = i;
        let _e101 = N;
        if !((_e100 < _e101)) {
            break;
        }
        let _e107 = i;
        buckets[_e107] = 0i;
        continuing {
            let _e104 = i;
            i = (_e104 + 1i);
        }
    }
    let _e110 = grey;
    let _e111 = sN;
    let _e114 = N;
    g = min(i32((_e110 * _e111)), (_e114 - 1i));
    let _e119 = g;
    let _e121 = buckets[_e119];
    buckets[_e119] = (_e121 + 1i);
    let _e126 = pos_3;
    pos1_ = _e126;
    loop {
        {
            let _e130 = pos1_;
            let _e131 = d;
            next = (_e130 + _e131);
            let _e134 = next;
            let _e138 = global.U[0];
            let _e141 = next;
            let _e150 = textureSample(t_source, samp, ((vec2<f32>((_e134.x / _e138.x), _e141.y) / vec2(2f)) + vec2(0.5f)));
            cNext = _e150;
            let _e152 = cNext;
            let _e154 = cNext;
            let _e157 = cNext;
            gNext = clamp(((_e152.x + _e154.y) + _e157.z), 0f, 3f);
            let _e164 = gNext;
            let _e165 = sC;
            let _e168 = count_1;
            scNext = min(i32((_e164 * _e165)), (_e168 - 1i));
            let _e173 = scNext;
            let _e174 = s;
            let _e176 = next;
            let _e177 = X_2;
            let _e178 = Y_2;
            let _e179 = inside(_e176, _e177, _e178);
            advance = ((_e173 == _e174) && _e179);
            let _e181 = advance;
            if _e181 {
                {
                    let _e182 = gNext;
                    let _e183 = sN;
                    let _e186 = N;
                    let _e191 = buckets[min(i32((_e182 * _e183)), (_e186 - 1i))];
                    buckets[min(i32((_e182 * _e183)), (_e186 - 1i))] = (_e191 + 1i);
                    let _e194 = preCount;
                    preCount = (_e194 + 1i);
                    let _e197 = next;
                    pos1_ = _e197;
                }
            }
        }
        let _e198 = advance;
        if !(_e198) {
            break;
        }
    }
    let _e200 = pos_3;
    pos2_ = _e200;
    loop {
        {
            let _e204 = pos2_;
            let _e205 = d;
            next_1 = (_e204 - _e205);
            let _e208 = next_1;
            let _e212 = global.U[0];
            let _e215 = next_1;
            let _e224 = textureSample(t_source, samp, ((vec2<f32>((_e208.x / _e212.x), _e215.y) / vec2(2f)) + vec2(0.5f)));
            cNext_1 = _e224;
            let _e226 = cNext_1;
            let _e228 = cNext_1;
            let _e231 = cNext_1;
            gNext_1 = clamp(((_e226.x + _e228.y) + _e231.z), 0f, 3f);
            let _e238 = gNext_1;
            let _e239 = sC;
            let _e242 = count_1;
            scNext_1 = min(i32((_e238 * _e239)), (_e242 - 1i));
            let _e247 = scNext_1;
            let _e248 = s;
            let _e250 = next_1;
            let _e251 = X_2;
            let _e252 = Y_2;
            let _e253 = inside(_e250, _e251, _e252);
            advance = ((_e247 == _e248) && _e253);
            let _e255 = advance;
            if _e255 {
                {
                    let _e256 = gNext_1;
                    let _e257 = sN;
                    let _e260 = N;
                    let _e265 = buckets[min(i32((_e256 * _e257)), (_e260 - 1i))];
                    buckets[min(i32((_e256 * _e257)), (_e260 - 1i))] = (_e265 + 1i);
                    let _e268 = postCount;
                    postCount = (_e268 + 1i);
                    let _e271 = next_1;
                    pos2_ = _e271;
                }
            }
        }
        let _e272 = advance;
        if !(_e272) {
            break;
        }
    }
    loop {
        let _e278 = bucketIndex;
        let _e279 = N;
        let _e281 = total;
        let _e282 = bucketIndex;
        let _e284 = buckets[_e282];
        let _e286 = preCount;
        if !(((_e278 < _e279) && ((_e281 + _e284) < (_e286 + 1i)))) {
            break;
        }
        {
            let _e292 = total;
            let _e293 = bucketIndex;
            let _e295 = buckets[_e293];
            total = (_e292 + _e295);
            let _e297 = bucketIndex;
            bucketIndex = (_e297 + 1i);
        }
    }
    let _e302 = bucketIndex;
    let _e303 = N;
    if (_e302 < _e303) {
        {
            let _e305 = preCount;
            let _e308 = total;
            let _e311 = N;
            let _e314 = bucketIndex;
            let _e316 = buckets[_e314];
            fractLum = (f32(((_e305 + 1i) - _e308)) / f32(((_e311 - 1i) * _e316)));
            let _e322 = fractLum;
            let _e323 = bucketIndex;
            let _e325 = N;
            lum = (3f * (_e322 + (f32(_e323) / f32((_e325 - 1i)))));
            let _e333 = s;
            let _e337 = count_1;
            avgLum = (3f * ((f32(_e333) + 0.5f) / f32(_e337)));
            let _e342 = lum;
            let _e343 = avgLum;
            deltaLum = (_e342 - _e343);
            let _e346 = avgLum;
            let _e347 = contrast_1;
            let _e348 = deltaLum;
            lum = (_e346 + (_e347 * _e348));
        }
    }
    let _e351 = col;
    let _e353 = col;
    let _e355 = col;
    let _e358 = col;
    let _e366 = lum;
    let _e367 = ((_e351.xyz / vec3(clamp(((_e353.x + _e355.y) + _e358.z), 0f, 3f))) * _e366);
    let _e368 = col;
    outCol = vec4<f32>(_e367.x, _e367.y, _e367.z, _e368.w);
    let _e375 = outCol;
    return _e375;
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
    let _e79 = global.U[8];
    let _e80 = _e79.xyz;
    let _e83 = global.U[9];
    let _e84 = _e83.xyz;
    let _e87 = global.U[10];
    let _e88 = _e87.xyz;
    let _e102 = contourInterpolate((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e9.x, _e9.y, _e9.z), vec3<f32>(_e13.x, _e13.y, _e13.z), vec3<f32>(_e17.x, _e17.y, _e17.z))) * vec3<f32>(_e44.x, _e44.y, 1f)).xy, (((_e51 - vec2(0.5f)) * 2f) * vec2<f32>(_e59.x, 1f)), _e66.xy, i32(_e70.x), _e75.x, mat3x3<f32>(vec3<f32>(_e80.x, _e80.y, _e80.z), vec3<f32>(_e84.x, _e84.y, _e84.z), vec3<f32>(_e88.x, _e88.y, _e88.z)));
    fragColor = _e102;
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
