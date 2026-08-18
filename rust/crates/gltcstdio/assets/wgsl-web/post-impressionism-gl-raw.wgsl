struct Params {
    U: array<vec4<f32>, 20>,
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
var t_source2_: texture_2d<f32>;

fn piFmod(a: f32, b: f32) -> f32 {
    var a_1: f32;
    var b_1: f32;

    a_1 = a;
    b_1 = b;
    let _e11 = a_1;
    let _e12 = b_1;
    let _e13 = a_1;
    let _e14 = b_1;
    return (_e11 - (_e12 * trunc((_e13 / _e14))));
}

fn piLocusGetBlock(pos: vec2<f32>) -> f32 {
    var pos_1: vec2<f32>;
    var inside: f32 = 0f;
    var i2_: f32;
    var divisor: f32;
    var threshold: f32;
    var total: f32 = 0f;
    var rdmz: vec4<f32>;
    var i: i32 = 0i;
    var v: vec2<f32>;
    var index: f32;
    var local: f32;
    var idx: f32;
    var ins: f32;
    var local_1: f32;

    pos_1 = pos;
    let _e11 = pos_1;
    let _e16 = pos_1;
    i2_ = (floor((_e11.x / 10f)) + floor((_e16.y / 10f)));
    let _e23 = pos_1;
    let _e26 = pos_1;
    let _e33 = piFmod(((_e23.x - (2f * _e26.y)) / 200f), 24f);
    divisor = (floor(_e33) / 2f);
    let _e38 = pos_1;
    let _e41 = pos_1;
    let _e48 = piFmod(((_e38.x + (2f * _e41.y)) / 200f), 24f);
    threshold = (_e48 / 6f);
    let _e54 = i2_;
    let _e58 = piFmod((_e54 * 8877f), 65536f);
    let _e60 = i2_;
    let _e65 = piFmod((55f + (_e60 * 777f)), 65536f);
    let _e66 = i2_;
    let _e70 = piFmod((_e66 * 413f), 65536f);
    let _e72 = i2_;
    let _e77 = piFmod((4445f + (_e72 * 78f)), 65536f);
    rdmz = vec4<f32>(_e58, _e65, _e70, _e77);
    loop {
        let _e82 = i;
        if !((_e82 < 5i)) {
            break;
        }
        {
            let _e89 = pos_1;
            let _e92 = piFmod(_e89.x, 8f);
            let _e93 = pos_1;
            let _e96 = piFmod(_e93.y, 8f);
            v = vec2<f32>(_e92, _e96);
            let _e99 = v;
            let _e101 = v;
            index = (_e99.x + (_e101.y * 8f));
            let _e107 = pos_1;
            let _e110 = piFmod(_e107.y, 300f);
            if (_e110 > 150f) {
                local = 3f;
            } else {
                let _e114 = index;
                local = clamp(floor((_e114 / 16f)), 0f, 3f);
            }
            let _e122 = local;
            idx = _e122;
            let _e124 = idx;
            let _e127 = rdmz[i32(_e124)];
            let _e129 = index;
            let _e130 = idx;
            let _e138 = piFmod(floor((_e127 / pow(2f, (_e129 - (_e130 * 16f))))), 2f);
            ins = _e138;
            let _e140 = total;
            let _e141 = ins;
            total = (_e140 + _e141);
            let _e143 = pos_1;
            let _e144 = divisor;
            pos_1 = floor((_e143 / vec2(_e144)));
        }
        continuing {
            let _e86 = i;
            i = (_e86 + 1i);
        }
    }
    let _e148 = total;
    let _e149 = threshold;
    if (_e148 >= _e149) {
        local_1 = 1f;
    } else {
        local_1 = 0f;
    }
    let _e154 = local_1;
    inside = _e154;
    let _e155 = inside;
    return _e155;
}

fn piLocusGetHue(c: vec4<f32>) -> f32 {
    var c_1: vec4<f32>;
    var r: f32;
    var g: f32;
    var b_2: f32;
    var mini: f32;
    var maxi: f32;

    c_1 = c;
    let _e9 = c_1;
    r = _e9.x;
    let _e12 = c_1;
    g = _e12.y;
    let _e15 = c_1;
    b_2 = _e15.z;
    let _e18 = r;
    let _e19 = g;
    let _e20 = b_2;
    mini = min(_e18, min(_e19, _e20));
    let _e24 = r;
    let _e25 = g;
    let _e26 = b_2;
    maxi = max(_e24, max(_e25, _e26));
    let _e30 = maxi;
    let _e31 = mini;
    if (_e30 == _e31) {
        return 0f;
    } else {
        let _e34 = maxi;
        let _e35 = r;
        if (_e34 == _e35) {
            let _e38 = g;
            let _e39 = b_2;
            let _e42 = maxi;
            let _e43 = mini;
            let _e49 = piFmod((((60f * (_e38 - _e39)) / (_e42 - _e43)) + 360f), 360f);
            return _e49;
        } else {
            let _e50 = maxi;
            let _e51 = g;
            if (_e50 == _e51) {
                let _e54 = b_2;
                let _e55 = r;
                let _e58 = maxi;
                let _e59 = mini;
                return (((60f * (_e54 - _e55)) / (_e58 - _e59)) + 120f);
            } else {
                let _e65 = r;
                let _e66 = g;
                let _e69 = maxi;
                let _e70 = mini;
                return (((60f * (_e65 - _e66)) / (_e69 - _e70)) + 240f);
            }
        }
    }
}

fn piGetLocus(pos_2: vec2<f32>, inCol: vec4<f32>, outCol: vec4<f32>, locusMode: i32, locusTransform: mat3x3<f32>) -> f32 {
    var pos_3: vec2<f32>;
    var inCol_1: vec4<f32>;
    var outCol_1: vec4<f32>;
    var locusMode_1: i32;
    var locusTransform_1: mat3x3<f32>;
    var m: mat3x3<f32>;
    var u: vec2<f32>;
    var local_2: f32;
    var hue: f32;
    var targetHue: f32;
    var d: f32;
    var maxD: f32;
    var v_1: vec2<f32>;
    var colDist: f32;
    var scale: f32;
    var local_3: f32;
    var maxDist: f32;
    var scale_1: f32;
    var angle: f32;
    var intensity: f32;
    var ca: f32;
    var sa: f32;
    var y: f32;
    var h: f32;
    var local_4: f32;

    pos_3 = pos_2;
    inCol_1 = inCol;
    outCol_1 = outCol;
    locusMode_1 = locusMode;
    locusTransform_1 = locusTransform;
    let _e17 = locusMode_1;
    if (_e17 == 0i) {
        return 1f;
    }
    let _e21 = locusTransform_1;
    m = _e21;
    let _e23 = locusMode_1;
    if (_e23 <= 3i) {
        let _e26 = locusTransform_1;
        m = _naga_inverse_3x3_f32(_e26);
    }
    let _e28 = m;
    let _e29 = pos_3;
    u = (_e28 * vec3<f32>(_e29.x, _e29.y, 1f)).xy;
    let _e37 = locusMode_1;
    if (_e37 == 1i) {
        {
            let _e40 = u;
            let _e43 = u;
            if (max(abs(_e40.x), abs(_e43.y)) > 1f) {
                local_2 = 0f;
            } else {
                local_2 = 1f;
            }
            let _e52 = local_2;
            return _e52;
        }
    } else {
        let _e53 = locusMode_1;
        if (_e53 == 2i) {
            {
                let _e58 = u;
                return smoothstep(0.5f, 1f, length(_e58));
            }
        } else {
            let _e61 = locusMode_1;
            if (_e61 == 3i) {
                {
                    let _e66 = u;
                    return smoothstep(1f, 0.5f, length(_e66));
                }
            } else {
                let _e69 = locusMode_1;
                if (_e69 == 4i) {
                    {
                        let _e72 = inCol_1;
                        let _e73 = piLocusGetHue(_e72);
                        hue = _e73;
                        let _e79 = locusTransform_1[2][0];
                        let _e83 = piFmod((_e79 * 180f), 360f);
                        targetHue = _e83;
                        let _e85 = hue;
                        let _e86 = targetHue;
                        d = (_e85 - _e86);
                        let _e89 = d;
                        if (_e89 < 0f) {
                            let _e92 = d;
                            d = -(_e92);
                        }
                        let _e94 = d;
                        if (_e94 > 180f) {
                            let _e98 = d;
                            d = (360f - _e98);
                        }
                        let _e105 = locusTransform_1[0][0];
                        let _e110 = locusTransform_1[0][1];
                        maxD = (360f / length(vec2<f32>(_e105, _e110)));
                        let _e115 = d;
                        let _e116 = maxD;
                        d = (_e115 / _e116);
                        let _e120 = d;
                        return smoothstep(1f, 0.75f, _e120);
                    }
                } else {
                    let _e122 = locusMode_1;
                    if (_e122 == 5i) {
                        {
                            let _e125 = u;
                            v_1 = floor((_e125 * 40f));
                            let _e130 = v_1;
                            let _e131 = piLocusGetBlock(_e130);
                            return _e131;
                        }
                    } else {
                        let _e132 = locusMode_1;
                        if (_e132 == 6i) {
                            {
                                let _e135 = inCol_1;
                                let _e137 = outCol_1;
                                colDist = length((_e135.xyz - _e137.xyz));
                                let _e146 = locusTransform_1[0][0];
                                let _e151 = locusTransform_1[0][1];
                                scale = length(vec2<f32>(_e146, _e151));
                                let _e155 = scale;
                                if (_e155 < 1f) {
                                    let _e159 = scale;
                                    local_3 = (1.732f * _e159);
                                } else {
                                    let _e162 = scale;
                                    local_3 = (1.732f / _e162);
                                }
                                let _e165 = local_3;
                                maxDist = _e165;
                                let _e167 = scale;
                                if (_e167 < 1f) {
                                    let _e171 = colDist;
                                    colDist = (1.732f - _e171);
                                }
                                let _e173 = colDist;
                                let _e174 = maxDist;
                                colDist = (_e173 / _e174);
                                let _e178 = colDist;
                                return smoothstep(1f, 0.75f, _e178);
                            }
                        } else {
                            let _e180 = locusMode_1;
                            if (_e180 == 7i) {
                                {
                                    let _e187 = locusTransform_1[2][0];
                                    let _e193 = locusTransform_1[2][1];
                                    return clamp((-(_e187) + _e193), 0f, 1f);
                                }
                            } else {
                                let _e198 = locusMode_1;
                                if (_e198 == 8i) {
                                    {
                                        let _e205 = locusTransform_1[0][0];
                                        let _e210 = locusTransform_1[0][1];
                                        scale_1 = length(vec2<f32>(_e205, _e210));
                                        let _e218 = locusTransform_1[2][0];
                                        angle = ((floor(((_e218 * 3f) + 0.5f)) / 12f) * 3.1415927f);
                                        let _e233 = locusTransform_1[2][1];
                                        intensity = clamp(_e233, 0f, 1f);
                                        let _e238 = angle;
                                        ca = cos(_e238);
                                        let _e241 = angle;
                                        sa = sin(_e241);
                                        let _e244 = sa;
                                        let _e246 = pos_3;
                                        let _e249 = ca;
                                        let _e250 = pos_3;
                                        y = ((-(_e244) * _e246.x) + (_e249 * _e250.y));
                                        let _e255 = y;
                                        let _e256 = scale_1;
                                        h = cos((((_e255 * _e256) * 3.1415927f) * 100f));
                                        let _e264 = intensity;
                                        if (_e264 < 0.5f) {
                                            let _e267 = intensity;
                                            let _e268 = h;
                                            local_4 = (_e267 * (_e268 + 1f));
                                        } else {
                                            let _e274 = intensity;
                                            let _e276 = h;
                                            local_4 = (1f + ((1f - _e274) * (_e276 - 1f)));
                                        }
                                        let _e282 = local_4;
                                        return _e282;
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    return 1f;
}

fn piPerturbate(p: vec2<f32>, dir: vec2<f32>, variabilityScaled: f32) -> vec2<f32> {
    var p_1: vec2<f32>;
    var dir_1: vec2<f32>;
    var variabilityScaled_1: f32;
    var local_5: f32;
    var M: f32;
    var len: f32;
    var ort: vec2<f32>;
    var x: f32;
    var y_1: f32;

    p_1 = p;
    dir_1 = dir;
    variabilityScaled_1 = variabilityScaled;
    let _e13 = variabilityScaled_1;
    if (_e13 == 0f) {
        let _e16 = p_1;
        return _e16;
    }
    let _e17 = variabilityScaled_1;
    if (_e17 < 0f) {
        local_5 = 1f;
    } else {
        local_5 = 5f;
    }
    let _e23 = local_5;
    M = _e23;
    let _e25 = dir_1;
    len = length(_e25);
    let _e28 = dir_1;
    let _e30 = dir_1;
    ort = vec2<f32>(_e28.y, -(_e30.x));
    let _e35 = p_1;
    let _e36 = dir_1;
    let _e38 = len;
    let _e39 = len;
    let _e42 = M;
    x = ((dot(_e35, _e36) / (_e38 * _e39)) * _e42);
    let _e45 = p_1;
    let _e46 = ort;
    let _e48 = len;
    let _e49 = len;
    y_1 = (dot(_e45, _e46) / (_e48 * _e49));
    let _e53 = p_1;
    let _e54 = variabilityScaled_1;
    let _e57 = dir_1;
    let _e60 = x;
    let _e67 = y_1;
    p_1 = (_e53 + ((((_e54 * 0.004f) * _e57) * sin(((1f * _e60) + 21.54f))) * cos(((5f * _e67) + 5245.24f))));
    let _e74 = p_1;
    let _e75 = variabilityScaled_1;
    let _e78 = dir_1;
    let _e81 = x;
    let _e88 = y_1;
    p_1 = (_e74 + ((((_e75 * 0.002f) * _e78) * sin(((3f * _e81) + 0.21f))) * cos(((15f * _e88) + 0.575f))));
    let _e95 = p_1;
    let _e96 = variabilityScaled_1;
    let _e99 = dir_1;
    let _e102 = x;
    let _e109 = y_1;
    p_1 = (_e95 + ((((_e96 * 0.001f) * _e99) * sin(((10f * _e102) - 1f))) * cos(((50f * _e109) + 1.255f))));
    let _e116 = p_1;
    let _e117 = variabilityScaled_1;
    let _e120 = ort;
    let _e123 = x;
    let _e130 = y_1;
    p_1 = (_e116 + ((((_e117 * 0.002f) * _e120) * sin(((1.2f * _e123) + 21.4f))) * cos(((4.52f * _e130) + 525.24f))));
    let _e137 = p_1;
    let _e138 = variabilityScaled_1;
    let _e141 = ort;
    let _e144 = x;
    let _e151 = y_1;
    p_1 = (_e137 + ((((_e138 * 0.001f) * _e141) * sin(((3.4f * _e144) + 0.1f))) * cos(((17f * _e151) + 0.75f))));
    let _e158 = p_1;
    let _e159 = variabilityScaled_1;
    let _e162 = ort;
    let _e165 = x;
    let _e172 = y_1;
    p_1 = (_e158 + ((((_e159 * 0.0005f) * _e162) * sin(((10.7f * _e165) - 1f))) * cos(((47.7f * _e172) + 1.25f))));
    let _e179 = p_1;
    return _e179;
}

fn piGetStroke(p_2: vec2<f32>, c_2: vec2<f32>, dir_2: vec2<f32>, thickness: f32, variabilityScaled_2: f32) -> vec2<f32> {
    var p_3: vec2<f32>;
    var c_3: vec2<f32>;
    var dir_3: vec2<f32>;
    var thickness_1: f32;
    var variabilityScaled_3: f32;
    var d_1: vec2<f32>;
    var len_1: f32;
    var l: f32;
    var k: f32;
    var local_6: f32;

    p_3 = p_2;
    c_3 = c_2;
    dir_3 = dir_2;
    thickness_1 = thickness;
    variabilityScaled_3 = variabilityScaled_2;
    let _e17 = dir_3;
    let _e21 = dir_3;
    if ((_e17.x == 0f) && (_e21.y == 0f)) {
        return vec2<f32>(0f, 0f);
    }
    let _e29 = dir_3;
    d_1 = normalize(_e29);
    let _e32 = dir_3;
    len_1 = length(_e32);
    let _e35 = p_3;
    let _e36 = dir_3;
    let _e37 = variabilityScaled_3;
    let _e38 = piPerturbate(_e35, _e36, _e37);
    p_3 = _e38;
    let _e39 = d_1;
    let _e41 = d_1;
    let _e44 = vec2<f32>(_e39.x, -(_e41.y));
    let _e45 = d_1;
    let _e46 = _e45.yx;
    let _e54 = p_3;
    let _e55 = c_3;
    p_3 = (mat2x2<f32>(vec2<f32>(_e44.x, _e44.y), vec2<f32>(_e46.x, _e46.y)) * (_e54 - _e55));
    let _e59 = p_3;
    let _e62 = len_1;
    let _e65 = p_3;
    l = length(vec2<f32>(max(0f, (abs(_e59.x) - _e62)), _e65.y));
    let _e70 = p_3;
    let _e72 = len_1;
    let _e75 = len_1;
    k = clamp(((_e70.x + _e72) / (2f * _e75)), 0f, 1f);
    let _e82 = l;
    let _e83 = thickness_1;
    if (_e82 < _e83) {
        local_6 = 1f;
    } else {
        local_6 = 0f;
    }
    let _e88 = local_6;
    let _e89 = k;
    return vec2<f32>(_e88, _e89);
}

fn piLuma(c_4: vec3<f32>) -> f32 {
    var c_5: vec3<f32>;

    c_5 = c_4;
    let _e10 = c_5;
    let _e14 = c_5;
    let _e19 = c_5;
    return (((0.2989f * _e10.x) + (0.587f * _e14.y)) + (0.114f * _e19.z));
}

fn piResponse(u_1: vec2<f32>) -> vec2<f32> {
    var u_2: vec2<f32>;

    u_2 = u_1;
    let _e9 = u_2;
    let _e13 = u_2;
    if ((_e9.x == 0f) && (_e13.y == 0f)) {
        let _e18 = u_2;
        return _e18;
    }
    let _e19 = u_2;
    return normalize(_e19);
}

fn postImpressionismGL(pos_4: vec2<f32>, outPos: vec2<f32>, count: i32, variability: f32, thickness_2: f32, angle_1: f32, blend: f32, color1_: vec4<f32>, color2_: vec4<f32>, color3_: vec4<f32>, locusMode_2: i32, locusTransform_2: mat3x3<f32>, modelTransform: mat3x3<f32>) -> vec4<f32> {
    var pos_5: vec2<f32>;
    var outPos_1: vec2<f32>;
    var count_1: i32;
    var variability_1: f32;
    var thickness_3: f32;
    var angle_2: f32;
    var blend_1: f32;
    var color1_1: vec4<f32>;
    var color2_1: vec4<f32>;
    var color3_1: vec4<f32>;
    var locusMode_3: i32;
    var locusTransform_3: mat3x3<f32>;
    var modelTransform_1: mat3x3<f32>;
    var variabilityScaled_4: f32;
    var thicknessFactor: f32;
    var gradient: f32;
    var ang: f32;
    var strokeIntensity: f32 = 0f;
    var resolution: f32;
    var sp: vec2<f32>;
    var delta: f32 = 0.02f;
    var step: f32;
    var curColor: vec4<f32> = vec4<f32>(0f, 0f, 0f, 1f);
    var rot: mat2x2<f32>;
    var fCount: f32;
    var jj: i32 = 0i;
    var j: f32;
    var ii: i32;
    var i_1: f32;
    var pp: vec2<f32>;
    var grad: vec2<f32>;
    var _o_d: f32;
    var _o_cx0_: vec4<f32>;
    var _o_cx1_: vec4<f32>;
    var _o_cy0_: vec4<f32>;
    var _o_cy1_: vec4<f32>;
    var g_1: vec2<f32>;
    var st: vec2<f32>;
    var kGrad: f32;
    var alpha: f32;
    var color: vec4<f32>;
    var bk: vec4<f32>;
    var bkgCol: vec4<f32>;
    var locus: f32;

    pos_5 = pos_4;
    outPos_1 = outPos;
    count_1 = count;
    variability_1 = variability;
    thickness_3 = thickness_2;
    angle_2 = angle_1;
    blend_1 = blend;
    color1_1 = color1_;
    color2_1 = color2_;
    color3_1 = color3_;
    locusMode_3 = locusMode_2;
    locusTransform_3 = locusTransform_2;
    modelTransform_1 = modelTransform;
    let _e33 = variability_1;
    variabilityScaled_4 = (_e33 * 100f);
    let _e37 = thickness_3;
    thicknessFactor = _e37;
    let _e39 = blend_1;
    gradient = (_e39 * 5f);
    let _e43 = angle_2;
    ang = (_e43 + 1.57079f);
    let _e53 = modelTransform_1[0][0];
    let _e58 = modelTransform_1[0][1];
    resolution = length(vec2<f32>(_e53, _e58));
    let _e62 = pos_5;
    let _e63 = resolution;
    let _e69 = resolution;
    let _e74 = modelTransform_1[2];
    let _e77 = resolution;
    sp = ((floor(((_e62 * _e63) + vec2(0.5f))) / vec2(_e69)) - (fract(_e74.xy) / vec2(_e77)));
    let _e85 = resolution;
    step = (1f / _e85);
    let _e94 = ang;
    let _e96 = ang;
    let _e98 = ang;
    let _e101 = ang;
    rot = mat2x2<f32>(vec2<f32>(cos(_e94), sin(_e96)), vec2<f32>(-(sin(_e98)), cos(_e101)));
    let _e107 = count_1;
    fCount = f32(_e107);
    loop {
        let _e112 = jj;
        if !((_e112 <= 200i)) {
            break;
        }
        {
            let _e119 = jj;
            let _e121 = count_1;
            if (_e119 > (2i * _e121)) {
                break;
            }
            let _e124 = jj;
            let _e126 = fCount;
            j = (f32(_e124) - _e126);
            ii = 0i;
            loop {
                let _e131 = ii;
                if !((_e131 <= 200i)) {
                    break;
                }
                {
                    let _e138 = ii;
                    let _e140 = count_1;
                    if (_e138 > (2i * _e140)) {
                        break;
                    }
                    let _e143 = ii;
                    let _e145 = fCount;
                    i_1 = (f32(_e143) - _e145);
                    let _e148 = sp;
                    let _e149 = i_1;
                    let _e150 = j;
                    let _e152 = step;
                    pp = (_e148 + (vec2<f32>(_e149, _e150) * _e152));
                    {
                        let _e157 = delta;
                        _o_d = _e157;
                        let _e159 = pp;
                        let _e160 = _o_d;
                        let _e167 = global.U[0];
                        let _e170 = pp;
                        let _e171 = _o_d;
                        let _e184 = textureSampleLevel(t_source2_, samp, ((vec2<f32>(((_e159 + vec2<f32>(_e160, 0f)).x / _e167.x), (_e170 + vec2<f32>(_e171, 0f)).y) / vec2(2f)) + vec2(0.5f)), 0f);
                        _o_cx0_ = _e184;
                        let _e186 = pp;
                        let _e187 = _o_d;
                        let _e194 = global.U[0];
                        let _e197 = pp;
                        let _e198 = _o_d;
                        let _e211 = textureSampleLevel(t_source2_, samp, ((vec2<f32>(((_e186 - vec2<f32>(_e187, 0f)).x / _e194.x), (_e197 - vec2<f32>(_e198, 0f)).y) / vec2(2f)) + vec2(0.5f)), 0f);
                        _o_cx1_ = _e211;
                        let _e213 = pp;
                        let _e215 = _o_d;
                        let _e221 = global.U[0];
                        let _e224 = pp;
                        let _e226 = _o_d;
                        let _e238 = textureSampleLevel(t_source2_, samp, ((vec2<f32>(((_e213 + vec2<f32>(0f, _e215)).x / _e221.x), (_e224 + vec2<f32>(0f, _e226)).y) / vec2(2f)) + vec2(0.5f)), 0f);
                        _o_cy0_ = _e238;
                        let _e240 = pp;
                        let _e242 = _o_d;
                        let _e248 = global.U[0];
                        let _e251 = pp;
                        let _e253 = _o_d;
                        let _e265 = textureSampleLevel(t_source2_, samp, ((vec2<f32>(((_e240 - vec2<f32>(0f, _e242)).x / _e248.x), (_e251 - vec2<f32>(0f, _e253)).y) / vec2(2f)) + vec2(0.5f)), 0f);
                        _o_cy1_ = _e265;
                        let _e267 = _o_cx0_;
                        let _e269 = _o_cx0_;
                        let _e272 = _o_cx0_;
                        let _e275 = _o_cx1_;
                        let _e277 = _o_cx1_;
                        let _e280 = _o_cx1_;
                        let _e286 = _o_d;
                        let _e290 = _o_cy0_;
                        let _e292 = _o_cy0_;
                        let _e295 = _o_cy0_;
                        let _e298 = _o_cy1_;
                        let _e300 = _o_cy1_;
                        let _e303 = _o_cy1_;
                        let _e309 = _o_d;
                        grad = vec2<f32>((((((_e267.x + _e269.y) + _e272.z) - ((_e275.x + _e277.y) + _e280.z)) / 3f) / (_e286 * 2f)), (((((_e290.x + _e292.y) + _e295.z) - ((_e298.x + _e300.y) + _e303.z)) / 3f) / (_e309 * 2f)));
                    }
                    let _e314 = grad;
                    let _e315 = delta;
                    grad = ((_e314 * _e315) / vec2(2f));
                    let _e320 = rot;
                    let _e321 = grad;
                    let _e322 = piResponse(_e321);
                    let _e323 = resolution;
                    let _e329 = fCount;
                    g_1 = (_e320 * (((_e322 / vec2(_e323)) / vec2(2f)) * _e329));
                    let _e333 = pos_5;
                    let _e334 = pp;
                    let _e335 = g_1;
                    let _e336 = thicknessFactor;
                    let _e337 = resolution;
                    let _e339 = variabilityScaled_4;
                    let _e340 = piGetStroke(_e333, _e334, _e335, (_e336 / _e337), _e339);
                    st = _e340;
                    let _e342 = st;
                    if (_e342.x > 0f) {
                        {
                            let _e346 = strokeIntensity;
                            let _e347 = st;
                            strokeIntensity = max(_e346, _e347.x);
                            let _e350 = st;
                            let _e354 = gradient;
                            kGrad = (((_e350.y - 0.5f) * _e354) + 0.5f);
                            let _e359 = color2_1;
                            let _e361 = color3_1;
                            let _e363 = st;
                            alpha = mix(_e359.w, _e361.w, _e363.y);
                            let _e367 = color2_1;
                            let _e369 = color3_1;
                            let _e371 = st;
                            let _e373 = kGrad;
                            let _e374 = color2_1;
                            let _e376 = color3_1;
                            let _e381 = mix(_e367.xyz, _e369.xyz, vec3(mix(_e371.y, _e373, min(_e374.w, _e376.w))));
                            let _e382 = alpha;
                            color = vec4<f32>(_e381.x, _e381.y, _e381.z, _e382);
                            let _e388 = color;
                            if (_e388.w < 1f) {
                                {
                                    let _e392 = pp;
                                    let _e393 = g_1;
                                    let _e396 = gradient;
                                    let _e402 = global.U[0];
                                    let _e405 = pp;
                                    let _e406 = g_1;
                                    let _e409 = gradient;
                                    let _e421 = textureSampleLevel(t_source, samp, ((vec2<f32>(((_e392 - ((_e393 * 0.5f) * _e396)).x / _e402.x), (_e405 - ((_e406 * 0.5f) * _e409)).y) / vec2(2f)) + vec2(0.5f)), 0f);
                                    let _e422 = pp;
                                    let _e423 = g_1;
                                    let _e426 = gradient;
                                    let _e432 = global.U[0];
                                    let _e435 = pp;
                                    let _e436 = g_1;
                                    let _e439 = gradient;
                                    let _e451 = textureSampleLevel(t_source, samp, ((vec2<f32>(((_e422 + ((_e423 * 0.5f) * _e426)).x / _e432.x), (_e435 + ((_e436 * 0.5f) * _e439)).y) / vec2(2f)) + vec2(0.5f)), 0f);
                                    bk = mix(_e421, _e451, vec4(0.5f));
                                    let _e456 = bk;
                                    let _e458 = color;
                                    let _e460 = color;
                                    let _e463 = mix(_e456.xyz, _e458.xyz, vec3(_e460.w));
                                    let _e464 = bk;
                                    color = vec4<f32>(_e463.x, _e463.y, _e463.z, _e464.w);
                                }
                            }
                            let _e470 = color;
                            let _e472 = piLuma(_e470.xyz);
                            let _e473 = curColor;
                            let _e475 = piLuma(_e473.xyz);
                            if (_e472 >= _e475) {
                                let _e477 = color;
                                curColor = _e477;
                            }
                        }
                    }
                }
                continuing {
                    let _e135 = ii;
                    ii = (_e135 + 1i);
                }
            }
        }
        continuing {
            let _e116 = jj;
            jj = (_e116 + 1i);
        }
    }
    let _e478 = pos_5;
    let _e482 = global.U[0];
    let _e485 = pos_5;
    let _e495 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e478.x / _e482.x), _e485.y) / vec2(2f)) + vec2(0.5f)), 0f);
    bkgCol = _e495;
    let _e497 = color1_1;
    let _e498 = curColor;
    let _e499 = strokeIntensity;
    curColor = mix(_e497, _e498, vec4(_e499));
    let _e502 = bkgCol;
    let _e504 = curColor;
    let _e506 = curColor;
    let _e509 = mix(_e502.xyz, _e504.xyz, vec3(_e506.w));
    let _e510 = bkgCol;
    let _e512 = curColor;
    let _e514 = curColor;
    curColor = vec4<f32>(_e509.x, _e509.y, _e509.z, mix(_e510.w, _e512.w, _e514.w));
    let _e521 = pos_5;
    let _e522 = bkgCol;
    let _e523 = curColor;
    let _e524 = locusMode_3;
    let _e525 = locusTransform_3;
    let _e526 = piGetLocus(_e521, _e522, _e523, _e524, _e525);
    locus = _e526;
    let _e528 = bkgCol;
    let _e529 = curColor;
    let _e530 = locus;
    return mix(_e528, _e529, vec4(_e530));
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
    let _e67 = global.U[5];
    let _e72 = global.U[6];
    let _e76 = global.U[7];
    let _e80 = global.U[8];
    let _e84 = global.U[9];
    let _e88 = global.U[10];
    let _e91 = global.U[11];
    let _e94 = global.U[12];
    let _e97 = global.U[13];
    let _e102 = global.U[14];
    let _e103 = _e102.xyz;
    let _e106 = global.U[15];
    let _e107 = _e106.xyz;
    let _e110 = global.U[16];
    let _e111 = _e110.xyz;
    let _e127 = global.U[17];
    let _e128 = _e127.xyz;
    let _e131 = global.U[18];
    let _e132 = _e131.xyz;
    let _e135 = global.U[19];
    let _e136 = _e135.xyz;
    let _e150 = postImpressionismGL((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e10.x, _e10.y, _e10.z), vec3<f32>(_e14.x, _e14.y, _e14.z), vec3<f32>(_e18.x, _e18.y, _e18.z))) * vec3<f32>(_e45.x, _e45.y, 1f)).xy, (((_e52 - vec2(0.5f)) * 2f) * vec2<f32>(_e60.x, 1f)), i32(_e67.x), _e72.x, _e76.x, _e80.x, _e84.x, _e88, _e91, _e94, i32(_e97.x), mat3x3<f32>(vec3<f32>(_e103.x, _e103.y, _e103.z), vec3<f32>(_e107.x, _e107.y, _e107.z), vec3<f32>(_e111.x, _e111.y, _e111.z)), mat3x3<f32>(vec3<f32>(_e128.x, _e128.y, _e128.z), vec3<f32>(_e132.x, _e132.y, _e132.z), vec3<f32>(_e136.x, _e136.y, _e136.z)));
    fragColor = _e150;
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
