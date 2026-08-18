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
                                    let _e242 = textureSample(t_source, samp, ((vec2<f32>((_e226.x / _e230.x), _e233.y) / vec2(2f)) + vec2(0.5f)));
                                    _reflBkg = _e242;
                                }
                            } else {
                                let _e243 = backgroundStyle_1;
                                if (_e243 == 1i) {
                                    {
                                        let _e246 = reflectedDir;
                                        let _e249 = reflectedDir;
                                        let _e252 = reflectedDir;
                                        let _e255 = reflectedDir;
                                        _o_pos_1 = vec2<f32>((-(_e246.x) / _e249.z), (-(_e252.y) / _e255.z));
                                        let _e260 = _o_pos_1;
                                        let _e263 = _o_pos_1;
                                        _o_m = max(abs(_e260.x), abs(_e263.y));
                                        let _e270 = _o_m;
                                        _o_darken = (4f / max(4f, _e270));
                                        let _e274 = _o_pos_1;
                                        let _e278 = global.U[0];
                                        let _e281 = _o_pos_1;
                                        let _e290 = textureSample(t_source, samp, ((vec2<f32>((_e274.x / _e278.x), _e281.y) / vec2(2f)) + vec2(0.5f)));
                                        let _e291 = _o_darken;
                                        let _e292 = _o_darken;
                                        let _e293 = _o_darken;
                                        _reflBkg = (_e290 * vec4<f32>(_e291, _e292, _e293, 1f));
                                    }
                                } else {
                                    let _e297 = backgroundStyle_1;
                                    if (_e297 == 2i) {
                                        {
                                            let _e300 = sourceDim_1;
                                            let _e302 = sourceDim_1;
                                            _o_ratio = (_e300.y / _e302.x);
                                            _o_X = 0.5f;
                                            _o_Y = 0.5f;
                                            let _e310 = reflectedDir;
                                            let _e313 = reflectedDir;
                                            let _e316 = _o_ratio;
                                            let _e319 = reflectedDir;
                                            let _e322 = reflectedDir;
                                            let _e325 = _o_ratio;
                                            if ((abs(_e310.y) > (abs(_e313.z) * _e316)) && (abs(_e319.y) > (abs(_e322.x) * _e325))) {
                                                {
                                                    let _e329 = _o_X;
                                                    let _e330 = reflectedDir;
                                                    let _e333 = reflectedDir;
                                                    _o_X = (_e329 + ((-(_e330.x) / _e333.y) * 0.5f));
                                                    let _e339 = _o_Y;
                                                    let _e340 = reflectedDir;
                                                    let _e343 = reflectedDir;
                                                    _o_Y = (_e339 + ((-(_e340.z) / _e343.y) * 0.5f));
                                                }
                                            } else {
                                                let _e349 = reflectedDir;
                                                let _e352 = reflectedDir;
                                                if (abs(_e349.x) < abs(_e352.z)) {
                                                    {
                                                        let _e356 = _o_X;
                                                        let _e357 = reflectedDir;
                                                        let _e359 = reflectedDir;
                                                        let _e363 = _o_ratio;
                                                        let _e367 = reflectedDir;
                                                        _o_X = (_e356 + ((((_e357.x / abs(_e359.z)) * _e363) * 0.5f) * -(sign(_e367.z))));
                                                        let _e373 = _o_Y;
                                                        let _e374 = reflectedDir;
                                                        let _e376 = reflectedDir;
                                                        _o_Y = (_e373 + ((_e374.y / abs(_e376.z)) * 0.5f));
                                                    }
                                                } else {
                                                    {
                                                        let _e383 = _o_X;
                                                        let _e384 = reflectedDir;
                                                        let _e386 = reflectedDir;
                                                        let _e390 = _o_ratio;
                                                        let _e394 = reflectedDir;
                                                        _o_X = (_e383 + ((((_e384.z / abs(_e386.x)) * _e390) * 0.5f) * -(sign(_e394.x))));
                                                        let _e400 = _o_Y;
                                                        let _e401 = reflectedDir;
                                                        let _e403 = reflectedDir;
                                                        _o_Y = (_e400 + ((_e401.y / abs(_e403.x)) * 0.5f));
                                                    }
                                                }
                                            }
                                            let _e410 = _o_X;
                                            let _e411 = _o_Y;
                                            let _e421 = global.U[0];
                                            let _e424 = _o_X;
                                            let _e425 = _o_Y;
                                            let _e440 = textureSample(t_source, samp, ((vec2<f32>((((vec2<f32>(_e410, _e411) * 2f) - vec2(1f)).x / _e421.x), ((vec2<f32>(_e424, _e425) * 2f) - vec2(1f)).y) / vec2(2f)) + vec2(0.5f)));
                                            _reflBkg = _e440;
                                        }
                                    } else {
                                        {
                                            let _e441 = reflectedDir;
                                            let _e446 = ((_e441 * 0.5f) + vec3(0.5f));
                                            _reflBkg = vec4<f32>(_e446.x, _e446.y, _e446.z, 1f);
                                        }
                                    }
                                }
                            }
                            let _e452 = _reflBkg;
                            reflectedColor = _e452;
                        }
                    }
                    let _e453 = dir_4;
                    let _e454 = normal;
                    let _e455 = eta;
                    dir_4 = refract(_e453, _e454, _e455);
                    let _e457 = intersection;
                    let _e458 = dir_4;
                    origin_4 = (_e457 + (_e458 * 0.001f));
                }
            }
            let _e462 = iter_1;
            iter_1 = (_e462 - 1i);
        }
        let _e465 = minI;
        let _e468 = iter_1;
        if !(((_e465 >= 0i) && (_e468 > 0i))) {
            break;
        }
    }
    let _e475 = reflectivity_1;
    balance = (1f - (2f * _e475));
    let _e482 = backgroundStyle_1;
    if (_e482 == 0i) {
        {
            let _e485 = dir_4;
            _o_n_1 = normalize(_e485);
            let _e488 = _o_n_1;
            let _e490 = _o_n_1;
            _o_alpha_1 = atan2(_e488.z, _e490.x);
            let _e494 = _o_n_1;
            _o_beta_1 = asin(_e494.y);
            let _e502 = _o_alpha_1;
            let _e508 = _o_nX_1;
            let _e511 = _o_nY_1;
            let _e512 = _o_beta_1;
            _o_pos_2 = ((vec2<f32>((((-(_e502) / 3.1415927f) * 0.5f) * _e508), (0.5f + ((_e511 * _e512) / 3.1415927f))) * 2f) - vec2(1f));
            let _e524 = _o_pos_2;
            let _e528 = global.U[0];
            let _e531 = _o_pos_2;
            let _e540 = textureSample(t_source, samp, ((vec2<f32>((_e524.x / _e528.x), _e531.y) / vec2(2f)) + vec2(0.5f)));
            _bkg = _e540;
        }
    } else {
        let _e541 = backgroundStyle_1;
        if (_e541 == 1i) {
            {
                let _e544 = dir_4;
                let _e547 = dir_4;
                let _e550 = dir_4;
                let _e553 = dir_4;
                _o_pos_3 = vec2<f32>((-(_e544.x) / _e547.z), (-(_e550.y) / _e553.z));
                let _e558 = _o_pos_3;
                let _e561 = _o_pos_3;
                _o_m_1 = max(abs(_e558.x), abs(_e561.y));
                let _e568 = _o_m_1;
                _o_darken_1 = (4f / max(4f, _e568));
                let _e572 = _o_pos_3;
                let _e576 = global.U[0];
                let _e579 = _o_pos_3;
                let _e588 = textureSample(t_source, samp, ((vec2<f32>((_e572.x / _e576.x), _e579.y) / vec2(2f)) + vec2(0.5f)));
                let _e589 = _o_darken_1;
                let _e590 = _o_darken_1;
                let _e591 = _o_darken_1;
                _bkg = (_e588 * vec4<f32>(_e589, _e590, _e591, 1f));
            }
        } else {
            let _e595 = backgroundStyle_1;
            if (_e595 == 2i) {
                {
                    let _e598 = sourceDim_1;
                    let _e600 = sourceDim_1;
                    _o_ratio_1 = (_e598.y / _e600.x);
                    let _e608 = dir_4;
                    let _e611 = dir_4;
                    let _e614 = _o_ratio_1;
                    let _e617 = dir_4;
                    let _e620 = dir_4;
                    let _e623 = _o_ratio_1;
                    if ((abs(_e608.y) > (abs(_e611.z) * _e614)) && (abs(_e617.y) > (abs(_e620.x) * _e623))) {
                        {
                            let _e627 = _o_X_1;
                            let _e628 = dir_4;
                            let _e631 = dir_4;
                            _o_X_1 = (_e627 + ((-(_e628.x) / _e631.y) * 0.5f));
                            let _e637 = _o_Y_1;
                            let _e638 = dir_4;
                            let _e641 = dir_4;
                            _o_Y_1 = (_e637 + ((-(_e638.z) / _e641.y) * 0.5f));
                        }
                    } else {
                        let _e647 = dir_4;
                        let _e650 = dir_4;
                        if (abs(_e647.x) < abs(_e650.z)) {
                            {
                                let _e654 = _o_X_1;
                                let _e655 = dir_4;
                                let _e657 = dir_4;
                                let _e661 = _o_ratio_1;
                                let _e665 = dir_4;
                                _o_X_1 = (_e654 + ((((_e655.x / abs(_e657.z)) * _e661) * 0.5f) * -(sign(_e665.z))));
                                let _e671 = _o_Y_1;
                                let _e672 = dir_4;
                                let _e674 = dir_4;
                                _o_Y_1 = (_e671 + ((_e672.y / abs(_e674.z)) * 0.5f));
                            }
                        } else {
                            {
                                let _e681 = _o_X_1;
                                let _e682 = dir_4;
                                let _e684 = dir_4;
                                let _e688 = _o_ratio_1;
                                let _e692 = dir_4;
                                _o_X_1 = (_e681 + ((((_e682.z / abs(_e684.x)) * _e688) * 0.5f) * -(sign(_e692.x))));
                                let _e698 = _o_Y_1;
                                let _e699 = dir_4;
                                let _e701 = dir_4;
                                _o_Y_1 = (_e698 + ((_e699.y / abs(_e701.x)) * 0.5f));
                            }
                        }
                    }
                    let _e708 = _o_X_1;
                    let _e709 = _o_Y_1;
                    let _e719 = global.U[0];
                    let _e722 = _o_X_1;
                    let _e723 = _o_Y_1;
                    let _e738 = textureSample(t_source, samp, ((vec2<f32>((((vec2<f32>(_e708, _e709) * 2f) - vec2(1f)).x / _e719.x), ((vec2<f32>(_e722, _e723) * 2f) - vec2(1f)).y) / vec2(2f)) + vec2(0.5f)));
                    _bkg = _e738;
                }
            } else {
                {
                    let _e739 = dir_4;
                    let _e744 = ((_e739 * 0.5f) + vec3(0.5f));
                    _bkg = vec4<f32>(_e744.x, _e744.y, _e744.z, 1f);
                }
            }
        }
    }
    let _e750 = reflectedColor;
    let _e751 = _bkg;
    let _e752 = incidence;
    let _e753 = balance;
    mixedCol = mix(_e750, _e751, vec4(clamp((_e752 + _e753), 0f, 1f)));
    let _e761 = objectIntersected;
    if _e761 {
        let _e762 = mixedCol;
        let _e763 = mixedCol;
        let _e765 = objectColor_1;
        let _e767 = (2f * _e765.xyz);
        let _e774 = objectColor_1;
        mixedCol = mix(_e762, (_e763 * vec4<f32>(_e767.x, _e767.y, _e767.z, 1f)), vec4(_e774.w));
    } else {
        let _e778 = mixedCol;
        let _e779 = mixedCol;
        let _e781 = bkgColor_1;
        let _e783 = (2f * _e781.xyz);
        let _e790 = bkgColor_1;
        mixedCol = mix(_e778, (_e779 * vec4<f32>(_e783.x, _e783.y, _e783.z, 1f)), vec4(_e790.w));
    }
    let _e795 = minDist_1;
    let _e796 = minDist_1;
    glowIntensity = (1.4f / pow(_e795, clamp(_e796, 1f, 3f)));
    let _e803 = mixedCol;
    let _e804 = glowColor_1;
    let _e806 = glowIntensity;
    let _e807 = (_e804.xyz * _e806);
    let _e813 = glowColor_1;
    glowCol = (_e803 + (vec4<f32>(_e807.x, _e807.y, _e807.z, 0f) * _e813.w));
    let _e818 = glowCol;
    return _e818;
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
