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

fn metaballsBoundingSphereK(center: vec3<f32>, radius: f32, origin: vec3<f32>, dir: vec3<f32>) -> vec2<f32> {
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
            let _e87 = l;
            if (_e87 > 0f) {
                let _e91 = l1_;
                let _e93 = l2_;
                return vec2<f32>(max(0f, _e91), _e93);
            }
        }
    }
    return vec2<f32>(-1f, -1f);
}

fn metaballsImplicitFn(p: vec3<f32>, spheres_size: i32) -> f32 {
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

fn metaballsGetIntersectionD(origin_2: vec3<f32>, dir_2: vec3<f32>, sphereRad: f32, spheres_size_2: i32) -> vec3<f32> {
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
    var maxIter: i32 = 100i;
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
    let _e23 = metaballsBoundingSphereK(vec3(0f), _e20, _e21, _e22);
    kBounds = _e23;
    let _e25 = kBounds;
    if (_e25.x < 0f) {
        let _e32 = minDist;
        return vec3<f32>(-1f, 0f, _e32);
    }
    let _e35 = kBounds;
    k0_ = max(0f, _e35.x);
    let _e39 = k0_;
    k1_ = _e39;
    let _e41 = origin_3;
    let _e42 = spheres_size_3;
    let _e43 = metaballsImplicitFn(_e41, _e42);
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
    let _e65 = metaballsImplicitFn(_e63, _e64);
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
            let _e82 = metaballsImplicitFn(_e80, _e81);
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
        let _e113 = maxIter;
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
            let _e155 = metaballsImplicitFn(_e153, _e154);
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

fn metaballsNormal(p_2: vec3<f32>, spheres_size_4: i32) -> vec3<f32> {
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
    let _e28 = metaballsImplicitFn(vec3<f32>((_e18.x - _e20), _e22.y, _e24.z), _e27);
    let _e29 = p_3;
    let _e31 = d;
    let _e33 = p_3;
    let _e35 = p_3;
    let _e38 = spheres_size_5;
    let _e39 = metaballsImplicitFn(vec3<f32>((_e29.x + _e31), _e33.y, _e35.z), _e38);
    let _e41 = d2_;
    let _e43 = p_3;
    let _e45 = p_3;
    let _e47 = d;
    let _e49 = p_3;
    let _e52 = spheres_size_5;
    let _e53 = metaballsImplicitFn(vec3<f32>(_e43.x, (_e45.y - _e47), _e49.z), _e52);
    let _e54 = p_3;
    let _e56 = p_3;
    let _e58 = d;
    let _e60 = p_3;
    let _e63 = spheres_size_5;
    let _e64 = metaballsImplicitFn(vec3<f32>(_e54.x, (_e56.y + _e58), _e60.z), _e63);
    let _e66 = d2_;
    let _e68 = p_3;
    let _e70 = p_3;
    let _e72 = p_3;
    let _e74 = d;
    let _e77 = spheres_size_5;
    let _e78 = metaballsImplicitFn(vec3<f32>(_e68.x, _e70.y, (_e72.z - _e74)), _e77);
    let _e79 = p_3;
    let _e81 = p_3;
    let _e83 = p_3;
    let _e85 = d;
    let _e88 = spheres_size_5;
    let _e89 = metaballsImplicitFn(vec3<f32>(_e79.x, _e81.y, (_e83.z + _e85)), _e88);
    let _e91 = d2_;
    return normalize(vec3<f32>(((_e28 - _e39) / _e41), ((_e53 - _e64) / _e66), ((_e78 - _e89) / _e91)));
}

fn metaballsGl(pos: vec2<f32>, outPos: vec2<f32>, model3DTransform: mat4x4<f32>, sourceDim: vec2<f32>, intensity: f32, reflectivity: f32, objectColor: vec4<f32>, glowColor: vec4<f32>, bkgColor: vec4<f32>, backgroundStyle: i32, spheres_size_6: i32) -> vec4<f32> {
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
    var local_2: f32;
    var sphereRad_2: f32;
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
    var k: f32;
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
    var glowIntensity: f32;

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
    let _e75 = glowColor_1;
    let _e79 = glowColor_1;
    let _e84 = glowColor_1;
    if (((_e75.x == 0f) && (_e79.y == 0f)) && (_e84.z == 0f)) {
        local_2 = 2.5f;
    } else {
        local_2 = 5f;
    }
    let _e92 = local_2;
    sphereRad_2 = _e92;
    let _e94 = cameraPos;
    origin_4 = _e94;
    let _e98 = maxIter_1;
    iter_1 = _e98;
    loop {
        {
            minK = 1000000f;
            minI = -1i;
            let _e120 = origin_4;
            let _e121 = dir_4;
            let _e122 = sphereRad_2;
            let _e123 = spheres_size_7;
            let _e124 = metaballsGetIntersectionD(_e120, _e121, _e122, _e123);
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
                let _e140 = maxIter_1;
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
                    let _e157 = metaballsImplicitFn(_e155, _e156);
                    if (_e157 <= 0f) {
                        let _e160 = intersection;
                        let _e161 = spheres_size_7;
                        let _e162 = metaballsNormal(_e160, _e161);
                        local_3 = _e162;
                    } else {
                        let _e163 = intersection;
                        let _e164 = spheres_size_7;
                        let _e165 = metaballsNormal(_e163, _e164);
                        local_3 = -(_e165);
                    }
                    let _e168 = local_3;
                    normal = _e168;
                    let _e170 = iter_1;
                    let _e171 = maxIter_1;
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
                                    let _e200 = _o_alpha;
                                    let _e207 = _o_beta;
                                    let _e215 = global.U[0];
                                    let _e218 = _o_alpha;
                                    let _e225 = _o_beta;
                                    let _e238 = textureSample(t_source, samp, ((vec2<f32>((vec2<f32>(((-(_e200) / 3.1415927f) * 2f), ((2f * _e207) / 3.1415927f)).x / _e215.x), vec2<f32>(((-(_e218) / 3.1415927f) * 2f), ((2f * _e225) / 3.1415927f)).y) / vec2(2f)) + vec2(0.5f)));
                                    _reflBkg = _e238;
                                }
                            } else {
                                let _e239 = backgroundStyle_1;
                                if (_e239 == 1i) {
                                    {
                                        let _e242 = reflectedDir;
                                        let _e245 = reflectedDir;
                                        let _e248 = reflectedDir;
                                        let _e251 = reflectedDir;
                                        _o_pos = vec2<f32>((-(_e242.x) / _e245.z), (-(_e248.y) / _e251.z));
                                        let _e256 = _o_pos;
                                        let _e259 = _o_pos;
                                        _o_m = max(abs(_e256.x), abs(_e259.y));
                                        let _e266 = _o_m;
                                        _o_darken = (4f / max(4f, _e266));
                                        let _e270 = _o_pos;
                                        let _e274 = global.U[0];
                                        let _e277 = _o_pos;
                                        let _e286 = textureSample(t_source, samp, ((vec2<f32>((_e270.x / _e274.x), _e277.y) / vec2(2f)) + vec2(0.5f)));
                                        let _e287 = _o_darken;
                                        let _e288 = _o_darken;
                                        let _e289 = _o_darken;
                                        _reflBkg = (_e286 * vec4<f32>(_e287, _e288, _e289, 1f));
                                    }
                                } else {
                                    let _e293 = backgroundStyle_1;
                                    if (_e293 == 2i) {
                                        {
                                            let _e296 = sourceDim_1;
                                            let _e298 = sourceDim_1;
                                            _o_ratio = (_e296.y / _e298.x);
                                            _o_X = 0.5f;
                                            _o_Y = 0.5f;
                                            let _e306 = reflectedDir;
                                            let _e309 = reflectedDir;
                                            let _e312 = _o_ratio;
                                            let _e315 = reflectedDir;
                                            let _e318 = reflectedDir;
                                            let _e321 = _o_ratio;
                                            if ((abs(_e306.y) > (abs(_e309.z) * _e312)) && (abs(_e315.y) > (abs(_e318.x) * _e321))) {
                                                {
                                                    let _e325 = _o_X;
                                                    let _e326 = reflectedDir;
                                                    let _e329 = reflectedDir;
                                                    _o_X = (_e325 + ((-(_e326.x) / _e329.y) * 0.5f));
                                                    let _e335 = _o_Y;
                                                    let _e336 = reflectedDir;
                                                    let _e339 = reflectedDir;
                                                    _o_Y = (_e335 + ((-(_e336.z) / _e339.y) * 0.5f));
                                                }
                                            } else {
                                                let _e345 = reflectedDir;
                                                let _e348 = reflectedDir;
                                                if (abs(_e345.x) < abs(_e348.z)) {
                                                    {
                                                        let _e352 = _o_X;
                                                        let _e353 = reflectedDir;
                                                        let _e355 = reflectedDir;
                                                        let _e359 = _o_ratio;
                                                        let _e363 = reflectedDir;
                                                        _o_X = (_e352 + ((((_e353.x / abs(_e355.z)) * _e359) * 0.5f) * -(sign(_e363.z))));
                                                        let _e369 = _o_Y;
                                                        let _e370 = reflectedDir;
                                                        let _e372 = reflectedDir;
                                                        _o_Y = (_e369 + ((_e370.y / abs(_e372.z)) * 0.5f));
                                                    }
                                                } else {
                                                    {
                                                        let _e379 = _o_X;
                                                        let _e380 = reflectedDir;
                                                        let _e382 = reflectedDir;
                                                        let _e386 = _o_ratio;
                                                        let _e390 = reflectedDir;
                                                        _o_X = (_e379 + ((((_e380.z / abs(_e382.x)) * _e386) * 0.5f) * -(sign(_e390.x))));
                                                        let _e396 = _o_Y;
                                                        let _e397 = reflectedDir;
                                                        let _e399 = reflectedDir;
                                                        _o_Y = (_e396 + ((_e397.y / abs(_e399.x)) * 0.5f));
                                                    }
                                                }
                                            }
                                            let _e406 = _o_X;
                                            let _e407 = _o_Y;
                                            let _e417 = global.U[0];
                                            let _e420 = _o_X;
                                            let _e421 = _o_Y;
                                            let _e436 = textureSample(t_source, samp, ((vec2<f32>((((vec2<f32>(_e406, _e407) * 2f) - vec2(1f)).x / _e417.x), ((vec2<f32>(_e420, _e421) * 2f) - vec2(1f)).y) / vec2(2f)) + vec2(0.5f)));
                                            _reflBkg = _e436;
                                        }
                                    } else {
                                        {
                                            let _e437 = reflectedDir;
                                            let _e442 = ((_e437 * 0.5f) + vec3(0.5f));
                                            _reflBkg = vec4<f32>(_e442.x, _e442.y, _e442.z, 1f);
                                        }
                                    }
                                }
                            }
                            let _e448 = _reflBkg;
                            reflectedColor = _e448;
                        }
                    }
                    let _e449 = dir_4;
                    let _e450 = normal;
                    let _e451 = eta;
                    dir_4 = refract(_e449, _e450, _e451);
                    let _e453 = intersection;
                    let _e454 = dir_4;
                    origin_4 = (_e453 + (_e454 * 0.001f));
                }
            }
            let _e458 = iter_1;
            iter_1 = (_e458 - 1i);
        }
        let _e461 = minI;
        let _e464 = iter_1;
        if !(((_e461 >= 0i) && (_e464 > 0i))) {
            break;
        }
    }
    let _e471 = reflectivity_1;
    balance = (1f - (2f * _e471));
    let _e478 = backgroundStyle_1;
    if (_e478 == 0i) {
        {
            let _e481 = dir_4;
            _o_n_1 = normalize(_e481);
            let _e484 = _o_n_1;
            let _e486 = _o_n_1;
            _o_alpha_1 = atan2(_e484.z, _e486.x);
            let _e490 = _o_n_1;
            _o_beta_1 = asin(_e490.y);
            let _e494 = _o_alpha_1;
            let _e501 = _o_beta_1;
            let _e509 = global.U[0];
            let _e512 = _o_alpha_1;
            let _e519 = _o_beta_1;
            let _e532 = textureSample(t_source, samp, ((vec2<f32>((vec2<f32>(((-(_e494) / 3.1415927f) * 2f), ((2f * _e501) / 3.1415927f)).x / _e509.x), vec2<f32>(((-(_e512) / 3.1415927f) * 2f), ((2f * _e519) / 3.1415927f)).y) / vec2(2f)) + vec2(0.5f)));
            _bkg = _e532;
        }
    } else {
        let _e533 = backgroundStyle_1;
        if (_e533 == 1i) {
            {
                let _e536 = dir_4;
                let _e539 = dir_4;
                let _e542 = dir_4;
                let _e545 = dir_4;
                _o_pos_1 = vec2<f32>((-(_e536.x) / _e539.z), (-(_e542.y) / _e545.z));
                let _e550 = _o_pos_1;
                let _e553 = _o_pos_1;
                _o_m_1 = max(abs(_e550.x), abs(_e553.y));
                let _e560 = _o_m_1;
                _o_darken_1 = (4f / max(4f, _e560));
                let _e564 = _o_pos_1;
                let _e568 = global.U[0];
                let _e571 = _o_pos_1;
                let _e580 = textureSample(t_source, samp, ((vec2<f32>((_e564.x / _e568.x), _e571.y) / vec2(2f)) + vec2(0.5f)));
                let _e581 = _o_darken_1;
                let _e582 = _o_darken_1;
                let _e583 = _o_darken_1;
                _bkg = (_e580 * vec4<f32>(_e581, _e582, _e583, 1f));
            }
        } else {
            let _e587 = backgroundStyle_1;
            if (_e587 == 2i) {
                {
                    let _e590 = sourceDim_1;
                    let _e592 = sourceDim_1;
                    _o_ratio_1 = (_e590.y / _e592.x);
                    let _e600 = dir_4;
                    let _e603 = dir_4;
                    let _e606 = _o_ratio_1;
                    let _e609 = dir_4;
                    let _e612 = dir_4;
                    let _e615 = _o_ratio_1;
                    if ((abs(_e600.y) > (abs(_e603.z) * _e606)) && (abs(_e609.y) > (abs(_e612.x) * _e615))) {
                        {
                            let _e619 = _o_X_1;
                            let _e620 = dir_4;
                            let _e623 = dir_4;
                            _o_X_1 = (_e619 + ((-(_e620.x) / _e623.y) * 0.5f));
                            let _e629 = _o_Y_1;
                            let _e630 = dir_4;
                            let _e633 = dir_4;
                            _o_Y_1 = (_e629 + ((-(_e630.z) / _e633.y) * 0.5f));
                        }
                    } else {
                        let _e639 = dir_4;
                        let _e642 = dir_4;
                        if (abs(_e639.x) < abs(_e642.z)) {
                            {
                                let _e646 = _o_X_1;
                                let _e647 = dir_4;
                                let _e649 = dir_4;
                                let _e653 = _o_ratio_1;
                                let _e657 = dir_4;
                                _o_X_1 = (_e646 + ((((_e647.x / abs(_e649.z)) * _e653) * 0.5f) * -(sign(_e657.z))));
                                let _e663 = _o_Y_1;
                                let _e664 = dir_4;
                                let _e666 = dir_4;
                                _o_Y_1 = (_e663 + ((_e664.y / abs(_e666.z)) * 0.5f));
                            }
                        } else {
                            {
                                let _e673 = _o_X_1;
                                let _e674 = dir_4;
                                let _e676 = dir_4;
                                let _e680 = _o_ratio_1;
                                let _e684 = dir_4;
                                _o_X_1 = (_e673 + ((((_e674.z / abs(_e676.x)) * _e680) * 0.5f) * -(sign(_e684.x))));
                                let _e690 = _o_Y_1;
                                let _e691 = dir_4;
                                let _e693 = dir_4;
                                _o_Y_1 = (_e690 + ((_e691.y / abs(_e693.x)) * 0.5f));
                            }
                        }
                    }
                    let _e700 = _o_X_1;
                    let _e701 = _o_Y_1;
                    let _e711 = global.U[0];
                    let _e714 = _o_X_1;
                    let _e715 = _o_Y_1;
                    let _e730 = textureSample(t_source, samp, ((vec2<f32>((((vec2<f32>(_e700, _e701) * 2f) - vec2(1f)).x / _e711.x), ((vec2<f32>(_e714, _e715) * 2f) - vec2(1f)).y) / vec2(2f)) + vec2(0.5f)));
                    _bkg = _e730;
                }
            } else {
                {
                    let _e731 = dir_4;
                    let _e736 = ((_e731 * 0.5f) + vec3(0.5f));
                    _bkg = vec4<f32>(_e736.x, _e736.y, _e736.z, 1f);
                }
            }
        }
    }
    let _e742 = reflectedColor;
    let _e743 = _bkg;
    let _e744 = incidence;
    let _e745 = balance;
    mixedCol = mix(_e742, _e743, vec4(clamp((_e744 + _e745), 0f, 1f)));
    let _e753 = objectIntersected;
    if _e753 {
        let _e754 = mixedCol;
        let _e755 = mixedCol;
        let _e757 = objectColor_1;
        let _e759 = (2f * _e757.xyz);
        let _e766 = objectColor_1;
        mixedCol = mix(_e754, (_e755 * vec4<f32>(_e759.x, _e759.y, _e759.z, 1f)), vec4(_e766.w));
    } else {
        let _e770 = mixedCol;
        let _e771 = mixedCol;
        let _e773 = bkgColor_1;
        let _e775 = (2f * _e773.xyz);
        let _e782 = bkgColor_1;
        mixedCol = mix(_e770, (_e771 * vec4<f32>(_e775.x, _e775.y, _e775.z, 1f)), vec4(_e782.w));
    }
    let _e787 = minDist_1;
    let _e788 = minDist_1;
    glowIntensity = (1.4f / pow(_e787, clamp(_e788, 1f, 3f)));
    let _e795 = mixedCol;
    let _e796 = glowColor_1;
    let _e798 = glowIntensity;
    let _e799 = (_e796.xyz * _e798);
    let _e805 = glowColor_1;
    return (_e795 + (vec4<f32>(_e799.x, _e799.y, _e799.z, 0f) * _e805.w));
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
    let _e130 = metaballsGl((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e11.x, _e11.y, _e11.z), vec3<f32>(_e15.x, _e15.y, _e15.z), vec3<f32>(_e19.x, _e19.y, _e19.z))) * vec3<f32>(_e46.x, _e46.y, 1f)).xy, (((_e53 - vec2(0.5f)) * 2f) * vec2<f32>(_e61.x, 1f)), mat4x4<f32>(vec4<f32>(_e68.x, _e68.y, _e68.z, _e68.w), vec4<f32>(_e71.x, _e71.y, _e71.z, _e71.w), vec4<f32>(_e74.x, _e74.y, _e74.z, _e74.w), vec4<f32>(_e77.x, _e77.y, _e77.z, _e77.w)), _e101.xy, _e105.x, _e109.x, _e113, _e116, _e119, i32(_e122.x), i32(_e127.x));
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
