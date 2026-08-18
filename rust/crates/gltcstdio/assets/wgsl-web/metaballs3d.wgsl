struct Params {
    U: array<vec4<f32>, 21>,
    u_spheres: array<vec4<f32>, 32>,
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

fn implicitFn(p: vec3<f32>, spheres_size: i32) -> f32 {
    var p_1: vec3<f32>;
    var spheres_size_1: i32;
    var total: f32 = 0f;
    var i: i32 = 0i;

    p_1 = p;
    spheres_size_1 = spheres_size;
    loop {
        let _e16 = i;
        let _e17 = spheres_size_1;
        if !((_e16 < _e17)) {
            break;
        }
        {
            let _e23 = total;
            let _e25 = i;
            let _e27 = global.u_spheres[_e25];
            let _e29 = p_1;
            let _e34 = i;
            let _e36 = global.u_spheres[_e34];
            total = (_e23 + ((1f / length((_e27.xyz - _e29))) - (1f / _e36.w)));
        }
        continuing {
            let _e20 = i;
            i = (_e20 + 1i);
        }
    }
    let _e41 = total;
    return _e41;
}

fn sphereIntersectionK(center: vec3<f32>, radius: f32, origin: vec3<f32>, dir: vec3<f32>) -> vec2<f32> {
    var center_1: vec3<f32>;
    var radius_1: f32;
    var origin_1: vec3<f32>;
    var dir_1: vec3<f32>;
    var relOrigin: vec3<f32>;
    var a: f32;
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
    radius_1 = radius;
    origin_1 = origin;
    dir_1 = dir;
    let _e16 = origin_1;
    let _e17 = center_1;
    relOrigin = (_e16 - _e17);
    let _e20 = dir_1;
    let _e21 = dir_1;
    a = dot(_e20, _e21);
    let _e25 = dir_1;
    let _e26 = relOrigin;
    b = (2f * dot(_e25, _e26));
    let _e30 = relOrigin;
    let _e31 = relOrigin;
    let _e33 = radius_1;
    let _e34 = radius_1;
    c = (dot(_e30, _e31) - (_e33 * _e34));
    let _e38 = b;
    let _e39 = b;
    let _e42 = a;
    let _e44 = c;
    delta = ((_e38 * _e39) - ((4f * _e42) * _e44));
    let _e48 = delta;
    if (_e48 >= 0f) {
        {
            let _e51 = delta;
            sqrtDelta = sqrt(_e51);
            let _e54 = b;
            let _e56 = sqrtDelta;
            let _e59 = a;
            l1_ = ((-(_e54) - _e56) / (2f * _e59));
            let _e63 = b;
            let _e65 = sqrtDelta;
            let _e68 = a;
            l2_ = ((-(_e63) + _e65) / (2f * _e68));
            let _e72 = l1_;
            if (_e72 > 0f) {
                let _e75 = l1_;
                local_1 = _e75;
            } else {
                let _e76 = l2_;
                if (_e76 > 0f) {
                    let _e79 = l2_;
                    local = _e79;
                } else {
                    local = -1f;
                }
                let _e83 = local;
                local_1 = _e83;
            }
            let _e85 = local_1;
            l = _e85;
            let _e87 = l1_;
            let _e88 = l2_;
            return vec2<f32>(_e87, _e88);
        }
    }
    return vec2(100000000000000000000f);
}

fn getIntersectionD(origin_2: vec3<f32>, dir_2: vec3<f32>, sphereRad: f32, spheres_size_2: i32) -> vec3<f32> {
    var origin_3: vec3<f32>;
    var dir_3: vec3<f32>;
    var sphereRad_1: f32;
    var spheres_size_3: i32;
    var minDist: f32 = 1000000000f;
    var kBounds: vec2<f32>;
    var k0_: f32;
    var k1_: f32;
    var originSign: f32;
    var steps: f32 = 100f;
    var dk: f32;
    var x0_: vec3<f32>;
    var x1_: vec3<f32>;
    var a_1: f32;
    var b_1: f32;
    var de: f32 = 0.001f;
    var maxSecantIter: i32 = 100i;
    var iter: i32 = 0i;
    var dy: f32;
    var deriv: f32;
    var k2_: f32;
    var x2_: vec3<f32>;
    var c_1: f32;

    origin_3 = origin_2;
    dir_3 = dir_2;
    sphereRad_1 = sphereRad;
    spheres_size_3 = spheres_size_2;
    let _e20 = sphereRad_1;
    let _e21 = origin_3;
    let _e22 = dir_3;
    let _e23 = sphereIntersectionK(vec3(0f), _e20, _e21, _e22);
    kBounds = _e23;
    let _e25 = kBounds;
    if (_e25.x >= 100000000f) {
        let _e32 = minDist;
        return vec3<f32>(-1f, 0f, _e32);
    }
    let _e35 = kBounds;
    k0_ = max(0f, _e35.x);
    let _e39 = k0_;
    k1_ = _e39;
    let _e41 = origin_3;
    let _e42 = spheres_size_3;
    let _e43 = implicitFn(_e41, _e42);
    originSign = sign(_e43);
    let _e48 = kBounds;
    let _e50 = k0_;
    let _e52 = steps;
    dk = ((_e48.y - _e50) / _e52);
    let _e55 = origin_3;
    let _e56 = k0_;
    let _e57 = dir_3;
    x0_ = (_e55 + (_e56 * _e57));
    let _e61 = x0_;
    x1_ = _e61;
    let _e63 = x0_;
    let _e64 = spheres_size_3;
    let _e65 = implicitFn(_e63, _e64);
    a_1 = _e65;
    let _e67 = a_1;
    b_1 = _e67;
    loop {
        {
            let _e69 = k1_;
            k0_ = _e69;
            let _e70 = x1_;
            x0_ = _e70;
            let _e71 = b_1;
            a_1 = _e71;
            let _e72 = k1_;
            let _e73 = dk;
            k1_ = (_e72 + _e73);
            let _e75 = origin_3;
            let _e76 = k1_;
            let _e77 = dir_3;
            x1_ = (_e75 + (_e76 * _e77));
            let _e80 = x1_;
            let _e81 = spheres_size_3;
            let _e82 = implicitFn(_e80, _e81);
            b_1 = _e82;
            let _e83 = minDist;
            let _e84 = b_1;
            minDist = min(_e83, abs(_e84));
        }
        let _e87 = k1_;
        let _e88 = kBounds;
        let _e91 = b_1;
        let _e93 = originSign;
        if !(((_e87 < _e88.y) && (sign(_e91) == _e93))) {
            break;
        }
    }
    let _e97 = b_1;
    let _e99 = originSign;
    if (sign(_e97) == _e99) {
        let _e104 = minDist;
        return vec3<f32>(-1f, 0f, _e104);
    }
    loop {
        let _e112 = iter;
        let _e113 = maxSecantIter;
        if !((_e112 < _e113)) {
            break;
        }
        {
            let _e116 = b_1;
            let _e117 = a_1;
            dy = (_e116 - _e117);
            let _e120 = k1_;
            let _e121 = k0_;
            dk = (_e120 - _e121);
            let _e123 = dy;
            let _e124 = dk;
            deriv = (_e123 / _e124);
            let _e127 = k0_;
            let _e128 = a_1;
            let _e129 = deriv;
            k2_ = (_e127 - (_e128 / _e129));
            let _e133 = k2_;
            let _e134 = kBounds;
            let _e137 = k2_;
            let _e138 = kBounds;
            if ((_e133 < _e134.x) || (_e137 > _e138.y)) {
                let _e142 = k0_;
                let _e143 = k1_;
                k2_ = ((_e142 + _e143) / 2f);
            }
            let _e147 = origin_3;
            let _e148 = k2_;
            let _e149 = dir_3;
            x2_ = (_e147 + (_e148 * _e149));
            let _e153 = x2_;
            let _e154 = spheres_size_3;
            let _e155 = implicitFn(_e153, _e154);
            c_1 = _e155;
            let _e157 = minDist;
            let _e158 = c_1;
            minDist = min(_e157, abs(_e158));
            let _e161 = c_1;
            let _e163 = de;
            if (abs(_e161) < _e163) {
                let _e165 = k2_;
                let _e166 = iter;
                let _e168 = minDist;
                return vec3<f32>(_e165, f32(_e166), _e168);
            }
            let _e170 = a_1;
            let _e172 = c_1;
            if (sign(_e170) != sign(_e172)) {
                {
                    let _e175 = k2_;
                    k1_ = _e175;
                    let _e176 = c_1;
                    b_1 = _e176;
                }
            } else {
                {
                    let _e177 = k2_;
                    k0_ = _e177;
                    let _e178 = c_1;
                    a_1 = _e178;
                }
            }
            let _e179 = iter;
            iter = (_e179 + 1i);
        }
    }
    let _e182 = k0_;
    let _e183 = k1_;
    let _e187 = iter;
    let _e189 = minDist;
    return vec3<f32>(((_e182 + _e183) / 2f), f32(_e187), _e189);
}

fn getNormal(p_2: vec3<f32>, spheres_size_4: i32) -> vec3<f32> {
    var p_3: vec3<f32>;
    var spheres_size_5: i32;
    var d: f32 = 0.01f;
    var d2_: f32;

    p_3 = p_2;
    spheres_size_5 = spheres_size_4;
    let _e14 = d;
    d2_ = (_e14 * 2f);
    let _e18 = p_3;
    let _e20 = d;
    let _e22 = p_3;
    let _e24 = p_3;
    let _e27 = spheres_size_5;
    let _e28 = implicitFn(vec3<f32>((_e18.x - _e20), _e22.y, _e24.z), _e27);
    let _e29 = p_3;
    let _e31 = d;
    let _e33 = p_3;
    let _e35 = p_3;
    let _e38 = spheres_size_5;
    let _e39 = implicitFn(vec3<f32>((_e29.x + _e31), _e33.y, _e35.z), _e38);
    let _e41 = d2_;
    let _e43 = p_3;
    let _e45 = p_3;
    let _e47 = d;
    let _e49 = p_3;
    let _e52 = spheres_size_5;
    let _e53 = implicitFn(vec3<f32>(_e43.x, (_e45.y - _e47), _e49.z), _e52);
    let _e54 = p_3;
    let _e56 = p_3;
    let _e58 = d;
    let _e60 = p_3;
    let _e63 = spheres_size_5;
    let _e64 = implicitFn(vec3<f32>(_e54.x, (_e56.y + _e58), _e60.z), _e63);
    let _e66 = d2_;
    let _e68 = p_3;
    let _e70 = p_3;
    let _e72 = p_3;
    let _e74 = d;
    let _e77 = spheres_size_5;
    let _e78 = implicitFn(vec3<f32>(_e68.x, _e70.y, (_e72.z - _e74)), _e77);
    let _e79 = p_3;
    let _e81 = p_3;
    let _e83 = p_3;
    let _e85 = d;
    let _e88 = spheres_size_5;
    let _e89 = implicitFn(vec3<f32>(_e79.x, _e81.y, (_e83.z + _e85)), _e88);
    let _e91 = d2_;
    return normalize(vec3<f32>(((_e28 - _e39) / _e41), ((_e53 - _e64) / _e66), ((_e78 - _e89) / _e91)));
}

fn metaballs3d(pos: vec2<f32>, outPos: vec2<f32>, model3DTransform: mat4x4<f32>, sourceDim: vec2<f32>, intensity: f32, reflectivity: f32, objectColor: vec4<f32>, glowColor: vec4<f32>, bkgColor: vec4<f32>, backgroundStyle: i32, spheres_size_6: i32) -> vec4<f32> {
    var pos_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var model3DTransform_1: mat4x4<f32>;
    var sourceDim_1: vec2<f32>;
    var intensity_1: f32;
    var reflectivity_1: f32;
    var objectColor_1: vec4<f32>;
    var glowColor_1: vec4<f32>;
    var bkgColor_1: vec4<f32>;
    var backgroundStyle_1: i32;
    var spheres_size_7: i32;
    var invModelTransform: mat4x4<f32>;
    var cameraPos: vec3<f32>;
    var D: f32 = 1f;
    var dir_4: vec3<f32>;
    var eta: f32;
    var origin_4: vec3<f32>;
    var maxIter: i32 = 12i;
    var iter_1: i32;
    var minI: i32 = -1i;
    var minK: f32 = 1000000f;
    var incidence: f32 = 2f;
    var reflectedColor: vec4<f32> = vec4<f32>(0f, 0f, 0f, 1f);
    var minDist_1: f32 = 1000000000f;
    var objectIntersected: bool = false;
    var local_2: f32;
    var sphereRad_2: f32;
    var inters: vec3<f32>;
    var k: f32;
    var intersection: vec3<f32>;
    var local_3: vec3<f32>;
    var normal: vec3<f32>;
    var reflectedDir: vec3<f32>;
    var _reflBkg: vec4<f32>;
    var _o_n: vec3<f32>;
    var _o_alpha: f32;
    var _o_beta: f32;
    var _o_nX: f32;
    var _o_nY: f32;
    var _o_pos: vec2<f32>;
    var _o_pos_1: vec2<f32>;
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
    var _o_nX_1: f32 = 2f;
    var _o_nY_1: f32 = 1f;
    var _o_pos_2: vec2<f32>;
    var _o_pos_3: vec2<f32>;
    var _o_m_1: f32;
    var _o_darken_1: f32;
    var _o_ratio_1: f32;
    var _o_X_1: f32 = 0.5f;
    var _o_Y_1: f32 = 0.5f;
    var mixedCol: vec4<f32>;
    var glowIntensity: f32;
    var glowCol: vec4<f32>;

    pos_1 = pos;
    outPos_1 = outPos;
    model3DTransform_1 = model3DTransform;
    sourceDim_1 = sourceDim;
    intensity_1 = intensity;
    reflectivity_1 = reflectivity;
    objectColor_1 = objectColor;
    glowColor_1 = glowColor;
    bkgColor_1 = bkgColor;
    backgroundStyle_1 = backgroundStyle;
    spheres_size_7 = spheres_size_6;
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
    let _e75 = cameraPos;
    origin_4 = _e75;
    let _e79 = maxIter;
    iter_1 = _e79;
    let _e98 = glowColor_1;
    let _e102 = glowColor_1;
    let _e107 = glowColor_1;
    if (((_e98.x == 0f) && (_e102.y == 0f)) && (_e107.z == 0f)) {
        local_2 = 2.5f;
    } else {
        local_2 = 5f;
    }
    let _e115 = local_2;
    sphereRad_2 = _e115;
    loop {
        {
            minK = 1000000f;
            minI = -1i;
            let _e120 = origin_4;
            let _e121 = dir_4;
            let _e122 = sphereRad_2;
            let _e123 = spheres_size_7;
            let _e124 = getIntersectionD(_e120, _e121, _e122, _e123);
            inters = _e124;
            let _e126 = inters;
            k = _e126.x;
            let _e129 = k;
            let _e132 = k;
            let _e133 = minK;
            if ((_e129 > 0f) && (_e132 < _e133)) {
                {
                    let _e136 = k;
                    minK = _e136;
                    minI = 0i;
                    objectIntersected = true;
                }
            } else {
                let _e139 = iter_1;
                let _e140 = maxIter;
                if (_e139 == _e140) {
                    {
                        let _e142 = minDist_1;
                        let _e143 = inters;
                        minDist_1 = min(_e142, _e143.z);
                    }
                }
            }
            let _e146 = minI;
            if (_e146 >= 0i) {
                {
                    let _e149 = origin_4;
                    let _e150 = minK;
                    let _e151 = dir_4;
                    intersection = (_e149 + (_e150 * _e151));
                    let _e155 = origin_4;
                    let _e156 = spheres_size_7;
                    let _e157 = implicitFn(_e155, _e156);
                    if (_e157 <= 0f) {
                        let _e160 = intersection;
                        let _e161 = spheres_size_7;
                        let _e162 = getNormal(_e160, _e161);
                        local_3 = _e162;
                    } else {
                        let _e163 = intersection;
                        let _e164 = spheres_size_7;
                        let _e165 = getNormal(_e163, _e164);
                        local_3 = -(_e165);
                    }
                    let _e168 = local_3;
                    normal = _e168;
                    let _e170 = iter_1;
                    let _e171 = maxIter;
                    if (_e170 == _e171) {
                        {
                            let _e173 = normal;
                            let _e174 = dir_4;
                            incidence = abs(dot(_e173, _e174));
                            let _e177 = dir_4;
                            let _e178 = normal;
                            reflectedDir = reflect(_e177, _e178);
                            _reflBkg = vec4(0f);
                            let _e184 = backgroundStyle_1;
                            if (_e184 == 0i) {
                                {
                                    let _e187 = reflectedDir;
                                    _o_n = normalize(_e187);
                                    let _e190 = _o_n;
                                    let _e192 = _o_n;
                                    _o_alpha = atan2(_e190.z, _e192.x);
                                    let _e196 = _o_n;
                                    _o_beta = asin(_e196.y);
                                    _o_nX = 2f;
                                    _o_nY = 1f;
                                    let _e204 = _o_alpha;
                                    let _e210 = _o_nX;
                                    let _e213 = _o_nY;
                                    let _e214 = _o_beta;
                                    _o_pos = ((vec2<f32>((((-(_e204) / 3.1415927f) * 0.5f) * _e210), (0.5f + ((_e213 * _e214) / 3.1415927f))) * 2f) - vec2(1f));
                                    let _e226 = _o_pos;
                                    let _e230 = global.U[0];
                                    let _e233 = _o_pos;
                                    let _e243 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e226.x / _e230.x), _e233.y) / vec2(2f)) + vec2(0.5f)), 0f);
                                    _reflBkg = _e243;
                                }
                            } else {
                                let _e244 = backgroundStyle_1;
                                if (_e244 == 1i) {
                                    {
                                        let _e247 = reflectedDir;
                                        let _e250 = reflectedDir;
                                        let _e253 = reflectedDir;
                                        let _e256 = reflectedDir;
                                        _o_pos_1 = vec2<f32>((-(_e247.x) / _e250.z), (-(_e253.y) / _e256.z));
                                        let _e261 = _o_pos_1;
                                        let _e264 = _o_pos_1;
                                        _o_m = max(abs(_e261.x), abs(_e264.y));
                                        let _e271 = _o_m;
                                        _o_darken = (4f / max(4f, _e271));
                                        let _e275 = _o_pos_1;
                                        let _e279 = global.U[0];
                                        let _e282 = _o_pos_1;
                                        let _e292 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e275.x / _e279.x), _e282.y) / vec2(2f)) + vec2(0.5f)), 0f);
                                        let _e293 = _o_darken;
                                        let _e294 = _o_darken;
                                        let _e295 = _o_darken;
                                        _reflBkg = (_e292 * vec4<f32>(_e293, _e294, _e295, 1f));
                                    }
                                } else {
                                    let _e299 = backgroundStyle_1;
                                    if (_e299 == 2i) {
                                        {
                                            let _e302 = sourceDim_1;
                                            let _e304 = sourceDim_1;
                                            _o_ratio = (_e302.y / _e304.x);
                                            _o_X = 0.5f;
                                            _o_Y = 0.5f;
                                            let _e312 = reflectedDir;
                                            let _e315 = reflectedDir;
                                            let _e318 = _o_ratio;
                                            let _e321 = reflectedDir;
                                            let _e324 = reflectedDir;
                                            let _e327 = _o_ratio;
                                            if ((abs(_e312.y) > (abs(_e315.z) * _e318)) && (abs(_e321.y) > (abs(_e324.x) * _e327))) {
                                                {
                                                    let _e331 = _o_X;
                                                    let _e332 = reflectedDir;
                                                    let _e335 = reflectedDir;
                                                    _o_X = (_e331 + ((-(_e332.x) / _e335.y) * 0.5f));
                                                    let _e341 = _o_Y;
                                                    let _e342 = reflectedDir;
                                                    let _e345 = reflectedDir;
                                                    _o_Y = (_e341 + ((-(_e342.z) / _e345.y) * 0.5f));
                                                }
                                            } else {
                                                let _e351 = reflectedDir;
                                                let _e354 = reflectedDir;
                                                if (abs(_e351.x) < abs(_e354.z)) {
                                                    {
                                                        let _e358 = _o_X;
                                                        let _e359 = reflectedDir;
                                                        let _e361 = reflectedDir;
                                                        let _e365 = _o_ratio;
                                                        let _e369 = reflectedDir;
                                                        _o_X = (_e358 + ((((_e359.x / abs(_e361.z)) * _e365) * 0.5f) * -(sign(_e369.z))));
                                                        let _e375 = _o_Y;
                                                        let _e376 = reflectedDir;
                                                        let _e378 = reflectedDir;
                                                        _o_Y = (_e375 + ((_e376.y / abs(_e378.z)) * 0.5f));
                                                    }
                                                } else {
                                                    {
                                                        let _e385 = _o_X;
                                                        let _e386 = reflectedDir;
                                                        let _e388 = reflectedDir;
                                                        let _e392 = _o_ratio;
                                                        let _e396 = reflectedDir;
                                                        _o_X = (_e385 + ((((_e386.z / abs(_e388.x)) * _e392) * 0.5f) * -(sign(_e396.x))));
                                                        let _e402 = _o_Y;
                                                        let _e403 = reflectedDir;
                                                        let _e405 = reflectedDir;
                                                        _o_Y = (_e402 + ((_e403.y / abs(_e405.x)) * 0.5f));
                                                    }
                                                }
                                            }
                                            let _e412 = _o_X;
                                            let _e413 = _o_Y;
                                            let _e423 = global.U[0];
                                            let _e426 = _o_X;
                                            let _e427 = _o_Y;
                                            let _e443 = textureSampleLevel(t_source, samp, ((vec2<f32>((((vec2<f32>(_e412, _e413) * 2f) - vec2(1f)).x / _e423.x), ((vec2<f32>(_e426, _e427) * 2f) - vec2(1f)).y) / vec2(2f)) + vec2(0.5f)), 0f);
                                            _reflBkg = _e443;
                                        }
                                    } else {
                                        {
                                            let _e444 = reflectedDir;
                                            let _e449 = ((_e444 * 0.5f) + vec3(0.5f));
                                            _reflBkg = vec4<f32>(_e449.x, _e449.y, _e449.z, 1f);
                                        }
                                    }
                                }
                            }
                            let _e455 = _reflBkg;
                            reflectedColor = _e455;
                        }
                    }
                    let _e456 = dir_4;
                    let _e457 = normal;
                    let _e458 = eta;
                    dir_4 = refract(_e456, _e457, _e458);
                    let _e460 = intersection;
                    let _e461 = dir_4;
                    origin_4 = (_e460 + (_e461 * 0.001f));
                }
            }
            let _e465 = iter_1;
            iter_1 = (_e465 - 1i);
        }
        let _e468 = minI;
        let _e471 = iter_1;
        if !(((_e468 >= 0i) && (_e471 > 0i))) {
            break;
        }
    }
    let _e478 = reflectivity_1;
    balance = (1f - (2f * _e478));
    let _e485 = backgroundStyle_1;
    if (_e485 == 0i) {
        {
            let _e488 = dir_4;
            _o_n_1 = normalize(_e488);
            let _e491 = _o_n_1;
            let _e493 = _o_n_1;
            _o_alpha_1 = atan2(_e491.z, _e493.x);
            let _e497 = _o_n_1;
            _o_beta_1 = asin(_e497.y);
            let _e505 = _o_alpha_1;
            let _e511 = _o_nX_1;
            let _e514 = _o_nY_1;
            let _e515 = _o_beta_1;
            _o_pos_2 = ((vec2<f32>((((-(_e505) / 3.1415927f) * 0.5f) * _e511), (0.5f + ((_e514 * _e515) / 3.1415927f))) * 2f) - vec2(1f));
            let _e527 = _o_pos_2;
            let _e531 = global.U[0];
            let _e534 = _o_pos_2;
            let _e544 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e527.x / _e531.x), _e534.y) / vec2(2f)) + vec2(0.5f)), 0f);
            _bkg = _e544;
        }
    } else {
        let _e545 = backgroundStyle_1;
        if (_e545 == 1i) {
            {
                let _e548 = dir_4;
                let _e551 = dir_4;
                let _e554 = dir_4;
                let _e557 = dir_4;
                _o_pos_3 = vec2<f32>((-(_e548.x) / _e551.z), (-(_e554.y) / _e557.z));
                let _e562 = _o_pos_3;
                let _e565 = _o_pos_3;
                _o_m_1 = max(abs(_e562.x), abs(_e565.y));
                let _e572 = _o_m_1;
                _o_darken_1 = (4f / max(4f, _e572));
                let _e576 = _o_pos_3;
                let _e580 = global.U[0];
                let _e583 = _o_pos_3;
                let _e593 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e576.x / _e580.x), _e583.y) / vec2(2f)) + vec2(0.5f)), 0f);
                let _e594 = _o_darken_1;
                let _e595 = _o_darken_1;
                let _e596 = _o_darken_1;
                _bkg = (_e593 * vec4<f32>(_e594, _e595, _e596, 1f));
            }
        } else {
            let _e600 = backgroundStyle_1;
            if (_e600 == 2i) {
                {
                    let _e603 = sourceDim_1;
                    let _e605 = sourceDim_1;
                    _o_ratio_1 = (_e603.y / _e605.x);
                    let _e613 = dir_4;
                    let _e616 = dir_4;
                    let _e619 = _o_ratio_1;
                    let _e622 = dir_4;
                    let _e625 = dir_4;
                    let _e628 = _o_ratio_1;
                    if ((abs(_e613.y) > (abs(_e616.z) * _e619)) && (abs(_e622.y) > (abs(_e625.x) * _e628))) {
                        {
                            let _e632 = _o_X_1;
                            let _e633 = dir_4;
                            let _e636 = dir_4;
                            _o_X_1 = (_e632 + ((-(_e633.x) / _e636.y) * 0.5f));
                            let _e642 = _o_Y_1;
                            let _e643 = dir_4;
                            let _e646 = dir_4;
                            _o_Y_1 = (_e642 + ((-(_e643.z) / _e646.y) * 0.5f));
                        }
                    } else {
                        let _e652 = dir_4;
                        let _e655 = dir_4;
                        if (abs(_e652.x) < abs(_e655.z)) {
                            {
                                let _e659 = _o_X_1;
                                let _e660 = dir_4;
                                let _e662 = dir_4;
                                let _e666 = _o_ratio_1;
                                let _e670 = dir_4;
                                _o_X_1 = (_e659 + ((((_e660.x / abs(_e662.z)) * _e666) * 0.5f) * -(sign(_e670.z))));
                                let _e676 = _o_Y_1;
                                let _e677 = dir_4;
                                let _e679 = dir_4;
                                _o_Y_1 = (_e676 + ((_e677.y / abs(_e679.z)) * 0.5f));
                            }
                        } else {
                            {
                                let _e686 = _o_X_1;
                                let _e687 = dir_4;
                                let _e689 = dir_4;
                                let _e693 = _o_ratio_1;
                                let _e697 = dir_4;
                                _o_X_1 = (_e686 + ((((_e687.z / abs(_e689.x)) * _e693) * 0.5f) * -(sign(_e697.x))));
                                let _e703 = _o_Y_1;
                                let _e704 = dir_4;
                                let _e706 = dir_4;
                                _o_Y_1 = (_e703 + ((_e704.y / abs(_e706.x)) * 0.5f));
                            }
                        }
                    }
                    let _e713 = _o_X_1;
                    let _e714 = _o_Y_1;
                    let _e724 = global.U[0];
                    let _e727 = _o_X_1;
                    let _e728 = _o_Y_1;
                    let _e744 = textureSampleLevel(t_source, samp, ((vec2<f32>((((vec2<f32>(_e713, _e714) * 2f) - vec2(1f)).x / _e724.x), ((vec2<f32>(_e727, _e728) * 2f) - vec2(1f)).y) / vec2(2f)) + vec2(0.5f)), 0f);
                    _bkg = _e744;
                }
            } else {
                {
                    let _e745 = dir_4;
                    let _e750 = ((_e745 * 0.5f) + vec3(0.5f));
                    _bkg = vec4<f32>(_e750.x, _e750.y, _e750.z, 1f);
                }
            }
        }
    }
    let _e756 = reflectedColor;
    let _e757 = _bkg;
    let _e758 = incidence;
    let _e759 = balance;
    mixedCol = mix(_e756, _e757, vec4(clamp((_e758 + _e759), 0f, 1f)));
    let _e767 = objectIntersected;
    if _e767 {
        let _e768 = mixedCol;
        let _e769 = mixedCol;
        let _e771 = objectColor_1;
        let _e773 = (2f * _e771.xyz);
        let _e780 = objectColor_1;
        mixedCol = mix(_e768, (_e769 * vec4<f32>(_e773.x, _e773.y, _e773.z, 1f)), vec4(_e780.w));
    } else {
        let _e784 = mixedCol;
        let _e785 = mixedCol;
        let _e787 = bkgColor_1;
        let _e789 = (2f * _e787.xyz);
        let _e796 = bkgColor_1;
        mixedCol = mix(_e784, (_e785 * vec4<f32>(_e789.x, _e789.y, _e789.z, 1f)), vec4(_e796.w));
    }
    let _e801 = minDist_1;
    let _e802 = minDist_1;
    glowIntensity = (1.4f / pow(_e801, clamp(_e802, 1f, 3f)));
    let _e809 = mixedCol;
    let _e810 = glowColor_1;
    let _e812 = glowIntensity;
    let _e813 = (_e810.xyz * _e812);
    let _e819 = glowColor_1;
    glowCol = (_e809 + (vec4<f32>(_e813.x, _e813.y, _e813.z, 0f) * _e819.w));
    let _e824 = glowCol;
    return _e824;
}

