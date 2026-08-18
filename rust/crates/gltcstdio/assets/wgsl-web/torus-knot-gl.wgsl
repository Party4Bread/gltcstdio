struct Params {
    U: array<vec4<f32>, 18>,
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

fn torusKnotImplicitFn(p: vec3<f32>, radius: f32, count: f32) -> f32 {
    var p_1: vec3<f32>;
    var radius_1: f32;
    var count_1: f32;
    var R: f32 = 0.5f;
    var r: f32;
    var a: f32;
    var ang: f32;
    var ca: f32;
    var sa: f32;
    var rot: mat2x2<f32>;
    var q: vec2<f32>;
    var c1_: vec2<f32> = vec2<f32>(0.15f, 0f);

    p_1 = p;
    radius_1 = radius;
    count_1 = count;
    let _e14 = R;
    let _e15 = radius_1;
    r = (_e14 * _e15);
    let _e18 = p_1;
    let _e20 = p_1;
    let _e23 = p_1;
    let _e25 = p_1;
    let _e30 = R;
    a = (sqrt(((_e18.x * _e20.x) + (_e23.y * _e25.y))) - _e30);
    let _e33 = p_1;
    let _e35 = p_1;
    let _e40 = count_1;
    ang = ((atan2(_e33.y, _e35.x) * 0.5f) * (_e40 - 1f));
    let _e45 = ang;
    ca = cos(_e45);
    let _e48 = ang;
    sa = sin(_e48);
    let _e51 = ca;
    let _e52 = sa;
    let _e53 = sa;
    let _e54 = ca;
    rot = mat2x2<f32>(vec2<f32>(_e51, _e52), vec2<f32>(_e53, -(_e54)));
    let _e60 = rot;
    let _e61 = a;
    let _e62 = p_1;
    q = (_e60 * vec2<f32>(_e61, _e62.z));
    let _e67 = q;
    if (_e67.x < 0f) {
        let _e71 = q;
        q = -(_e71);
    }
    let _e78 = q;
    let _e79 = c1_;
    let _e82 = r;
    return (0.4f * (length((_e78 - _e79)) - _e82));
}

fn torusKnotNormal(p_2: vec3<f32>, radius_2: f32, count_2: f32) -> vec3<f32> {
    var p_3: vec3<f32>;
    var radius_3: f32;
    var count_3: f32;
    var d: f32 = 0.0001f;
    var d2_: f32;

    p_3 = p_2;
    radius_3 = radius_2;
    count_3 = count_2;
    let _e14 = d;
    d2_ = (_e14 * 2f);
    let _e18 = p_3;
    let _e20 = d;
    let _e22 = p_3;
    let _e24 = p_3;
    let _e27 = radius_3;
    let _e28 = count_3;
    let _e29 = torusKnotImplicitFn(vec3<f32>((_e18.x - _e20), _e22.y, _e24.z), _e27, _e28);
    let _e30 = p_3;
    let _e32 = d;
    let _e34 = p_3;
    let _e36 = p_3;
    let _e39 = radius_3;
    let _e40 = count_3;
    let _e41 = torusKnotImplicitFn(vec3<f32>((_e30.x + _e32), _e34.y, _e36.z), _e39, _e40);
    let _e43 = d2_;
    let _e45 = p_3;
    let _e47 = p_3;
    let _e49 = d;
    let _e51 = p_3;
    let _e54 = radius_3;
    let _e55 = count_3;
    let _e56 = torusKnotImplicitFn(vec3<f32>(_e45.x, (_e47.y - _e49), _e51.z), _e54, _e55);
    let _e57 = p_3;
    let _e59 = p_3;
    let _e61 = d;
    let _e63 = p_3;
    let _e66 = radius_3;
    let _e67 = count_3;
    let _e68 = torusKnotImplicitFn(vec3<f32>(_e57.x, (_e59.y + _e61), _e63.z), _e66, _e67);
    let _e70 = d2_;
    let _e72 = p_3;
    let _e74 = p_3;
    let _e76 = p_3;
    let _e78 = d;
    let _e81 = radius_3;
    let _e82 = count_3;
    let _e83 = torusKnotImplicitFn(vec3<f32>(_e72.x, _e74.y, (_e76.z - _e78)), _e81, _e82);
    let _e84 = p_3;
    let _e86 = p_3;
    let _e88 = p_3;
    let _e90 = d;
    let _e93 = radius_3;
    let _e94 = count_3;
    let _e95 = torusKnotImplicitFn(vec3<f32>(_e84.x, _e86.y, (_e88.z + _e90)), _e93, _e94);
    let _e97 = d2_;
    return normalize(vec3<f32>(((_e29 - _e41) / _e43), ((_e56 - _e68) / _e70), ((_e83 - _e95) / _e97)));
}

fn torusKnotBoundingSphereK(center: vec3<f32>, radius_4: f32, origin: vec3<f32>, dir: vec3<f32>) -> vec2<f32> {
    var center_1: vec3<f32>;
    var radius_5: f32;
    var origin_1: vec3<f32>;
    var dir_1: vec3<f32>;
    var relOrigin: vec3<f32>;
    var a_1: f32;
    var b: f32;
    var c: f32;
    var delta: f32;
    var sqrtDelta: f32;
    var l1_: f32;
    var l2_: f32;
    var local: f32;
    var local_1: f32;
    var l: f32;

    center_1 = center;
    radius_5 = radius_4;
    origin_1 = origin;
    dir_1 = dir;
    let _e14 = origin_1;
    let _e15 = center_1;
    relOrigin = (_e14 - _e15);
    let _e18 = dir_1;
    let _e19 = dir_1;
    a_1 = dot(_e18, _e19);
    let _e23 = dir_1;
    let _e24 = relOrigin;
    b = (2f * dot(_e23, _e24));
    let _e28 = relOrigin;
    let _e29 = relOrigin;
    let _e31 = radius_5;
    let _e32 = radius_5;
    c = (dot(_e28, _e29) - (_e31 * _e32));
    let _e36 = b;
    let _e37 = b;
    let _e40 = a_1;
    let _e42 = c;
    delta = ((_e36 * _e37) - ((4f * _e40) * _e42));
    let _e46 = delta;
    if (_e46 >= 0f) {
        {
            let _e49 = delta;
            sqrtDelta = sqrt(_e49);
            let _e52 = b;
            let _e54 = sqrtDelta;
            let _e57 = a_1;
            l1_ = ((-(_e52) - _e54) / (2f * _e57));
            let _e61 = b;
            let _e63 = sqrtDelta;
            let _e66 = a_1;
            l2_ = ((-(_e61) + _e63) / (2f * _e66));
            let _e70 = l1_;
            if (_e70 > 0f) {
                let _e73 = l1_;
                local_1 = _e73;
            } else {
                let _e74 = l2_;
                if (_e74 > 0f) {
                    let _e77 = l2_;
                    local = _e77;
                } else {
                    local = -1f;
                }
                let _e81 = local;
                local_1 = _e81;
            }
            let _e83 = local_1;
            l = _e83;
            let _e85 = l;
            if (_e85 > 0f) {
                let _e89 = l1_;
                let _e91 = l2_;
                return vec2<f32>(max(0f, _e89), _e91);
            }
        }
    }
    return vec2<f32>(-1f, -1f);
}

fn torusKnotRayMarch(origin_2: vec3<f32>, dir_2: vec3<f32>, radius_6: f32, count_4: f32, glowColor: vec4<f32>) -> vec3<f32> {
    var origin_3: vec3<f32>;
    var dir_3: vec3<f32>;
    var radius_7: f32;
    var count_5: f32;
    var glowColor_1: vec4<f32>;
    var minDist: f32 = 1000000000f;
    var k: f32 = 0f;
    var kBounds: vec2<f32>;
    var kk: f32;
    var de: f32 = 0.0001f;
    var maxIter: i32 = 1256i;
    var iter: i32 = 0i;
    var p_4: vec3<f32>;
    var dist: f32;
    var local_2: vec3<f32>;

    origin_3 = origin_2;
    dir_3 = dir_2;
    radius_7 = radius_6;
    count_5 = count_4;
    glowColor_1 = glowColor;
    let _e20 = glowColor_1;
    let _e24 = glowColor_1;
    let _e29 = glowColor_1;
    if (((_e20.x == 0f) && (_e24.y == 0f)) && (_e29.z == 0f)) {
        {
            let _e38 = radius_7;
            let _e41 = origin_3;
            let _e42 = dir_3;
            let _e43 = torusKnotBoundingSphereK(vec3(0f), (0.5f * (2.25f + _e38)), _e41, _e42);
            kBounds = _e43;
            let _e45 = kBounds;
            kk = _e45.x;
            let _e48 = kk;
            if (_e48 < 0f) {
                let _e51 = kk;
                let _e53 = minDist;
                return vec3<f32>(_e51, 0f, _e53);
            }
        }
    }
    let _e61 = origin_3;
    p_4 = _e61;
    let _e63 = p_4;
    let _e64 = radius_7;
    let _e65 = count_5;
    let _e66 = torusKnotImplicitFn(_e63, _e64, _e65);
    dist = _e66;
    loop {
        let _e68 = dist;
        let _e70 = de;
        let _e72 = iter;
        let _e73 = maxIter;
        if !(((abs(_e68) > _e70) && (_e72 < _e73))) {
            break;
        }
        {
            let _e77 = k;
            let _e78 = dist;
            k = (_e77 + abs(_e78));
            let _e81 = origin_3;
            let _e82 = k;
            let _e83 = dir_3;
            p_4 = (_e81 + (_e82 * _e83));
            let _e86 = p_4;
            let _e87 = radius_7;
            let _e88 = count_5;
            let _e89 = torusKnotImplicitFn(_e86, _e87, _e88);
            dist = _e89;
            let _e90 = minDist;
            let _e91 = dist;
            minDist = min(_e90, abs(_e91));
            let _e94 = iter;
            iter = (_e94 + 1i);
        }
    }
    let _e97 = dist;
    let _e98 = de;
    if (_e97 < _e98) {
        let _e100 = k;
        let _e101 = iter;
        let _e103 = minDist;
        local_2 = vec3<f32>(_e100, f32(_e101), _e103);
    } else {
        let _e107 = iter;
        let _e109 = minDist;
        local_2 = vec3<f32>(-1f, f32(_e107), _e109);
    }
    let _e112 = local_2;
    return _e112;
}

fn torusKnotGl(pos: vec2<f32>, outPos: vec2<f32>, model3DTransform: mat4x4<f32>, sourceDim: vec2<f32>, intensity: f32, reflectivity: f32, radius_8: f32, count_6: i32, objectColor: vec4<f32>, glowColor_2: vec4<f32>, bkgColor: vec4<f32>, backgroundStyle: i32) -> vec4<f32> {
    var pos_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var model3DTransform_1: mat4x4<f32>;
    var sourceDim_1: vec2<f32>;
    var intensity_1: f32;
    var reflectivity_1: f32;
    var radius_9: f32;
    var count_7: i32;
    var objectColor_1: vec4<f32>;
    var glowColor_3: vec4<f32>;
    var bkgColor_1: vec4<f32>;
    var backgroundStyle_1: i32;
    var invModelTransform: mat4x4<f32>;
    var cameraPos: vec3<f32>;
    var D: f32 = 1f;
    var dir_4: vec3<f32>;
    var eta: f32;
    var fcount: f32;
    var origin_4: vec3<f32>;
    var maxIter_1: i32 = 12i;
    var iter_1: i32;
    var minI: i32 = -1i;
    var minK: f32 = 1000000f;
    var incidence: f32 = 2f;
    var reflectedColor: vec4<f32> = vec4<f32>(0f, 0f, 0f, 1f);
    var minDist_1: f32 = 1000000000f;
    var objectIntersected: bool = false;
    var inters: vec3<f32>;
    var k_1: f32;
    var intersection: vec3<f32>;
    var local_3: vec3<f32>;
    var normal: vec3<f32>;
    var reflectedDir: vec3<f32>;
    var _reflBkg: vec4<f32>;
    var _o_n: vec3<f32>;
    var _o_alpha: f32;
    var _o_beta: f32;
    var _o_pos: vec2<f32>;
    var _o_m: f32;
    var _o_darken: f32;
    var _o_ratio: f32;
    var _o_X: f32;
    var _o_Y: f32;
    var balance: f32;
    var _bkg: vec4<f32> = vec4(0f);
    var _o_n_1: vec3<f32>;
    var _o_alpha_1: f32;
    var _o_beta_1: f32;
    var _o_pos_1: vec2<f32>;
    var _o_m_1: f32;
    var _o_darken_1: f32;
    var _o_ratio_1: f32;
    var _o_X_1: f32 = 0.5f;
    var _o_Y_1: f32 = 0.5f;
    var mixedCol: vec4<f32>;

    pos_1 = pos;
    outPos_1 = outPos;
    model3DTransform_1 = model3DTransform;
    sourceDim_1 = sourceDim;
    intensity_1 = intensity;
    reflectivity_1 = reflectivity;
    radius_9 = radius_8;
    count_7 = count_6;
    objectColor_1 = objectColor;
    glowColor_3 = glowColor_2;
    bkgColor_1 = bkgColor;
    backgroundStyle_1 = backgroundStyle;
    let _e30 = model3DTransform_1;
    invModelTransform = _naga_inverse_4x4_f32(_e30);
    let _e33 = invModelTransform;
    cameraPos = (_e33 * vec4<f32>(0f, 0f, 0f, 1f)).xyz;
    let _e44 = pos_1;
    let _e46 = D;
    let _e48 = pos_1;
    let _e50 = D;
    dir_4 = normalize(vec3<f32>((_e44.x * _e46), (_e48.y * _e50), -1f));
    let _e57 = invModelTransform;
    let _e67 = dir_4;
    dir_4 = (mat3x3<f32>(_e57[0].xyz, _e57[1].xyz, _e57[2].xyz) * _e67);
    let _e71 = intensity_1;
    eta = (1f - (2f * _e71));
    let _e75 = count_7;
    fcount = f32(_e75);
    let _e78 = cameraPos;
    origin_4 = _e78;
    let _e82 = maxIter_1;
    iter_1 = _e82;
    loop {
        {
            minK = 1000000f;
            minI = -1i;
            let _e104 = origin_4;
            let _e105 = dir_4;
            let _e106 = radius_9;
            let _e107 = fcount;
            let _e108 = glowColor_3;
            let _e109 = torusKnotRayMarch(_e104, _e105, _e106, _e107, _e108);
            inters = _e109;
            let _e111 = inters;
            k_1 = _e111.x;
            let _e114 = k_1;
            let _e117 = k_1;
            let _e118 = minK;
            if ((_e114 > 0f) && (_e117 < _e118)) {
                {
                    let _e121 = k_1;
                    minK = _e121;
                    minI = 0i;
                    objectIntersected = true;
                }
            } else {
                let _e124 = iter_1;
                let _e125 = maxIter_1;
                if (_e124 == _e125) {
                    {
                        let _e127 = minDist_1;
                        let _e128 = inters;
                        minDist_1 = min(_e127, _e128.z);
                    }
                }
            }
            let _e131 = minI;
            if (_e131 >= 0i) {
                {
                    let _e134 = origin_4;
                    let _e135 = minK;
                    let _e136 = dir_4;
                    intersection = (_e134 + (_e135 * _e136));
                    let _e140 = origin_4;
                    let _e141 = radius_9;
                    let _e142 = fcount;
                    let _e143 = torusKnotImplicitFn(_e140, _e141, _e142);
                    if (_e143 <= 0f) {
                        let _e146 = intersection;
                        let _e147 = radius_9;
                        let _e148 = fcount;
                        let _e149 = torusKnotNormal(_e146, _e147, _e148);
                        local_3 = _e149;
                    } else {
                        let _e150 = intersection;
                        let _e151 = radius_9;
                        let _e152 = fcount;
                        let _e153 = torusKnotNormal(_e150, _e151, _e152);
                        local_3 = -(_e153);
                    }
                    let _e156 = local_3;
                    normal = _e156;
                    let _e158 = iter_1;
                    let _e159 = maxIter_1;
                    if (_e158 == _e159) {
                        {
                            let _e161 = normal;
                            let _e162 = dir_4;
                            incidence = abs(dot(_e161, _e162));
                            let _e165 = dir_4;
                            let _e166 = normal;
                            reflectedDir = reflect(_e165, _e166);
                            _reflBkg = vec4(0f);
                            let _e172 = backgroundStyle_1;
                            if (_e172 == 0i) {
                                {
                                    let _e175 = reflectedDir;
                                    _o_n = normalize(_e175);
                                    let _e178 = _o_n;
                                    let _e180 = _o_n;
                                    _o_alpha = atan2(_e178.z, _e180.x);
                                    let _e184 = _o_n;
                                    _o_beta = asin(_e184.y);
                                    let _e188 = _o_alpha;
                                    let _e195 = _o_beta;
                                    let _e203 = global.U[0];
                                    let _e206 = _o_alpha;
                                    let _e213 = _o_beta;
                                    let _e227 = textureSampleLevel(t_source, samp, ((vec2<f32>((vec2<f32>(((-(_e188) / 3.1415927f) * 2f), ((2f * _e195) / 3.1415927f)).x / _e203.x), vec2<f32>(((-(_e206) / 3.1415927f) * 2f), ((2f * _e213) / 3.1415927f)).y) / vec2(2f)) + vec2(0.5f)), 0f);
                                    _reflBkg = _e227;
                                }
                            } else {
                                let _e228 = backgroundStyle_1;
                                if (_e228 == 1i) {
                                    {
                                        let _e231 = reflectedDir;
                                        let _e234 = reflectedDir;
                                        let _e237 = reflectedDir;
                                        let _e240 = reflectedDir;
                                        _o_pos = vec2<f32>((-(_e231.x) / _e234.z), (-(_e237.y) / _e240.z));
                                        let _e245 = _o_pos;
                                        let _e248 = _o_pos;
                                        _o_m = max(abs(_e245.x), abs(_e248.y));
                                        let _e255 = _o_m;
                                        _o_darken = (4f / max(4f, _e255));
                                        let _e259 = _o_pos;
                                        let _e263 = global.U[0];
                                        let _e266 = _o_pos;
                                        let _e276 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e259.x / _e263.x), _e266.y) / vec2(2f)) + vec2(0.5f)), 0f);
                                        let _e277 = _o_darken;
                                        let _e278 = _o_darken;
                                        let _e279 = _o_darken;
                                        _reflBkg = (_e276 * vec4<f32>(_e277, _e278, _e279, 1f));
                                    }
                                } else {
                                    let _e283 = backgroundStyle_1;
                                    if (_e283 == 2i) {
                                        {
                                            let _e286 = sourceDim_1;
                                            let _e288 = sourceDim_1;
                                            _o_ratio = (_e286.y / _e288.x);
                                            _o_X = 0.5f;
                                            _o_Y = 0.5f;
                                            let _e296 = reflectedDir;
                                            let _e299 = reflectedDir;
                                            let _e302 = _o_ratio;
                                            let _e305 = reflectedDir;
                                            let _e308 = reflectedDir;
                                            let _e311 = _o_ratio;
                                            if ((abs(_e296.y) > (abs(_e299.z) * _e302)) && (abs(_e305.y) > (abs(_e308.x) * _e311))) {
                                                {
                                                    let _e315 = _o_X;
                                                    let _e316 = reflectedDir;
                                                    let _e319 = reflectedDir;
                                                    _o_X = (_e315 + ((-(_e316.x) / _e319.y) * 0.5f));
                                                    let _e325 = _o_Y;
                                                    let _e326 = reflectedDir;
                                                    let _e329 = reflectedDir;
                                                    _o_Y = (_e325 + ((-(_e326.z) / _e329.y) * 0.5f));
                                                }
                                            } else {
                                                let _e335 = reflectedDir;
                                                let _e338 = reflectedDir;
                                                if (abs(_e335.x) < abs(_e338.z)) {
                                                    {
                                                        let _e342 = _o_X;
                                                        let _e343 = reflectedDir;
                                                        let _e345 = reflectedDir;
                                                        let _e349 = _o_ratio;
                                                        let _e353 = reflectedDir;
                                                        _o_X = (_e342 + ((((_e343.x / abs(_e345.z)) * _e349) * 0.5f) * -(sign(_e353.z))));
                                                        let _e359 = _o_Y;
                                                        let _e360 = reflectedDir;
                                                        let _e362 = reflectedDir;
                                                        _o_Y = (_e359 + ((_e360.y / abs(_e362.z)) * 0.5f));
                                                    }
                                                } else {
                                                    {
                                                        let _e369 = _o_X;
                                                        let _e370 = reflectedDir;
                                                        let _e372 = reflectedDir;
                                                        let _e376 = _o_ratio;
                                                        let _e380 = reflectedDir;
                                                        _o_X = (_e369 + ((((_e370.z / abs(_e372.x)) * _e376) * 0.5f) * -(sign(_e380.x))));
                                                        let _e386 = _o_Y;
                                                        let _e387 = reflectedDir;
                                                        let _e389 = reflectedDir;
                                                        _o_Y = (_e386 + ((_e387.y / abs(_e389.x)) * 0.5f));
                                                    }
                                                }
                                            }
                                            let _e396 = _o_X;
                                            let _e397 = _o_Y;
                                            let _e407 = global.U[0];
                                            let _e410 = _o_X;
                                            let _e411 = _o_Y;
                                            let _e427 = textureSampleLevel(t_source, samp, ((vec2<f32>((((vec2<f32>(_e396, _e397) * 2f) - vec2(1f)).x / _e407.x), ((vec2<f32>(_e410, _e411) * 2f) - vec2(1f)).y) / vec2(2f)) + vec2(0.5f)), 0f);
                                            _reflBkg = _e427;
                                        }
                                    } else {
                                        {
                                            let _e428 = reflectedDir;
                                            let _e433 = ((_e428 * 0.5f) + vec3(0.5f));
                                            _reflBkg = vec4<f32>(_e433.x, _e433.y, _e433.z, 1f);
                                        }
                                    }
                                }
                            }
                            let _e439 = _reflBkg;
                            reflectedColor = _e439;
                        }
                    }
                    let _e440 = dir_4;
                    let _e441 = normal;
                    let _e442 = eta;
                    dir_4 = refract(_e440, _e441, _e442);
                    let _e444 = intersection;
                    let _e445 = dir_4;
                    origin_4 = (_e444 + (_e445 * 0.001f));
                }
            }
            let _e449 = iter_1;
            iter_1 = (_e449 - 1i);
        }
        let _e452 = minI;
        let _e455 = iter_1;
        if !(((_e452 >= 0i) && (_e455 > 0i))) {
            break;
        }
    }
    let _e462 = reflectivity_1;
    balance = (1f - (2f * _e462));
    let _e469 = backgroundStyle_1;
    if (_e469 == 0i) {
        {
            let _e472 = dir_4;
            _o_n_1 = normalize(_e472);
            let _e475 = _o_n_1;
            let _e477 = _o_n_1;
            _o_alpha_1 = atan2(_e475.z, _e477.x);
            let _e481 = _o_n_1;
            _o_beta_1 = asin(_e481.y);
            let _e485 = _o_alpha_1;
            let _e492 = _o_beta_1;
            let _e500 = global.U[0];
            let _e503 = _o_alpha_1;
            let _e510 = _o_beta_1;
            let _e524 = textureSampleLevel(t_source, samp, ((vec2<f32>((vec2<f32>(((-(_e485) / 3.1415927f) * 2f), ((2f * _e492) / 3.1415927f)).x / _e500.x), vec2<f32>(((-(_e503) / 3.1415927f) * 2f), ((2f * _e510) / 3.1415927f)).y) / vec2(2f)) + vec2(0.5f)), 0f);
            _bkg = _e524;
        }
    } else {
        let _e525 = backgroundStyle_1;
        if (_e525 == 1i) {
            {
                let _e528 = dir_4;
                let _e531 = dir_4;
                let _e534 = dir_4;
                let _e537 = dir_4;
                _o_pos_1 = vec2<f32>((-(_e528.x) / _e531.z), (-(_e534.y) / _e537.z));
                let _e542 = _o_pos_1;
                let _e545 = _o_pos_1;
                _o_m_1 = max(abs(_e542.x), abs(_e545.y));
                let _e552 = _o_m_1;
                _o_darken_1 = (4f / max(4f, _e552));
                let _e556 = _o_pos_1;
                let _e560 = global.U[0];
                let _e563 = _o_pos_1;
                let _e573 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e556.x / _e560.x), _e563.y) / vec2(2f)) + vec2(0.5f)), 0f);
                let _e574 = _o_darken_1;
                let _e575 = _o_darken_1;
                let _e576 = _o_darken_1;
                _bkg = (_e573 * vec4<f32>(_e574, _e575, _e576, 1f));
            }
        } else {
            let _e580 = backgroundStyle_1;
            if (_e580 == 2i) {
                {
                    let _e583 = sourceDim_1;
                    let _e585 = sourceDim_1;
                    _o_ratio_1 = (_e583.y / _e585.x);
                    let _e593 = dir_4;
                    let _e596 = dir_4;
                    let _e599 = _o_ratio_1;
                    let _e602 = dir_4;
                    let _e605 = dir_4;
                    let _e608 = _o_ratio_1;
                    if ((abs(_e593.y) > (abs(_e596.z) * _e599)) && (abs(_e602.y) > (abs(_e605.x) * _e608))) {
                        {
                            let _e612 = _o_X_1;
                            let _e613 = dir_4;
                            let _e616 = dir_4;
                            _o_X_1 = (_e612 + ((-(_e613.x) / _e616.y) * 0.5f));
                            let _e622 = _o_Y_1;
                            let _e623 = dir_4;
                            let _e626 = dir_4;
                            _o_Y_1 = (_e622 + ((-(_e623.z) / _e626.y) * 0.5f));
                        }
                    } else {
                        let _e632 = dir_4;
                        let _e635 = dir_4;
                        if (abs(_e632.x) < abs(_e635.z)) {
                            {
                                let _e639 = _o_X_1;
                                let _e640 = dir_4;
                                let _e642 = dir_4;
                                let _e646 = _o_ratio_1;
                                let _e650 = dir_4;
                                _o_X_1 = (_e639 + ((((_e640.x / abs(_e642.z)) * _e646) * 0.5f) * -(sign(_e650.z))));
                                let _e656 = _o_Y_1;
                                let _e657 = dir_4;
                                let _e659 = dir_4;
                                _o_Y_1 = (_e656 + ((_e657.y / abs(_e659.z)) * 0.5f));
                            }
                        } else {
                            {
                                let _e666 = _o_X_1;
                                let _e667 = dir_4;
                                let _e669 = dir_4;
                                let _e673 = _o_ratio_1;
                                let _e677 = dir_4;
                                _o_X_1 = (_e666 + ((((_e667.z / abs(_e669.x)) * _e673) * 0.5f) * -(sign(_e677.x))));
                                let _e683 = _o_Y_1;
                                let _e684 = dir_4;
                                let _e686 = dir_4;
                                _o_Y_1 = (_e683 + ((_e684.y / abs(_e686.x)) * 0.5f));
                            }
                        }
                    }
                    let _e693 = _o_X_1;
                    let _e694 = _o_Y_1;
                    let _e704 = global.U[0];
                    let _e707 = _o_X_1;
                    let _e708 = _o_Y_1;
                    let _e724 = textureSampleLevel(t_source, samp, ((vec2<f32>((((vec2<f32>(_e693, _e694) * 2f) - vec2(1f)).x / _e704.x), ((vec2<f32>(_e707, _e708) * 2f) - vec2(1f)).y) / vec2(2f)) + vec2(0.5f)), 0f);
                    _bkg = _e724;
                }
            } else {
                {
                    let _e725 = dir_4;
                    let _e730 = ((_e725 * 0.5f) + vec3(0.5f));
                    _bkg = vec4<f32>(_e730.x, _e730.y, _e730.z, 1f);
                }
            }
        }
    }
    let _e736 = reflectedColor;
    let _e737 = _bkg;
    let _e738 = incidence;
    let _e739 = balance;
    mixedCol = mix(_e736, _e737, vec4(clamp((_e738 + _e739), 0f, 1f)));
    let _e747 = objectIntersected;
    if _e747 {
        let _e748 = mixedCol;
        let _e749 = mixedCol;
        let _e751 = objectColor_1;
        let _e753 = (2f * _e751.xyz);
        let _e760 = objectColor_1;
        mixedCol = mix(_e748, (_e749 * vec4<f32>(_e753.x, _e753.y, _e753.z, 1f)), vec4(_e760.w));
    } else {
        let _e764 = mixedCol;
        let _e765 = mixedCol;
        let _e767 = bkgColor_1;
        let _e769 = (2f * _e767.xyz);
        let _e776 = bkgColor_1;
        mixedCol = mix(_e764, (_e765 * vec4<f32>(_e769.x, _e769.y, _e769.z, 1f)), vec4(_e776.w));
    }
    let _e780 = mixedCol;
    let _e781 = glowColor_3;
    let _e785 = minDist_1;
    let _e789 = ((_e781.xyz * 0.1f) / vec3(pow(_e785, 1f)));
    let _e795 = glowColor_3;
    return (_e780 + (vec4<f32>(_e789.x, _e789.y, _e789.z, 0f) * _e795.w));
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
    let _e66 = global.U[6];
    let _e69 = global.U[7];
    let _e72 = global.U[8];
    let _e75 = global.U[9];
    let _e99 = global.U[4];
    let _e103 = global.U[10];
    let _e107 = global.U[11];
    let _e111 = global.U[12];
    let _e115 = global.U[13];
    let _e120 = global.U[14];
    let _e123 = global.U[15];
    let _e126 = global.U[16];
    let _e129 = global.U[17];
    let _e132 = torusKnotGl((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e9.x, _e9.y, _e9.z), vec3<f32>(_e13.x, _e13.y, _e13.z), vec3<f32>(_e17.x, _e17.y, _e17.z))) * vec3<f32>(_e44.x, _e44.y, 1f)).xy, (((_e51 - vec2(0.5f)) * 2f) * vec2<f32>(_e59.x, 1f)), mat4x4<f32>(vec4<f32>(_e66.x, _e66.y, _e66.z, _e66.w), vec4<f32>(_e69.x, _e69.y, _e69.z, _e69.w), vec4<f32>(_e72.x, _e72.y, _e72.z, _e72.w), vec4<f32>(_e75.x, _e75.y, _e75.z, _e75.w)), _e99.xy, _e103.x, _e107.x, _e111.x, i32(_e115.x), _e120, _e123, _e126, i32(_e129.x));
    fragColor = _e132;
    return;
}

