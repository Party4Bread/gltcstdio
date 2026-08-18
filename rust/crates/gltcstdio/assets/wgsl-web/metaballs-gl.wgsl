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
                                    let _e239 = textureSampleLevel(t_source, samp, ((vec2<f32>((vec2<f32>(((-(_e200) / 3.1415927f) * 2f), ((2f * _e207) / 3.1415927f)).x / _e215.x), vec2<f32>(((-(_e218) / 3.1415927f) * 2f), ((2f * _e225) / 3.1415927f)).y) / vec2(2f)) + vec2(0.5f)), 0f);
                                    _reflBkg = _e239;
                                }
                            } else {
                                let _e240 = backgroundStyle_1;
                                if (_e240 == 1i) {
                                    {
                                        let _e243 = reflectedDir;
                                        let _e246 = reflectedDir;
                                        let _e249 = reflectedDir;
                                        let _e252 = reflectedDir;
                                        _o_pos = vec2<f32>((-(_e243.x) / _e246.z), (-(_e249.y) / _e252.z));
                                        let _e257 = _o_pos;
                                        let _e260 = _o_pos;
                                        _o_m = max(abs(_e257.x), abs(_e260.y));
                                        let _e267 = _o_m;
                                        _o_darken = (4f / max(4f, _e267));
                                        let _e271 = _o_pos;
                                        let _e275 = global.U[0];
                                        let _e278 = _o_pos;
                                        let _e288 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e271.x / _e275.x), _e278.y) / vec2(2f)) + vec2(0.5f)), 0f);
                                        let _e289 = _o_darken;
                                        let _e290 = _o_darken;
                                        let _e291 = _o_darken;
                                        _reflBkg = (_e288 * vec4<f32>(_e289, _e290, _e291, 1f));
                                    }
                                } else {
                                    let _e295 = backgroundStyle_1;
                                    if (_e295 == 2i) {
                                        {
                                            let _e298 = sourceDim_1;
                                            let _e300 = sourceDim_1;
                                            _o_ratio = (_e298.y / _e300.x);
                                            _o_X = 0.5f;
                                            _o_Y = 0.5f;
                                            let _e308 = reflectedDir;
                                            let _e311 = reflectedDir;
                                            let _e314 = _o_ratio;
                                            let _e317 = reflectedDir;
                                            let _e320 = reflectedDir;
                                            let _e323 = _o_ratio;
                                            if ((abs(_e308.y) > (abs(_e311.z) * _e314)) && (abs(_e317.y) > (abs(_e320.x) * _e323))) {
                                                {
                                                    let _e327 = _o_X;
                                                    let _e328 = reflectedDir;
                                                    let _e331 = reflectedDir;
                                                    _o_X = (_e327 + ((-(_e328.x) / _e331.y) * 0.5f));
                                                    let _e337 = _o_Y;
                                                    let _e338 = reflectedDir;
                                                    let _e341 = reflectedDir;
                                                    _o_Y = (_e337 + ((-(_e338.z) / _e341.y) * 0.5f));
                                                }
                                            } else {
                                                let _e347 = reflectedDir;
                                                let _e350 = reflectedDir;
                                                if (abs(_e347.x) < abs(_e350.z)) {
                                                    {
                                                        let _e354 = _o_X;
                                                        let _e355 = reflectedDir;
                                                        let _e357 = reflectedDir;
                                                        let _e361 = _o_ratio;
                                                        let _e365 = reflectedDir;
                                                        _o_X = (_e354 + ((((_e355.x / abs(_e357.z)) * _e361) * 0.5f) * -(sign(_e365.z))));
                                                        let _e371 = _o_Y;
                                                        let _e372 = reflectedDir;
                                                        let _e374 = reflectedDir;
                                                        _o_Y = (_e371 + ((_e372.y / abs(_e374.z)) * 0.5f));
                                                    }
                                                } else {
                                                    {
                                                        let _e381 = _o_X;
                                                        let _e382 = reflectedDir;
                                                        let _e384 = reflectedDir;
                                                        let _e388 = _o_ratio;
                                                        let _e392 = reflectedDir;
                                                        _o_X = (_e381 + ((((_e382.z / abs(_e384.x)) * _e388) * 0.5f) * -(sign(_e392.x))));
                                                        let _e398 = _o_Y;
                                                        let _e399 = reflectedDir;
                                                        let _e401 = reflectedDir;
                                                        _o_Y = (_e398 + ((_e399.y / abs(_e401.x)) * 0.5f));
                                                    }
                                                }
                                            }
                                            let _e408 = _o_X;
                                            let _e409 = _o_Y;
                                            let _e419 = global.U[0];
                                            let _e422 = _o_X;
                                            let _e423 = _o_Y;
                                            let _e439 = textureSampleLevel(t_source, samp, ((vec2<f32>((((vec2<f32>(_e408, _e409) * 2f) - vec2(1f)).x / _e419.x), ((vec2<f32>(_e422, _e423) * 2f) - vec2(1f)).y) / vec2(2f)) + vec2(0.5f)), 0f);
                                            _reflBkg = _e439;
                                        }
                                    } else {
                                        {
                                            let _e440 = reflectedDir;
                                            let _e445 = ((_e440 * 0.5f) + vec3(0.5f));
                                            _reflBkg = vec4<f32>(_e445.x, _e445.y, _e445.z, 1f);
                                        }
                                    }
                                }
                            }
                            let _e451 = _reflBkg;
                            reflectedColor = _e451;
                        }
                    }
                    let _e452 = dir_4;
                    let _e453 = normal;
                    let _e454 = eta;
                    dir_4 = refract(_e452, _e453, _e454);
                    let _e456 = intersection;
                    let _e457 = dir_4;
                    origin_4 = (_e456 + (_e457 * 0.001f));
                }
            }
            let _e461 = iter_1;
            iter_1 = (_e461 - 1i);
        }
        let _e464 = minI;
        let _e467 = iter_1;
        if !(((_e464 >= 0i) && (_e467 > 0i))) {
            break;
        }
    }
    let _e474 = reflectivity_1;
    balance = (1f - (2f * _e474));
    let _e481 = backgroundStyle_1;
    if (_e481 == 0i) {
        {
            let _e484 = dir_4;
            _o_n_1 = normalize(_e484);
            let _e487 = _o_n_1;
            let _e489 = _o_n_1;
            _o_alpha_1 = atan2(_e487.z, _e489.x);
            let _e493 = _o_n_1;
            _o_beta_1 = asin(_e493.y);
            let _e497 = _o_alpha_1;
            let _e504 = _o_beta_1;
            let _e512 = global.U[0];
            let _e515 = _o_alpha_1;
            let _e522 = _o_beta_1;
            let _e536 = textureSampleLevel(t_source, samp, ((vec2<f32>((vec2<f32>(((-(_e497) / 3.1415927f) * 2f), ((2f * _e504) / 3.1415927f)).x / _e512.x), vec2<f32>(((-(_e515) / 3.1415927f) * 2f), ((2f * _e522) / 3.1415927f)).y) / vec2(2f)) + vec2(0.5f)), 0f);
            _bkg = _e536;
        }
    } else {
        let _e537 = backgroundStyle_1;
        if (_e537 == 1i) {
            {
                let _e540 = dir_4;
                let _e543 = dir_4;
                let _e546 = dir_4;
                let _e549 = dir_4;
                _o_pos_1 = vec2<f32>((-(_e540.x) / _e543.z), (-(_e546.y) / _e549.z));
                let _e554 = _o_pos_1;
                let _e557 = _o_pos_1;
                _o_m_1 = max(abs(_e554.x), abs(_e557.y));
                let _e564 = _o_m_1;
                _o_darken_1 = (4f / max(4f, _e564));
                let _e568 = _o_pos_1;
                let _e572 = global.U[0];
                let _e575 = _o_pos_1;
                let _e585 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e568.x / _e572.x), _e575.y) / vec2(2f)) + vec2(0.5f)), 0f);
                let _e586 = _o_darken_1;
                let _e587 = _o_darken_1;
                let _e588 = _o_darken_1;
                _bkg = (_e585 * vec4<f32>(_e586, _e587, _e588, 1f));
            }
        } else {
            let _e592 = backgroundStyle_1;
            if (_e592 == 2i) {
                {
                    let _e595 = sourceDim_1;
                    let _e597 = sourceDim_1;
                    _o_ratio_1 = (_e595.y / _e597.x);
                    let _e605 = dir_4;
                    let _e608 = dir_4;
                    let _e611 = _o_ratio_1;
                    let _e614 = dir_4;
                    let _e617 = dir_4;
                    let _e620 = _o_ratio_1;
                    if ((abs(_e605.y) > (abs(_e608.z) * _e611)) && (abs(_e614.y) > (abs(_e617.x) * _e620))) {
                        {
                            let _e624 = _o_X_1;
                            let _e625 = dir_4;
                            let _e628 = dir_4;
                            _o_X_1 = (_e624 + ((-(_e625.x) / _e628.y) * 0.5f));
                            let _e634 = _o_Y_1;
                            let _e635 = dir_4;
                            let _e638 = dir_4;
                            _o_Y_1 = (_e634 + ((-(_e635.z) / _e638.y) * 0.5f));
                        }
                    } else {
                        let _e644 = dir_4;
                        let _e647 = dir_4;
                        if (abs(_e644.x) < abs(_e647.z)) {
                            {
                                let _e651 = _o_X_1;
                                let _e652 = dir_4;
                                let _e654 = dir_4;
                                let _e658 = _o_ratio_1;
                                let _e662 = dir_4;
                                _o_X_1 = (_e651 + ((((_e652.x / abs(_e654.z)) * _e658) * 0.5f) * -(sign(_e662.z))));
                                let _e668 = _o_Y_1;
                                let _e669 = dir_4;
                                let _e671 = dir_4;
                                _o_Y_1 = (_e668 + ((_e669.y / abs(_e671.z)) * 0.5f));
                            }
                        } else {
                            {
                                let _e678 = _o_X_1;
                                let _e679 = dir_4;
                                let _e681 = dir_4;
                                let _e685 = _o_ratio_1;
                                let _e689 = dir_4;
                                _o_X_1 = (_e678 + ((((_e679.z / abs(_e681.x)) * _e685) * 0.5f) * -(sign(_e689.x))));
                                let _e695 = _o_Y_1;
                                let _e696 = dir_4;
                                let _e698 = dir_4;
                                _o_Y_1 = (_e695 + ((_e696.y / abs(_e698.x)) * 0.5f));
                            }
                        }
                    }
                    let _e705 = _o_X_1;
                    let _e706 = _o_Y_1;
                    let _e716 = global.U[0];
                    let _e719 = _o_X_1;
                    let _e720 = _o_Y_1;
                    let _e736 = textureSampleLevel(t_source, samp, ((vec2<f32>((((vec2<f32>(_e705, _e706) * 2f) - vec2(1f)).x / _e716.x), ((vec2<f32>(_e719, _e720) * 2f) - vec2(1f)).y) / vec2(2f)) + vec2(0.5f)), 0f);
                    _bkg = _e736;
                }
            } else {
                {
                    let _e737 = dir_4;
                    let _e742 = ((_e737 * 0.5f) + vec3(0.5f));
                    _bkg = vec4<f32>(_e742.x, _e742.y, _e742.z, 1f);
                }
            }
        }
    }
    let _e748 = reflectedColor;
    let _e749 = _bkg;
    let _e750 = incidence;
    let _e751 = balance;
    mixedCol = mix(_e748, _e749, vec4(clamp((_e750 + _e751), 0f, 1f)));
    let _e759 = objectIntersected;
    if _e759 {
        let _e760 = mixedCol;
        let _e761 = mixedCol;
        let _e763 = objectColor_1;
        let _e765 = (2f * _e763.xyz);
        let _e772 = objectColor_1;
        mixedCol = mix(_e760, (_e761 * vec4<f32>(_e765.x, _e765.y, _e765.z, 1f)), vec4(_e772.w));
    } else {
        let _e776 = mixedCol;
        let _e777 = mixedCol;
        let _e779 = bkgColor_1;
        let _e781 = (2f * _e779.xyz);
        let _e788 = bkgColor_1;
        mixedCol = mix(_e776, (_e777 * vec4<f32>(_e781.x, _e781.y, _e781.z, 1f)), vec4(_e788.w));
    }
    let _e793 = minDist_1;
    let _e794 = minDist_1;
    glowIntensity = (1.4f / pow(_e793, clamp(_e794, 1f, 3f)));
    let _e801 = mixedCol;
    let _e802 = glowColor_1;
    let _e804 = glowIntensity;
    let _e805 = (_e802.xyz * _e804);
    let _e811 = glowColor_1;
    return (_e801 + (vec4<f32>(_e805.x, _e805.y, _e805.z, 0f) * _e811.w));
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
