struct Params {
    U: array<vec4<f32>, 16>,
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
    let _e10 = c_1;
    let _e12 = vec2(2f);
    return (vec2(1f) - abs(((_e10 - (floor((_e10 / _e12)) * _e12)) - vec2(1f))));
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
    let _e15 = target_1;
    let _e16 = camera_1;
    camZ = normalize((_e15 - _e16));
    let _e24 = camZ;
    camX = normalize(cross(vec3<f32>(0f, 1f, 0f), _e24));
    let _e28 = camZ;
    let _e29 = camX;
    camY = cross(_e28, _e29);
    let _e32 = camZ;
    let _e33 = focalDist_1;
    let _e35 = uv_1;
    let _e37 = camX;
    let _e40 = uv_1;
    let _e42 = camY;
    return normalize((((_e32 * _e33) + (_e35.x * _e37)) + (_e40.y * _e42)));
}

fn luma(c_2: vec3<f32>) -> f32 {
    var c_3: vec3<f32>;

    c_3 = c_2;
    let _e10 = c_3;
    let _e14 = c_3;
    let _e19 = c_3;
    return (((0.2989f * _e10.x) + (0.587f * _e14.y)) + (0.114f * _e19.z));
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

fn mergeColorOpacifying(bkg_2: vec4<f32>, front_2: vec4<f32>) -> vec4<f32> {
    var bkg_3: vec4<f32>;
    var front_3: vec4<f32>;
    var a: f32;

    bkg_3 = bkg_2;
    front_3 = front_2;
    let _e12 = bkg_3;
    let _e16 = front_3;
    a = ((1f - _e12.w) * (1f - _e16.w));
    let _e21 = bkg_3;
    let _e23 = front_3;
    let _e25 = front_3;
    let _e27 = a;
    let _e30 = mix(_e21.xyz, _e23.xyz, vec3((_e25.w + _e27)));
    let _e32 = a;
    return vec4<f32>(_e30.x, _e30.y, _e30.z, (1f - _e32));
}

fn topography(pos: vec2<f32>, outPos: vec2<f32>, intensity: f32, count: i32, overlap: f32, mode: i32, sourceBkg_specified: i32, colorFog: vec4<f32>, model3DTransform: mat4x4<f32>, sourceDim: vec2<f32>) -> vec4<f32> {
    var pos_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var intensity_1: f32;
    var count_1: i32;
    var overlap_1: f32;
    var mode_1: i32;
    var sourceBkg_specified_1: i32;
    var colorFog_1: vec4<f32>;
    var model3DTransform_1: mat4x4<f32>;
    var sourceDim_1: vec2<f32>;
    var backgroundColor: vec4<f32> = vec4<f32>(0f, 0f, 0f, 1f);
    var D: f32 = 0.5f;
    var cameraPos: vec3<f32> = vec3<f32>(0f, 0f, 0f);
    var m: mat4x4<f32>;
    var dir: vec3<f32>;
    var kFog: f32 = 1000000000f;
    var col: vec4<f32> = vec4<f32>(0f, 0f, 0f, 0f);
    var N: f32;
    var layerSize: f32;
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
    var uv_2: vec2<f32>;
    var sampleCol: vec4<f32>;
    var lum: f32;
    var layerStart: f32;
    var layerEnd: f32;
    var intersection: vec3<f32>;
    var local_2: vec4<f32>;
    var local_3: vec4<f32>;
    var bkg_4: vec4<f32>;
    var nearDist: f32;
    var farDist: f32;

    pos_1 = pos;
    outPos_1 = outPos;
    intensity_1 = intensity;
    count_1 = count;
    overlap_1 = overlap;
    mode_1 = mode;
    sourceBkg_specified_1 = sourceBkg_specified;
    colorFog_1 = colorFog;
    model3DTransform_1 = model3DTransform;
    sourceDim_1 = sourceDim;
    let _e40 = model3DTransform_1;
    m = _naga_inverse_4x4_f32(_e40);
    let _e43 = m;
    let _e44 = cameraPos;
    cameraPos = (_e43 * vec4<f32>(_e44.x, _e44.y, _e44.z, 1f)).xyz;
    let _e52 = pos_1;
    let _e54 = D;
    let _e56 = pos_1;
    let _e58 = D;
    dir = normalize(vec3<f32>((_e52.x * _e54), (_e56.y * _e58), -1f));
    let _e65 = m;
    let _e75 = dir;
    dir = (mat3x3<f32>(_e65[0].xyz, _e65[1].xyz, _e65[2].xyz) * _e75);
    let _e85 = dir;
    if (_e85.z == 0f) {
        let _e89 = col;
        return _e89;
    }
    let _e90 = count_1;
    N = f32(_e90);
    let _e94 = overlap_1;
    let _e95 = N;
    let _e100 = N;
    layerSize = ((1f + (_e94 * (_e95 - 1f))) / _e100);
    let _e104 = layerSize;
    let _e107 = N;
    layerOffset = ((1f - _e104) / max(1f, (_e107 - 1f)));
    let _e113 = N;
    mid = ((_e113 - 1f) * 0.5f);
    let _e119 = D;
    let _e122 = intensity_1;
    let _e125 = N;
    zStep = (((_e119 * 2f) * _e122) / max(1f, (_e125 - 1f)));
    let _e131 = mode_1;
    clip = (_e131 == 0i);
    let _e137 = sourceDim_1;
    let _e139 = sourceDim_1;
    ratio = (_e137.x / _e139.y);
    let _e143 = dir;
    let _e145 = intensity_1;
    iterDir = ((_e143.z * _e145) > 0f);
    let _e150 = iterDir;
    if _e150 {
        local = 0i;
    } else {
        let _e152 = count_1;
        local = (_e152 - 1i);
    }
    let _e156 = local;
    i = _e156;
    let _e158 = iterDir;
    if _e158 {
        local_1 = 1i;
    } else {
        local_1 = -1i;
    }
    let _e163 = local_1;
    di = _e163;
    loop {
        if false {
            break;
        }
        {
            let _e167 = zStep;
            let _e168 = i;
            let _e170 = mid;
            z = (_e167 * (f32(_e168) - _e170));
            let _e174 = z;
            let _e175 = cameraPos;
            let _e178 = dir;
            k = ((_e174 - _e175.z) / _e178.z);
            let _e182 = dual;
            let _e183 = k;
            if (_e182 || (_e183 > 0f)) {
                {
                    let _e187 = dir;
                    let _e189 = k;
                    let _e191 = cameraPos;
                    uv_2 = ((_e187.xy * _e189) + _e191.xy);
                    let _e195 = clip;
                    let _e197 = uv_2;
                    let _e200 = ratio;
                    let _e202 = uv_2;
                    if (!(_e195) || ((abs(_e197.x) < _e200) && (abs(_e202.y) < 1f))) {
                        {
                            let _e209 = uv_2;
                            let _e213 = global.U[0];
                            let _e216 = uv_2;
                            let _e225 = _mirror_wrap(((vec2<f32>((_e209.x / _e213.x), _e216.y) / vec2(2f)) + vec2(0.5f)));
                            let _e226 = textureSample(t_source, samp, _e225);
                            sampleCol = _e226;
                            let _e228 = sampleCol;
                            let _e230 = luma(_e228.xyz);
                            lum = _e230;
                            let _e232 = layerOffset;
                            let _e233 = i;
                            layerStart = (_e232 * f32(_e233));
                            let _e237 = layerStart;
                            let _e238 = layerSize;
                            layerEnd = (_e237 + _e238);
                            let _e241 = lum;
                            let _e242 = layerStart;
                            let _e244 = lum;
                            let _e245 = layerEnd;
                            if ((_e241 >= _e242) && (_e244 <= _e245)) {
                                {
                                    let _e248 = dir;
                                    let _e249 = k;
                                    let _e251 = cameraPos;
                                    intersection = ((_e248 * _e249) + _e251);
                                    let _e254 = cameraPos;
                                    let _e255 = intersection;
                                    kFog = length((_e254 - _e255));
                                    let _e258 = col;
                                    let _e259 = sampleCol;
                                    let _e260 = mergeColorOpacifying(_e258, _e259);
                                    col = _e260;
                                    let _e261 = col;
                                    if (_e261.w == 1f) {
                                        break;
                                    }
                                }
                            }
                        }
                    }
                }
            }
            let _e265 = i;
            let _e266 = di;
            i = (_e265 + _e266);
            let _e268 = iterDir;
            let _e269 = i;
            let _e270 = count_1;
            let _e273 = iterDir;
            let _e275 = i;
            if ((_e268 && (_e269 >= _e270)) || (!(_e273) && (_e275 < 0i))) {
                break;
            }
        }
    }
    let _e280 = col;
    if (_e280.w < 1f) {
        {
            let _e284 = colorFog_1;
            if (_e284.w != 0f) {
                let _e288 = colorFog_1;
                let _e289 = _e288.xyz;
                local_3 = vec4<f32>(_e289.x, _e289.y, _e289.z, 1f);
            } else {
                let _e295 = sourceBkg_specified_1;
                if (_e295 == 1i) {
                    let _e298 = outPos_1;
                    let _e302 = global.U[0];
                    let _e305 = outPos_1;
                    let _e314 = _mirror_wrap(((vec2<f32>((_e298.x / _e302.x), _e305.y) / vec2(2f)) + vec2(0.5f)));
                    let _e315 = textureSample(t_sourceBkg, samp, _e314);
                    local_2 = _e315;
                } else {
                    local_2 = vec4<f32>(0f, 0f, 0f, 1f);
                }
                let _e322 = local_2;
                local_3 = _e322;
            }
            let _e324 = local_3;
            bkg_4 = _e324;
            let _e326 = bkg_4;
            let _e327 = col;
            let _e328 = mergeColor(_e326, _e327);
            col = _e328;
        }
    }
    let _e329 = colorFog_1;
    if (_e329.w != 0f) {
        {
            let _e335 = colorFog_1;
            nearDist = (2f * (1f - _e335.w));
            let _e341 = nearDist;
            farDist = (2f * _e341);
            let _e344 = nearDist;
            let _e345 = farDist;
            let _e346 = kFog;
            kFog = smoothstep(_e344, _e345, _e346);
            let _e348 = col;
            let _e350 = col;
            let _e352 = colorFog_1;
            let _e354 = kFog;
            let _e356 = mix(_e350.xyz, _e352.xyz, vec3(_e354));
            col.x = _e356.x;
            col.y = _e356.y;
            col.z = _e356.z;
        }
    }
    let _e363 = col;
    return _e363;
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
    let _e67 = global.U[7];
    let _e71 = global.U[8];
    let _e76 = global.U[9];
    let _e80 = global.U[10];
    let _e85 = global.U[4];
    let _e90 = global.U[11];
    let _e93 = global.U[12];
    let _e96 = global.U[13];
    let _e99 = global.U[14];
    let _e102 = global.U[15];
    let _e126 = global.U[5];
    let _e128 = topography((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e10.x, _e10.y, _e10.z), vec3<f32>(_e14.x, _e14.y, _e14.z), vec3<f32>(_e18.x, _e18.y, _e18.z))) * vec3<f32>(_e45.x, _e45.y, 1f)).xy, (((_e52 - vec2(0.5f)) * 2f) * vec2<f32>(_e60.x, 1f)), _e67.x, i32(_e71.x), _e76.x, i32(_e80.x), i32(_e85.x), _e90, mat4x4<f32>(vec4<f32>(_e93.x, _e93.y, _e93.z, _e93.w), vec4<f32>(_e96.x, _e96.y, _e96.z, _e96.w), vec4<f32>(_e99.x, _e99.y, _e99.z, _e99.w), vec4<f32>(_e102.x, _e102.y, _e102.z, _e102.w)), _e126.xy);
    fragColor = _e128;
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
