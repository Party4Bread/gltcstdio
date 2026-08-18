struct Params {
    U: array<vec4<f32>, 15>,
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

fn getBackground(dir: vec3<f32>) -> vec4<f32> {
    var dir_1: vec3<f32>;

    dir_1 = dir;
    return vec4<f32>(0f, 0f, 0f, 1f);
}

fn luma(c: vec3<f32>) -> f32 {
    var c_1: vec3<f32>;

    c_1 = c;
    let _e9 = c_1;
    let _e13 = c_1;
    let _e18 = c_1;
    return (((0.2989f * _e9.x) + (0.587f * _e13.y)) + (0.114f * _e18.z));
}

fn mergeColorOpacifying(bkg: vec4<f32>, front: vec4<f32>) -> vec4<f32> {
    var bkg_1: vec4<f32>;
    var front_1: vec4<f32>;
    var a: f32;

    bkg_1 = bkg;
    front_1 = front;
    let _e11 = bkg_1;
    let _e15 = front_1;
    a = ((1f - _e11.w) * (1f - _e15.w));
    let _e20 = bkg_1;
    let _e22 = front_1;
    let _e24 = front_1;
    let _e26 = a;
    let _e29 = mix(_e20.xyz, _e22.xyz, vec3((_e24.w + _e26)));
    let _e31 = a;
    return vec4<f32>(_e29.x, _e29.y, _e29.z, (1f - _e31));
}

fn translucentSlices(pos: vec2<f32>, outPos: vec2<f32>, intensity: f32, count: i32, overlap: f32, dampening: f32, mode: i32, model3DTransform: mat4x4<f32>, sourceDim: vec2<f32>) -> vec4<f32> {
    var pos_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var intensity_1: f32;
    var count_1: i32;
    var overlap_1: f32;
    var dampening_1: f32;
    var mode_1: i32;
    var model3DTransform_1: mat4x4<f32>;
    var sourceDim_1: vec2<f32>;
    var backgroundColor: vec4<f32> = vec4<f32>(0f, 0f, 0f, 1f);
    var D: f32 = 0.5f;
    var cameraPos: vec3<f32> = vec3<f32>(0f, 0f, 0f);
    var m: mat4x4<f32>;
    var dir_2: vec3<f32>;
    var col: vec4<f32> = vec4(0f);
    var N: f32;
    var layerSize: f32;
    var layerOpaqueSize: f32;
    var maxDist: f32;
    var layerOffset: f32;
    var mid: f32;
    var zStep: f32;
    var clip: bool;
    var dual: bool = false;
    var ratio: f32;
    var iterDir: bool;
    var local: i32;
    var i: i32;
    var local_1: i32;
    var di: i32;
    var z: f32;
    var k: f32;
    var uv: vec2<f32>;
    var sampleCol: vec4<f32>;
    var lum: f32;
    var layerStart: f32;
    var layerEnd: f32;
    var lumCenter: f32;
    var lDist: f32;
    var ka: f32;

    pos_1 = pos;
    outPos_1 = outPos;
    intensity_1 = intensity;
    count_1 = count;
    overlap_1 = overlap;
    dampening_1 = dampening;
    mode_1 = mode;
    model3DTransform_1 = model3DTransform;
    sourceDim_1 = sourceDim;
    let _e37 = model3DTransform_1;
    m = _naga_inverse_4x4_f32(_e37);
    let _e40 = m;
    let _e41 = cameraPos;
    cameraPos = (_e40 * vec4<f32>(_e41.x, _e41.y, _e41.z, 1f)).xyz;
    let _e49 = pos_1;
    let _e51 = D;
    let _e53 = pos_1;
    let _e55 = D;
    dir_2 = normalize(vec3<f32>((_e49.x * _e51), (_e53.y * _e55), -1f));
    let _e62 = m;
    let _e72 = dir_2;
    dir_2 = (mat3x3<f32>(_e62[0].xyz, _e62[1].xyz, _e62[2].xyz) * _e72);
    let _e77 = dir_2;
    if (_e77.z == 0f) {
        let _e81 = col;
        return _e81;
    }
    let _e82 = count_1;
    N = f32(_e82);
    let _e86 = overlap_1;
    let _e87 = N;
    let _e92 = N;
    layerSize = ((1f + (_e86 * (_e87 - 1f))) / _e92);
    let _e96 = N;
    layerOpaqueSize = (0.5f / _e96);
    let _e99 = layerSize;
    let _e102 = layerOpaqueSize;
    maxDist = ((_e99 * 0.5f) - _e102);
    let _e106 = layerSize;
    let _e109 = N;
    layerOffset = ((1f - _e106) / max(1f, (_e109 - 1f)));
    let _e115 = N;
    mid = ((_e115 - 1f) * 0.5f);
    let _e121 = D;
    let _e124 = intensity_1;
    let _e127 = N;
    zStep = (((_e121 * 2f) * _e124) / max(1f, (_e127 - 1f)));
    let _e133 = mode_1;
    clip = (_e133 == 0i);
    let _e139 = sourceDim_1;
    let _e141 = sourceDim_1;
    ratio = (_e139.x / _e141.y);
    let _e145 = dir_2;
    let _e147 = intensity_1;
    iterDir = ((_e145.z * _e147) > 0f);
    let _e152 = iterDir;
    if _e152 {
        local = 0i;
    } else {
        let _e154 = count_1;
        local = (_e154 - 1i);
    }
    let _e158 = local;
    i = _e158;
    let _e160 = iterDir;
    if _e160 {
        local_1 = 1i;
    } else {
        local_1 = -1i;
    }
    let _e165 = local_1;
    di = _e165;
    loop {
        if false {
            break;
        }
        {
            let _e169 = zStep;
            let _e170 = i;
            let _e172 = mid;
            z = (_e169 * (f32(_e170) - _e172));
            let _e176 = z;
            let _e177 = cameraPos;
            let _e180 = dir_2;
            k = ((_e176 - _e177.z) / _e180.z);
            let _e184 = dual;
            let _e185 = k;
            if (_e184 || (_e185 > 0f)) {
                {
                    let _e189 = dir_2;
                    let _e191 = k;
                    let _e193 = cameraPos;
                    uv = ((_e189.xy * _e191) + _e193.xy);
                    let _e197 = clip;
                    let _e199 = uv;
                    let _e202 = ratio;
                    let _e204 = uv;
                    if (!(_e197) || ((abs(_e199.x) < _e202) && (abs(_e204.y) < 1f))) {
                        {
                            let _e211 = uv;
                            let _e215 = global.U[0];
                            let _e218 = uv;
                            let _e228 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e211.x / _e215.x), _e218.y) / vec2(2f)) + vec2(0.5f)), 0f);
                            sampleCol = _e228;
                            let _e230 = sampleCol;
                            let _e232 = luma(_e230.xyz);
                            lum = _e232;
                            let _e234 = layerOffset;
                            let _e235 = i;
                            layerStart = (_e234 * f32(_e235));
                            let _e239 = layerStart;
                            let _e240 = layerSize;
                            layerEnd = (_e239 + _e240);
                            let _e243 = lum;
                            let _e244 = layerStart;
                            let _e246 = lum;
                            let _e247 = layerEnd;
                            if ((_e243 >= _e244) && (_e246 <= _e247)) {
                                {
                                    let _e250 = i;
                                    let _e254 = N;
                                    lumCenter = ((f32(_e250) + 0.5f) / _e254);
                                    let _e257 = lum;
                                    let _e258 = lumCenter;
                                    lDist = abs((_e257 - _e258));
                                    let _e262 = lDist;
                                    let _e263 = layerOpaqueSize;
                                    if (_e262 <= _e263) {
                                        {
                                            let _e265 = col;
                                            let _e266 = sampleCol;
                                            let _e267 = mergeColorOpacifying(_e265, _e266);
                                            col = _e267;
                                        }
                                    } else {
                                        {
                                            let _e270 = lDist;
                                            let _e271 = layerOpaqueSize;
                                            let _e273 = maxDist;
                                            let _e278 = dampening_1;
                                            ka = pow(max(0f, (1f - ((_e270 - _e271) / _e273))), pow(10f, _e278));
                                            let _e282 = col;
                                            let _e283 = sampleCol;
                                            let _e284 = _e283.xyz;
                                            let _e285 = sampleCol;
                                            let _e287 = ka;
                                            let _e293 = mergeColorOpacifying(_e282, vec4<f32>(_e284.x, _e284.y, _e284.z, (_e285.w * _e287)));
                                            col = _e293;
                                        }
                                    }
                                    let _e294 = col;
                                    if (_e294.w > 0.995f) {
                                        break;
                                    }
                                }
                            }
                        }
                    }
                }
            }
            let _e298 = i;
            let _e299 = di;
            i = (_e298 + _e299);
            let _e301 = iterDir;
            let _e302 = i;
            let _e303 = count_1;
            let _e306 = iterDir;
            let _e308 = i;
            if ((_e301 && (_e302 >= _e303)) || (!(_e306) && (_e308 < 0i))) {
                break;
            }
        }
    }
    let _e313 = dir_2;
    let _e314 = getBackground(_e313);
    let _e315 = col;
    let _e316 = mergeColorOpacifying(_e314, _e315);
    col = _e316;
    let _e317 = col;
    let _e318 = _e317.xyz;
    return vec4<f32>(_e318.x, _e318.y, _e318.z, 1f);
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
    let _e75 = global.U[8];
    let _e79 = global.U[9];
    let _e83 = global.U[10];
    let _e88 = global.U[11];
    let _e91 = global.U[12];
    let _e94 = global.U[13];
    let _e97 = global.U[14];
    let _e121 = global.U[4];
    let _e123 = translucentSlices((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e9.x, _e9.y, _e9.z), vec3<f32>(_e13.x, _e13.y, _e13.z), vec3<f32>(_e17.x, _e17.y, _e17.z))) * vec3<f32>(_e44.x, _e44.y, 1f)).xy, (((_e51 - vec2(0.5f)) * 2f) * vec2<f32>(_e59.x, 1f)), _e66.x, i32(_e70.x), _e75.x, _e79.x, i32(_e83.x), mat4x4<f32>(vec4<f32>(_e88.x, _e88.y, _e88.z, _e88.w), vec4<f32>(_e91.x, _e91.y, _e91.z, _e91.w), vec4<f32>(_e94.x, _e94.y, _e94.z, _e94.w), vec4<f32>(_e97.x, _e97.y, _e97.z, _e97.w)), _e121.xy);
    fragColor = _e123;
    return;
}

@fragment 
fn main(@location(0) v_uv: vec2<f32>) -> FragmentOutput {
    v_uv_1 = v_uv;
    main_1();
    let _e13 = fragColor;
    return FragmentOutput(_e13);
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
