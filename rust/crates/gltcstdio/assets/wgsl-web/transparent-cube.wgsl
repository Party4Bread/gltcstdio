struct Params {
    U: array<vec4<f32>, 12>,
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

fn height(intensity: f32, color: vec4<f32>) -> f32 {
    var intensity_1: f32;
    var color_1: vec4<f32>;

    intensity_1 = intensity;
    color_1 = color;
    let _e10 = intensity_1;
    let _e13 = color_1;
    let _e15 = color_1;
    let _e18 = color_1;
    return ((_e10 * 0.04f) * ((((_e13.x + _e15.y) + _e18.z) / 3f) - 0.5f));
}

fn transparentCube(pos: vec2<f32>, outPos: vec2<f32>, intensity_2: f32, dampening: f32, model3DTransform: mat4x4<f32>, sourceDim: vec2<f32>) -> vec4<f32> {
    var pos_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var intensity_3: f32;
    var dampening_1: f32;
    var model3DTransform_1: mat4x4<f32>;
    var sourceDim_1: vec2<f32>;
    var backgroundColor: vec4<f32> = vec4<f32>(0f, 0f, 0f, 1f);
    var normalizedDampening: f32;
    var m: mat4x4<f32>;
    var cameraPos: vec3<f32>;
    var dir: vec3<f32>;
    var maxZ: f32;
    var ratio: f32;
    var dk: f32;
    var step: vec3<f32>;
    var k1_: f32 = 0f;
    var k2_: f32 = 100000000f;
    var k3_: f32;
    var k4_: f32;
    var k3_1: f32;
    var k4_1: f32;
    var k3_2: f32;
    var k4_2: f32;
    var k3_3: f32;
    var k4_3: f32;
    var k3_4: f32;
    var k4_4: f32;
    var k3_5: f32;
    var k4_5: f32;
    var k: f32;
    var p: vec3<f32>;
    var color_2: vec4<f32>;
    var sumColor: vec4<f32> = vec4<f32>(0f, 0f, 0f, 0f);
    var h: f32 = 0f;
    var dz: f32 = 0f;
    var prevDz: f32;
    var prevColor: vec4<f32>;
    var prevH: f32;
    var stop: bool = false;
    var sum: f32 = 0f;
    var weight: f32 = 1f;
    var dw: f32;

    pos_1 = pos;
    outPos_1 = outPos;
    intensity_3 = intensity_2;
    dampening_1 = dampening;
    model3DTransform_1 = model3DTransform;
    sourceDim_1 = sourceDim;
    let _e24 = dampening_1;
    normalizedDampening = (_e24 * 100f);
    let _e28 = model3DTransform_1;
    m = _naga_inverse_4x4_f32(_e28);
    let _e31 = m;
    cameraPos = (_e31 * vec4<f32>(0f, 0f, 0f, 1f)).xyz;
    let _e40 = pos_1;
    let _e42 = pos_1;
    dir = normalize(vec3<f32>(_e40.x, _e42.y, -1f));
    let _e49 = m;
    let _e59 = dir;
    dir = (mat3x3<f32>(_e49[0].xyz, _e49[1].xyz, _e49[2].xyz) * _e59);
    let _e61 = intensity_3;
    maxZ = (abs(_e61) * 0.02f);
    let _e66 = sourceDim_1;
    let _e68 = sourceDim_1;
    ratio = (_e66.x / _e68.y);
    let _e73 = sourceDim_1;
    dk = (2f / _e73.y);
    let _e77 = dir;
    let _e78 = dk;
    step = (_e77 * _e78);
    let _e85 = dir;
    if (_e85.x > 0f) {
        {
            let _e89 = ratio;
            let _e91 = cameraPos;
            let _e94 = dir;
            k3_ = ((-(_e89) - _e91.x) / _e94.x);
            let _e98 = ratio;
            let _e99 = cameraPos;
            let _e102 = dir;
            k4_ = ((_e98 - _e99.x) / _e102.x);
            let _e106 = k1_;
            let _e107 = k3_;
            k1_ = max(_e106, _e107);
            let _e109 = k2_;
            let _e110 = k4_;
            k2_ = min(_e109, _e110);
        }
    } else {
        let _e112 = dir;
        if (_e112.x < 0f) {
            {
                let _e116 = ratio;
                let _e117 = cameraPos;
                let _e120 = dir;
                k3_1 = ((_e116 - _e117.x) / _e120.x);
                let _e124 = ratio;
                let _e126 = cameraPos;
                let _e129 = dir;
                k4_1 = ((-(_e124) - _e126.x) / _e129.x);
                let _e133 = k1_;
                let _e134 = k3_1;
                k1_ = max(_e133, _e134);
                let _e136 = k2_;
                let _e137 = k4_1;
                k2_ = min(_e136, _e137);
            }
        }
    }
    let _e139 = dir;
    if (_e139.y > 0f) {
        {
            let _e145 = cameraPos;
            let _e148 = dir;
            k3_2 = ((-1f - _e145.y) / _e148.y);
            let _e153 = cameraPos;
            let _e156 = dir;
            k4_2 = ((1f - _e153.y) / _e156.y);
            let _e160 = k1_;
            let _e161 = k3_2;
            k1_ = max(_e160, _e161);
            let _e163 = k2_;
            let _e164 = k4_2;
            k2_ = min(_e163, _e164);
        }
    } else {
        let _e166 = dir;
        if (_e166.y < 0f) {
            {
                let _e171 = cameraPos;
                let _e174 = dir;
                k3_3 = ((1f - _e171.y) / _e174.y);
                let _e180 = cameraPos;
                let _e183 = dir;
                k4_3 = ((-1f - _e180.y) / _e183.y);
                let _e187 = k1_;
                let _e188 = k3_3;
                k1_ = max(_e187, _e188);
                let _e190 = k2_;
                let _e191 = k4_3;
                k2_ = min(_e190, _e191);
            }
        }
    }
    let _e193 = dir;
    if (_e193.z > 0f) {
        {
            let _e197 = maxZ;
            let _e199 = cameraPos;
            let _e202 = dir;
            k3_4 = ((-(_e197) - _e199.z) / _e202.z);
            let _e206 = maxZ;
            let _e207 = cameraPos;
            let _e210 = dir;
            k4_4 = ((_e206 - _e207.z) / _e210.z);
            let _e214 = k1_;
            let _e215 = k3_4;
            k1_ = max(_e214, _e215);
            let _e217 = k2_;
            let _e218 = k4_4;
            k2_ = min(_e217, _e218);
        }
    } else {
        let _e220 = dir;
        if (_e220.z < 0f) {
            {
                let _e224 = maxZ;
                let _e225 = cameraPos;
                let _e228 = dir;
                k3_5 = ((_e224 - _e225.z) / _e228.z);
                let _e232 = maxZ;
                let _e234 = cameraPos;
                let _e237 = dir;
                k4_5 = ((-(_e232) - _e234.z) / _e237.z);
                let _e241 = k1_;
                let _e242 = k3_5;
                k1_ = max(_e241, _e242);
                let _e244 = k2_;
                let _e245 = k4_5;
                k2_ = min(_e244, _e245);
            }
        }
    }
    let _e247 = k1_;
    let _e248 = k2_;
    if (_e247 > _e248) {
        let _e250 = backgroundColor;
        return _e250;
    }
    let _e251 = k1_;
    k = _e251;
    let _e253 = cameraPos;
    let _e254 = k;
    let _e255 = dir;
    p = (_e253 + (_e254 * _e255));
    let _e259 = backgroundColor;
    color_2 = _e259;
    let _e278 = normalizedDampening;
    if (_e278 == 0f) {
        {
            loop {
                {
                    let _e281 = color_2;
                    prevColor = _e281;
                    let _e282 = dz;
                    prevDz = _e282;
                    let _e283 = h;
                    prevH = _e283;
                    let _e284 = p;
                    let _e289 = global.U[0];
                    let _e292 = p;
                    let _e303 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e284.x / _e289.x), _e292.y) / vec2(2f)) + vec2(0.5f)), 0f);
                    color_2 = _e303;
                    let _e304 = sumColor;
                    let _e305 = color_2;
                    sumColor = (_e304 + _e305);
                    let _e307 = sum;
                    sum = (_e307 + 1f);
                    let _e310 = intensity_3;
                    let _e311 = color_2;
                    let _e312 = height(_e310, _e311);
                    h = _e312;
                    let _e313 = p;
                    let _e315 = h;
                    dz = (_e313.z - _e315);
                    let _e317 = p;
                    let _e318 = step;
                    p = (_e317 + _e318);
                    let _e320 = k;
                    let _e321 = dk;
                    k = (_e320 + _e321);
                    let _e323 = stop;
                    let _e324 = dz;
                    let _e327 = k;
                    let _e328 = k1_;
                    let _e330 = dz;
                    let _e332 = prevDz;
                    stop = (_e323 || ((_e324 == 0f) || ((_e327 != _e328) && (sign(_e330) == -(sign(_e332))))));
                }
                let _e339 = k;
                let _e340 = k2_;
                if !((_e339 <= _e340)) {
                    break;
                }
            }
        }
    } else {
        {
            let _e346 = normalizedDampening;
            let _e351 = sourceDim_1;
            let _e353 = sourceDim_1;
            dw = pow((1.001f - (_e346 * 0.01f)), (10f / max(_e351.x, _e353.y)));
            loop {
                {
                    let _e359 = color_2;
                    prevColor = _e359;
                    let _e360 = dz;
                    prevDz = _e360;
                    let _e361 = h;
                    prevH = _e361;
                    let _e362 = p;
                    let _e367 = global.U[0];
                    let _e370 = p;
                    let _e381 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e362.x / _e367.x), _e370.y) / vec2(2f)) + vec2(0.5f)), 0f);
                    color_2 = _e381;
                    let _e382 = sumColor;
                    let _e383 = weight;
                    let _e384 = color_2;
                    sumColor = (_e382 + (_e383 * _e384));
                    let _e387 = sum;
                    let _e388 = weight;
                    sum = (_e387 + _e388);
                    let _e390 = weight;
                    let _e391 = dw;
                    weight = (_e390 * _e391);
                    let _e393 = intensity_3;
                    let _e394 = color_2;
                    let _e395 = height(_e393, _e394);
                    h = _e395;
                    let _e396 = p;
                    let _e398 = h;
                    dz = (_e396.z - _e398);
                    let _e400 = p;
                    let _e401 = step;
                    p = (_e400 + _e401);
                    let _e403 = k;
                    let _e404 = dk;
                    k = (_e403 + _e404);
                    let _e406 = stop;
                    let _e407 = dz;
                    let _e410 = k;
                    let _e411 = k1_;
                    let _e413 = dz;
                    let _e415 = prevDz;
                    stop = (_e406 || ((_e407 == 0f) || ((_e410 != _e411) && (sign(_e413) == -(sign(_e415))))));
                }
                let _e422 = k;
                let _e423 = k2_;
                if !((_e422 <= _e423)) {
                    break;
                }
            }
        }
    }
    let _e426 = stop;
    let _e427 = dz;
    let _e429 = dk;
    stop = (_e426 || (abs(_e427) < _e429));
    let _e432 = sumColor;
    let _e433 = sum;
    return (_e432 / vec4(_e433));
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
    let _e77 = global.U[9];
    let _e80 = global.U[10];
    let _e83 = global.U[11];
    let _e107 = global.U[4];
    let _e109 = transparentCube((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e9.x, _e9.y, _e9.z), vec3<f32>(_e13.x, _e13.y, _e13.z), vec3<f32>(_e17.x, _e17.y, _e17.z))) * vec3<f32>(_e44.x, _e44.y, 1f)).xy, (((_e51 - vec2(0.5f)) * 2f) * vec2<f32>(_e59.x, 1f)), _e66.x, _e70.x, mat4x4<f32>(vec4<f32>(_e74.x, _e74.y, _e74.z, _e74.w), vec4<f32>(_e77.x, _e77.y, _e77.z, _e77.w), vec4<f32>(_e80.x, _e80.y, _e80.z, _e80.w), vec4<f32>(_e83.x, _e83.y, _e83.z, _e83.w)), _e107.xy);
    fragColor = _e109;
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
