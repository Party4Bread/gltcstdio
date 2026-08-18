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
@group(0) @binding(3) 
var t_sourceBkg: texture_2d<f32>;
@group(0) @binding(4) 
var t_sourceElevation: texture_2d<f32>;

fn hmggl_height(intensity: f32, color: vec4<f32>) -> f32 {
    var intensity_1: f32;
    var color_1: vec4<f32>;

    intensity_1 = intensity;
    color_1 = color;
    let _e12 = intensity_1;
    let _e15 = color_1;
    let _e17 = color_1;
    let _e20 = color_1;
    return ((_e12 * 0.04f) * ((((_e15.x + _e17.y) + _e20.z) / 3f) - 0.5f));
}

fn heightMapGlitchyGl(pos: vec2<f32>, outPos: vec2<f32>, sourceBkg_specified: i32, sourceElevation_specified: i32, intensity_2: f32, count: i32, sourceDim: vec2<f32>, sourceElevationDim: vec2<f32>, model3DTransform: mat4x4<f32>) -> vec4<f32> {
    var pos_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var sourceBkg_specified_1: i32;
    var sourceElevation_specified_1: i32;
    var intensity_3: f32;
    var count_1: i32;
    var sourceDim_1: vec2<f32>;
    var sourceElevationDim_1: vec2<f32>;
    var model3DTransform_1: mat4x4<f32>;
    var backgroundColor: vec4<f32> = vec4<f32>(0f, 0f, 0f, 1f);
    var D: f32 = 1f;
    var cameraPos: vec3<f32> = vec3<f32>(0f, 0f, 0f);
    var m: mat4x4<f32>;
    var dir: vec3<f32>;
    var heightMap: bool;
    var maxZ: f32;
    var local: f32;
    var ratio: f32;
    var local_1: f32;
    var dk: f32;
    var fResolution: f32;
    var ballSize: f32;
    var surfaceHeight: f32 = 2f;
    var k1_: f32 = 0f;
    var k2_: f32 = 100000000f;
    var s: f32;
    var k3_: f32;
    var k4_: f32;
    var s_1: f32;
    var k3_1: f32;
    var k4_1: f32;
    var maxZ2_: f32;
    var s_2: f32;
    var k3_2: f32;
    var k4_2: f32;
    var local_2: vec4<f32>;
    var k: f32;
    var p: vec3<f32>;
    var local_3: vec4<f32>;
    var color_2: vec4<f32>;
    var intersected: f32 = 0f;
    var outColor: vec4<f32> = vec4<f32>(0f, 0f, 0f, 0f);
    var maxIter: i32 = 500i;
    var minK: f32;
    var step: vec3<f32>;
    var local_4: vec4<f32>;
    var hColor: vec4<f32>;
    var h: f32;

    pos_1 = pos;
    outPos_1 = outPos;
    sourceBkg_specified_1 = sourceBkg_specified;
    sourceElevation_specified_1 = sourceElevation_specified;
    intensity_3 = intensity_2;
    count_1 = count;
    sourceDim_1 = sourceDim;
    sourceElevationDim_1 = sourceElevationDim;
    model3DTransform_1 = model3DTransform;
    let _e39 = model3DTransform_1;
    m = _naga_inverse_4x4_f32(_e39);
    let _e42 = m;
    let _e43 = cameraPos;
    cameraPos = (_e42 * vec4<f32>(_e43.x, _e43.y, _e43.z, 1f)).xyz;
    let _e51 = pos_1;
    let _e53 = D;
    let _e55 = pos_1;
    let _e57 = D;
    dir = vec3<f32>((_e51.x * _e53), (_e55.y * _e57), -1f);
    let _e63 = m;
    let _e73 = dir;
    dir = normalize((mat3x3<f32>(_e63[0].xyz, _e63[1].xyz, _e63[2].xyz) * _e73));
    let _e76 = sourceElevation_specified_1;
    heightMap = (_e76 == 1i);
    let _e80 = intensity_3;
    maxZ = (abs(_e80) * 0.02f);
    let _e85 = heightMap;
    if _e85 {
        let _e86 = sourceElevationDim_1;
        let _e88 = sourceElevationDim_1;
        local = (_e86.x / _e88.y);
    } else {
        let _e91 = sourceDim_1;
        let _e93 = sourceDim_1;
        local = (_e91.x / _e93.y);
    }
    let _e97 = local;
    ratio = _e97;
    let _e99 = heightMap;
    if _e99 {
        let _e101 = sourceElevationDim_1;
        local_1 = (2f / _e101.y);
    } else {
        let _e105 = sourceDim_1;
        local_1 = (2f / _e105.y);
    }
    let _e109 = local_1;
    dk = _e109;
    let _e111 = count_1;
    fResolution = f32(_e111);
    let _e115 = fResolution;
    ballSize = (2f / _e115);
    let _e118 = maxZ;
    let _e119 = ballSize;
    maxZ = (_e118 + _e119);
    let _e127 = dir;
    if (_e127.x != 0f) {
        {
            let _e131 = dir;
            s = sign(_e131.x);
            let _e135 = s;
            let _e137 = ratio;
            let _e139 = cameraPos;
            let _e142 = dir;
            k3_ = (((-(_e135) * _e137) - _e139.x) / _e142.x);
            let _e146 = s;
            let _e147 = ratio;
            let _e149 = cameraPos;
            let _e152 = dir;
            k4_ = (((_e146 * _e147) - _e149.x) / _e152.x);
            let _e156 = k1_;
            let _e157 = k3_;
            k1_ = max(_e156, _e157);
            let _e159 = k2_;
            let _e160 = k4_;
            k2_ = min(_e159, _e160);
        }
    }
    let _e162 = dir;
    if (_e162.y != 0f) {
        {
            let _e166 = dir;
            s_1 = sign(_e166.y);
            let _e170 = s_1;
            let _e172 = cameraPos;
            let _e175 = dir;
            k3_1 = ((-(_e170) - _e172.y) / _e175.y);
            let _e179 = s_1;
            let _e180 = cameraPos;
            let _e183 = dir;
            k4_1 = ((_e179 - _e180.y) / _e183.y);
            let _e187 = k1_;
            let _e188 = k3_1;
            k1_ = max(_e187, _e188);
            let _e190 = k2_;
            let _e191 = k4_1;
            k2_ = min(_e190, _e191);
        }
    }
    let _e193 = maxZ;
    maxZ2_ = (_e193 + 0.0001f);
    let _e197 = dir;
    if (_e197.z != 0f) {
        {
            let _e201 = dir;
            s_2 = sign(_e201.z);
            let _e205 = s_2;
            let _e207 = maxZ2_;
            let _e209 = cameraPos;
            let _e212 = dir;
            k3_2 = (((-(_e205) * _e207) - _e209.z) / _e212.z);
            let _e216 = s_2;
            let _e217 = maxZ2_;
            let _e219 = cameraPos;
            let _e222 = dir;
            k4_2 = (((_e216 * _e217) - _e219.z) / _e222.z);
            let _e226 = k1_;
            let _e227 = k3_2;
            k1_ = max(_e226, _e227);
            let _e229 = k2_;
            let _e230 = k4_2;
            k2_ = min(_e229, _e230);
        }
    }
    let _e232 = k1_;
    let _e233 = k2_;
    if (_e232 > _e233) {
        let _e235 = sourceBkg_specified_1;
        if (_e235 == 1i) {
            let _e238 = outPos_1;
            let _e242 = global.U[0];
            let _e245 = outPos_1;
            let _e255 = textureSampleLevel(t_sourceBkg, samp, ((vec2<f32>((_e238.x / _e242.x), _e245.y) / vec2(2f)) + vec2(0.5f)), 0f);
            local_2 = _e255;
        } else {
            local_2 = vec4<f32>(0f, 0f, 0f, 1f);
        }
        let _e262 = local_2;
        return _e262;
    }
    let _e263 = k1_;
    k = _e263;
    let _e265 = cameraPos;
    let _e266 = k;
    let _e267 = dir;
    p = (_e265 + (_e266 * _e267));
    let _e271 = sourceBkg_specified_1;
    if (_e271 == 1i) {
        let _e274 = outPos_1;
        let _e278 = global.U[0];
        let _e281 = outPos_1;
        let _e291 = textureSampleLevel(t_sourceBkg, samp, ((vec2<f32>((_e274.x / _e278.x), _e281.y) / vec2(2f)) + vec2(0.5f)), 0f);
        local_3 = _e291;
    } else {
        local_3 = vec4<f32>(0f, 0f, 0f, 1f);
    }
    let _e298 = local_3;
    color_2 = _e298;
    let _e310 = ballSize;
    minK = (_e310 / 4f);
    let _e314 = minK;
    let _e315 = dir;
    step = (_e314 * _e315);
    loop {
        let _e318 = intersected;
        let _e321 = k;
        let _e322 = k2_;
        let _e325 = maxIter;
        if !((((_e318 < 1f) && (_e321 <= _e322)) && (_e325 > 0i))) {
            break;
        }
        {
            let _e330 = heightMap;
            if _e330 {
                let _e331 = p;
                let _e336 = global.U[0];
                let _e339 = p;
                let _e350 = textureSampleLevel(t_sourceElevation, samp, ((vec2<f32>((_e331.x / _e336.x), _e339.y) / vec2(2f)) + vec2(0.5f)), 0f);
                local_4 = _e350;
            } else {
                let _e351 = p;
                let _e356 = global.U[0];
                let _e359 = p;
                let _e370 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e351.x / _e356.x), _e359.y) / vec2(2f)) + vec2(0.5f)), 0f);
                local_4 = _e370;
            }
            let _e372 = local_4;
            hColor = _e372;
            let _e374 = intensity_3;
            let _e375 = hColor;
            let _e376 = hmggl_height(_e374, _e375);
            h = _e376;
            let _e378 = h;
            let _e379 = p;
            if (_e378 > _e379.z) {
                {
                    let _e382 = p;
                    let _e387 = global.U[0];
                    let _e390 = p;
                    let _e401 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e382.x / _e387.x), _e390.y) / vec2(2f)) + vec2(0.5f)), 0f);
                    outColor = _e401;
                    intersected = 1f;
                }
            }
            let _e403 = k;
            let _e404 = minK;
            k = (_e403 + _e404);
            let _e406 = p;
            let _e407 = step;
            p = (_e406 + _e407);
            let _e409 = maxIter;
            maxIter = (_e409 - 1i);
        }
    }
    let _e412 = color_2;
    let _e413 = outColor;
    let _e414 = _e413.xyz;
    let _e415 = color_2;
    let _e421 = outColor;
    return mix(_e412, vec4<f32>(_e414.x, _e414.y, _e414.z, _e415.w), vec4(_e421.w));
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
    let _e68 = global.U[4];
    let _e73 = global.U[5];
    let _e78 = global.U[9];
    let _e82 = global.U[10];
    let _e87 = global.U[6];
    let _e91 = global.U[7];
    let _e95 = global.U[11];
    let _e98 = global.U[12];
    let _e101 = global.U[13];
    let _e104 = global.U[14];
    let _e126 = heightMapGlitchyGl((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e11.x, _e11.y, _e11.z), vec3<f32>(_e15.x, _e15.y, _e15.z), vec3<f32>(_e19.x, _e19.y, _e19.z))) * vec3<f32>(_e46.x, _e46.y, 1f)).xy, (((_e53 - vec2(0.5f)) * 2f) * vec2<f32>(_e61.x, 1f)), i32(_e68.x), i32(_e73.x), _e78.x, i32(_e82.x), _e87.xy, _e91.xy, mat4x4<f32>(vec4<f32>(_e95.x, _e95.y, _e95.z, _e95.w), vec4<f32>(_e98.x, _e98.y, _e98.z, _e98.w), vec4<f32>(_e101.x, _e101.y, _e101.z, _e101.w), vec4<f32>(_e104.x, _e104.y, _e104.z, _e104.w)));
    fragColor = _e126;
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
