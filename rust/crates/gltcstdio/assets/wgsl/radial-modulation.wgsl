struct Params {
    U: array<vec4<f32>, 19>,
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

fn tf(m: mat3x3<f32>, u: vec2<f32>) -> vec2<f32> {
    var m_1: mat3x3<f32>;
    var u_1: vec2<f32>;

    m_1 = m;
    u_1 = u;
    let _e10 = m_1;
    let _e11 = u_1;
    return (_e10 * vec3<f32>(_e11.x, _e11.y, 1f)).xy;
}

fn modulation(pos: vec2<f32>, outPos: vec2<f32>, intensity: f32, thickness: f32, smoothen: f32, step: f32, color1_: vec4<f32>, color2_: vec4<f32>, contrast: f32, brightness: f32, vignetting: f32, scanlines: f32, sourceDim: vec2<f32>, modelTransform: mat3x3<f32>) -> vec4<f32> {
    var pos_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var intensity_1: f32;
    var thickness_1: f32;
    var smoothen_1: f32;
    var step_1: f32;
    var color1_1: vec4<f32>;
    var color2_1: vec4<f32>;
    var contrast_1: f32;
    var brightness_1: f32;
    var vignetting_1: f32;
    var scanlines_1: f32;
    var sourceDim_1: vec2<f32>;
    var modelTransform_1: mat3x3<f32>;
    var centre: vec2<f32>;
    var ratio: f32;
    var dir: vec2<f32>;
    var pixel: f32;
    var dim: vec2<f32>;
    var p: vec2<f32>;
    var k: f32 = 0f;
    var acc: f32 = 0f;
    var diag: f32;
    var radius: f32;
    var weight: f32;
    var N: i32;
    var bestL: f32 = 10000000000f;
    var i: i32 = 0i;
    var c: vec4<f32>;
    var val: f32;
    var dd: vec2<f32>;
    var i_1: i32 = 0i;
    var c_1: vec4<f32>;
    var val_1: f32;
    var vignette: f32;
    var bkgCol: vec4<f32>;
    var lineColor: vec4<f32>;
    var backColor: vec4<f32>;
    var color: vec4<f32>;
    var outColor: vec4<f32>;

    pos_1 = pos;
    outPos_1 = outPos;
    intensity_1 = intensity;
    thickness_1 = thickness;
    smoothen_1 = smoothen;
    step_1 = step;
    color1_1 = color1_;
    color2_1 = color2_;
    contrast_1 = contrast;
    brightness_1 = brightness;
    vignetting_1 = vignetting;
    scanlines_1 = scanlines;
    sourceDim_1 = sourceDim;
    modelTransform_1 = modelTransform;
    let _e34 = modelTransform_1;
    let _e37 = tf(_e34, vec2(0f));
    centre = _e37;
    let _e39 = sourceDim_1;
    let _e41 = sourceDim_1;
    ratio = (_e39.x / _e41.y);
    let _e45 = pos_1;
    let _e46 = centre;
    dir = normalize((_e45 - _e46));
    let _e51 = sourceDim_1;
    pixel = (2f / _e51.y);
    let _e55 = pixel;
    let _e58 = step_1;
    step_1 = ((_e55 * 1f) * _e58);
    let _e60 = ratio;
    dim = vec2<f32>(_e60, 1f);
    let _e64 = centre;
    p = _e64;
    let _e70 = dim;
    diag = length(_e70);
    let _e73 = thickness_1;
    radius = (_e73 * 0.02f);
    let _e77 = step_1;
    let _e80 = intensity_1;
    weight = ((_e77 * 333.33f) * _e80);
    let _e83 = dim;
    let _e85 = dim;
    let _e90 = pixel;
    let _e92 = p;
    let _e93 = pos_1;
    let _e96 = radius;
    let _e98 = step_1;
    N = i32(min((((_e83.x + _e85.y) * 2.01f) / _e90), ceil(((length((_e92 - _e93)) + _e96) / _e98))));
    let _e106 = vignetting_1;
    let _e109 = contrast_1;
    let _e113 = brightness_1;
    let _e117 = smoothen_1;
    if ((((_e106 == 0f) && (_e109 == 0f)) && (_e113 == 0f)) && (_e117 == 0f)) {
        {
            loop {
                let _e123 = i;
                let _e124 = N;
                if !((_e123 < _e124)) {
                    break;
                }
                {
                    let _e130 = p;
                    let _e134 = global.U[0];
                    let _e137 = p;
                    let _e146 = textureSample(t_source, samp, ((vec2<f32>((_e130.x / _e134.x), _e137.y) / vec2(2f)) + vec2(0.5f)));
                    c = _e146;
                    let _e148 = c;
                    let _e150 = c;
                    let _e153 = c;
                    val = ((_e148.x + _e150.y) + _e153.z);
                    let _e157 = acc;
                    let _e158 = weight;
                    let _e159 = val;
                    acc = (_e157 + (_e158 * _e159));
                    let _e162 = acc;
                    if (_e162 >= 1f) {
                        {
                            let _e165 = p;
                            let _e166 = pos_1;
                            dd = (_e165 - _e166);
                            let _e169 = bestL;
                            let _e170 = dd;
                            let _e171 = dd;
                            bestL = min(_e169, dot(_e170, _e171));
                            acc = 0f;
                        }
                    }
                    let _e175 = p;
                    let _e176 = step_1;
                    let _e177 = dir;
                    p = (_e175 + (_e176 * _e177));
                }
                continuing {
                    let _e127 = i;
                    i = (_e127 + 1i);
                }
            }
            let _e180 = radius;
            let _e182 = bestL;
            k = smoothstep(_e180, 0f, sqrt(_e182));
        }
    } else {
        {
            loop {
                let _e187 = i_1;
                let _e188 = N;
                if !((_e187 < _e188)) {
                    break;
                }
                {
                    let _e194 = p;
                    let _e198 = global.U[0];
                    let _e201 = p;
                    let _e210 = textureSample(t_source, samp, ((vec2<f32>((_e194.x / _e198.x), _e201.y) / vec2(2f)) + vec2(0.5f)));
                    c_1 = _e210;
                    let _e212 = c_1;
                    let _e214 = c_1;
                    let _e217 = c_1;
                    val_1 = ((_e212.x + _e214.y) + _e217.z);
                    let _e221 = val_1;
                    let _e224 = contrast_1;
                    let _e228 = brightness_1;
                    val_1 = ((((_e221 - 0.5f) * _e224) + 0.5f) + _e228);
                    let _e230 = vignetting_1;
                    if (_e230 != 0f) {
                        {
                            let _e236 = p;
                            let _e238 = diag;
                            let _e241 = vignetting_1;
                            vignette = mix(1f, smoothstep(1f, 0f, (length(_e236) / _e238)), _e241);
                            let _e244 = val_1;
                            let _e245 = vignette;
                            val_1 = (_e244 * _e245);
                        }
                    }
                    let _e247 = acc;
                    let _e248 = weight;
                    let _e249 = val_1;
                    acc = (_e247 + (_e248 * _e249));
                    let _e252 = acc;
                    if (_e252 >= 1f) {
                        {
                            let _e255 = bestL;
                            let _e256 = p;
                            let _e257 = pos_1;
                            bestL = min(_e255, length((_e256 - _e257)));
                            acc = 0f;
                        }
                    }
                    let _e262 = smoothen_1;
                    if (_e262 > 0f) {
                        {
                            let _e265 = acc;
                            let _e268 = p;
                            let _e275 = smoothen_1;
                            let _e278 = pixel;
                            acc = mix(_e265, (0.5f + (0.5f * sin((_e268.x * 100f)))), ((_e275 * 91f) * _e278));
                        }
                    }
                    let _e281 = p;
                    let _e282 = step_1;
                    let _e283 = dir;
                    p = (_e281 + (_e282 * _e283));
                }
                continuing {
                    let _e191 = i_1;
                    i_1 = (_e191 + 1i);
                }
            }
            let _e286 = radius;
            let _e288 = bestL;
            k = smoothstep(_e286, 0f, _e288);
        }
    }
    let _e290 = pos_1;
    let _e294 = global.U[0];
    let _e297 = pos_1;
    let _e306 = textureSample(t_source, samp, ((vec2<f32>((_e290.x / _e294.x), _e297.y) / vec2(2f)) + vec2(0.5f)));
    bkgCol = _e306;
    let _e308 = bkgCol;
    let _e310 = color2_1;
    let _e312 = color2_1;
    let _e315 = mix(_e308.xyz, _e310.xyz, vec3(_e312.w));
    let _e316 = bkgCol;
    lineColor = vec4<f32>(_e315.x, _e315.y, _e315.z, _e316.w);
    let _e323 = bkgCol;
    let _e325 = color1_1;
    let _e327 = color1_1;
    let _e330 = mix(_e323.xyz, _e325.xyz, vec3(_e327.w));
    let _e331 = bkgCol;
    backColor = vec4<f32>(_e330.x, _e330.y, _e330.z, _e331.w);
    let _e338 = backColor;
    let _e339 = lineColor;
    let _e340 = k;
    color = mix(_e338, _e339, vec4(clamp(_e340, 0f, 1f)));
    let _e347 = color;
    outColor = _e347;
    let _e349 = scanlines_1;
    if (_e349 != 0f) {
        {
            let _e352 = outColor;
            let _e354 = outColor;
            let _e358 = pos_1;
            let _e362 = ratio;
            let _e370 = scanlines_1;
            let _e372 = (_e354.xyz * mix(1f, pow(((1.1f + sin(((_e358.y * 400f) / _e362))) * 0.5f), 0.4f), _e370));
            outColor.x = _e372.x;
            outColor.y = _e372.y;
            outColor.z = _e372.z;
        }
    }
    let _e379 = outColor;
    return _e379;
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
    let _e66 = global.U[6];
    let _e70 = global.U[7];
    let _e74 = global.U[8];
    let _e78 = global.U[9];
    let _e82 = global.U[10];
    let _e85 = global.U[11];
    let _e88 = global.U[12];
    let _e92 = global.U[13];
    let _e96 = global.U[14];
    let _e100 = global.U[15];
    let _e104 = global.U[4];
    let _e108 = global.U[16];
    let _e109 = _e108.xyz;
    let _e112 = global.U[17];
    let _e113 = _e112.xyz;
    let _e116 = global.U[18];
    let _e117 = _e116.xyz;
    let _e131 = modulation((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e9.x, _e9.y, _e9.z), vec3<f32>(_e13.x, _e13.y, _e13.z), vec3<f32>(_e17.x, _e17.y, _e17.z))) * vec3<f32>(_e44.x, _e44.y, 1f)).xy, (((_e51 - vec2(0.5f)) * 2f) * vec2<f32>(_e59.x, 1f)), _e66.x, _e70.x, _e74.x, _e78.x, _e82, _e85, _e88.x, _e92.x, _e96.x, _e100.x, _e104.xy, mat3x3<f32>(vec3<f32>(_e109.x, _e109.y, _e109.z), vec3<f32>(_e113.x, _e113.y, _e113.z), vec3<f32>(_e117.x, _e117.y, _e117.z)));
    fragColor = _e131;
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