fn main_1() {
    let _e10 = global.U[1];
    let _e11 = _e10.xyz;
    let _e14 = global.U[2];
    let _e15 = _e14.xyz;
    let _e18 = global.U[3];
    let _e19 = _e18.xyz;
    let _e34 = v_uv_1;
    let _e42 = global.U[0];
    let _e46 = (((_e34 - vec2(0.5f)) * 2f) * vec2<f32>(_e42.x, 1f));
    let _e53 = v_uv_1;
    let _e61 = global.U[0];
    let _e68 = global.U[6];
    let _e71 = global.U[7];
    let _e74 = global.U[8];
    let _e77 = global.U[9];
    let _e101 = global.U[4];
    let _e105 = global.U[10];
    let _e109 = global.U[11];
    let _e113 = global.U[12];
    let _e116 = global.U[13];
    let _e119 = global.U[14];
    let _e122 = global.U[15];
    let _e127 = global.U[16];
    let _e130 = metaballs3d((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e11.x, _e11.y, _e11.z), vec3<f32>(_e15.x, _e15.y, _e15.z), vec3<f32>(_e19.x, _e19.y, _e19.z))) * vec3<f32>(_e46.x, _e46.y, 1f)).xy, (((_e53 - vec2(0.5f)) * 2f) * vec2<f32>(_e61.x, 1f)), mat4x4<f32>(vec4<f32>(_e68.x, _e68.y, _e68.z, _e68.w), vec4<f32>(_e71.x, _e71.y, _e71.z, _e71.w), vec4<f32>(_e74.x, _e74.y, _e74.z, _e74.w), vec4<f32>(_e77.x, _e77.y, _e77.z, _e77.w)), _e101.xy, _e105.x, _e109.x, _e113, _e116, _e119, i32(_e122.x), i32(_e127.x));
    fragColor = _e130;
    return;
}

@fragment 
fn main(@location(0) v_uv: vec2<f32>) -> FragmentOutput {
    v_uv_1 = v_uv;
    main_1();
    let _e15 = fragColor;
    return FragmentOutput(_e15);
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
