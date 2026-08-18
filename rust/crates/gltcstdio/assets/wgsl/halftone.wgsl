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

fn _mirror_wrap(c: vec2<f32>) -> vec2<f32> {
    var c_1: vec2<f32>;

    c_1 = c;
    let _e9 = c_1;
    let _e11 = vec2(2f);
    return (vec2(1f) - abs(((_e9 - (floor((_e9 / _e11)) * _e11)) - vec2(1f))));
}

fn luma(c_2: vec3<f32>) -> f32 {
    var c_3: vec3<f32>;

    c_3 = c_2;
    let _e9 = c_3;
    let _e13 = c_3;
    let _e18 = c_3;
    return (((0.2989f * _e9.x) + (0.587f * _e13.y)) + (0.114f * _e18.z));
}

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

fn halftone(uv_10: vec2<f32>, outPos: vec2<f32>, smoothen: f32, intensity: f32, modelTransform: mat3x3<f32>, color1_: vec4<f32>, color2_: vec4<f32>, sampling: i32, style: i32) -> vec4<f32> {
    var uv_11: vec2<f32>;
    var outPos_1: vec2<f32>;
    var smoothen_1: f32;
    var intensity_1: f32;
    var modelTransform_1: mat3x3<f32>;
    var color1_1: vec4<f32>;
    var color2_1: vec4<f32>;
    var sampling_1: i32;
    var style_1: i32;
    var pattern: vec3<f32>;
    var _sw_sel: i32;
    var threshold_5: f32;
    var samplePos: vec2<f32>;
    var _sw_sel_1: i32;
    var color: vec4<f32> = vec4(0f);
    var N: i32 = 5i;
    var r_1: f32;
    var step: f32;
    var j: i32;
    var i: i32;
    var local_1: f32;
    var k: f32;
    var outColor: vec4<f32>;

    uv_11 = uv_10;
    outPos_1 = outPos;
    smoothen_1 = smoothen;
    intensity_1 = intensity;
    modelTransform_1 = modelTransform;
    color1_1 = color1_;
    color2_1 = color2_;
    sampling_1 = sampling;
    style_1 = style;
    {
        let _e25 = style_1;
        _sw_sel = i32(_e25);
        let _e28 = _sw_sel;
        if (_e28 == 0i) {
            {
                let _e32 = modelTransform_1;
                let _e34 = uv_11;
                let _e35 = patternDots(_naga_inverse_3x3_f32(_e32), _e34);
                pattern = _e35;
            }
        } else {
            let _e36 = _sw_sel;
            if (_e36 == 1i) {
                {
                    let _e40 = modelTransform_1;
                    let _e42 = uv_11;
                    let _e43 = patternHexDots(_naga_inverse_3x3_f32(_e40), _e42);
                    pattern = _e43;
                }
            } else {
                let _e44 = _sw_sel;
                if (_e44 == 2i) {
                    {
                        let _e48 = modelTransform_1;
                        let _e50 = uv_11;
                        let _e51 = patternLines(_naga_inverse_3x3_f32(_e48), _e50);
                        pattern = _e51;
                    }
                } else {
                    let _e52 = _sw_sel;
                    if (_e52 == 3i) {
                        {
                            let _e56 = modelTransform_1;
                            let _e58 = uv_11;
                            let _e59 = patternConcentricLines(_naga_inverse_3x3_f32(_e56), _e58);
                            pattern = _e59;
                        }
                    } else {
                        let _e60 = _sw_sel;
                        if (_e60 == 4i) {
                            {
                                let _e64 = modelTransform_1;
                                let _e66 = uv_11;
                                let _e67 = patternWavyLines(_naga_inverse_3x3_f32(_e64), _e66);
                                pattern = _e67;
                            }
                        }
                    }
                }
            }
        }
    }
    let _e68 = pattern;
    let _e70 = intensity_1;
    threshold_5 = (_e68.z * _e70);
    {
        let _e74 = sampling_1;
        _sw_sel_1 = i32(_e74);
        let _e77 = _sw_sel_1;
        if (_e77 == 0i) {
            {
                let _e81 = modelTransform_1;
                let _e82 = pattern;
                let _e84 = tf(_e81, _e82.xy);
                samplePos = _e84;
            }
        } else {
            {
                let _e85 = uv_11;
                samplePos = _e85;
            }
        }
    }
    let _e89 = smoothen_1;
    if (_e89 > 0f) {
        {
            let _e96 = modelTransform_1[0];
            let _e99 = smoothen_1;
            r_1 = ((length(_e96.xy) * _e99) * 3f);
            let _e104 = r_1;
            let _e105 = N;
            step = (_e104 / f32(_e105));
            let _e109 = N;
            j = -(_e109);
            loop {
                let _e112 = j;
                let _e113 = N;
                if !((_e112 <= _e113)) {
                    break;
                }
                {
                    let _e119 = N;
                    i = -(_e119);
                    loop {
                        let _e122 = i;
                        let _e123 = N;
                        if !((_e122 <= _e123)) {
                            break;
                        }
                        {
                            let _e129 = color;
                            let _e130 = samplePos;
                            let _e131 = i;
                            let _e133 = j;
                            let _e136 = step;
                            let _e142 = global.U[0];
                            let _e145 = samplePos;
                            let _e146 = i;
                            let _e148 = j;
                            let _e151 = step;
                            let _e162 = _mirror_wrap(((vec2<f32>(((_e130 + (vec2<f32>(f32(_e131), f32(_e133)) * _e136)).x / _e142.x), (_e145 + (vec2<f32>(f32(_e146), f32(_e148)) * _e151)).y) / vec2(2f)) + vec2(0.5f)));
                            let _e163 = textureSample(t_source, samp, _e162);
                            color = (_e129 + _e163);
                        }
                        continuing {
                            let _e126 = i;
                            i = (_e126 + 1i);
                        }
                    }
                }
                continuing {
                    let _e116 = j;
                    j = (_e116 + 1i);
                }
            }
            let _e165 = color;
            let _e167 = N;
            let _e172 = N;
            color = (_e165 / vec4(f32((((2i * _e167) + 1i) * ((2i * _e172) + 1i)))));
        }
    } else {
        {
            let _e180 = samplePos;
            let _e184 = global.U[0];
            let _e187 = samplePos;
            let _e196 = _mirror_wrap(((vec2<f32>((_e180.x / _e184.x), _e187.y) / vec2(2f)) + vec2(0.5f)));
            let _e197 = textureSample(t_source, samp, _e196);
            color = _e197;
        }
    }
    let _e198 = color;
    let _e200 = luma(_e198.xyz);
    let _e201 = threshold_5;
    if (_e200 > _e201) {
        local_1 = 1f;
    } else {
        local_1 = 0f;
    }
    let _e206 = local_1;
    k = _e206;
    let _e208 = color2_1;
    let _e209 = color1_1;
    let _e210 = k;
    outColor = mix(_e208, _e209, vec4(_e210));
    let _e214 = color;
    let _e215 = outColor;
    let _e216 = mergeColor(_e214, _e215);
    return _e216;
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
    let _e102 = global.U[11];
    let _e105 = global.U[12];
    let _e110 = global.U[13];
    let _e113 = halftone((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e9.x, _e9.y, _e9.z), vec3<f32>(_e13.x, _e13.y, _e13.z), vec3<f32>(_e17.x, _e17.y, _e17.z))) * vec3<f32>(_e44.x, _e44.y, 1f)).xy, (((_e51 - vec2(0.5f)) * 2f) * vec2<f32>(_e59.x, 1f)), _e66.x, _e70.x, mat3x3<f32>(vec3<f32>(_e75.x, _e75.y, _e75.z), vec3<f32>(_e79.x, _e79.y, _e79.z), vec3<f32>(_e83.x, _e83.y, _e83.z)), _e99, _e102, i32(_e105.x), i32(_e110.x));
    fragColor = _e113;
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
