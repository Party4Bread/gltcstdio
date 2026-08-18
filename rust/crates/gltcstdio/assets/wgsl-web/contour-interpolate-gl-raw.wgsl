struct Params {
    U: array<vec4<f32>, 14>,
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
@group(0) @binding(4) 
var t_legacy_2_: texture_2d<f32>;
@group(0) @binding(5) 
var t_legacy_3_: texture_2d<f32>;

fn ciFmod(a: f32, b: f32) -> f32 {
    var a_1: f32;
    var b_1: f32;

    a_1 = a;
    b_1 = b;
    let _e13 = a_1;
    let _e14 = b_1;
    let _e15 = a_1;
    let _e16 = b_1;
    return (_e13 - (_e14 * trunc((_e15 / _e16))));
}

fn ciLocusGetBlock(pos: vec2<f32>) -> f32 {
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
    let _e13 = pos_1;
    let _e18 = pos_1;
    i2_ = (floor((_e13.x / 10f)) + floor((_e18.y / 10f)));
    let _e25 = pos_1;
    let _e28 = pos_1;
    let _e35 = ciFmod(((_e25.x - (2f * _e28.y)) / 200f), 24f);
    divisor = (floor(_e35) / 2f);
    let _e40 = pos_1;
    let _e43 = pos_1;
    let _e50 = ciFmod(((_e40.x + (2f * _e43.y)) / 200f), 24f);
    threshold = (_e50 / 6f);
    let _e56 = i2_;
    let _e60 = ciFmod((_e56 * 8877f), 65536f);
    let _e62 = i2_;
    let _e67 = ciFmod((55f + (_e62 * 777f)), 65536f);
    let _e68 = i2_;
    let _e72 = ciFmod((_e68 * 413f), 65536f);
    let _e74 = i2_;
    let _e79 = ciFmod((4445f + (_e74 * 78f)), 65536f);
    rdmz = vec4<f32>(_e60, _e67, _e72, _e79);
    loop {
        let _e84 = i;
        if !((_e84 < 5i)) {
            break;
        }
        {
            let _e91 = pos_1;
            let _e94 = ciFmod(_e91.x, 8f);
            let _e95 = pos_1;
            let _e98 = ciFmod(_e95.y, 8f);
            v = vec2<f32>(_e94, _e98);
            let _e101 = v;
            let _e103 = v;
            index = (_e101.x + (_e103.y * 8f));
            let _e109 = pos_1;
            let _e112 = ciFmod(_e109.y, 300f);
            if (_e112 > 150f) {
                local = 3f;
            } else {
                let _e116 = index;
                local = clamp(floor((_e116 / 16f)), 0f, 3f);
            }
            let _e124 = local;
            idx = _e124;
            let _e126 = idx;
            let _e129 = rdmz[i32(_e126)];
            let _e131 = index;
            let _e132 = idx;
            let _e140 = ciFmod(floor((_e129 / pow(2f, (_e131 - (_e132 * 16f))))), 2f);
            ins = _e140;
            let _e142 = total;
            let _e143 = ins;
            total = (_e142 + _e143);
            let _e145 = pos_1;
            let _e146 = divisor;
            pos_1 = floor((_e145 / vec2(_e146)));
        }
        continuing {
            let _e88 = i;
            i = (_e88 + 1i);
        }
    }
    let _e150 = total;
    let _e151 = threshold;
    if (_e150 >= _e151) {
        local_1 = 1f;
    } else {
        local_1 = 0f;
    }
    let _e156 = local_1;
    inside = _e156;
    let _e157 = inside;
    return _e157;
}

fn ciLocusGetHue(c: vec4<f32>) -> f32 {
    var c_1: vec4<f32>;
    var r: f32;
    var g: f32;
    var b_2: f32;
    var mini: f32;
    var maxi: f32;

    c_1 = c;
    let _e11 = c_1;
    r = _e11.x;
    let _e14 = c_1;
    g = _e14.y;
    let _e17 = c_1;
    b_2 = _e17.z;
    let _e20 = r;
    let _e21 = g;
    let _e22 = b_2;
    mini = min(_e20, min(_e21, _e22));
    let _e26 = r;
    let _e27 = g;
    let _e28 = b_2;
    maxi = max(_e26, max(_e27, _e28));
    let _e32 = maxi;
    let _e33 = mini;
    if (_e32 == _e33) {
        return 0f;
    } else {
        let _e36 = maxi;
        let _e37 = r;
        if (_e36 == _e37) {
            let _e40 = g;
            let _e41 = b_2;
            let _e44 = maxi;
            let _e45 = mini;
            let _e51 = ciFmod((((60f * (_e40 - _e41)) / (_e44 - _e45)) + 360f), 360f);
            return _e51;
        } else {
            let _e52 = maxi;
            let _e53 = g;
            if (_e52 == _e53) {
                let _e56 = b_2;
                let _e57 = r;
                let _e60 = maxi;
                let _e61 = mini;
                return (((60f * (_e56 - _e57)) / (_e60 - _e61)) + 120f);
            } else {
                let _e67 = r;
                let _e68 = g;
                let _e71 = maxi;
                let _e72 = mini;
                return (((60f * (_e67 - _e68)) / (_e71 - _e72)) + 240f);
            }
        }
    }
}

fn ciGetLocus(pos_2: vec2<f32>, inCol: vec4<f32>, outCol: vec4<f32>, locusMode: i32, locusTransform: mat3x3<f32>) -> f32 {
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
    let _e19 = locusMode_1;
    if (_e19 == 0i) {
        return 1f;
    }
    let _e23 = locusTransform_1;
    m = _e23;
    let _e25 = locusMode_1;
    if (_e25 <= 3i) {
        let _e28 = locusTransform_1;
        m = _naga_inverse_3x3_f32(_e28);
    }
    let _e30 = m;
    let _e31 = pos_3;
    u = (_e30 * vec3<f32>(_e31.x, _e31.y, 1f)).xy;
    let _e39 = locusMode_1;
    if (_e39 == 1i) {
        {
            let _e42 = u;
            let _e45 = u;
            if (max(abs(_e42.x), abs(_e45.y)) > 1f) {
                local_2 = 0f;
            } else {
                local_2 = 1f;
            }
            let _e54 = local_2;
            return _e54;
        }
    } else {
        let _e55 = locusMode_1;
        if (_e55 == 2i) {
            {
                let _e60 = u;
                return smoothstep(0.5f, 1f, length(_e60));
            }
        } else {
            let _e63 = locusMode_1;
            if (_e63 == 3i) {
                {
                    let _e68 = u;
                    return smoothstep(1f, 0.5f, length(_e68));
                }
            } else {
                let _e71 = locusMode_1;
                if (_e71 == 4i) {
                    {
                        let _e74 = inCol_1;
                        let _e75 = ciLocusGetHue(_e74);
                        hue = _e75;
                        let _e81 = locusTransform_1[2][0];
                        let _e85 = ciFmod((_e81 * 180f), 360f);
                        targetHue = _e85;
                        let _e87 = hue;
                        let _e88 = targetHue;
                        d = (_e87 - _e88);
                        let _e91 = d;
                        if (_e91 < 0f) {
                            let _e94 = d;
                            d = -(_e94);
                        }
                        let _e96 = d;
                        if (_e96 > 180f) {
                            let _e100 = d;
                            d = (360f - _e100);
                        }
                        let _e107 = locusTransform_1[0][0];
                        let _e112 = locusTransform_1[0][1];
                        maxD = (360f / length(vec2<f32>(_e107, _e112)));
                        let _e117 = d;
                        let _e118 = maxD;
                        d = (_e117 / _e118);
                        let _e122 = d;
                        return smoothstep(1f, 0.75f, _e122);
                    }
                } else {
                    let _e124 = locusMode_1;
                    if (_e124 == 5i) {
                        {
                            let _e127 = u;
                            v_1 = floor((_e127 * 40f));
                            let _e132 = v_1;
                            let _e133 = ciLocusGetBlock(_e132);
                            return _e133;
                        }
                    } else {
                        let _e134 = locusMode_1;
                        if (_e134 == 6i) {
                            {
                                let _e137 = inCol_1;
                                let _e139 = outCol_1;
                                colDist = length((_e137.xyz - _e139.xyz));
                                let _e148 = locusTransform_1[0][0];
                                let _e153 = locusTransform_1[0][1];
                                scale = length(vec2<f32>(_e148, _e153));
                                let _e157 = scale;
                                if (_e157 < 1f) {
                                    let _e161 = scale;
                                    local_3 = (1.732f * _e161);
                                } else {
                                    let _e164 = scale;
                                    local_3 = (1.732f / _e164);
                                }
                                let _e167 = local_3;
                                maxDist = _e167;
                                let _e169 = scale;
                                if (_e169 < 1f) {
                                    let _e173 = colDist;
                                    colDist = (1.732f - _e173);
                                }
                                let _e175 = colDist;
                                let _e176 = maxDist;
                                colDist = (_e175 / _e176);
                                let _e180 = colDist;
                                return smoothstep(1f, 0.75f, _e180);
                            }
                        } else {
                            let _e182 = locusMode_1;
                            if (_e182 == 7i) {
                                {
                                    let _e189 = locusTransform_1[2][0];
                                    let _e195 = locusTransform_1[2][1];
                                    return clamp((-(_e189) + _e195), 0f, 1f);
                                }
                            } else {
                                let _e200 = locusMode_1;
                                if (_e200 == 8i) {
                                    {
                                        let _e207 = locusTransform_1[0][0];
                                        let _e212 = locusTransform_1[0][1];
                                        scale_1 = length(vec2<f32>(_e207, _e212));
                                        let _e220 = locusTransform_1[2][0];
                                        angle = ((floor(((_e220 * 3f) + 0.5f)) / 12f) * 3.1415927f);
                                        let _e235 = locusTransform_1[2][1];
                                        intensity = clamp(_e235, 0f, 1f);
                                        let _e240 = angle;
                                        ca = cos(_e240);
                                        let _e243 = angle;
                                        sa = sin(_e243);
                                        let _e246 = sa;
                                        let _e248 = pos_3;
                                        let _e251 = ca;
                                        let _e252 = pos_3;
                                        y = ((-(_e246) * _e248.x) + (_e251 * _e252.y));
                                        let _e257 = y;
                                        let _e258 = scale_1;
                                        h = cos((((_e257 * _e258) * 3.1415927f) * 100f));
                                        let _e266 = intensity;
                                        if (_e266 < 0.5f) {
                                            let _e269 = intensity;
                                            let _e270 = h;
                                            local_4 = (_e269 * (_e270 + 1f));
                                        } else {
                                            let _e276 = intensity;
                                            let _e278 = h;
                                            local_4 = (1f + ((1f - _e276) * (_e278 - 1f)));
                                        }
                                        let _e284 = local_4;
                                        return _e284;
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

fn inside_1(pos_4: vec2<f32>, X: f32, Y: f32) -> bool {
    var pos_5: vec2<f32>;
    var X_1: f32;
    var Y_1: f32;

    pos_5 = pos_4;
    X_1 = X;
    Y_1 = Y;
    let _e15 = pos_5;
    let _e18 = Y_1;
    let _e20 = pos_5;
    let _e23 = X_1;
    return ((abs(_e15.y) <= _e18) && (abs(_e20.x) <= _e23));
}

fn sampleCol(color: vec4<f32>, count: i32) -> f32 {
    var color_1: vec4<f32>;
    var count_1: i32;

    color_1 = color;
    count_1 = count;
    let _e13 = color_1;
    let _e15 = color_1;
    let _e18 = color_1;
    let _e21 = count_1;
    return floor((((((_e13.x + _e15.y) + _e18.z) * (f32(_e21) - 1f)) / 3f) + 0.5f));
}

fn contourInterpolateGL(pos_6: vec2<f32>, outPos: vec2<f32>, sourceDim: vec2<f32>, count_2: i32, modelTransform: mat3x3<f32>, locusMode_2: i32, locusTransform_2: mat3x3<f32>) -> vec4<f32> {
    var pos_7: vec2<f32>;
    var outPos_1: vec2<f32>;
    var sourceDim_1: vec2<f32>;
    var count_3: i32;
    var modelTransform_1: mat3x3<f32>;
    var locusMode_3: i32;
    var locusTransform_3: mat3x3<f32>;
    var pixel: f32;
    var X_2: f32;
    var Y_2: f32 = 1f;
    var p: vec2<f32>;
    var d_1: vec2<f32>;
    var bkg: vec4<f32>;
    var col: vec4<f32>;
    var s: f32;
    var pos1_: vec2<f32>;
    var col1_: vec4<f32>;
    var pos2_: vec2<f32>;
    var col2_: vec4<f32>;
    var dd: vec2<f32>;
    var len: f32;
    var outCol_2: vec4<f32>;
    var locus: f32;

    pos_7 = pos_6;
    outPos_1 = outPos;
    sourceDim_1 = sourceDim;
    count_3 = count_2;
    modelTransform_1 = modelTransform;
    locusMode_3 = locusMode_2;
    locusTransform_3 = locusTransform_2;
    let _e24 = sourceDim_1;
    pixel = (2f / _e24.y);
    let _e28 = sourceDim_1;
    let _e30 = sourceDim_1;
    X_2 = (_e28.x / _e30.y);
    let _e36 = pixel;
    p = vec2<f32>(_e36, 0f);
    let _e40 = pixel;
    let _e41 = modelTransform_1;
    let _e49 = p;
    d_1 = (_e40 * normalize((mat2x2<f32>(_e41[0].xy, _e41[1].xy) * _e49)));
    let _e54 = pos_7;
    let _e58 = global.U[0];
    let _e61 = pos_7;
    let _e71 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e54.x / _e58.x), _e61.y) / vec2(2f)) + vec2(0.5f)), 0f);
    bkg = _e71;
    let _e73 = pos_7;
    let _e77 = global.U[0];
    let _e80 = pos_7;
    let _e90 = textureSampleLevel(t_source2_, samp, ((vec2<f32>((_e73.x / _e77.x), _e80.y) / vec2(2f)) + vec2(0.5f)), 0f);
    col = _e90;
    let _e92 = col;
    let _e93 = count_3;
    let _e94 = sampleCol(_e92, _e93);
    s = _e94;
    let _e96 = pos_7;
    pos1_ = _e96;
    loop {
        let _e98 = pos1_;
        let _e99 = d_1;
        let _e104 = global.U[0];
        let _e107 = pos1_;
        let _e108 = d_1;
        let _e119 = textureSampleLevel(t_source2_, samp, ((vec2<f32>(((_e98 + _e99).x / _e104.x), (_e107 + _e108).y) / vec2(2f)) + vec2(0.5f)), 0f);
        let _e120 = count_3;
        let _e121 = sampleCol(_e119, _e120);
        let _e122 = s;
        let _e124 = pos1_;
        let _e125 = d_1;
        let _e127 = X_2;
        let _e128 = Y_2;
        let _e129 = inside_1((_e124 + _e125), _e127, _e128);
        if !(((_e121 == _e122) && _e129)) {
            break;
        }
        {
            let _e132 = pos1_;
            let _e133 = d_1;
            pos1_ = (_e132 + _e133);
        }
    }
    let _e135 = pos1_;
    let _e139 = global.U[0];
    let _e142 = pos1_;
    let _e152 = textureSampleLevel(t_source2_, samp, ((vec2<f32>((_e135.x / _e139.x), _e142.y) / vec2(2f)) + vec2(0.5f)), 0f);
    col1_ = _e152;
    let _e154 = pos_7;
    pos2_ = _e154;
    loop {
        let _e156 = pos2_;
        let _e157 = d_1;
        let _e162 = global.U[0];
        let _e165 = pos2_;
        let _e166 = d_1;
        let _e177 = textureSampleLevel(t_source2_, samp, ((vec2<f32>(((_e156 - _e157).x / _e162.x), (_e165 - _e166).y) / vec2(2f)) + vec2(0.5f)), 0f);
        let _e178 = count_3;
        let _e179 = sampleCol(_e177, _e178);
        let _e180 = s;
        let _e182 = pos2_;
        let _e183 = d_1;
        let _e185 = X_2;
        let _e186 = Y_2;
        let _e187 = inside_1((_e182 - _e183), _e185, _e186);
        if !(((_e179 == _e180) && _e187)) {
            break;
        }
        {
            let _e190 = pos2_;
            let _e191 = d_1;
            pos2_ = (_e190 - _e191);
        }
    }
    let _e193 = pos2_;
    let _e197 = global.U[0];
    let _e200 = pos2_;
    let _e210 = textureSampleLevel(t_source2_, samp, ((vec2<f32>((_e193.x / _e197.x), _e200.y) / vec2(2f)) + vec2(0.5f)), 0f);
    col2_ = _e210;
    let _e212 = pos2_;
    let _e213 = pos1_;
    dd = (_e212 - _e213);
    let _e216 = dd;
    len = length(_e216);
    let _e219 = len;
    if (_e219 == 0f) {
        let _e222 = col;
        return _e222;
    }
    let _e223 = col1_;
    let _e224 = col2_;
    let _e225 = pos_7;
    let _e226 = pos1_;
    let _e228 = len;
    let _e231 = pos2_;
    let _e232 = pos1_;
    let _e234 = len;
    outCol_2 = mix(_e223, _e224, vec4(dot(((_e225 - _e226) / vec2(_e228)), ((_e231 - _e232) / vec2(_e234)))));
    let _e241 = pos_7;
    let _e242 = bkg;
    let _e243 = outCol_2;
    let _e244 = locusMode_3;
    let _e245 = locusTransform_3;
    let _e246 = ciGetLocus(_e241, _e242, _e243, _e244, _e245);
    locus = _e246;
    let _e248 = bkg;
    let _e249 = outCol_2;
    let _e250 = locus;
    return mix(_e248, _e249, vec4(_e250));
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
    let _e69 = global.U[4];
    let _e73 = global.U[6];
    let _e78 = global.U[7];
    let _e79 = _e78.xyz;
    let _e82 = global.U[8];
    let _e83 = _e82.xyz;
    let _e86 = global.U[9];
    let _e87 = _e86.xyz;
    let _e103 = global.U[10];
    let _e108 = global.U[11];
    let _e109 = _e108.xyz;
    let _e112 = global.U[12];
    let _e113 = _e112.xyz;
    let _e116 = global.U[13];
    let _e117 = _e116.xyz;
    let _e131 = contourInterpolateGL((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e12.x, _e12.y, _e12.z), vec3<f32>(_e16.x, _e16.y, _e16.z), vec3<f32>(_e20.x, _e20.y, _e20.z))) * vec3<f32>(_e47.x, _e47.y, 1f)).xy, (((_e54 - vec2(0.5f)) * 2f) * vec2<f32>(_e62.x, 1f)), _e69.xy, i32(_e73.x), mat3x3<f32>(vec3<f32>(_e79.x, _e79.y, _e79.z), vec3<f32>(_e83.x, _e83.y, _e83.z), vec3<f32>(_e87.x, _e87.y, _e87.z)), i32(_e103.x), mat3x3<f32>(vec3<f32>(_e109.x, _e109.y, _e109.z), vec3<f32>(_e113.x, _e113.y, _e113.z), vec3<f32>(_e117.x, _e117.y, _e117.z)));
    fragColor = _e131;
    return;
}

@fragment 
fn main(@location(0) v_uv: vec2<f32>) -> FragmentOutput {
    v_uv_1 = v_uv;
    main_1();
    let _e19 = fragColor;
    return FragmentOutput(_e19);
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
