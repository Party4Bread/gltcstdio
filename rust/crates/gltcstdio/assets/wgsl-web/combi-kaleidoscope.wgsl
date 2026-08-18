struct Params {
    U: array<vec4<f32>, 25>,
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
var t_source1_: texture_2d<f32>;
@group(0) @binding(3) 
var t_source2_: texture_2d<f32>;

fn _mirror_wrap(c: vec2<f32>) -> vec2<f32> {
    var c_1: vec2<f32>;

    c_1 = c;
    let _e10 = c_1;
    let _e12 = vec2(2f);
    return (vec2(1f) - abs(((_e10 - (floor((_e10 / _e12)) * _e12)) - vec2(1f))));
}

fn mergeColor(bkg: vec4<f32>, front: vec4<f32>) -> vec4<f32> {
    var bkg_1: vec4<f32>;
    var front_1: vec4<f32>;

    bkg_1 = bkg;
    front_1 = front;
    let _e11 = bkg_1;
    let _e13 = front_1;
    let _e15 = front_1;
    let _e18 = bkg_1;
    let _e22 = front_1;
    let _e28 = mix(_e11.xyz, _e13.xyz, vec3((_e15.w + ((1f - _e18.w) * (1f - _e22.w)))));
    let _e29 = bkg_1;
    let _e31 = front_1;
    return vec4<f32>(_e28.x, _e28.y, _e28.z, max(_e29.w, _e31.w));
}

fn sdStar(u: vec2<f32>, spikeCount: i32, r: f32, m: f32) -> f32 {
    var u_1: vec2<f32>;
    var spikeCount_1: i32;
    var r_1: f32;
    var m_1: f32;
    var an: f32;
    var en: f32;
    var acs: vec2<f32>;
    var ecs: vec2<f32>;
    var bn: f32;

    u_1 = u;
    spikeCount_1 = spikeCount;
    r_1 = r;
    m_1 = m;
    let _e16 = spikeCount_1;
    an = (3.1415927f / f32(_e16));
    let _e21 = m_1;
    en = (3.1415927f / _e21);
    let _e24 = an;
    let _e26 = an;
    acs = vec2<f32>(cos(_e24), sin(_e26));
    let _e30 = en;
    let _e32 = en;
    ecs = vec2<f32>(cos(_e30), sin(_e32));
    let _e36 = u_1;
    let _e38 = u_1;
    let _e40 = atan2(_e36.x, _e38.y);
    let _e42 = an;
    let _e43 = (2f * _e42);
    let _e48 = an;
    bn = ((_e40 - (floor((_e40 / _e43)) * _e43)) - _e48);
    let _e51 = u_1;
    let _e53 = bn;
    let _e55 = bn;
    u_1 = (length(_e51) * vec2<f32>(cos(_e53), abs(sin(_e55))));
    let _e60 = u_1;
    let _e61 = r_1;
    let _e62 = acs;
    u_1 = (_e60 - (_e61 * _e62));
    let _e65 = u_1;
    let _e66 = ecs;
    let _e67 = u_1;
    let _e68 = ecs;
    let _e72 = r_1;
    let _e73 = acs;
    let _e76 = ecs;
    u_1 = (_e65 + (_e66 * clamp(-(dot(_e67, _e68)), 0f, ((_e72 * _e73.y) / _e76.y))));
    let _e82 = u_1;
    let _e84 = u_1;
    return (length(_e82) * sign(_e84.x));
}

fn sdVesica(u_2: vec2<f32>, r_2: f32, d: f32) -> f32 {
    var u_3: vec2<f32>;
    var r_3: f32;
    var d_1: f32;
    var b: f32;
    var local: f32;

    u_3 = u_2;
    r_3 = r_2;
    d_1 = d;
    let _e13 = u_3;
    u_3 = abs(_e13);
    let _e15 = r_3;
    let _e16 = r_3;
    let _e18 = d_1;
    let _e19 = d_1;
    b = sqrt(((_e15 * _e16) - (_e18 * _e19)));
    let _e24 = u_3;
    let _e26 = b;
    let _e28 = d_1;
    let _e30 = u_3;
    let _e32 = b;
    if (((_e24.y - _e26) * _e28) > (_e30.x * _e32)) {
        let _e35 = u_3;
        let _e37 = b;
        local = length((_e35 - vec2<f32>(0f, _e37)));
    } else {
        let _e41 = u_3;
        let _e42 = d_1;
        let _e48 = r_3;
        local = (length((_e41 - vec2<f32>(-(_e42), 0f))) - _e48);
    }
    let _e51 = local;
    return _e51;
}

fn shapeSdf(u_4: vec2<f32>, spikeCount_2: i32, shape: f32) -> f32 {
    var u_5: vec2<f32>;
    var spikeCount_3: i32;
    var shape_1: f32;
    var k: f32;
    var radius: f32 = 0.66666f;
    var starMul: f32;
    var d1_: f32;
    var d2_: f32;
    var kk: f32;
    var m_2: f32;
    var m_3: f32;
    var d1_1: f32;
    var d2_1: f32;
    var d1_2: f32;
    var d2_2: f32;

    u_5 = u_4;
    spikeCount_3 = spikeCount_2;
    shape_1 = shape;
    let _e14 = spikeCount_3;
    spikeCount_3 = max(3i, _e14);
    let _e16 = shape_1;
    k = fract(_e16);
    let _e22 = radius;
    starMul = (0.9f / _e22);
    let _e25 = shape_1;
    if (_e25 < 1f) {
        {
            let _e28 = u_5;
            let _e30 = radius;
            d1_ = (length(_e28) - _e30);
            let _e33 = u_5;
            let _e35 = u_5;
            let _e39 = starMul;
            let _e41 = spikeCount_3;
            let _e44 = sdStar((vec2<f32>(_e33.x, -(_e35.y)) * _e39), _e41, 1f, 2f);
            d2_ = _e44;
            let _e46 = d1_;
            let _e47 = d2_;
            let _e48 = k;
            return mix(_e46, _e47, _e48);
        }
    } else {
        let _e50 = shape_1;
        if (_e50 < 2f) {
            {
                let _e53 = k;
                kk = (_e53 * 0.75f);
                let _e58 = kk;
                let _e59 = kk;
                let _e61 = spikeCount_3;
                m_2 = (2f + ((_e58 * _e59) * (f32(_e61) - 2f)));
                let _e68 = u_5;
                let _e70 = u_5;
                let _e74 = starMul;
                let _e76 = spikeCount_3;
                let _e78 = m_2;
                let _e79 = sdStar((vec2<f32>(_e68.x, -(_e70.y)) * _e74), _e76, 1f, _e78);
                return _e79;
            }
        } else {
            let _e80 = shape_1;
            if (_e80 < 3f) {
                {
                    let _e87 = spikeCount_3;
                    m_3 = (2f + (0.5625f * (f32(_e87) - 2f)));
                    let _e94 = u_5;
                    let _e96 = u_5;
                    let _e100 = starMul;
                    let _e102 = spikeCount_3;
                    let _e104 = m_3;
                    let _e105 = sdStar((vec2<f32>(_e94.x, -(_e96.y)) * _e100), _e102, 1f, _e104);
                    d1_1 = _e105;
                    let _e107 = u_5;
                    let _e110 = radius;
                    let _e111 = radius;
                    let _e114 = sdVesica((_e107 * 0.75f), _e110, (_e111 * 0.5f));
                    d2_1 = _e114;
                    let _e116 = d1_1;
                    let _e117 = d2_1;
                    let _e118 = k;
                    return mix(_e116, _e117, _e118);
                }
            } else {
                {
                    let _e120 = shape_1;
                    k = (_e120 - 3f);
                    let _e123 = u_5;
                    let _e126 = radius;
                    let _e127 = radius;
                    let _e130 = sdVesica((_e123 * 0.75f), _e126, (_e127 * 0.5f));
                    d1_2 = _e130;
                    let _e132 = u_5;
                    let _e134 = radius;
                    d2_2 = (length(_e132) - _e134);
                    let _e137 = d1_2;
                    let _e138 = d2_2;
                    let _e139 = k;
                    return mix(_e137, _e138, _e139);
                }
            }
        }
    }
}

fn tf(m_4: mat3x3<f32>, u_6: vec2<f32>) -> vec2<f32> {
    var m_5: mat3x3<f32>;
    var u_7: vec2<f32>;

    m_5 = m_4;
    u_7 = u_6;
    let _e11 = m_5;
    let _e12 = u_7;
    return (_e11 * vec3<f32>(_e12.x, _e12.y, 1f)).xy;
}

fn combiKaleidoscope(uv: vec2<f32>, outPos: vec2<f32>, source2_specified: i32, spikeCount_4: i32, border: f32, shadows: f32, borderColor: vec4<f32>, colorShadow: vec4<f32>, blend: f32, transformPairing: i32, shape_2: f32, modelTransform: mat3x3<f32>, modelTransform2_: mat3x3<f32>, borderTransform: mat3x3<f32>, offset: f32, stretch: f32) -> vec4<f32> {
    var uv_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var source2_specified_1: i32;
    var spikeCount_5: i32;
    var border_1: f32;
    var shadows_1: f32;
    var borderColor_1: vec4<f32>;
    var colorShadow_1: vec4<f32>;
    var blend_1: f32;
    var transformPairing_1: i32;
    var shape_3: f32;
    var modelTransform_1: mat3x3<f32>;
    var modelTransform2_1: mat3x3<f32>;
    var borderTransform_1: mat3x3<f32>;
    var offset_1: f32;
    var stretch_1: f32;
    var u_8: vec2<f32>;
    var a: f32;
    var period: f32;
    var halfPeriod: f32;
    var index: f32;
    var bu: vec2<f32>;
    var dist: f32;
    var inside: bool;
    var outColor: vec4<f32>;
    var d_2: f32;
    var u1_: vec2<f32>;
    var local_1: mat3x3<f32>;
    var transform2_: mat3x3<f32>;
    var u2_: vec2<f32>;
    var local_2: vec4<f32>;
    var local_3: vec4<f32>;
    var c1_: vec4<f32>;
    var local_4: vec4<f32>;
    var c2_: vec4<f32>;
    var bk: f32;
    var adist: f32;
    var local_5: f32;
    var ds: f32;

    uv_1 = uv;
    outPos_1 = outPos;
    source2_specified_1 = source2_specified;
    spikeCount_5 = spikeCount_4;
    border_1 = border;
    shadows_1 = shadows;
    borderColor_1 = borderColor;
    colorShadow_1 = colorShadow;
    blend_1 = blend;
    transformPairing_1 = transformPairing;
    shape_3 = shape_2;
    modelTransform_1 = modelTransform;
    modelTransform2_1 = modelTransform2_;
    borderTransform_1 = borderTransform;
    offset_1 = offset;
    stretch_1 = stretch;
    let _e39 = uv_1;
    u_8 = _e39;
    let _e41 = u_8;
    let _e43 = u_8;
    a = abs(atan2(_e41.x, _e43.y));
    let _e49 = spikeCount_5;
    period = (6.2831855f / f32(_e49));
    let _e53 = period;
    halfPeriod = (_e53 * 0.5f);
    let _e57 = a;
    let _e58 = period;
    index = floor((_e57 / _e58));
    let _e62 = a;
    let _e63 = period;
    a = (_e62 - (floor((_e62 / _e63)) * _e63));
    let _e68 = a;
    let _e69 = halfPeriod;
    if (_e68 > _e69) {
        {
            let _e71 = period;
            let _e72 = a;
            a = (_e71 - _e72);
            let _e74 = offset_1;
            let _e75 = index;
            let _e79 = halfPeriod;
            let _e80 = offset_1;
            let _e81 = index;
            let _e86 = a;
            let _e87 = halfPeriod;
            a = mix((_e74 * (_e75 + 1f)), (_e79 + (_e80 * (_e81 + 1f))), (_e86 / _e87));
        }
    } else {
        {
            let _e90 = offset_1;
            let _e91 = index;
            let _e93 = halfPeriod;
            let _e94 = offset_1;
            let _e95 = index;
            let _e100 = a;
            let _e101 = halfPeriod;
            a = mix((_e90 * _e91), (_e93 + (_e94 * (_e95 + 1f))), (_e100 / _e101));
        }
    }
    let _e104 = borderTransform_1;
    let _e106 = u_8;
    let _e107 = tf(_naga_inverse_3x3_f32(_e104), _e106);
    bu = _e107;
    let _e109 = bu;
    let _e110 = spikeCount_5;
    let _e111 = shape_3;
    let _e112 = shapeSdf(_e109, _e110, _e111);
    dist = _e112;
    let _e114 = dist;
    inside = (_e114 < 0f);
    let _e119 = u_8;
    d_2 = length(_e119);
    let _e122 = d_2;
    let _e123 = a;
    let _e125 = a;
    u_8 = (_e122 * vec2<f32>(cos(_e123), sin(_e125)));
    let _e129 = modelTransform_1;
    let _e131 = u_8;
    let _e139 = stretch_1;
    let _e142 = d_2;
    u1_ = ((_naga_inverse_3x3_f32(_e129) * vec3<f32>(_e131.x, _e131.y, 1f)).xy * pow(2f, (-(_e139) * max(0f, _e142))));
    let _e148 = transformPairing_1;
    if (_e148 == 0i) {
        let _e151 = modelTransform2_1;
        local_1 = _e151;
    } else {
        let _e152 = modelTransform_1;
        let _e153 = modelTransform2_1;
        local_1 = (_e152 * _e153);
    }
    let _e156 = local_1;
    transform2_ = _e156;
    let _e158 = transform2_;
    let _e160 = u_8;
    let _e168 = stretch_1;
    let _e171 = d_2;
    u2_ = ((_naga_inverse_3x3_f32(_e158) * vec3<f32>(_e160.x, _e160.y, 1f)).xy * pow(2f, (-(_e168) * max(0f, _e171))));
    let _e177 = blend_1;
    if (_e177 == 0f) {
        {
            let _e180 = inside;
            if _e180 {
                let _e181 = u1_;
                let _e185 = global.U[0];
                let _e188 = u1_;
                let _e197 = _mirror_wrap(((vec2<f32>((_e181.x / _e185.x), _e188.y) / vec2(2f)) + vec2(0.5f)));
                let _e199 = textureSampleLevel(t_source1_, samp, _e197, 0f);
                local_3 = _e199;
            } else {
                let _e200 = source2_specified_1;
                if (_e200 != 1i) {
                    let _e203 = u2_;
                    let _e207 = global.U[0];
                    let _e210 = u2_;
                    let _e219 = _mirror_wrap(((vec2<f32>((_e203.x / _e207.x), _e210.y) / vec2(2f)) + vec2(0.5f)));
                    let _e221 = textureSampleLevel(t_source1_, samp, _e219, 0f);
                    local_2 = _e221;
                } else {
                    let _e222 = u2_;
                    let _e226 = global.U[0];
                    let _e229 = u2_;
                    let _e238 = _mirror_wrap(((vec2<f32>((_e222.x / _e226.x), _e229.y) / vec2(2f)) + vec2(0.5f)));
                    let _e240 = textureSampleLevel(t_source2_, samp, _e238, 0f);
                    local_2 = _e240;
                }
                let _e242 = local_2;
                local_3 = _e242;
            }
            let _e244 = local_3;
            outColor = _e244;
        }
    } else {
        {
            let _e245 = u1_;
            let _e249 = global.U[0];
            let _e252 = u1_;
            let _e261 = _mirror_wrap(((vec2<f32>((_e245.x / _e249.x), _e252.y) / vec2(2f)) + vec2(0.5f)));
            let _e263 = textureSampleLevel(t_source1_, samp, _e261, 0f);
            c1_ = _e263;
            let _e265 = source2_specified_1;
            if (_e265 != 1i) {
                let _e268 = u2_;
                let _e272 = global.U[0];
                let _e275 = u2_;
                let _e284 = _mirror_wrap(((vec2<f32>((_e268.x / _e272.x), _e275.y) / vec2(2f)) + vec2(0.5f)));
                let _e286 = textureSampleLevel(t_source1_, samp, _e284, 0f);
                local_4 = _e286;
            } else {
                let _e287 = u2_;
                let _e291 = global.U[0];
                let _e294 = u2_;
                let _e303 = _mirror_wrap(((vec2<f32>((_e287.x / _e291.x), _e294.y) / vec2(2f)) + vec2(0.5f)));
                let _e305 = textureSampleLevel(t_source2_, samp, _e303, 0f);
                local_4 = _e305;
            }
            let _e307 = local_4;
            c2_ = _e307;
            let _e309 = blend_1;
            let _e311 = blend_1;
            let _e312 = dist;
            bk = smoothstep(-(_e309), _e311, _e312);
            let _e315 = c1_;
            let _e316 = c2_;
            let _e317 = bk;
            outColor = mix(_e315, _e316, vec4(_e317));
        }
    }
    let _e320 = dist;
    adist = abs(_e320);
    let _e323 = adist;
    let _e324 = border_1;
    if (_e323 < (_e324 * 0.1f)) {
        let _e328 = outColor;
        let _e329 = borderColor_1;
        let _e330 = mergeColor(_e328, _e329);
        outColor = _e330;
    } else {
        let _e331 = adist;
        let _e332 = shadows_1;
        if (_e331 < abs(_e332)) {
            {
                let _e335 = shadows_1;
                let _e338 = inside;
                let _e340 = dist;
                let _e341 = shadows_1;
                let _e344 = shadows_1;
                let _e347 = inside;
                let _e350 = dist;
                let _e351 = shadows_1;
                if ((((_e335 < 0f) && _e338) && (_e340 > _e341)) || (((_e344 > 0f) && !(_e347)) && (_e350 < _e351))) {
                    let _e355 = dist;
                    let _e357 = shadows_1;
                    local_5 = (abs(_e355) / abs(_e357));
                } else {
                    local_5 = 1f;
                }
                let _e362 = local_5;
                ds = _e362;
                let _e364 = outColor;
                let _e365 = colorShadow_1;
                let _e366 = _e365.xyz;
                let _e367 = colorShadow_1;
                let _e373 = ds;
                let _e380 = mergeColor(_e364, vec4<f32>(_e366.x, _e366.y, _e366.z, ((_e367.w * 0.8f) * smoothstep(1f, 0f, _e373))));
                outColor = _e380;
            }
        }
    }
    let _e381 = outColor;
    return _e381;
}

fn main_1() {
    let _e9 = global.U[1];
    let _e10 = _e9.xyz;
    let _e13 = global.U[2];
    let _e14 = _e13.xyz;
    let _e17 = global.U[3];
    let _e18 = _e17.xyz;
    let _e33 = v_uv_1;
    let _e41 = global.U[0];
    let _e45 = (((_e33 - vec2(0.5f)) * 2f) * vec2<f32>(_e41.x, 1f));
    let _e52 = v_uv_1;
    let _e60 = global.U[0];
    let _e67 = global.U[4];
    let _e72 = global.U[6];
    let _e77 = global.U[7];
    let _e81 = global.U[8];
    let _e85 = global.U[9];
    let _e88 = global.U[10];
    let _e91 = global.U[11];
    let _e95 = global.U[12];
    let _e100 = global.U[13];
    let _e104 = global.U[14];
    let _e105 = _e104.xyz;
    let _e108 = global.U[15];
    let _e109 = _e108.xyz;
    let _e112 = global.U[16];
    let _e113 = _e112.xyz;
    let _e129 = global.U[17];
    let _e130 = _e129.xyz;
    let _e133 = global.U[18];
    let _e134 = _e133.xyz;
    let _e137 = global.U[19];
    let _e138 = _e137.xyz;
    let _e154 = global.U[20];
    let _e155 = _e154.xyz;
    let _e158 = global.U[21];
    let _e159 = _e158.xyz;
    let _e162 = global.U[22];
    let _e163 = _e162.xyz;
    let _e179 = global.U[23];
    let _e183 = global.U[24];
    let _e185 = combiKaleidoscope((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e10.x, _e10.y, _e10.z), vec3<f32>(_e14.x, _e14.y, _e14.z), vec3<f32>(_e18.x, _e18.y, _e18.z))) * vec3<f32>(_e45.x, _e45.y, 1f)).xy, (((_e52 - vec2(0.5f)) * 2f) * vec2<f32>(_e60.x, 1f)), i32(_e67.x), i32(_e72.x), _e77.x, _e81.x, _e85, _e88, _e91.x, i32(_e95.x), _e100.x, mat3x3<f32>(vec3<f32>(_e105.x, _e105.y, _e105.z), vec3<f32>(_e109.x, _e109.y, _e109.z), vec3<f32>(_e113.x, _e113.y, _e113.z)), mat3x3<f32>(vec3<f32>(_e130.x, _e130.y, _e130.z), vec3<f32>(_e134.x, _e134.y, _e134.z), vec3<f32>(_e138.x, _e138.y, _e138.z)), mat3x3<f32>(vec3<f32>(_e155.x, _e155.y, _e155.z), vec3<f32>(_e159.x, _e159.y, _e159.z), vec3<f32>(_e163.x, _e163.y, _e163.z)), _e179.x, _e183.x);
    fragColor = _e185;
    return;
}

@fragment 
fn main(@location(0) v_uv: vec2<f32>) -> FragmentOutput {
    v_uv_1 = v_uv;
    main_1();
    let _e15 = fragColor;
    return FragmentOutput(_e15);
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
