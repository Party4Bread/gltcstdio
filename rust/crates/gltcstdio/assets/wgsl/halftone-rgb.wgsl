struct Params {
    U: array<vec4<f32>, 23>,
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

fn mergeColor(bkg: vec4<f32>, front: vec4<f32>) -> vec4<f32> {
    var bkg_1: vec4<f32>;
    var front_1: vec4<f32>;

    bkg_1 = bkg;
    front_1 = front;
    let _e10 = bkg_1;
    let _e12 = front_1;
    let _e14 = front_1;
    let _e17 = bkg_1;
    let _e21 = front_1;
    let _e27 = mix(_e10.xyz, _e12.xyz, vec3((_e14.w + ((1f - _e17.w) * (1f - _e21.w)))));
    let _e28 = bkg_1;
    let _e30 = front_1;
    return vec4<f32>(_e27.x, _e27.y, _e27.z, max(_e28.w, _e30.w));
}

fn tf(m: mat3x3<f32>, u: vec2<f32>) -> vec2<f32> {
    var m_1: mat3x3<f32>;
    var u_1: vec2<f32>;

    m_1 = m;
    u_1 = u;
    let _e10 = m_1;
    let _e11 = u_1;
    return (_e10 * vec3<f32>(_e11.x, _e11.y, 1f)).xy;
}

fn patternConcentricLines(transform: mat3x3<f32>, uv: vec2<f32>) -> vec3<f32> {
    var transform_1: mat3x3<f32>;
    var uv_1: vec2<f32>;
    var u_2: vec2<f32>;
    var d: f32;
    var center: vec2<f32>;
    var threshold: f32;

    transform_1 = transform;
    uv_1 = uv;
    let _e10 = transform_1;
    let _e11 = uv_1;
    let _e12 = tf(_e10, _e11);
    u_2 = _e12;
    let _e14 = u_2;
    d = round(length(_e14));
    let _e18 = d;
    let _e19 = u_2;
    center = (_e18 * normalize(_e19));
    let _e23 = u_2;
    let _e24 = center;
    threshold = (length((_e23 - _e24)) * 2f);
    let _e30 = center;
    let _e31 = threshold;
    return vec3<f32>(_e30.x, _e30.y, _e31);
}

fn patternDots(transform_2: mat3x3<f32>, uv_2: vec2<f32>) -> vec3<f32> {
    var transform_3: mat3x3<f32>;
    var uv_3: vec2<f32>;
    var u_3: vec2<f32>;
    var center_1: vec2<f32>;
    var threshold_1: f32;

    transform_3 = transform_2;
    uv_3 = uv_2;
    let _e10 = transform_3;
    let _e11 = uv_3;
    let _e12 = tf(_e10, _e11);
    u_3 = _e12;
    let _e14 = u_3;
    center_1 = round(_e14);
    let _e17 = u_3;
    let _e18 = center_1;
    threshold_1 = (length((_e17 - _e18)) * 2f);
    let _e24 = center_1;
    let _e25 = threshold_1;
    return vec3<f32>(_e24.x, _e24.y, _e25);
}

fn hexCoords(v: vec2<f32>) -> vec4<f32> {
    var v_1: vec2<f32>;
    var r: vec2<f32> = vec2<f32>(1f, 1.7320508f);
    var h: vec2<f32>;
    var a: vec2<f32>;
    var b: vec2<f32>;
    var local: vec2<f32>;
    var hv: vec2<f32>;
    var id: vec2<f32>;

    v_1 = v;
    let _e12 = r;
    h = (_e12 / vec2(2f));
    let _e17 = v_1;
    let _e19 = r;
    let _e25 = v_1;
    let _e27 = r;
    let _e34 = h;
    a = (vec2<f32>((_e17.x - (floor((_e17.x / _e19.x)) * _e19.x)), (_e25.y - (floor((_e25.y / _e27.y)) * _e27.y))) - _e34);
    let _e37 = v_1;
    let _e39 = h;
    let _e41 = (_e37.x - _e39.x);
    let _e42 = r;
    let _e48 = v_1;
    let _e50 = h;
    let _e52 = (_e48.y - _e50.y);
    let _e53 = r;
    let _e60 = h;
    b = (vec2<f32>((_e41 - (floor((_e41 / _e42.x)) * _e42.x)), (_e52 - (floor((_e52 / _e53.y)) * _e53.y))) - _e60);
    let _e63 = a;
    let _e65 = b;
    if (length(_e63) < length(_e65)) {
        let _e68 = a;
        local = _e68;
    } else {
        let _e69 = b;
        local = _e69;
    }
    let _e71 = local;
    hv = _e71;
    let _e73 = v_1;
    let _e74 = hv;
    id = (_e73 - _e74);
    let _e77 = hv;
    let _e78 = id;
    return vec4<f32>(_e77.x, _e77.y, _e78.x, _e78.y);
}

fn patternHexDots(transform_4: mat3x3<f32>, uv_4: vec2<f32>) -> vec3<f32> {
    var transform_5: mat3x3<f32>;
    var uv_5: vec2<f32>;
    var u_4: vec2<f32>;
    var hex: vec4<f32>;
    var threshold_2: f32;

    transform_5 = transform_4;
    uv_5 = uv_4;
    let _e10 = transform_5;
    let _e11 = uv_5;
    let _e12 = tf(_e10, _e11);
    u_4 = _e12;
    let _e14 = u_4;
    let _e15 = hexCoords(_e14);
    hex = _e15;
    let _e17 = hex;
    threshold_2 = (length(_e17.xy) * 2f);
    let _e23 = hex;
    let _e24 = _e23.zw;
    let _e25 = threshold_2;
    return vec3<f32>(_e24.x, _e24.y, _e25);
}

fn patternLines(transform_6: mat3x3<f32>, uv_6: vec2<f32>) -> vec3<f32> {
    var transform_7: mat3x3<f32>;
    var uv_7: vec2<f32>;
    var u_5: vec2<f32>;
    var center_2: vec2<f32>;
    var threshold_3: f32;

    transform_7 = transform_6;
    uv_7 = uv_6;
    let _e10 = transform_7;
    let _e11 = uv_7;
    let _e12 = tf(_e10, _e11);
    u_5 = _e12;
    let _e14 = u_5;
    let _e16 = u_5;
    center_2 = vec2<f32>(_e14.x, round(_e16.y));
    let _e21 = u_5;
    let _e22 = center_2;
    threshold_3 = (length((_e21 - _e22)) * 2f);
    let _e28 = center_2;
    let _e29 = threshold_3;
    return vec3<f32>(_e28.x, _e28.y, _e29);
}

fn patternWavyLines(transform_8: mat3x3<f32>, uv_8: vec2<f32>) -> vec3<f32> {
    var transform_9: mat3x3<f32>;
    var uv_9: vec2<f32>;
    var u_6: vec2<f32>;
    var center_3: vec2<f32>;
    var threshold_4: f32;

    transform_9 = transform_8;
    uv_9 = uv_8;
    let _e10 = transform_9;
    let _e11 = uv_9;
    let _e12 = tf(_e10, _e11);
    u_6 = _e12;
    let _e14 = u_6;
    let _e16 = u_6;
    let _e18 = u_6;
    let _e27 = u_6;
    center_3 = vec2<f32>(_e14.x, (round((_e16.y - (sin((_e18.x * 0.5f)) * 2f))) + (sin((_e27.x * 0.5f)) * 1.5f)));
    let _e37 = u_6;
    let _e38 = center_3;
    threshold_4 = (length((_e37 - _e38)) * 2f);
    let _e44 = center_3;
    let _e45 = threshold_4;
    return vec3<f32>(_e44.x, _e44.y, _e45);
}

fn rotation3_(angle: f32) -> mat3x3<f32> {
    var angle_1: f32;
    var ca: f32;
    var sa: f32;

    angle_1 = angle;
    let _e8 = angle_1;
    ca = cos(_e8);
    let _e11 = angle_1;
    sa = sin(_e11);
    let _e14 = ca;
    let _e15 = sa;
    let _e17 = sa;
    let _e19 = ca;
    return mat3x3<f32>(vec3<f32>(_e14, _e15, 0f), vec3<f32>(-(_e17), _e19, 0f), vec3<f32>(0f, 0f, 1f));
}

fn translation3_(t: vec2<f32>) -> mat3x3<f32> {
    var t_1: vec2<f32>;

    t_1 = t;
    let _e14 = t_1;
    let _e16 = t_1;
    return mat3x3<f32>(vec3<f32>(1f, 0f, 0f), vec3<f32>(0f, 1f, 0f), vec3<f32>(_e14.x, _e16.y, 1f));
}

fn halftoneRGB(uv_10: vec2<f32>, outPos: vec2<f32>, smoothen: f32, intensity: f32, modelTransform: mat3x3<f32>, redTransform: mat3x3<f32>, greenTransform: mat3x3<f32>, blueTransform: mat3x3<f32>, color1_: vec4<f32>, color2_: vec4<f32>, sampling: i32, style: i32) -> vec4<f32> {
    var uv_11: vec2<f32>;
    var outPos_1: vec2<f32>;
    var smoothen_1: f32;
    var intensity_1: f32;
    var modelTransform_1: mat3x3<f32>;
    var redTransform_1: mat3x3<f32>;
    var greenTransform_1: mat3x3<f32>;
    var blueTransform_1: mat3x3<f32>;
    var color1_1: vec4<f32>;
    var color2_1: vec4<f32>;
    var sampling_1: i32;
    var style_1: i32;
    var patternR: vec3<f32>;
    var patternG: vec3<f32>;
    var patternB: vec3<f32>;
    var transformR: mat3x3<f32>;
    var invTransformR: mat3x3<f32>;
    var transformG: mat3x3<f32>;
    var invTransformG: mat3x3<f32>;
    var transformB: mat3x3<f32>;
    var invTransformB: mat3x3<f32>;
    var _sw_sel: i32;
    var thresholdR: f32;
    var thresholdG: f32;
    var thresholdB: f32;
    var color: vec4<f32> = vec4(0f);
    var kR: f32;
    var kG: f32;
    var kB: f32;
    var _sw_sel_1: i32;
    var samplePosR: vec2<f32>;
    var N: i32 = 5i;
    var r_1: f32;
    var step: f32;
    var j: i32;
    var i: i32;
    var local_1: f32;
    var samplePosG: vec2<f32>;
    var N_1: i32 = 5i;
    var r_2: f32;
    var step_1: f32;
    var j_1: i32;
    var i_1: i32;
    var local_2: f32;
    var samplePosB: vec2<f32>;
    var N_2: i32 = 5i;
    var r_3: f32;
    var step_2: f32;
    var j_2: i32;
    var i_2: i32;
    var local_3: f32;
    var samplePos: vec2<f32>;
    var N_3: i32 = 5i;
    var r_4: f32;
    var step_3: f32;
    var j_3: i32;
    var i_3: i32;
    var local_4: f32;
    var local_5: f32;
    var local_6: f32;
    var outColor: vec4<f32>;

    uv_11 = uv_10;
    outPos_1 = outPos;
    smoothen_1 = smoothen;
    intensity_1 = intensity;
    modelTransform_1 = modelTransform;
    redTransform_1 = redTransform;
    greenTransform_1 = greenTransform;
    blueTransform_1 = blueTransform;
    color1_1 = color1_;
    color2_1 = color2_;
    sampling_1 = sampling;
    style_1 = style;
    let _e39 = modelTransform_1;
    transformG = _e39;
    let _e40 = style_1;
    if (_e40 == 3i) {
        {
            let _e43 = modelTransform_1;
            let _e52 = translation3_(vec2<f32>(15f, 25.980762f));
            transformR = (_e43 * _e52);
            let _e54 = modelTransform_1;
            let _e64 = translation3_(vec2<f32>(-15f, 25.980762f));
            transformB = (_e54 * _e64);
        }
    } else {
        let _e66 = style_1;
        if (_e66 == 1i) {
            {
                let _e69 = modelTransform_1;
                let _e71 = rotation3_(0.4f);
                transformR = (_e69 * _e71);
                let _e73 = modelTransform_1;
                let _e75 = rotation3_(1.6f);
                transformB = (_e73 * _e75);
            }
        } else {
            {
                let _e77 = modelTransform_1;
                let _e79 = rotation3_(0.2618f);
                transformR = (_e77 * _e79);
                let _e81 = modelTransform_1;
                let _e83 = rotation3_(1.309f);
                transformB = (_e81 * _e83);
            }
        }
    }
    let _e85 = transformR;
    let _e86 = redTransform_1;
    transformR = (_e85 * _e86);
    let _e88 = transformG;
    let _e89 = greenTransform_1;
    transformG = (_e88 * _e89);
    let _e91 = transformB;
    let _e92 = blueTransform_1;
    transformB = (_e91 * _e92);
    let _e94 = transformR;
    invTransformR = _naga_inverse_3x3_f32(_e94);
    let _e96 = transformG;
    invTransformG = _naga_inverse_3x3_f32(_e96);
    let _e98 = transformB;
    invTransformB = _naga_inverse_3x3_f32(_e98);
    {
        let _e100 = style_1;
        _sw_sel = i32(_e100);
        let _e103 = _sw_sel;
        if (_e103 == 0i) {
            {
                let _e107 = modelTransform_1;
                let _e109 = uv_11;
                let _e110 = patternDots(_naga_inverse_3x3_f32(_e107), _e109);
                patternG = _e110;
                let _e111 = invTransformR;
                let _e112 = uv_11;
                let _e113 = patternDots(_e111, _e112);
                patternR = _e113;
                let _e114 = invTransformB;
                let _e115 = uv_11;
                let _e116 = patternDots(_e114, _e115);
                patternB = _e116;
            }
        } else {
            let _e117 = _sw_sel;
            if (_e117 == 1i) {
                {
                    let _e121 = modelTransform_1;
                    let _e123 = uv_11;
                    let _e124 = patternHexDots(_naga_inverse_3x3_f32(_e121), _e123);
                    patternG = _e124;
                    let _e125 = invTransformR;
                    let _e126 = uv_11;
                    let _e127 = patternHexDots(_e125, _e126);
                    patternR = _e127;
                    let _e128 = invTransformB;
                    let _e129 = uv_11;
                    let _e130 = patternHexDots(_e128, _e129);
                    patternB = _e130;
                }
            } else {
                let _e131 = _sw_sel;
                if (_e131 == 2i) {
                    {
                        let _e135 = modelTransform_1;
                        let _e137 = uv_11;
                        let _e138 = patternLines(_naga_inverse_3x3_f32(_e135), _e137);
                        patternG = _e138;
                        let _e139 = invTransformR;
                        let _e140 = uv_11;
                        let _e141 = patternLines(_e139, _e140);
                        patternR = _e141;
                        let _e142 = invTransformB;
                        let _e143 = uv_11;
                        let _e144 = patternLines(_e142, _e143);
                        patternB = _e144;
                    }
                } else {
                    let _e145 = _sw_sel;
                    if (_e145 == 3i) {
                        {
                            let _e149 = modelTransform_1;
                            let _e151 = uv_11;
                            let _e152 = patternConcentricLines(_naga_inverse_3x3_f32(_e149), _e151);
                            patternG = _e152;
                            let _e153 = invTransformR;
                            let _e154 = uv_11;
                            let _e155 = patternConcentricLines(_e153, _e154);
                            patternR = _e155;
                            let _e156 = invTransformB;
                            let _e157 = uv_11;
                            let _e158 = patternConcentricLines(_e156, _e157);
                            patternB = _e158;
                        }
                    } else {
                        let _e159 = _sw_sel;
                        if (_e159 == 4i) {
                            {
                                let _e163 = modelTransform_1;
                                let _e165 = uv_11;
                                let _e166 = patternWavyLines(_naga_inverse_3x3_f32(_e163), _e165);
                                patternG = _e166;
                                let _e167 = invTransformR;
                                let _e168 = uv_11;
                                let _e169 = patternWavyLines(_e167, _e168);
                                patternR = _e169;
                                let _e170 = invTransformB;
                                let _e171 = uv_11;
                                let _e172 = patternWavyLines(_e170, _e171);
                                patternB = _e172;
                            }
                        }
                    }
                }
            }
        }
    }
    let _e173 = patternR;
    let _e175 = intensity_1;
    thresholdR = (_e173.z * _e175);
    let _e178 = patternG;
    let _e180 = intensity_1;
    thresholdG = (_e178.z * _e180);
    let _e183 = patternB;
    let _e185 = intensity_1;
    thresholdB = (_e183.z * _e185);
    {
        let _e194 = sampling_1;
        _sw_sel_1 = i32(_e194);
        let _e197 = _sw_sel_1;
        if (_e197 == 0i) {
            {
                {
                    let _e201 = transformR;
                    let _e202 = patternR;
                    let _e204 = tf(_e201, _e202.xy);
                    samplePosR = _e204;
                    let _e206 = smoothen_1;
                    if (_e206 > 0f) {
                        {
                            let _e213 = transformR[0];
                            let _e216 = smoothen_1;
                            r_1 = ((length(_e213.xy) * _e216) * 3f);
                            let _e221 = r_1;
                            let _e222 = N;
                            step = (_e221 / f32(_e222));
                            let _e226 = N;
                            j = -(_e226);
                            loop {
                                let _e229 = j;
                                let _e230 = N;
                                if !((_e229 <= _e230)) {
                                    break;
                                }
                                {
                                    let _e236 = N;
                                    i = -(_e236);
                                    loop {
                                        let _e239 = i;
                                        let _e240 = N;
                                        if !((_e239 <= _e240)) {
                                            break;
                                        }
                                        {
                                            let _e246 = color;
                                            let _e247 = samplePosR;
                                            let _e248 = i;
                                            let _e250 = j;
                                            let _e253 = step;
                                            let _e259 = global.U[0];
                                            let _e262 = samplePosR;
                                            let _e263 = i;
                                            let _e265 = j;
                                            let _e268 = step;
                                            let _e279 = textureSample(t_source, samp, ((vec2<f32>(((_e247 + (vec2<f32>(f32(_e248), f32(_e250)) * _e253)).x / _e259.x), (_e262 + (vec2<f32>(f32(_e263), f32(_e265)) * _e268)).y) / vec2(2f)) + vec2(0.5f)));
                                            color = (_e246 + _e279);
                                        }
                                        continuing {
                                            let _e243 = i;
                                            i = (_e243 + 1i);
                                        }
                                    }
                                }
                                continuing {
                                    let _e233 = j;
                                    j = (_e233 + 1i);
                                }
                            }
                            let _e281 = color;
                            let _e283 = N;
                            let _e288 = N;
                            color = (_e281 / vec4(f32((((2i * _e283) + 1i) * ((2i * _e288) + 1i)))));
                        }
                    } else {
                        {
                            let _e296 = samplePosR;
                            let _e300 = global.U[0];
                            let _e303 = samplePosR;
                            let _e312 = textureSample(t_source, samp, ((vec2<f32>((_e296.x / _e300.x), _e303.y) / vec2(2f)) + vec2(0.5f)));
                            color = _e312;
                        }
                    }
                    let _e313 = color;
                    let _e315 = thresholdR;
                    if (_e313.x > _e315) {
                        local_1 = 1f;
                    } else {
                        local_1 = 0f;
                    }
                    let _e320 = local_1;
                    kR = _e320;
                    color = vec4(0f);
                    let _e323 = transformG;
                    let _e324 = patternG;
                    let _e326 = tf(_e323, _e324.xy);
                    samplePosG = _e326;
                    let _e328 = smoothen_1;
                    if (_e328 > 0f) {
                        {
                            let _e335 = transformG[0];
                            let _e338 = smoothen_1;
                            r_2 = ((length(_e335.xy) * _e338) * 3f);
                            let _e343 = r_2;
                            let _e344 = N_1;
                            step_1 = (_e343 / f32(_e344));
                            let _e348 = N_1;
                            j_1 = -(_e348);
                            loop {
                                let _e351 = j_1;
                                let _e352 = N_1;
                                if !((_e351 <= _e352)) {
                                    break;
                                }
                                {
                                    let _e358 = N_1;
                                    i_1 = -(_e358);
                                    loop {
                                        let _e361 = i_1;
                                        let _e362 = N_1;
                                        if !((_e361 <= _e362)) {
                                            break;
                                        }
                                        {
                                            let _e368 = color;
                                            let _e369 = samplePosG;
                                            let _e370 = i_1;
                                            let _e372 = j_1;
                                            let _e375 = step_1;
                                            let _e381 = global.U[0];
                                            let _e384 = samplePosG;
                                            let _e385 = i_1;
                                            let _e387 = j_1;
                                            let _e390 = step_1;
                                            let _e401 = textureSample(t_source, samp, ((vec2<f32>(((_e369 + (vec2<f32>(f32(_e370), f32(_e372)) * _e375)).x / _e381.x), (_e384 + (vec2<f32>(f32(_e385), f32(_e387)) * _e390)).y) / vec2(2f)) + vec2(0.5f)));
                                            color = (_e368 + _e401);
                                        }
                                        continuing {
                                            let _e365 = i_1;
                                            i_1 = (_e365 + 1i);
                                        }
                                    }
                                }
                                continuing {
                                    let _e355 = j_1;
                                    j_1 = (_e355 + 1i);
                                }
                            }
                            let _e403 = color;
                            let _e405 = N_1;
                            let _e410 = N_1;
                            color = (_e403 / vec4(f32((((2i * _e405) + 1i) * ((2i * _e410) + 1i)))));
                        }
                    } else {
                        {
                            let _e418 = samplePosG;
                            let _e422 = global.U[0];
                            let _e425 = samplePosG;
                            let _e434 = textureSample(t_source, samp, ((vec2<f32>((_e418.x / _e422.x), _e425.y) / vec2(2f)) + vec2(0.5f)));
                            color = _e434;
                        }
                    }
                    let _e435 = color;
                    let _e437 = thresholdG;
                    if (_e435.y > _e437) {
                        local_2 = 1f;
                    } else {
                        local_2 = 0f;
                    }
                    let _e442 = local_2;
                    kG = _e442;
                    color = vec4(0f);
                    let _e445 = transformB;
                    let _e446 = patternB;
                    let _e448 = tf(_e445, _e446.xy);
                    samplePosB = _e448;
                    let _e450 = smoothen_1;
                    if (_e450 > 0f) {
                        {
                            let _e457 = transformB[0];
                            let _e460 = smoothen_1;
                            r_3 = ((length(_e457.xy) * _e460) * 3f);
                            let _e465 = r_3;
                            let _e466 = N_2;
                            step_2 = (_e465 / f32(_e466));
                            let _e470 = N_2;
                            j_2 = -(_e470);
                            loop {
                                let _e473 = j_2;
                                let _e474 = N_2;
                                if !((_e473 <= _e474)) {
                                    break;
                                }
                                {
                                    let _e480 = N_2;
                                    i_2 = -(_e480);
                                    loop {
                                        let _e483 = i_2;
                                        let _e484 = N_2;
                                        if !((_e483 <= _e484)) {
                                            break;
                                        }
                                        {
                                            let _e490 = color;
                                            let _e491 = samplePosB;
                                            let _e492 = i_2;
                                            let _e494 = j_2;
                                            let _e497 = step_2;
                                            let _e503 = global.U[0];
                                            let _e506 = samplePosB;
                                            let _e507 = i_2;
                                            let _e509 = j_2;
                                            let _e512 = step_2;
                                            let _e523 = textureSample(t_source, samp, ((vec2<f32>(((_e491 + (vec2<f32>(f32(_e492), f32(_e494)) * _e497)).x / _e503.x), (_e506 + (vec2<f32>(f32(_e507), f32(_e509)) * _e512)).y) / vec2(2f)) + vec2(0.5f)));
                                            color = (_e490 + _e523);
                                        }
                                        continuing {
                                            let _e487 = i_2;
                                            i_2 = (_e487 + 1i);
                                        }
                                    }
                                }
                                continuing {
                                    let _e477 = j_2;
                                    j_2 = (_e477 + 1i);
                                }
                            }
                            let _e525 = color;
                            let _e527 = N_2;
                            let _e532 = N_2;
                            color = (_e525 / vec4(f32((((2i * _e527) + 1i) * ((2i * _e532) + 1i)))));
                        }
                    } else {
                        {
                            let _e540 = samplePosB;
                            let _e544 = global.U[0];
                            let _e547 = samplePosB;
                            let _e556 = textureSample(t_source, samp, ((vec2<f32>((_e540.x / _e544.x), _e547.y) / vec2(2f)) + vec2(0.5f)));
                            color = _e556;
                        }
                    }
                    let _e557 = color;
                    let _e559 = thresholdB;
                    if (_e557.z > _e559) {
                        local_3 = 1f;
                    } else {
                        local_3 = 0f;
                    }
                    let _e564 = local_3;
                    kB = _e564;
                }
            }
        } else {
            {
                {
                    let _e565 = uv_11;
                    samplePos = _e565;
                    let _e567 = smoothen_1;
                    if (_e567 > 0f) {
                        {
                            let _e574 = modelTransform_1[0];
                            let _e577 = smoothen_1;
                            r_4 = ((length(_e574.xy) * _e577) * 3f);
                            let _e582 = r_4;
                            let _e583 = N_3;
                            step_3 = (_e582 / f32(_e583));
                            let _e587 = N_3;
                            j_3 = -(_e587);
                            loop {
                                let _e590 = j_3;
                                let _e591 = N_3;
                                if !((_e590 <= _e591)) {
                                    break;
                                }
                                {
                                    let _e597 = N_3;
                                    i_3 = -(_e597);
                                    loop {
                                        let _e600 = i_3;
                                        let _e601 = N_3;
                                        if !((_e600 <= _e601)) {
                                            break;
                                        }
                                        {
                                            let _e607 = color;
                                            let _e608 = samplePos;
                                            let _e609 = i_3;
                                            let _e611 = j_3;
                                            let _e614 = step_3;
                                            let _e620 = global.U[0];
                                            let _e623 = samplePos;
                                            let _e624 = i_3;
                                            let _e626 = j_3;
                                            let _e629 = step_3;
                                            let _e640 = textureSample(t_source, samp, ((vec2<f32>(((_e608 + (vec2<f32>(f32(_e609), f32(_e611)) * _e614)).x / _e620.x), (_e623 + (vec2<f32>(f32(_e624), f32(_e626)) * _e629)).y) / vec2(2f)) + vec2(0.5f)));
                                            color = (_e607 + _e640);
                                        }
                                        continuing {
                                            let _e604 = i_3;
                                            i_3 = (_e604 + 1i);
                                        }
                                    }
                                }
                                continuing {
                                    let _e594 = j_3;
                                    j_3 = (_e594 + 1i);
                                }
                            }
                            let _e642 = color;
                            let _e644 = N_3;
                            let _e649 = N_3;
                            color = (_e642 / vec4(f32((((2i * _e644) + 1i) * ((2i * _e649) + 1i)))));
                        }
                    } else {
                        {
                            let _e657 = samplePos;
                            let _e661 = global.U[0];
                            let _e664 = samplePos;
                            let _e673 = textureSample(t_source, samp, ((vec2<f32>((_e657.x / _e661.x), _e664.y) / vec2(2f)) + vec2(0.5f)));
                            color = _e673;
                        }
                    }
                    let _e674 = color;
                    let _e676 = thresholdR;
                    if (_e674.x > _e676) {
                        local_4 = 1f;
                    } else {
                        local_4 = 0f;
                    }
                    let _e681 = local_4;
                    kR = _e681;
                    let _e682 = color;
                    let _e684 = thresholdG;
                    if (_e682.y > _e684) {
                        local_5 = 1f;
                    } else {
                        local_5 = 0f;
                    }
                    let _e689 = local_5;
                    kG = _e689;
                    let _e690 = color;
                    let _e692 = thresholdB;
                    if (_e690.z > _e692) {
                        local_6 = 1f;
                    } else {
                        local_6 = 0f;
                    }
                    let _e697 = local_6;
                    kB = _e697;
                }
            }
        }
    }
    let _e698 = color2_1;
    let _e700 = color1_1;
    let _e702 = kR;
    let _e704 = color2_1;
    let _e706 = color1_1;
    let _e708 = kG;
    let _e710 = color2_1;
    let _e712 = color1_1;
    let _e714 = kB;
    let _e716 = color2_1;
    let _e718 = color1_1;
    outColor = vec4<f32>(mix(_e698.x, _e700.x, _e702), mix(_e704.y, _e706.y, _e708), mix(_e710.z, _e712.z, _e714), mix(_e716.w, _e718.w, 0.5f));
    let _e724 = color;
    let _e725 = outColor;
    let _e726 = mergeColor(_e724, _e725);
    return _e726;
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
    let _e66 = global.U[5];
    let _e70 = global.U[6];
    let _e74 = global.U[7];
    let _e75 = _e74.xyz;
    let _e78 = global.U[8];
    let _e79 = _e78.xyz;
    let _e82 = global.U[9];
    let _e83 = _e82.xyz;
    let _e99 = global.U[10];
    let _e100 = _e99.xyz;
    let _e103 = global.U[11];
    let _e104 = _e103.xyz;
    let _e107 = global.U[12];
    let _e108 = _e107.xyz;
    let _e124 = global.U[13];
    let _e125 = _e124.xyz;
    let _e128 = global.U[14];
    let _e129 = _e128.xyz;
    let _e132 = global.U[15];
    let _e133 = _e132.xyz;
    let _e149 = global.U[16];
    let _e150 = _e149.xyz;
    let _e153 = global.U[17];
    let _e154 = _e153.xyz;
    let _e157 = global.U[18];
    let _e158 = _e157.xyz;
    let _e174 = global.U[19];
    let _e177 = global.U[20];
    let _e180 = global.U[21];
    let _e185 = global.U[22];
    let _e188 = halftoneRGB((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e9.x, _e9.y, _e9.z), vec3<f32>(_e13.x, _e13.y, _e13.z), vec3<f32>(_e17.x, _e17.y, _e17.z))) * vec3<f32>(_e44.x, _e44.y, 1f)).xy, (((_e51 - vec2(0.5f)) * 2f) * vec2<f32>(_e59.x, 1f)), _e66.x, _e70.x, mat3x3<f32>(vec3<f32>(_e75.x, _e75.y, _e75.z), vec3<f32>(_e79.x, _e79.y, _e79.z), vec3<f32>(_e83.x, _e83.y, _e83.z)), mat3x3<f32>(vec3<f32>(_e100.x, _e100.y, _e100.z), vec3<f32>(_e104.x, _e104.y, _e104.z), vec3<f32>(_e108.x, _e108.y, _e108.z)), mat3x3<f32>(vec3<f32>(_e125.x, _e125.y, _e125.z), vec3<f32>(_e129.x, _e129.y, _e129.z), vec3<f32>(_e133.x, _e133.y, _e133.z)), mat3x3<f32>(vec3<f32>(_e150.x, _e150.y, _e150.z), vec3<f32>(_e154.x, _e154.y, _e154.z), vec3<f32>(_e158.x, _e158.y, _e158.z)), _e174, _e177, i32(_e180.x), i32(_e185.x));
    fragColor = _e188;
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