@fragment 
fn main(@location(0) v_uv: vec2<f32>) -> FragmentOutput {
    v_uv_1 = v_uv;
    main_1();
    let _e13 = fragColor;
    return FragmentOutput(_e13);
}

fn _naga_inverse_4x4_f32(m: mat4x4<f32>) -> mat4x4<f32> {
   let sub_factor00: f32 = m[2][2] * m[3][3] - m[3][2] * m[2][3];
   let sub_factor01: f32 = m[2][1] * m[3][3] - m[3][1] * m[2][3];
   let sub_factor02: f32 = m[2][1] * m[3][2] - m[3][1] * m[2][2];
   let sub_factor03: f32 = m[2][0] * m[3][3] - m[3][0] * m[2][3];
   let sub_factor04: f32 = m[2][0] * m[3][2] - m[3][0] * m[2][2];
   let sub_factor05: f32 = m[2][0] * m[3][1] - m[3][0] * m[2][1];
   let sub_factor06: f32 = m[1][2] * m[3][3] - m[3][2] * m[1][3];
   let sub_factor07: f32 = m[1][1] * m[3][3] - m[3][1] * m[1][3];
   let sub_factor08: f32 = m[1][1] * m[3][2] - m[3][1] * m[1][2];
   let sub_factor09: f32 = m[1][0] * m[3][3] - m[3][0] * m[1][3];
   let sub_factor10: f32 = m[1][0] * m[3][2] - m[3][0] * m[1][2];
   let sub_factor11: f32 = m[1][1] * m[3][3] - m[3][1] * m[1][3];
   let sub_factor12: f32 = m[1][0] * m[3][1] - m[3][0] * m[1][1];
   let sub_factor13: f32 = m[1][2] * m[2][3] - m[2][2] * m[1][3];
   let sub_factor14: f32 = m[1][1] * m[2][3] - m[2][1] * m[1][3];
   let sub_factor15: f32 = m[1][1] * m[2][2] - m[2][1] * m[1][2];
   let sub_factor16: f32 = m[1][0] * m[2][3] - m[2][0] * m[1][3];
   let sub_factor17: f32 = m[1][0] * m[2][2] - m[2][0] * m[1][2];
   let sub_factor18: f32 = m[1][0] * m[2][1] - m[2][0] * m[1][1];

   var adj: mat4x4<f32>;
   adj[0][0] =   (m[1][1] * sub_factor00 - m[1][2] * sub_factor01 + m[1][3] * sub_factor02);
   adj[1][0] = - (m[1][0] * sub_factor00 - m[1][2] * sub_factor03 + m[1][3] * sub_factor04);
   adj[2][0] =   (m[1][0] * sub_factor01 - m[1][1] * sub_factor03 + m[1][3] * sub_factor05);
   adj[3][0] = - (m[1][0] * sub_factor02 - m[1][1] * sub_factor04 + m[1][2] * sub_factor05);
   adj[0][1] = - (m[0][1] * sub_factor00 - m[0][2] * sub_factor01 + m[0][3] * sub_factor02);
   adj[1][1] =   (m[0][0] * sub_factor00 - m[0][2] * sub_factor03 + m[0][3] * sub_factor04);
   adj[2][1] = - (m[0][0] * sub_factor01 - m[0][1] * sub_factor03 + m[0][3] * sub_factor05);
   adj[3][1] =   (m[0][0] * sub_factor02 - m[0][1] * sub_factor04 + m[0][2] * sub_factor05);
   adj[0][2] =   (m[0][1] * sub_factor06 - m[0][2] * sub_factor07 + m[0][3] * sub_factor08);
   adj[1][2] = - (m[0][0] * sub_factor06 - m[0][2] * sub_factor09 + m[0][3] * sub_factor10);
   adj[2][2] =   (m[0][0] * sub_factor11 - m[0][1] * sub_factor09 + m[0][3] * sub_factor12);
   adj[3][2] = - (m[0][0] * sub_factor08 - m[0][1] * sub_factor10 + m[0][2] * sub_factor12);
   adj[0][3] = - (m[0][1] * sub_factor13 - m[0][2] * sub_factor14 + m[0][3] * sub_factor15);
   adj[1][3] =   (m[0][0] * sub_factor13 - m[0][2] * sub_factor16 + m[0][3] * sub_factor17);
   adj[2][3] = - (m[0][0] * sub_factor14 - m[0][1] * sub_factor16 + m[0][3] * sub_factor18);
   adj[3][3] =   (m[0][0] * sub_factor15 - m[0][1] * sub_factor17 + m[0][2] * sub_factor18);

   let det = (m[0][0] * adj[0][0] + m[0][1] * adj[1][0] + m[0][2] * adj[2][0] + m[0][3] * adj[3][0]);

   return adj * (1 / det);
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
