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
    let _e68 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e51.x / _e55.x), _e58.y) / vec2(2f)) + vec2(0.5f)), 0f);
    col = _e68;
    let _e70 = col;
    let _e72 = col;
    let _e75 = col;
    grey = clamp(((_e70.x + _e72.y) + _e75.z), 0f, 3f);
    let _e82 = grey;
    let _e83 = sC;
    let _e86 = count_1;
    s = min(i32((_e82 * _e83)), (_e86 - 1i));
    let _e93 = N;
    sN = (f32(_e93) / 3f);
    loop {
        let _e101 = i;
        let _e102 = N;
        if !((_e101 < _e102)) {
            break;
        }
        let _e108 = i;
        buckets[_e108] = 0i;
        continuing {
            let _e105 = i;
            i = (_e105 + 1i);
        }
    }
    let _e111 = grey;
    let _e112 = sN;
    let _e115 = N;
    g = min(i32((_e111 * _e112)), (_e115 - 1i));
    let _e120 = g;
    let _e122 = buckets[_e120];
    buckets[_e120] = (_e122 + 1i);
    let _e127 = pos_3;
    pos1_ = _e127;
    loop {
        {
            let _e131 = pos1_;
            let _e132 = d;
            next = (_e131 + _e132);
            let _e135 = next;
            let _e139 = global.U[0];
            let _e142 = next;
            let _e152 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e135.x / _e139.x), _e142.y) / vec2(2f)) + vec2(0.5f)), 0f);
            cNext = _e152;
            let _e154 = cNext;
            let _e156 = cNext;
            let _e159 = cNext;
            gNext = clamp(((_e154.x + _e156.y) + _e159.z), 0f, 3f);
            let _e166 = gNext;
            let _e167 = sC;
            let _e170 = count_1;
            scNext = min(i32((_e166 * _e167)), (_e170 - 1i));
            let _e175 = scNext;
            let _e176 = s;
            let _e178 = next;
            let _e179 = X_2;
            let _e180 = Y_2;
            let _e181 = inside(_e178, _e179, _e180);
            advance = ((_e175 == _e176) && _e181);
            let _e183 = advance;
            if _e183 {
                {
                    let _e184 = gNext;
                    let _e185 = sN;
                    let _e188 = N;
                    let _e193 = buckets[min(i32((_e184 * _e185)), (_e188 - 1i))];
                    buckets[min(i32((_e184 * _e185)), (_e188 - 1i))] = (_e193 + 1i);
                    let _e196 = preCount;
                    preCount = (_e196 + 1i);
                    let _e199 = next;
                    pos1_ = _e199;
                }
            }
        }
        let _e200 = advance;
        if !(_e200) {
            break;
        }
    }
    let _e202 = pos_3;
    pos2_ = _e202;
    loop {
        {
            let _e206 = pos2_;
            let _e207 = d;
            next_1 = (_e206 - _e207);
            let _e210 = next_1;
            let _e214 = global.U[0];
            let _e217 = next_1;
            let _e227 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e210.x / _e214.x), _e217.y) / vec2(2f)) + vec2(0.5f)), 0f);
            cNext_1 = _e227;
            let _e229 = cNext_1;
            let _e231 = cNext_1;
            let _e234 = cNext_1;
            gNext_1 = clamp(((_e229.x + _e231.y) + _e234.z), 0f, 3f);
            let _e241 = gNext_1;
            let _e242 = sC;
            let _e245 = count_1;
            scNext_1 = min(i32((_e241 * _e242)), (_e245 - 1i));
            let _e250 = scNext_1;
            let _e251 = s;
            let _e253 = next_1;
            let _e254 = X_2;
            let _e255 = Y_2;
            let _e256 = inside(_e253, _e254, _e255);
            advance = ((_e250 == _e251) && _e256);
            let _e258 = advance;
            if _e258 {
                {
                    let _e259 = gNext_1;
                    let _e260 = sN;
                    let _e263 = N;
                    let _e268 = buckets[min(i32((_e259 * _e260)), (_e263 - 1i))];
                    buckets[min(i32((_e259 * _e260)), (_e263 - 1i))] = (_e268 + 1i);
                    let _e271 = postCount;
                    postCount = (_e271 + 1i);
                    let _e274 = next_1;
                    pos2_ = _e274;
                }
            }
        }
        let _e275 = advance;
        if !(_e275) {
            break;
        }
    }
    loop {
        let _e281 = bucketIndex;
        let _e282 = N;
        let _e284 = total;
        let _e285 = bucketIndex;
        let _e287 = buckets[_e285];
        let _e289 = preCount;
        if !(((_e281 < _e282) && ((_e284 + _e287) < (_e289 + 1i)))) {
            break;
        }
        {
            let _e295 = total;
            let _e296 = bucketIndex;
            let _e298 = buckets[_e296];
            total = (_e295 + _e298);
            let _e300 = bucketIndex;
            bucketIndex = (_e300 + 1i);
        }
    }
    let _e305 = bucketIndex;
    let _e306 = N;
    if (_e305 < _e306) {
        {
            let _e308 = preCount;
            let _e311 = total;
            let _e314 = N;
            let _e317 = bucketIndex;
            let _e319 = buckets[_e317];
            fractLum = (f32(((_e308 + 1i) - _e311)) / f32(((_e314 - 1i) * _e319)));
            let _e325 = fractLum;
            let _e326 = bucketIndex;
            let _e328 = N;
            lum = (3f * (_e325 + (f32(_e326) / f32((_e328 - 1i)))));
            let _e336 = s;
            let _e340 = count_1;
            avgLum = (3f * ((f32(_e336) + 0.5f) / f32(_e340)));
            let _e345 = lum;
            let _e346 = avgLum;
            deltaLum = (_e345 - _e346);
            let _e349 = avgLum;
            let _e350 = contrast_1;
            let _e351 = deltaLum;
            lum = (_e349 + (_e350 * _e351));
        }
    }
    let _e354 = col;
    let _e356 = col;
    let _e358 = col;
    let _e361 = col;
    let _e369 = lum;
    let _e370 = ((_e354.xyz / vec3(clamp(((_e356.x + _e358.y) + _e361.z), 0f, 3f))) * _e369);
    let _e371 = col;
    outCol = vec4<f32>(_e370.x, _e370.y, _e370.z, _e371.w);
    let _e378 = outCol;
    return _e378;
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
