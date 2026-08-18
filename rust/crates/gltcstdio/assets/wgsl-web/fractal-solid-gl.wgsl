struct Params {
    U: array<vec4<f32>, 41>,
    u_params: array<vec4<f32>, 11>,
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
@group(0) @binding(3) 
var t_sourceBkg: texture_2d<f32>;

fn _mirror_wrap(c: vec2<f32>) -> vec2<f32> {
    var c_1: vec2<f32>;

    c_1 = c;
    let _e12 = c_1;
    let _e14 = vec2(2f);
    return (vec2(1f) - abs(((_e12 - (floor((_e12 / _e14)) * _e14)) - vec2(1f))));
}

fn getVar(x: f32, variability: f32) -> f32 {
    var x_1: f32;
    var variability_1: f32;

    x_1 = x;
    variability_1 = variability;
    let _e13 = variability_1;
    if (_e13 >= 0f) {
        let _e16 = x_1;
        return _e16;
    } else {
        let _e17 = x_1;
        return fract((_e17 * 3f));
    }
}

fn sawWave2Pi(x_2: f32) -> f32 {
    var x_3: f32;

    x_3 = x_2;
    let _e12 = x_3;
    let _e15 = (0.5f - (_e12 * 0.31830987f));
    return ((abs(((_e15 - (floor((_e15 / 2f)) * 2f)) - 1f)) * 2f) - 1f);
}

fn sdBox(p: vec3<f32>, b: vec3<f32>) -> f32 {
    var p_1: vec3<f32>;
    var b_1: vec3<f32>;
    var q: vec3<f32>;

    p_1 = p;
    b_1 = b;
    let _e13 = p_1;
    let _e15 = b_1;
    q = (abs(_e13) - _e15);
    let _e18 = q;
    let _e23 = q;
    let _e25 = q;
    let _e27 = q;
    return (length(max(_e18, vec3(0f))) + min(max(_e23.x, max(_e25.y, _e27.z)), 0f));
}

fn sdPyramid(p_2: vec3<f32>, h: f32) -> f32 {
    var p_3: vec3<f32>;
    var h_1: f32;
    var m2_: f32;
    var local: vec2<f32>;
    var q_1: vec3<f32>;
    var s: f32;
    var t: f32;
    var a: f32;
    var b_2: f32;
    var local_1: f32;
    var d2_: f32;

    p_3 = p_2;
    h_1 = h;
    let _e13 = h_1;
    let _e14 = h_1;
    m2_ = ((_e13 * _e14) + 0.25f);
    let _e19 = p_3;
    let _e21 = p_3;
    let _e23 = abs(_e21.xz);
    p_3.x = _e23.x;
    p_3.z = _e23.y;
    let _e28 = p_3;
    let _e30 = p_3;
    let _e32 = p_3;
    if (_e30.z > _e32.x) {
        let _e35 = p_3;
        local = _e35.zx;
    } else {
        let _e37 = p_3;
        local = _e37.xz;
    }
    let _e40 = local;
    p_3.x = _e40.x;
    p_3.z = _e40.y;
    let _e45 = p_3;
    let _e47 = p_3;
    let _e51 = (_e47.xz - vec2(0.5f));
    p_3.x = _e51.x;
    p_3.z = _e51.y;
    let _e56 = p_3;
    let _e58 = h_1;
    let _e59 = p_3;
    let _e63 = p_3;
    let _e67 = h_1;
    let _e68 = p_3;
    let _e72 = p_3;
    q_1 = vec3<f32>(_e56.z, ((_e58 * _e59.y) - (0.5f * _e63.x)), ((_e67 * _e68.x) + (0.5f * _e72.y)));
    let _e78 = q_1;
    s = max(-(_e78.x), 0f);
    let _e84 = q_1;
    let _e87 = p_3;
    let _e91 = m2_;
    t = clamp(((_e84.y - (0.5f * _e87.z)) / (_e91 + 0.25f)), 0f, 1f);
    let _e99 = m2_;
    let _e100 = q_1;
    let _e102 = s;
    let _e105 = q_1;
    let _e107 = s;
    let _e110 = q_1;
    let _e112 = q_1;
    a = (((_e99 * (_e100.x + _e102)) * (_e105.x + _e107)) + (_e110.y * _e112.y));
    let _e117 = m2_;
    let _e118 = q_1;
    let _e121 = t;
    let _e125 = q_1;
    let _e128 = t;
    let _e132 = q_1;
    let _e134 = m2_;
    let _e135 = t;
    let _e138 = q_1;
    let _e140 = m2_;
    let _e141 = t;
    b_2 = (((_e117 * (_e118.x + (0.5f * _e121))) * (_e125.x + (0.5f * _e128))) + ((_e132.y - (_e134 * _e135)) * (_e138.y - (_e140 * _e141))));
    let _e147 = q_1;
    let _e149 = q_1;
    let _e152 = m2_;
    let _e154 = q_1;
    if (min(_e147.y, ((-(_e149.x) * _e152) - (_e154.y * 0.5f))) > 0f) {
        local_1 = 0f;
    } else {
        let _e163 = a;
        let _e164 = b_2;
        local_1 = min(_e163, _e164);
    }
    let _e167 = local_1;
    d2_ = _e167;
    let _e169 = d2_;
    let _e170 = q_1;
    let _e172 = q_1;
    let _e176 = m2_;
    let _e179 = q_1;
    let _e181 = p_3;
    return (sqrt(((_e169 + (_e170.z * _e172.z)) / _e176)) * sign(max(_e179.z, -(_e181.y))));
}

fn sdTorusSp(p_4: vec3<f32>, t_1: vec2<f32>) -> f32 {
    var p_5: vec3<f32>;
    var t_2: vec2<f32>;
    var q_2: vec2<f32>;

    p_5 = p_4;
    t_2 = t_1;
    let _e13 = p_5;
    let _e16 = t_2;
    let _e19 = p_5;
    q_2 = vec2<f32>((length(_e13.xz) - _e16.x), _e19.y);
    let _e23 = q_2;
    let _e25 = t_2;
    return (length(_e23) - _e25.y);
}

fn getDistAndGlow(q_3: vec3<f32>, mode: i32, colorGlow: vec4<f32>, thickness: f32, variability_2: f32, randomSeed: f32, clamper: vec3<f32>, iterations: i32, fractMat: mat4x4<f32>, glowParams: array<f32, 5>, internalIter: i32) -> vec2<f32> {
    var q_4: vec3<f32>;
    var mode_1: i32;
    var colorGlow_1: vec4<f32>;
    var thickness_1: f32;
    var variability_3: f32;
    var randomSeed_1: f32;
    var clamper_1: vec3<f32>;
    var iterations_1: i32;
    var fractMat_1: mat4x4<f32>;
    var glowParams_1: array<f32, 5>;
    var internalIter_1: i32;
    var p_6: vec3<f32>;
    var d: f32;
    var shapeMode: i32;
    var shape0_: i32;
    var local_2: f32;
    var mul: f32 = 1f;
    var reflectNormal: vec3<f32>;
    var offset: vec3<f32>;
    var glowVal: f32 = 0f;
    var local_3: i32;
    var j: i32;
    var local_4: f32;
    var lowR: f32;
    var local_5: f32;
    var highR: f32;
    var freq1_: f32 = 1f;
    var freq2_: f32 = 0.3f;
    var i: i32 = 0i;
    var var_: f32;
    var dr: f32;
    var paramix: f32;
    var local_6: f32;
    var r: f32;
    var qq: vec3<f32>;
    var size: vec3<f32>;
    var d2_1: f32;
    var addOrSub: bool;
    var local_7: f32;
    var signD: f32;
    var local_8: f32;
    var local_9: f32;

    q_4 = q_3;
    mode_1 = mode;
    colorGlow_1 = colorGlow;
    thickness_1 = thickness;
    variability_3 = variability_2;
    randomSeed_1 = randomSeed;
    clamper_1 = clamper;
    iterations_1 = iterations;
    fractMat_1 = fractMat;
    glowParams_1 = glowParams;
    internalIter_1 = internalIter;
    let _e31 = q_4;
    p_6 = _e31;
    let _e34 = mode_1;
    shapeMode = (_e34 / 64i);
    let _e38 = shapeMode;
    shape0_ = (_e38 % 4i);
    let _e42 = shape0_;
    if (_e42 == 0i) {
        let _e45 = p_6;
        let _e50 = sdBox(_e45, vec3<f32>(1f, 1f, 1f));
        d = _e50;
    } else {
        let _e51 = shape0_;
        if (_e51 == 1i) {
            let _e54 = p_6;
            d = (length(_e54) - 1f);
        } else {
            let _e58 = shape0_;
            if (_e58 == 2i) {
                let _e62 = p_6;
                let _e72 = sdPyramid(((-(_e62) * 0.5f) + vec3<f32>(0f, 0.5f, 0f)), 1f);
                d = (2f * _e72);
            } else {
                let _e74 = p_6;
                let _e79 = sdTorusSp(_e74.xzy, vec2<f32>(1f, 0.33f));
                d = _e79;
            }
        }
    }
    let _e80 = shapeMode;
    shapeMode = (_e80 / 4i);
    let _e83 = d;
    let _e84 = colorGlow_1;
    if (_e84.w > 0f) {
        local_2 = 1f;
    } else {
        local_2 = 0.1f;
    }
    let _e91 = local_2;
    if (_e83 > _e91) {
        let _e93 = d;
        return vec2<f32>(_e93, 0f);
    }
    reflectNormal = normalize(vec3<f32>(-1f, 1f, 0f));
    let _e105 = thickness_1;
    offset = vec3<f32>((_e105 * 2f), 0f, 0f);
    let _e114 = variability_3;
    if (_e114 < 0f) {
        local_3 = 2i;
    } else {
        local_3 = 1i;
    }
    let _e120 = local_3;
    j = _e120;
    let _e122 = variability_3;
    if (_e122 < 0f) {
        local_4 = 0.1f;
    } else {
        local_4 = 0f;
    }
    let _e128 = local_4;
    lowR = _e128;
    let _e130 = variability_3;
    if (_e130 < 0f) {
        local_5 = 0.5f;
    } else {
        local_5 = 0.6f;
    }
    let _e136 = local_5;
    highR = _e136;
    loop {
        let _e144 = i;
        let _e145 = iterations_1;
        if !((_e144 < (_e145 - 1i))) {
            break;
        }
        {
            let _e153 = j;
            if (_e153 == 3i) {
                j = 0i;
            }
            let _e157 = i;
            let _e159 = q_4[_e157];
            let _e160 = variability_3;
            let _e161 = getVar(_e159, _e160);
            var_ = _e161;
            let _e165 = randomSeed_1;
            let _e166 = freq1_;
            let _e168 = sawWave2Pi((_e165 * _e166));
            dr = (0.1f + (0.1f * _e168));
            let _e176 = randomSeed_1;
            let _e177 = freq2_;
            let _e180 = sawWave2Pi((-0.460554f + (_e176 * _e177)));
            paramix = (0.4f + (0.15f * _e180));
            let _e184 = paramix;
            let _e185 = i;
            if (_e185 > 0i) {
                let _e188 = dr;
                let _e189 = variability_3;
                let _e191 = var_;
                local_6 = ((_e188 * _e189) * _e191);
            } else {
                local_6 = 0f;
            }
            let _e195 = local_6;
            let _e198 = lowR;
            let _e199 = highR;
            r = clamp(abs((_e184 + _e195)), _e198, _e199);
            let _e202 = freq1_;
            freq1_ = (_e202 * 1.52f);
            let _e205 = freq2_;
            freq2_ = (_e205 * 1.42f);
            let _e208 = p_6;
            qq = _e208;
            let _e211 = r;
            let _e212 = r;
            size = vec3<f32>(1.05f, _e211, _e212);
            let _e215 = i;
            if (_e215 > 0i) {
                let _e218 = size;
                let _e219 = i;
                let _e221 = q_4[_e219];
                let _e222 = variability_3;
                let _e224 = clamper_1;
                size = (_e218 + clamp((((_e221 * _e222) * _e224) * 5f), vec3(-1f), vec3(1f)));
            }
            let _e235 = j;
            let _e237 = j;
            let _e239 = offset[_e237];
            let _e240 = i;
            let _e242 = q_4[_e240];
            let _e243 = variability_3;
            let _e245 = dr;
            let _e247 = r;
            offset[_e235] = (_e239 + clamp((((_e242 * _e243) * _e245) * (_e247 * 15f)), 0f, 1f));
            let _e255 = p_6;
            p_6 = abs(_e255);
            let _e257 = p_6;
            let _e259 = p_6;
            if (_e257.y > _e259.x) {
                let _e262 = p_6;
                let _e264 = reflectNormal;
                let _e265 = p_6;
                let _e266 = reflectNormal;
                let _e272 = reflectNormal;
                p_6 = (_e262 - ((2f * dot(_e264, (_e265 - (_e266 * 0f)))) * _e272));
            }
            let _e275 = p_6;
            let _e277 = p_6;
            if (_e275.z > _e277.x) {
                let _e280 = p_6;
                let _e282 = reflectNormal;
                let _e284 = p_6;
                let _e287 = reflectNormal;
                p_6 = (_e280 - ((2f * dot(_e282.xzy, _e284)) * _e287.xzy));
            }
            let _e292 = mode_1;
            addOrSub = ((_e292 % 2i) == 0i);
            let _e298 = addOrSub;
            if _e298 {
                local_7 = -1f;
            } else {
                local_7 = 1f;
            }
            let _e303 = local_7;
            signD = _e303;
            let _e305 = shapeMode;
            if ((_e305 % 2i) == 0i) {
                let _e310 = addOrSub;
                if _e310 {
                    let _e311 = mul;
                    let _e313 = p_6;
                    let _e314 = offset;
                    let _e317 = size;
                    let _e319 = sdBox((_e313 - _e314), (1f * _e317));
                    local_8 = (-(_e311) * _e319);
                } else {
                    let _e321 = mul;
                    let _e322 = p_6;
                    let _e323 = offset;
                    let _e327 = r;
                    let _e328 = r;
                    let _e331 = sdBox((_e322 - _e323), (1.5f * vec3<f32>(1f, _e327, _e328)));
                    local_8 = (_e321 * _e331);
                }
                let _e334 = local_8;
                d2_1 = _e334;
            } else {
                let _e335 = addOrSub;
                if _e335 {
                    let _e336 = mul;
                    let _e338 = p_6;
                    let _e339 = offset;
                    let _e343 = r;
                    local_9 = (-(_e336) * (length((_e338 - _e339)) - (1f * _e343)));
                } else {
                    let _e347 = mul;
                    let _e348 = p_6;
                    let _e349 = offset;
                    let _e353 = r;
                    local_9 = (_e347 * (length((_e348 - _e349)) - (1.5f * _e353)));
                }
                let _e358 = local_9;
                d2_1 = _e358;
            }
            let _e359 = shapeMode;
            shapeMode = (_e359 / 2i);
            let _e362 = mode_1;
            mode_1 = (_e362 / 2i);
            let _e365 = i;
            if (_e365 < 5i) {
                let _e368 = glowVal;
                let _e370 = mul;
                let _e372 = i;
                let _e374 = glowParams_1[_e372];
                let _e376 = d;
                let _e377 = signD;
                let _e378 = d2_1;
                glowVal = max(_e368, (((0.01f * _e370) * _e374) / abs((_e376 + (_e377 * _e378)))));
            }
            let _e384 = d;
            let _e385 = d2_1;
            d = max(_e384, _e385);
            let _e387 = i;
            let _e388 = internalIter_1;
            if (_e387 < _e388) {
                {
                    let _e390 = fractMat_1;
                    let _e391 = p_6;
                    p_6 = (_e390 * vec4<f32>(_e391.x, _e391.y, _e391.z, 1f)).xyz;
                }
            }
            let _e399 = p_6;
            let _e400 = r;
            let _e404 = r;
            let _e411 = r;
            let _e413 = r;
            let _e416 = r;
            p_6 = ((((fract(((_e399 + vec3(_e400)) / vec3((2f * _e404)))) * 2f) * _e411) - vec3(_e413)) / vec3(_e416));
            let _e419 = mul;
            let _e420 = r;
            mul = (_e419 * _e420);
        }
        continuing {
            let _e150 = i;
            i = (_e150 + 1i);
        }
    }
    let _e422 = d;
    let _e423 = glowVal;
    return vec2<f32>(_e422, _e423);
}

fn getDist(q_5: vec3<f32>, mode_2: i32, colorGlow_2: vec4<f32>, thickness_2: f32, variability_4: f32, randomSeed_2: f32, clamper_2: vec3<f32>, iterations_2: i32, fractMat_2: mat4x4<f32>, glowParams_2: array<f32, 5>, internalIter_2: i32) -> f32 {
    var q_6: vec3<f32>;
    var mode_3: i32;
    var colorGlow_3: vec4<f32>;
    var thickness_3: f32;
    var variability_5: f32;
    var randomSeed_3: f32;
    var clamper_3: vec3<f32>;
    var iterations_3: i32;
    var fractMat_3: mat4x4<f32>;
    var glowParams_3: array<f32, 5>;
    var internalIter_3: i32;

    q_6 = q_5;
    mode_3 = mode_2;
    colorGlow_3 = colorGlow_2;
    thickness_3 = thickness_2;
    variability_5 = variability_4;
    randomSeed_3 = randomSeed_2;
    clamper_3 = clamper_2;
    iterations_3 = iterations_2;
    fractMat_3 = fractMat_2;
    glowParams_3 = glowParams_2;
    internalIter_3 = internalIter_2;
    let _e31 = q_6;
    let _e32 = mode_3;
    let _e33 = colorGlow_3;
    let _e34 = thickness_3;
    let _e35 = variability_5;
    let _e36 = randomSeed_3;
    let _e37 = clamper_3;
    let _e38 = iterations_3;
    let _e39 = fractMat_3;
    let _e40 = glowParams_3;
    let _e41 = internalIter_3;
    let _e42 = getDistAndGlow(_e31, _e32, _e33, _e34, _e35, _e36, _e37, _e38, _e39, _e40, _e41);
    return _e42.x;
}

fn getNormal(p_7: vec3<f32>, mode_4: i32, colorGlow_4: vec4<f32>, thickness_4: f32, variability_6: f32, randomSeed_4: f32, clamper_4: vec3<f32>, iterations_4: i32, fractMat_4: mat4x4<f32>, glowParams_4: array<f32, 5>, internalIter_4: i32) -> vec3<f32> {
    var p_8: vec3<f32>;
    var mode_5: i32;
    var colorGlow_5: vec4<f32>;
    var thickness_5: f32;
    var variability_7: f32;
    var randomSeed_5: f32;
    var clamper_5: vec3<f32>;
    var iterations_5: i32;
    var fractMat_5: mat4x4<f32>;
    var glowParams_5: array<f32, 5>;
    var internalIter_5: i32;
    var d_1: f32 = 0.0001f;
    var d2_2: f32;

    p_8 = p_7;
    mode_5 = mode_4;
    colorGlow_5 = colorGlow_4;
    thickness_5 = thickness_4;
    variability_7 = variability_6;
    randomSeed_5 = randomSeed_4;
    clamper_5 = clamper_4;
    iterations_5 = iterations_4;
    fractMat_5 = fractMat_4;
    glowParams_5 = glowParams_4;
    internalIter_5 = internalIter_4;
    let _e33 = d_1;
    d2_2 = (_e33 * 2f);
    let _e37 = p_8;
    let _e39 = d_1;
    let _e41 = p_8;
    let _e43 = p_8;
    let _e46 = mode_5;
    let _e47 = colorGlow_5;
    let _e48 = thickness_5;
    let _e49 = variability_7;
    let _e50 = randomSeed_5;
    let _e51 = clamper_5;
    let _e52 = iterations_5;
    let _e53 = fractMat_5;
    let _e54 = glowParams_5;
    let _e55 = internalIter_5;
    let _e56 = getDist(vec3<f32>((_e37.x - _e39), _e41.y, _e43.z), _e46, _e47, _e48, _e49, _e50, _e51, _e52, _e53, _e54, _e55);
    let _e57 = p_8;
    let _e59 = d_1;
    let _e61 = p_8;
    let _e63 = p_8;
    let _e66 = mode_5;
    let _e67 = colorGlow_5;
    let _e68 = thickness_5;
    let _e69 = variability_7;
    let _e70 = randomSeed_5;
    let _e71 = clamper_5;
    let _e72 = iterations_5;
    let _e73 = fractMat_5;
    let _e74 = glowParams_5;
    let _e75 = internalIter_5;
    let _e76 = getDist(vec3<f32>((_e57.x + _e59), _e61.y, _e63.z), _e66, _e67, _e68, _e69, _e70, _e71, _e72, _e73, _e74, _e75);
    let _e78 = d2_2;
    let _e80 = p_8;
    let _e82 = p_8;
    let _e84 = d_1;
    let _e86 = p_8;
    let _e89 = mode_5;
    let _e90 = colorGlow_5;
    let _e91 = thickness_5;
    let _e92 = variability_7;
    let _e93 = randomSeed_5;
    let _e94 = clamper_5;
    let _e95 = iterations_5;
    let _e96 = fractMat_5;
    let _e97 = glowParams_5;
    let _e98 = internalIter_5;
    let _e99 = getDist(vec3<f32>(_e80.x, (_e82.y - _e84), _e86.z), _e89, _e90, _e91, _e92, _e93, _e94, _e95, _e96, _e97, _e98);
    let _e100 = p_8;
    let _e102 = p_8;
    let _e104 = d_1;
    let _e106 = p_8;
    let _e109 = mode_5;
    let _e110 = colorGlow_5;
    let _e111 = thickness_5;
    let _e112 = variability_7;
    let _e113 = randomSeed_5;
    let _e114 = clamper_5;
    let _e115 = iterations_5;
    let _e116 = fractMat_5;
    let _e117 = glowParams_5;
    let _e118 = internalIter_5;
    let _e119 = getDist(vec3<f32>(_e100.x, (_e102.y + _e104), _e106.z), _e109, _e110, _e111, _e112, _e113, _e114, _e115, _e116, _e117, _e118);
    let _e121 = d2_2;
    let _e123 = p_8;
    let _e125 = p_8;
    let _e127 = p_8;
    let _e129 = d_1;
    let _e132 = mode_5;
    let _e133 = colorGlow_5;
    let _e134 = thickness_5;
    let _e135 = variability_7;
    let _e136 = randomSeed_5;
    let _e137 = clamper_5;
    let _e138 = iterations_5;
    let _e139 = fractMat_5;
    let _e140 = glowParams_5;
    let _e141 = internalIter_5;
    let _e142 = getDist(vec3<f32>(_e123.x, _e125.y, (_e127.z - _e129)), _e132, _e133, _e134, _e135, _e136, _e137, _e138, _e139, _e140, _e141);
    let _e143 = p_8;
    let _e145 = p_8;
    let _e147 = p_8;
    let _e149 = d_1;
    let _e152 = mode_5;
    let _e153 = colorGlow_5;
    let _e154 = thickness_5;
    let _e155 = variability_7;
    let _e156 = randomSeed_5;
    let _e157 = clamper_5;
    let _e158 = iterations_5;
    let _e159 = fractMat_5;
    let _e160 = glowParams_5;
    let _e161 = internalIter_5;
    let _e162 = getDist(vec3<f32>(_e143.x, _e145.y, (_e147.z + _e149)), _e152, _e153, _e154, _e155, _e156, _e157, _e158, _e159, _e160, _e161);
    let _e164 = d2_2;
    return normalize(vec3<f32>(((_e56 - _e76) / _e78), ((_e99 - _e119) / _e121), ((_e142 - _e162) / _e164)));
}

fn getRay(uv: vec2<f32>, camera: vec3<f32>, target_: vec3<f32>, focalDist: f32) -> vec3<f32> {
    var uv_1: vec2<f32>;
    var camera_1: vec3<f32>;
    var target_1: vec3<f32>;
    var focalDist_1: f32;
    var camZ: vec3<f32>;
    var camX: vec3<f32>;
    var camY: vec3<f32>;

    uv_1 = uv;
    camera_1 = camera;
    target_1 = target_;
    focalDist_1 = focalDist;
    let _e17 = target_1;
    let _e18 = camera_1;
    camZ = normalize((_e17 - _e18));
    let _e26 = camZ;
    camX = normalize(cross(vec3<f32>(0f, 1f, 0f), _e26));
    let _e30 = camZ;
    let _e31 = camX;
    camY = cross(_e30, _e31);
    let _e34 = camZ;
    let _e35 = focalDist_1;
    let _e37 = uv_1;
    let _e39 = camX;
    let _e42 = uv_1;
    let _e44 = camY;
    return normalize((((_e34 * _e35) + (_e37.x * _e39)) + (_e42.y * _e44)));
}

fn hash3_(u: vec3<f32>) -> f32 {
    var u_1: vec3<f32>;
    var k: f32;
    var l: f32;

    u_1 = u;
    let _e11 = u_1;
    let _e13 = u_1;
    let _e19 = u_1;
    let _e21 = u_1;
    k = ((dot(_e11.xy, -(_e13.yz)) * 644.2834f) - (dot(_e19.zx, _e21.xy) * 3184.43f));
    let _e28 = u_1;
    let _e30 = u_1;
    let _e36 = u_1;
    let _e39 = u_1;
    let _e42 = k;
    let _e46 = u_1;
    let _e49 = u_1;
    let _e53 = u_1;
    let _e58 = u_1;
    let _e63 = u_1;
    let _e66 = k;
    l = fract(((((((((_e28.x * _e30.z) * 20.01f) - (((33.11f * _e36.y) * _e39.x) * _e42)) + ((23.32f * _e46.z) * _e49.y)) + (_e53.x * 2.11f)) - (_e58.y * 33.454f)) + _e63.z) + _e66));
    let _e71 = k;
    let _e72 = u_1;
    let _e73 = _e72.xy;
    let _e77 = u_1;
    let _e78 = _e77.zy;
    let _e79 = l;
    return fract((45.4518f * dot(vec3<f32>(_e71, _e73.x, _e73.y), vec3<f32>(_e78.x, _e78.y, _e79))));
}

fn hueRotate(c_2: vec3<f32>, a_1: f32) -> vec3<f32> {
    var c_3: vec3<f32>;
    var a_2: f32;
    var k_1: vec3<f32> = vec3(0.57735026f);
    var cosA: f32;

    c_3 = c_2;
    a_2 = a_1;
    let _e16 = a_2;
    cosA = cos(_e16);
    let _e19 = c_3;
    let _e20 = cosA;
    let _e22 = k_1;
    let _e23 = c_3;
    let _e25 = a_2;
    let _e29 = k_1;
    let _e30 = k_1;
    let _e31 = c_3;
    let _e35 = cosA;
    return (((_e19 * _e20) + (cross(_e22, _e23) * sin(_e25))) + ((_e29 * dot(_e30, _e31)) * (1f - _e35)));
}

fn max3_(u_2: vec3<f32>) -> f32 {
    var u_3: vec3<f32>;

    u_3 = u_2;
    let _e11 = u_3;
    let _e13 = u_3;
    let _e15 = u_3;
    return max(_e11.x, max(_e13.y, _e15.z));
}

fn rayMarch(origin: vec3<f32>, dir: vec3<f32>, mode_6: i32, colorGlow_6: vec4<f32>, thickness_6: f32, variability_8: f32, randomSeed_6: f32, clamper_6: vec3<f32>, iterations_6: i32, fractMat_6: mat4x4<f32>, glowParams_6: array<f32, 5>, internalIter_6: i32) -> mat3x3<f32> {
    var origin_1: vec3<f32>;
    var dir_1: vec3<f32>;
    var mode_7: i32;
    var colorGlow_7: vec4<f32>;
    var thickness_7: f32;
    var variability_9: f32;
    var randomSeed_7: f32;
    var clamper_7: vec3<f32>;
    var iterations_7: i32;
    var fractMat_7: mat4x4<f32>;
    var glowParams_7: array<f32, 5>;
    var internalIter_7: i32;
    var d_2: f32 = 0f;
    var i_1: i32 = 0i;
    var current: vec3<f32>;
    var glow: f32 = 0f;
    var distGlow: vec2<f32>;
    var dist: f32;

    origin_1 = origin;
    dir_1 = dir;
    mode_7 = mode_6;
    colorGlow_7 = colorGlow_6;
    thickness_7 = thickness_6;
    variability_9 = variability_8;
    randomSeed_7 = randomSeed_6;
    clamper_7 = clamper_6;
    iterations_7 = iterations_6;
    fractMat_7 = fractMat_6;
    glowParams_7 = glowParams_6;
    internalIter_7 = internalIter_6;
    let _e37 = origin_1;
    current = _e37;
    loop {
        let _e41 = i_1;
        if !((_e41 < 200i)) {
            break;
        }
        {
            let _e45 = current;
            let _e46 = mode_7;
            let _e47 = colorGlow_7;
            let _e48 = thickness_7;
            let _e49 = variability_9;
            let _e50 = randomSeed_7;
            let _e51 = clamper_7;
            let _e52 = iterations_7;
            let _e53 = fractMat_7;
            let _e54 = glowParams_7;
            let _e55 = internalIter_7;
            let _e56 = getDistAndGlow(_e45, _e46, _e47, _e48, _e49, _e50, _e51, _e52, _e53, _e54, _e55);
            distGlow = _e56;
            let _e58 = distGlow;
            dist = _e58.x;
            let _e61 = glow;
            let _e62 = distGlow;
            glow = max(_e61, _e62.y);
            let _e65 = dist;
            if (_e65 < 0.00005f) {
                break;
            }
            let _e68 = current;
            let _e69 = dist;
            let _e70 = dir_1;
            current = (_e68 + ((_e69 * _e70) * 0.8f));
            let _e75 = i_1;
            i_1 = (_e75 + 1i);
        }
    }
    let _e78 = i_1;
    if (_e78 >= 200i) {
        let _e83 = glow;
        let _e84 = i_1;
        let _e87 = vec3<f32>(_e83, f32(_e84), 0f);
        return mat3x3<f32>(vec3<f32>(100000000000000000000f, 100000000000000000000f, 100000000000000000000f), vec3<f32>(_e87.x, _e87.y, _e87.z), vec3<f32>(0f, 0f, 0f));
    } else {
        let _e97 = current;
        let _e98 = glow;
        let _e99 = i_1;
        let _e102 = vec3<f32>(_e98, f32(_e99), 0f);
        return mat3x3<f32>(vec3<f32>(_e97.x, _e97.y, _e97.z), vec3<f32>(_e102.x, _e102.y, _e102.z), vec3<f32>(0f, 0f, 0f));
    }
}

fn upStayDown(x_4: f32, a_3: f32, b_3: f32) -> f32 {
    var x_5: f32;
    var a_4: f32;
    var b_4: f32;
    var c_4: f32;
    var d_3: f32;

    x_5 = x_4;
    a_4 = a_3;
    b_4 = b_3;
    let _e15 = a_4;
    let _e16 = b_4;
    c_4 = (_e15 + _e16);
    let _e19 = b_4;
    let _e20 = a_4;
    d_3 = (_e19 - _e20);
    let _e24 = d_3;
    let _e28 = x_5;
    let _e29 = c_4;
    return clamp(((1f + (_e24 * 0.5f)) - abs((_e28 - (_e29 * 0.5f)))), 0f, 1f);
}

fn mengerSponge(uv_2: vec2<f32>, outPos: vec2<f32>, iterations_8: i32, model3DTransform: mat4x4<f32>, camera3DTransform: mat4x4<f32>, lightSourceTransform: mat4x4<f32>, internal3DTransform: mat4x4<f32>, sourceDim: vec2<f32>, sourceBkgDim: vec2<f32>, sourceBkg_specified: i32, mode_8: i32, internalIter_8: i32, colorScheme: f32, thickness_8: f32, variability_10: f32, randomSeed_8: f32, colorSource: vec4<f32>, colorAmbient: vec4<f32>, colorFog: vec4<f32>, colorGlow_8: vec4<f32>, backgroundStyle: f32, backgroundMode: i32, specular: f32, glow_1: f32, fog: f32, gamma: f32) -> vec4<f32> {
    var uv_3: vec2<f32>;
    var outPos_1: vec2<f32>;
    var iterations_9: i32;
    var model3DTransform_1: mat4x4<f32>;
    var camera3DTransform_1: mat4x4<f32>;
    var lightSourceTransform_1: mat4x4<f32>;
    var internal3DTransform_1: mat4x4<f32>;
    var sourceDim_1: vec2<f32>;
    var sourceBkgDim_1: vec2<f32>;
    var sourceBkg_specified_1: i32;
    var mode_9: i32;
    var internalIter_9: i32;
    var colorScheme_1: f32;
    var thickness_9: f32;
    var variability_11: f32;
    var randomSeed_9: f32;
    var colorSource_1: vec4<f32>;
    var colorAmbient_1: vec4<f32>;
    var colorFog_1: vec4<f32>;
    var colorGlow_9: vec4<f32>;
    var backgroundStyle_1: f32;
    var backgroundMode_1: i32;
    var specular_1: f32;
    var glow_2: f32;
    var fog_1: f32;
    var gamma_1: f32;
    var D: f32 = 1f;
    var camera_2: vec3<f32> = vec3<f32>(0f, 0f, 0f);
    var target_2: vec3<f32> = vec3(0f);
    var camDir: vec3<f32>;
    var lightPos: vec3<f32>;
    var invModelTransform: mat4x4<f32>;
    var model3DTransform3_: mat3x3<f32>;
    var dir_2: vec3<f32>;
    var cameraPos: vec3<f32>;
    var origin_2: vec3<f32>;
    var fractMat_8: mat4x4<f32>;
    var col: vec3<f32>;
    var COLOR_SCHEMES: f32 = 3f;
    var csRaw: f32;
    var glowK: f32;
    var glowParams_8: array<f32, 5>;
    var k_2: f32;
    var clamper_8: vec3<f32>;
    var intersectionGlow: mat3x3<f32>;
    var intersection: vec3<f32>;
    var glowI: f32;
    var glowIterations: f32;
    var normal: vec3<f32>;
    var lightDir: vec3<f32>;
    var illum: f32;
    var nc: vec3<f32>;
    var posCol: vec3<f32>;
    var cN1_: vec3<f32>;
    var cN2_: vec3<f32>;
    var depth: f32;
    var depthCol: vec3<f32>;
    var s_1: f32;
    var col1_: vec3<f32>;
    var pos2_: vec2<f32>;
    var col2_: vec3<f32>;
    var local_10: vec3<f32>;
    var tu: vec3<f32>;
    var tv: vec3<f32>;
    var pos1_: vec2<f32>;
    var col1_1: vec3<f32>;
    var pos2_1: vec2<f32>;
    var col2_1: vec3<f32>;
    var light: f32 = 1f;
    var local_11: f32;
    var spec: f32;
    var BKG_STYLES: f32 = 5f;
    var bkgStyle: f32;
    var bkgCol: vec4<f32>;
    var hasBkg: bool;
    var local_12: vec2<f32>;
    var sDim: vec2<f32>;
    var pos: vec2<f32>;
    var m: f32;
    var darken: f32;
    var local_13: vec4<f32>;
    var local_14: vec2<f32>;
    var sDim_1: vec2<f32>;
    var ratio: f32;
    var X: f32 = 0.5f;
    var Y: f32 = 0.5f;
    var pos_1: vec2<f32>;
    var local_15: vec4<f32>;
    var n: vec3<f32>;
    var alpha: f32;
    var beta: f32;
    var nX: f32 = 2f;
    var nY: f32 = 1f;
    var local_16: vec2<f32>;
    var sDim_2: vec2<f32>;
    var pos_2: vec2<f32>;
    var local_17: vec4<f32>;
    var lightDir_1: vec3<f32>;
    var lightProx: f32;
    var lightProx_1: f32;
    var colImg: vec3<f32>;
    var colSpectrum: vec3<f32>;
    var colSpectrum_1: vec3<f32>;
    var lightProx_2: f32;
    var colDay: vec3<f32>;
    var lightProx_3: f32;
    var colDay_1: vec3<f32>;
    var R: f32 = 40f;
    var center: vec3<f32>;
    var mag: f32;
    var stars1_: f32;
    var stars2_: f32;
    var mainStar: f32;
    var colNight: vec3<f32>;
    var glow0_: f32;
    var glow1_: f32;
    var local_18: f32;
    var near: f32;
    var far: f32;

    uv_3 = uv_2;
    outPos_1 = outPos;
    iterations_9 = iterations_8;
    model3DTransform_1 = model3DTransform;
    camera3DTransform_1 = camera3DTransform;
    lightSourceTransform_1 = lightSourceTransform;
    internal3DTransform_1 = internal3DTransform;
    sourceDim_1 = sourceDim;
    sourceBkgDim_1 = sourceBkgDim;
    sourceBkg_specified_1 = sourceBkg_specified;
    mode_9 = mode_8;
    internalIter_9 = internalIter_8;
    colorScheme_1 = colorScheme;
    thickness_9 = thickness_8;
    variability_11 = variability_10;
    randomSeed_9 = randomSeed_8;
    colorSource_1 = colorSource;
    colorAmbient_1 = colorAmbient;
    colorFog_1 = colorFog;
    colorGlow_9 = colorGlow_8;
    backgroundStyle_1 = backgroundStyle;
    backgroundMode_1 = backgroundMode;
    specular_1 = specular;
    glow_2 = glow_1;
    fog_1 = fog;
    gamma_1 = gamma;
    let _e68 = camera3DTransform_1;
    let _e69 = camera_2;
    camera_2 = (_e68 * vec4<f32>(_e69.x, _e69.y, _e69.z, 1f)).xyz;
    let _e80 = uv_3;
    let _e81 = camera_2;
    let _e82 = target_2;
    let _e84 = getRay(_e80, _e81, _e82, 1f);
    camDir = _e84;
    let _e86 = lightSourceTransform_1;
    lightPos = (_e86 * vec4<f32>(0f, 0f, 0f, 1f)).xyz;
    let _e95 = model3DTransform_1;
    invModelTransform = _naga_inverse_4x4_f32(_e95);
    let _e98 = model3DTransform_1;
    model3DTransform3_ = mat3x3<f32>(_e98[0].xyz, _e98[1].xyz, _e98[2].xyz);
    let _e109 = invModelTransform;
    let _e110 = camera_2;
    camera_2 = (_e109 * vec4<f32>(_e110.x, _e110.y, _e110.z, 1f)).xyz;
    let _e118 = uv_3;
    let _e120 = D;
    let _e122 = uv_3;
    let _e124 = D;
    dir_2 = normalize(vec3<f32>((_e118.x * _e120), (_e122.y * _e124), -1f));
    let _e131 = camera3DTransform_1;
    let _e141 = dir_2;
    dir_2 = (mat3x3<f32>(_e131[0].xyz, _e131[1].xyz, _e131[2].xyz) * _e141);
    let _e143 = invModelTransform;
    let _e153 = dir_2;
    camDir = normalize((mat3x3<f32>(_e143[0].xyz, _e143[1].xyz, _e143[2].xyz) * _e153));
    let _e156 = camera_2;
    cameraPos = _e156;
    let _e158 = camDir;
    dir_2 = _e158;
    let _e159 = cameraPos;
    origin_2 = _e159;
    let _e162 = internalIter_9;
    if (_e162 > 0i) {
        let _e165 = internal3DTransform_1;
        fractMat_8 = _naga_inverse_4x4_f32(_e165);
    }
    let _e167 = randomSeed_9;
    randomSeed_9 = (_e167 - 0.52f);
    let _e173 = colorScheme_1;
    csRaw = _e173;
    let _e175 = colorScheme_1;
    let _e176 = COLOR_SCHEMES;
    colorScheme_1 = (_e175 * (_e176 - 1f));
    let _e180 = glow_2;
    glowK = (_e180 * 13f);
    let _e185 = glowK;
    if (_e185 > 12f) {
        {
            let _e188 = glowK;
            k_2 = (_e188 - 12f);
            let _e194 = k_2;
            glowParams_8[0i] = _e194;
            let _e197 = k_2;
            glowParams_8[1i] = (_e197 * 0.5f);
            let _e202 = k_2;
            glowParams_8[2i] = (_e202 * 0.25f);
            let _e207 = k_2;
            glowParams_8[3i] = (_e207 * 0.125f);
            let _e212 = k_2;
            glowParams_8[4i] = (_e212 * 0.06125f);
        }
    } else {
        let _e215 = glowK;
        if (_e215 > 4f) {
            {
                let _e220 = glowK;
                let _e223 = upStayDown(_e220, 5f, 6f);
                glowParams_8[0i] = _e223;
                let _e226 = glowK;
                let _e229 = upStayDown(_e226, 6f, 7f);
                glowParams_8[1i] = _e229;
                let _e232 = glowK;
                let _e235 = upStayDown(_e232, 9f, 10f);
                glowParams_8[2i] = _e235;
                let _e238 = glowK;
                let _e241 = upStayDown(_e238, 10f, 11f);
                glowParams_8[3i] = _e241;
                let _e244 = glowK;
                let _e247 = upStayDown(_e244, 5f, 6f);
                glowParams_8[4i] = _e247;
            }
        } else {
            {
                glowParams_8[0i] = 0f;
                glowParams_8[1i] = 0f;
                glowParams_8[2i] = 0f;
                glowParams_8[3i] = 0f;
                glowParams_8[4i] = 0f;
            }
        }
    }
    let _e265 = randomSeed_9;
    let _e268 = sawWave2Pi((_e265 * 0.76f));
    let _e273 = randomSeed_9;
    let _e276 = sawWave2Pi((_e273 * 1.1552f));
    let _e281 = randomSeed_9;
    let _e284 = sawWave2Pi((_e281 * 1.7559f));
    clamper_8 = vec3<f32>((0.1f + (0.1f * _e268)), (0.1f + (0.1f * _e276)), (0.1f + (0.1f * _e284)));
    let _e289 = origin_2;
    let _e290 = dir_2;
    let _e291 = mode_9;
    let _e292 = colorGlow_9;
    let _e293 = thickness_9;
    let _e294 = variability_11;
    let _e295 = randomSeed_9;
    let _e296 = clamper_8;
    let _e297 = iterations_9;
    let _e298 = fractMat_8;
    let _e299 = glowParams_8;
    let _e300 = internalIter_9;
    let _e301 = rayMarch(_e289, _e290, _e291, _e292, _e293, _e294, _e295, _e296, _e297, _e298, _e299, _e300);
    intersectionGlow = _e301;
    let _e305 = intersectionGlow[0];
    intersection = _e305;
    let _e309 = intersectionGlow[1];
    glowI = _e309.x;
    let _e314 = intersectionGlow[1];
    glowIterations = _e314.y;
    let _e317 = intersection;
    if (_e317.x != 100000000000000000000f) {
        {
            let _e321 = intersection;
            let _e322 = mode_9;
            let _e323 = colorGlow_9;
            let _e324 = thickness_9;
            let _e325 = variability_11;
            let _e326 = randomSeed_9;
            let _e327 = clamper_8;
            let _e328 = iterations_9;
            let _e329 = fractMat_8;
            let _e330 = glowParams_8;
            let _e331 = internalIter_9;
            let _e332 = getNormal(_e321, _e322, _e323, _e324, _e325, _e326, _e327, _e328, _e329, _e330, _e331);
            normal = -(_e332);
            let _e335 = lightPos;
            let _e336 = intersection;
            lightDir = normalize((_e335 - _e336));
            let _e340 = normal;
            let _e341 = lightDir;
            illum = clamp(dot(_e340, _e341), 0f, 1f);
            let _e347 = csRaw;
            if (_e347 < 0f) {
                {
                    let _e350 = normal;
                    nc = ((_e350 * 0.5f) + vec3(0.5f));
                    let _e357 = intersection;
                    posCol = abs(_e357.zxy);
                    let _e361 = nc;
                    let _e363 = hueRotate(_e361, 2.0943952f);
                    cN1_ = _e363;
                    let _e365 = nc;
                    let _e367 = hueRotate(_e365, 4.1887903f);
                    cN2_ = _e367;
                    let _e369 = origin_2;
                    let _e370 = intersection;
                    depth = length((_e369 - _e370));
                    let _e378 = depth;
                    depthCol = (vec3(0.5f) + (0.5f * cos((6.2831855f * (vec3((0.7f * _e378)) + vec3<f32>(0f, 0.3333f, 0.6667f))))));
                    let _e392 = csRaw;
                    s_1 = -(_e392);
                    let _e395 = s_1;
                    if (_e395 < 0.25f) {
                        let _e398 = posCol;
                        let _e399 = nc;
                        let _e400 = s_1;
                        col = mix(_e398, _e399, vec3((_e400 * 4f)));
                    } else {
                        let _e405 = s_1;
                        if (_e405 < 0.5f) {
                            let _e408 = nc;
                            let _e409 = cN1_;
                            let _e410 = s_1;
                            col = mix(_e408, _e409, vec3(((_e410 - 0.25f) * 4f)));
                        } else {
                            let _e417 = s_1;
                            if (_e417 < 0.75f) {
                                let _e420 = cN1_;
                                let _e421 = cN2_;
                                let _e422 = s_1;
                                col = mix(_e420, _e421, vec3(((_e422 - 0.5f) * 4f)));
                            } else {
                                let _e429 = cN2_;
                                let _e430 = depthCol;
                                let _e431 = s_1;
                                col = mix(_e429, _e430, vec3(((_e431 - 0.75f) * 4f)));
                            }
                        }
                    }
                }
            } else {
                let _e438 = colorScheme_1;
                if (_e438 <= 1f) {
                    {
                        let _e441 = intersection;
                        col1_ = abs(_e441.zxy);
                        let _e446 = intersection;
                        let _e453 = max3_(((abs(_e446) * 2f) - vec3(1f)));
                        pos2_ = vec2<f32>(0f, _e453);
                        let _e456 = pos2_;
                        let _e460 = global.U[0];
                        let _e463 = pos2_;
                        let _e472 = _mirror_wrap(((vec2<f32>((_e456.x / _e460.x), _e463.y) / vec2(2f)) + vec2(0.5f)));
                        let _e474 = textureSampleLevel(t_source, samp, _e472, 0f);
                        col2_ = _e474.xyz;
                        let _e477 = col1_;
                        let _e478 = col2_;
                        let _e479 = colorScheme_1;
                        col = mix(_e477, _e478, vec3(_e479));
                    }
                } else {
                    {
                        let _e482 = normal;
                        let _e485 = normal;
                        if (abs(_e482.x) >= abs(_e485.y)) {
                            let _e489 = normal;
                            let _e492 = normal;
                            local_10 = normalize(vec3<f32>(_e489.z, 0f, -(_e492.x)));
                        } else {
                            let _e498 = normal;
                            let _e501 = normal;
                            local_10 = normalize(vec3<f32>(0f, -(_e498.z), _e501.y));
                        }
                        let _e506 = local_10;
                        tu = _e506;
                        let _e508 = normal;
                        let _e509 = tu;
                        tv = cross(_e508, _e509);
                        let _e513 = intersection;
                        let _e520 = max3_(((abs(_e513) * 2f) - vec3(1f)));
                        pos1_ = vec2<f32>(0f, _e520);
                        let _e523 = pos1_;
                        let _e527 = global.U[0];
                        let _e530 = pos1_;
                        let _e539 = _mirror_wrap(((vec2<f32>((_e523.x / _e527.x), _e530.y) / vec2(2f)) + vec2(0.5f)));
                        let _e541 = textureSampleLevel(t_source, samp, _e539, 0f);
                        col1_1 = _e541.xyz;
                        let _e544 = tu;
                        let _e545 = intersection;
                        let _e547 = normal;
                        let _e552 = tv;
                        let _e553 = intersection;
                        let _e555 = normal;
                        pos2_1 = vec2<f32>((dot(_e544, _e545) + (_e547.x * 2f)), (dot(_e552, _e553) + (_e555.y * 2f)));
                        let _e562 = pos2_1;
                        let _e566 = global.U[0];
                        let _e569 = pos2_1;
                        let _e578 = _mirror_wrap(((vec2<f32>((_e562.x / _e566.x), _e569.y) / vec2(2f)) + vec2(0.5f)));
                        let _e580 = textureSampleLevel(t_source, samp, _e578, 0f);
                        col2_1 = _e580.xyz;
                        let _e583 = col1_1;
                        let _e584 = col2_1;
                        let _e585 = colorScheme_1;
                        col = mix(_e583, _e584, vec3((_e585 - 1f)));
                    }
                }
            }
            let _e592 = colorSource_1;
            let _e596 = colorSource_1;
            let _e600 = colorSource_1;
            let _e605 = colorSource_1;
            let _e611 = specular_1;
            if (((_e592.w != 0f) && (((_e596.x != 0f) || (_e600.y != 0f)) || (_e605.z != 0f))) || (_e611 != 0f)) {
                {
                    let _e616 = intersection;
                    let _e617 = lightDir;
                    let _e621 = lightDir;
                    let _e622 = mode_9;
                    let _e623 = colorGlow_9;
                    let _e624 = thickness_9;
                    let _e625 = variability_11;
                    let _e626 = randomSeed_9;
                    let _e627 = clamper_8;
                    let _e628 = iterations_9;
                    let _e629 = fractMat_8;
                    let _e630 = glowParams_8;
                    let _e631 = internalIter_9;
                    let _e632 = rayMarch((_e616 + (_e617 * 0.01f)), _e621, _e622, _e623, _e624, _e625, _e626, _e627, _e628, _e629, _e630, _e631);
                    if (_e632[0].x == 100000000000000000000f) {
                        local_11 = 1f;
                    } else {
                        local_11 = 0f;
                    }
                    let _e640 = local_11;
                    light = _e640;
                    let _e641 = colorAmbient_1;
                    let _e643 = col;
                    let _e645 = light;
                    let _e646 = illum;
                    let _e648 = colorSource_1;
                    let _e651 = col;
                    col = ((_e641.xyz * _e643) + (((_e645 * _e646) * _e648.xyz) * _e651));
                }
            } else {
                {
                    let _e654 = colorAmbient_1;
                    let _e656 = col;
                    col = (_e654.xyz * _e656);
                }
            }
            let _e658 = light;
            let _e659 = specular_1;
            let _e666 = dir_2;
            let _e667 = normal;
            let _e670 = lightDir;
            spec = (_e658 * clamp((max(((_e659 * 0.01f) - 0.5f), 0f) + dot(normalize(reflect(_e666, _e667)), _e670)), 0f, 1f));
            let _e678 = col;
            let _e679 = specular_1;
            let _e680 = colorSource_1;
            let _e685 = spec;
            let _e687 = specular_1;
            col = (_e678 + (((_e679 * _e680.xyz) * 0.04f) * pow(_e685, (20f - (_e687 * 0.1f)))));
        }
    } else {
        {
            let _e696 = backgroundStyle_1;
            let _e697 = BKG_STYLES;
            bkgStyle = (_e696 * (_e697 - 1f));
            let _e703 = bkgStyle;
            if (_e703 <= 2f) {
                {
                    let _e706 = sourceBkg_specified_1;
                    hasBkg = (_e706 == 1i);
                    let _e710 = backgroundMode_1;
                    if (_e710 == 1i) {
                        {
                            let _e713 = hasBkg;
                            if _e713 {
                                let _e714 = sourceBkgDim_1;
                                local_12 = _e714;
                            } else {
                                let _e715 = sourceDim_1;
                                local_12 = _e715;
                            }
                            let _e717 = local_12;
                            sDim = _e717;
                            let _e719 = dir_2;
                            let _e722 = dir_2;
                            let _e725 = dir_2;
                            let _e728 = dir_2;
                            pos = vec2<f32>((-(_e719.x) / _e722.z), (-(_e725.y) / _e728.z));
                            let _e733 = pos;
                            let _e736 = pos;
                            m = max(abs(_e733.x), abs(_e736.y));
                            let _e743 = m;
                            darken = (4f / max(4f, _e743));
                            let _e747 = hasBkg;
                            if _e747 {
                                let _e748 = pos;
                                let _e752 = global.U[0];
                                let _e755 = pos;
                                let _e764 = _mirror_wrap(((vec2<f32>((_e748.x / _e752.x), _e755.y) / vec2(2f)) + vec2(0.5f)));
                                let _e766 = textureSampleLevel(t_sourceBkg, samp, _e764, 0f);
                                local_13 = _e766;
                            } else {
                                let _e767 = pos;
                                let _e771 = global.U[0];
                                let _e774 = pos;
                                let _e783 = _mirror_wrap(((vec2<f32>((_e767.x / _e771.x), _e774.y) / vec2(2f)) + vec2(0.5f)));
                                let _e785 = textureSampleLevel(t_source, samp, _e783, 0f);
                                local_13 = _e785;
                            }
                            let _e787 = local_13;
                            let _e788 = darken;
                            let _e789 = darken;
                            let _e790 = darken;
                            bkgCol = (_e787 * vec4<f32>(_e788, _e789, _e790, 1f));
                        }
                    } else {
                        let _e794 = backgroundMode_1;
                        if (_e794 == 2i) {
                            {
                                let _e797 = hasBkg;
                                if _e797 {
                                    let _e798 = sourceBkgDim_1;
                                    local_14 = _e798;
                                } else {
                                    let _e799 = sourceDim_1;
                                    local_14 = _e799;
                                }
                                let _e801 = local_14;
                                sDim_1 = _e801;
                                let _e803 = sDim_1;
                                let _e805 = sDim_1;
                                ratio = (_e803.y / _e805.x);
                                let _e813 = dir_2;
                                let _e816 = dir_2;
                                let _e819 = ratio;
                                let _e822 = dir_2;
                                let _e825 = dir_2;
                                let _e828 = ratio;
                                if ((abs(_e813.y) > (abs(_e816.z) * _e819)) && (abs(_e822.y) > (abs(_e825.x) * _e828))) {
                                    {
                                        let _e832 = X;
                                        let _e833 = dir_2;
                                        let _e836 = dir_2;
                                        X = (_e832 + ((-(_e833.x) / _e836.y) * 0.5f));
                                        let _e842 = Y;
                                        let _e843 = dir_2;
                                        let _e846 = dir_2;
                                        Y = (_e842 + ((-(_e843.z) / _e846.y) * 0.5f));
                                    }
                                } else {
                                    let _e852 = dir_2;
                                    let _e855 = dir_2;
                                    if (abs(_e852.x) < abs(_e855.z)) {
                                        {
                                            let _e859 = X;
                                            let _e860 = dir_2;
                                            let _e862 = dir_2;
                                            let _e866 = ratio;
                                            let _e870 = dir_2;
                                            X = (_e859 + ((((_e860.x / abs(_e862.z)) * _e866) * 0.5f) * -(sign(_e870.z))));
                                            let _e876 = Y;
                                            let _e877 = dir_2;
                                            let _e879 = dir_2;
                                            Y = (_e876 + ((_e877.y / abs(_e879.z)) * 0.5f));
                                        }
                                    } else {
                                        {
                                            let _e886 = X;
                                            let _e887 = dir_2;
                                            let _e889 = dir_2;
                                            let _e893 = ratio;
                                            let _e897 = dir_2;
                                            X = (_e886 + ((((_e887.z / abs(_e889.x)) * _e893) * 0.5f) * -(sign(_e897.x))));
                                            let _e903 = Y;
                                            let _e904 = dir_2;
                                            let _e906 = dir_2;
                                            Y = (_e903 + ((_e904.y / abs(_e906.x)) * 0.5f));
                                        }
                                    }
                                }
                                let _e913 = X;
                                let _e914 = Y;
                                pos_1 = ((vec2<f32>(_e913, _e914) * 2f) - vec2(1f));
                                let _e923 = pos_1;
                                let _e925 = sDim_1;
                                let _e927 = sDim_1;
                                pos_1.x = (_e923.x * (_e925.x / _e927.y));
                                let _e931 = hasBkg;
                                if _e931 {
                                    let _e932 = pos_1;
                                    let _e936 = global.U[0];
                                    let _e939 = pos_1;
                                    let _e948 = _mirror_wrap(((vec2<f32>((_e932.x / _e936.x), _e939.y) / vec2(2f)) + vec2(0.5f)));
                                    let _e950 = textureSampleLevel(t_sourceBkg, samp, _e948, 0f);
                                    local_15 = _e950;
                                } else {
                                    let _e951 = pos_1;
                                    let _e955 = global.U[0];
                                    let _e958 = pos_1;
                                    let _e967 = _mirror_wrap(((vec2<f32>((_e951.x / _e955.x), _e958.y) / vec2(2f)) + vec2(0.5f)));
                                    let _e969 = textureSampleLevel(t_source, samp, _e967, 0f);
                                    local_15 = _e969;
                                }
                                let _e971 = local_15;
                                bkgCol = _e971;
                            }
                        } else {
                            {
                                let _e972 = dir_2;
                                n = normalize(_e972);
                                let _e975 = n;
                                let _e977 = n;
                                alpha = atan2(_e975.z, _e977.x);
                                let _e981 = n;
                                beta = asin(_e981.y);
                                let _e989 = hasBkg;
                                if _e989 {
                                    let _e990 = sourceBkgDim_1;
                                    local_16 = _e990;
                                } else {
                                    let _e991 = sourceDim_1;
                                    local_16 = _e991;
                                }
                                let _e993 = local_16;
                                sDim_2 = _e993;
                                let _e995 = alpha;
                                let _e1001 = nX;
                                let _e1004 = nY;
                                let _e1005 = beta;
                                pos_2 = ((vec2<f32>((((-(_e995) / 3.1415927f) * 0.5f) * _e1001), (0.5f + ((_e1004 * _e1005) / 3.1415927f))) * 2f) - vec2(1f));
                                let _e1018 = pos_2;
                                let _e1020 = sDim_2;
                                let _e1022 = sDim_2;
                                pos_2.x = (_e1018.x * (_e1020.x / _e1022.y));
                                let _e1026 = hasBkg;
                                if _e1026 {
                                    let _e1027 = pos_2;
                                    let _e1031 = global.U[0];
                                    let _e1034 = pos_2;
                                    let _e1043 = _mirror_wrap(((vec2<f32>((_e1027.x / _e1031.x), _e1034.y) / vec2(2f)) + vec2(0.5f)));
                                    let _e1045 = textureSampleLevel(t_sourceBkg, samp, _e1043, 0f);
                                    local_17 = _e1045;
                                } else {
                                    let _e1046 = pos_2;
                                    let _e1050 = global.U[0];
                                    let _e1053 = pos_2;
                                    let _e1062 = _mirror_wrap(((vec2<f32>((_e1046.x / _e1050.x), _e1053.y) / vec2(2f)) + vec2(0.5f)));
                                    let _e1064 = textureSampleLevel(t_source, samp, _e1062, 0f);
                                    local_17 = _e1064;
                                }
                                let _e1066 = local_17;
                                bkgCol = _e1066;
                            }
                        }
                    }
                }
            }
            let _e1067 = lightPos;
            let _e1068 = cameraPos;
            lightDir_1 = normalize((_e1067 - _e1068));
            let _e1072 = bkgStyle;
            if (_e1072 <= 1f) {
                {
                    let _e1075 = lightDir_1;
                    let _e1076 = dir_2;
                    lightProx = dot(_e1075, _e1076);
                    let _e1079 = bkgCol;
                    let _e1081 = bkgStyle;
                    let _e1084 = lightProx;
                    let _e1092 = colorSource_1;
                    col = (_e1079.xyz + (((_e1081 * 0.2f) * pow(((_e1084 + 1f) / 1.95f), 100f)) * _e1092.xyz));
                }
            } else {
                let _e1096 = bkgStyle;
                if (_e1096 <= 2f) {
                    {
                        let _e1099 = lightDir_1;
                        let _e1100 = dir_2;
                        lightProx_1 = dot(_e1099, _e1100);
                        let _e1103 = bkgCol;
                        let _e1106 = lightProx_1;
                        let _e1114 = colorSource_1;
                        colImg = (_e1103.xyz + ((0.2f * pow(((_e1106 + 1f) / 1.95f), 100f)) * _e1114.xyz));
                        let _e1119 = dir_2;
                        let _e1121 = lightDir_1;
                        let _e1122 = dir_2;
                        colSpectrum = (abs(_e1119) + vec3(pow(((dot(_e1121, _e1122) + 1f) / 1.95f), 50f)));
                        let _e1133 = colImg;
                        let _e1134 = colSpectrum;
                        let _e1135 = bkgStyle;
                        col = mix(_e1133, _e1134, vec3((_e1135 - 1f)));
                    }
                } else {
                    let _e1140 = bkgStyle;
                    if (_e1140 <= 3f) {
                        {
                            let _e1143 = dir_2;
                            let _e1145 = lightDir_1;
                            let _e1146 = dir_2;
                            colSpectrum_1 = (abs(_e1143) + vec3(pow(((dot(_e1145, _e1146) + 1f) / 1.95f), 50f)));
                            let _e1157 = lightDir_1;
                            let _e1158 = dir_2;
                            lightProx_2 = dot(_e1157, _e1158);
                            let _e1169 = lightProx_2;
                            let _e1177 = lightProx_2;
                            let _e1185 = colorSource_1;
                            colDay = (mix(vec3<f32>(0.03f, 0.12f, 0.82f), vec3<f32>(0.2f, 0.4f, 1f), vec3(((_e1169 + 1f) / 2f))) + ((0.2f * pow(((_e1177 + 1f) / 1.95f), 100f)) * _e1185.xyz));
                            let _e1190 = colSpectrum_1;
                            let _e1191 = colDay;
                            let _e1192 = bkgStyle;
                            col = mix(_e1190, _e1191, vec3((_e1192 - 2f)));
                        }
                    } else {
                        {
                            let _e1197 = lightDir_1;
                            let _e1198 = dir_2;
                            lightProx_3 = dot(_e1197, _e1198);
                            let _e1209 = lightProx_3;
                            let _e1217 = lightProx_3;
                            let _e1225 = colorSource_1;
                            colDay_1 = (mix(vec3<f32>(0f, 0.14f, 0.85f), vec3<f32>(0.2f, 0.4f, 1f), vec3(((_e1209 + 1f) / 2f))) + ((0.2f * pow(((_e1217 + 1f) / 1.95f), 100f)) * _e1225.xyz));
                            let _e1232 = dir_2;
                            let _e1233 = R;
                            let _e1239 = R;
                            center = (floor(((_e1232 * _e1233) + vec3(0.5f))) / vec3(_e1239));
                            let _e1243 = center;
                            let _e1244 = hash3_(_e1243);
                            mag = (pow(_e1244, 10f) * 40f);
                            let _e1252 = mag;
                            let _e1255 = center;
                            let _e1256 = dir_2;
                            stars1_ = smoothstep(0.3f, 1f, ((_e1252 * 0.00000001f) / pow(length((_e1255 - _e1256)), 2.5f)));
                            R = 400f;
                            let _e1265 = dir_2;
                            let _e1266 = R;
                            let _e1272 = R;
                            center = (floor(((_e1265 * _e1266) + vec3(0.5f))) / vec3(_e1272));
                            let _e1275 = center;
                            let _e1276 = hash3_(_e1275);
                            mag = (pow(_e1276, 100f) * 4f);
                            let _e1283 = mag;
                            let _e1286 = center;
                            let _e1287 = dir_2;
                            stars2_ = smoothstep(0.3f, 1f, ((_e1283 * 0.00000001f) / pow(length((_e1286 - _e1287)), 2.5f)));
                            let _e1296 = lightProx_3;
                            mainStar = pow((max(0f, _e1296) * 1.001f), 1000f);
                            let _e1305 = stars1_;
                            let _e1308 = stars2_;
                            let _e1311 = mainStar;
                            let _e1312 = colorSource_1;
                            colNight = (((vec3(0f) + vec3(_e1305)) + vec3(_e1308)) + (_e1311 * _e1312.xyz));
                            let _e1317 = colDay_1;
                            let _e1318 = colNight;
                            let _e1319 = bkgStyle;
                            col = mix(_e1317, _e1318, vec3((_e1319 - 3f)));
                        }
                    }
                }
            }
        }
    }
    let _e1324 = col;
    let _e1325 = glowI;
    let _e1326 = colorGlow_9;
    let _e1329 = colorGlow_9;
    col = (_e1324 + ((_e1325 * _e1326.w) * _e1329.xyz));
    let _e1333 = intersection;
    let _e1337 = glowK;
    let _e1341 = glowK;
    if (((_e1333.x != 100000000000000000000f) && (_e1337 > 0f)) && (_e1341 < 4f)) {
        {
            let _e1345 = glowK;
            let _e1348 = upStayDown(_e1345, 1f, 2f);
            glow0_ = _e1348;
            let _e1350 = glowK;
            let _e1353 = upStayDown(_e1350, 2f, 3f);
            glow1_ = _e1353;
            let _e1355 = col;
            let _e1359 = glowIterations;
            let _e1363 = colorGlow_9;
            let _e1373 = glow0_;
            let _e1374 = colorGlow_9;
            col = mix(_e1355, max(vec3(0f), (vec3(1.5f) - ((_e1359 * 0.1f) * (vec3(1f) - (_e1363.xyz * 0.5f))))), vec3((_e1373 * _e1374.w)));
            let _e1379 = col;
            let _e1380 = colorGlow_9;
            let _e1382 = glowIterations;
            let _e1387 = glow1_;
            let _e1388 = colorGlow_9;
            col = mix(_e1379, ((_e1380.xyz * vec3(_e1382)) * 0.01f), vec3((_e1387 * _e1388.w)));
        }
    }
    let _e1393 = fog_1;
    if (_e1393 != 0f) {
        {
            let _e1396 = fog_1;
            fog_1 = (_e1396 * 100f);
            let _e1399 = fog_1;
            if (_e1399 < 10f) {
                let _e1403 = fog_1;
                local_18 = (10000000000f / pow(_e1403, 10f));
            } else {
                let _e1408 = fog_1;
                let _e1409 = fog_1;
                local_18 = (100f / (_e1408 * _e1409));
            }
            let _e1413 = local_18;
            near = _e1413;
            let _e1415 = near;
            far = (_e1415 * 10f);
            let _e1419 = col;
            let _e1420 = colorFog_1;
            let _e1422 = near;
            let _e1423 = far;
            let _e1424 = origin_2;
            let _e1425 = intersection;
            col = mix(_e1419, _e1420.xyz, vec3(smoothstep(_e1422, _e1423, length((_e1424 - _e1425.xyz)))));
        }
    }
    let _e1432 = col;
    let _e1434 = gamma_1;
    col = pow(_e1432, vec3((1f - _e1434)));
    let _e1438 = col;
    return vec4<f32>(_e1438.x, _e1438.y, _e1438.z, 1f);
}

fn main_1() {
    let _e11 = global.U[1];
    let _e12 = _e11.xyz;
    let _e15 = global.U[2];
    let _e16 = _e15.xyz;
    let _e19 = global.U[3];
    let _e20 = _e19.xyz;
    let _e35 = v_uv_1;
    let _e43 = global.U[0];
    let _e47 = (((_e35 - vec2(0.5f)) * 2f) * vec2<f32>(_e43.x, 1f));
    let _e54 = v_uv_1;
    let _e62 = global.U[0];
    let _e69 = global.U[8];
    let _e74 = global.U[9];
    let _e77 = global.U[10];
    let _e80 = global.U[11];
    let _e83 = global.U[12];
    let _e107 = global.U[13];
    let _e110 = global.U[14];
    let _e113 = global.U[15];
    let _e116 = global.U[16];
    let _e140 = global.U[17];
    let _e143 = global.U[18];
    let _e146 = global.U[19];
    let _e149 = global.U[20];
    let _e173 = global.U[21];
    let _e176 = global.U[22];
    let _e179 = global.U[23];
    let _e182 = global.U[24];
    let _e206 = global.U[4];
    let _e210 = global.U[5];
    let _e214 = global.U[6];
    let _e219 = global.U[25];
    let _e224 = global.U[26];
    let _e229 = global.U[27];
    let _e233 = global.U[28];
    let _e237 = global.U[29];
    let _e241 = global.U[30];
    let _e245 = global.U[31];
    let _e248 = global.U[32];
    let _e251 = global.U[33];
    let _e254 = global.U[34];
    let _e257 = global.U[35];
    let _e261 = global.U[36];
    let _e266 = global.U[37];
    let _e270 = global.U[38];
    let _e274 = global.U[39];
    let _e278 = global.U[40];
    let _e280 = mengerSponge((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e12.x, _e12.y, _e12.z), vec3<f32>(_e16.x, _e16.y, _e16.z), vec3<f32>(_e20.x, _e20.y, _e20.z))) * vec3<f32>(_e47.x, _e47.y, 1f)).xy, (((_e54 - vec2(0.5f)) * 2f) * vec2<f32>(_e62.x, 1f)), i32(_e69.x), mat4x4<f32>(vec4<f32>(_e74.x, _e74.y, _e74.z, _e74.w), vec4<f32>(_e77.x, _e77.y, _e77.z, _e77.w), vec4<f32>(_e80.x, _e80.y, _e80.z, _e80.w), vec4<f32>(_e83.x, _e83.y, _e83.z, _e83.w)), mat4x4<f32>(vec4<f32>(_e107.x, _e107.y, _e107.z, _e107.w), vec4<f32>(_e110.x, _e110.y, _e110.z, _e110.w), vec4<f32>(_e113.x, _e113.y, _e113.z, _e113.w), vec4<f32>(_e116.x, _e116.y, _e116.z, _e116.w)), mat4x4<f32>(vec4<f32>(_e140.x, _e140.y, _e140.z, _e140.w), vec4<f32>(_e143.x, _e143.y, _e143.z, _e143.w), vec4<f32>(_e146.x, _e146.y, _e146.z, _e146.w), vec4<f32>(_e149.x, _e149.y, _e149.z, _e149.w)), mat4x4<f32>(vec4<f32>(_e173.x, _e173.y, _e173.z, _e173.w), vec4<f32>(_e176.x, _e176.y, _e176.z, _e176.w), vec4<f32>(_e179.x, _e179.y, _e179.z, _e179.w), vec4<f32>(_e182.x, _e182.y, _e182.z, _e182.w)), _e206.xy, _e210.xy, i32(_e214.x), i32(_e219.x), i32(_e224.x), _e229.x, _e233.x, _e237.x, _e241.x, _e245, _e248, _e251, _e254, _e257.x, i32(_e261.x), _e266.x, _e270.x, _e274.x, _e278.x);
    fragColor = _e280;
    return;
}

@fragment 
fn main(@location(0) v_uv: vec2<f32>) -> FragmentOutput {
    v_uv_1 = v_uv;
    main_1();
    let _e17 = fragColor;
    return FragmentOutput(_e17);
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
