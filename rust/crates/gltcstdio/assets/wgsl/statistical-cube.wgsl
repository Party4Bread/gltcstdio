struct Params {
    U: array<vec4<f32>, 11>,
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

fn statisticalCube(pos: vec2<f32>, outPos: vec2<f32>, intensity_2: f32, model3DTransform: mat4x4<f32>, sourceDim: vec2<f32>) -> vec4<f32> {
    var pos_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var intensity_3: f32;
    var model3DTransform_1: mat4x4<f32>;
    var sourceDim_1: vec2<f32>;
    var backgroundColor: vec4<f32> = vec4<f32>(0f, 0f, 0f, 1f);
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
    var h: f32 = 0f;
    var dz: f32 = 0f;
    var prevDz: f32;
    var prevColor: vec4<f32>;
    var prevH: f32;
    var stop: bool;
    var local: f32;

    pos_1 = pos;
    outPos_1 = outPos;
    intensity_3 = intensity_2;
    model3DTransform_1 = model3DTransform;
    sourceDim_1 = sourceDim;
    let _e22 = model3DTransform_1;
    m = _naga_inverse_4x4_f32(_e22);
    let _e25 = m;
    cameraPos = (_e25 * vec4<f32>(0f, 0f, 0f, 1f)).xyz;
    let _e34 = pos_1;
    let _e36 = pos_1;
    dir = normalize(vec3<f32>(_e34.x, _e36.y, -1f));
    let _e43 = m;
    let _e53 = dir;
    dir = (mat3x3<f32>(_e43[0].xyz, _e43[1].xyz, _e43[2].xyz) * _e53);
    let _e55 = intensity_3;
    maxZ = (abs(_e55) * 0.02f);
    let _e60 = sourceDim_1;
    let _e62 = sourceDim_1;
    ratio = (_e60.x / _e62.y);
    let _e67 = sourceDim_1;
    dk = (2f / _e67.y);
    let _e71 = dir;
    let _e72 = dk;
    step = (_e71 * _e72);
    let _e79 = dir;
    if (_e79.x > 0f) {
        {
            let _e83 = ratio;
            let _e85 = cameraPos;
            let _e88 = dir;
            k3_ = ((-(_e83) - _e85.x) / _e88.x);
            let _e92 = ratio;
            let _e93 = cameraPos;
            let _e96 = dir;
            k4_ = ((_e92 - _e93.x) / _e96.x);
            let _e100 = k1_;
            let _e101 = k3_;
            k1_ = max(_e100, _e101);
            let _e103 = k2_;
            let _e104 = k4_;
            k2_ = min(_e103, _e104);
        }
    } else {
        let _e106 = dir;
        if (_e106.x < 0f) {
            {
                let _e110 = ratio;
                let _e111 = cameraPos;
                let _e114 = dir;
                k3_1 = ((_e110 - _e111.x) / _e114.x);
                let _e118 = ratio;
                let _e120 = cameraPos;
                let _e123 = dir;
                k4_1 = ((-(_e118) - _e120.x) / _e123.x);
                let _e127 = k1_;
                let _e128 = k3_1;
                k1_ = max(_e127, _e128);
                let _e130 = k2_;
                let _e131 = k4_1;
                k2_ = min(_e130, _e131);
            }
        }
    }
    let _e133 = dir;
    if (_e133.y > 0f) {
        {
            let _e139 = cameraPos;
            let _e142 = dir;
            k3_2 = ((-1f - _e139.y) / _e142.y);
            let _e147 = cameraPos;
            let _e150 = dir;
            k4_2 = ((1f - _e147.y) / _e150.y);
            let _e154 = k1_;
            let _e155 = k3_2;
            k1_ = max(_e154, _e155);
            let _e157 = k2_;
            let _e158 = k4_2;
            k2_ = min(_e157, _e158);
        }
    } else {
        let _e160 = dir;
        if (_e160.y < 0f) {
            {
                let _e165 = cameraPos;
                let _e168 = dir;
                k3_3 = ((1f - _e165.y) / _e168.y);
                let _e174 = cameraPos;
                let _e177 = dir;
                k4_3 = ((-1f - _e174.y) / _e177.y);
                let _e181 = k1_;
                let _e182 = k3_3;
                k1_ = max(_e181, _e182);
                let _e184 = k2_;
                let _e185 = k4_3;
                k2_ = min(_e184, _e185);
            }
        }
    }
    let _e187 = dir;
    if (_e187.z > 0f) {
        {
            let _e191 = maxZ;
            let _e193 = cameraPos;
            let _e196 = dir;
            k3_4 = ((-(_e191) - _e193.z) / _e196.z);
            let _e200 = maxZ;
            let _e201 = cameraPos;
            let _e204 = dir;
            k4_4 = ((_e200 - _e201.z) / _e204.z);
            let _e208 = k1_;
            let _e209 = k3_4;
            k1_ = max(_e208, _e209);
            let _e211 = k2_;
            let _e212 = k4_4;
            k2_ = min(_e211, _e212);
        }
    } else {
        let _e214 = dir;
        if (_e214.z < 0f) {
            {
                let _e218 = maxZ;
                let _e219 = cameraPos;
                let _e222 = dir;
                k3_5 = ((_e218 - _e219.z) / _e222.z);
                let _e226 = maxZ;
                let _e228 = cameraPos;
                let _e231 = dir;
                k4_5 = ((-(_e226) - _e228.z) / _e231.z);
                let _e235 = k1_;
                let _e236 = k3_5;
                k1_ = max(_e235, _e236);
                let _e238 = k2_;
                let _e239 = k4_5;
                k2_ = min(_e238, _e239);
            }
        }
    }
    let _e241 = k1_;
    let _e242 = k2_;
    if (_e241 > _e242) {
        let _e244 = backgroundColor;
        return _e244;
    }
    let _e245 = k1_;
    k = _e245;
    let _e247 = cameraPos;
    let _e248 = k;
    let _e249 = dir;
    p = (_e247 + (_e248 * _e249));
    let _e253 = backgroundColor;
    color_2 = _e253;
    loop {
        {
            let _e263 = color_2;
            prevColor = _e263;
            let _e264 = dz;
            prevDz = _e264;
            let _e265 = h;
            prevH = _e265;
            let _e266 = p;
            let _e271 = global.U[0];
            let _e274 = p;
            let _e284 = textureSample(t_source, samp, ((vec2<f32>((_e266.x / _e271.x), _e274.y) / vec2(2f)) + vec2(0.5f)));
            color_2 = _e284;
            let _e285 = intensity_3;
            let _e286 = color_2;
            let _e287 = height(_e285, _e286);
            h = _e287;
            let _e288 = p;
            let _e290 = h;
            dz = (_e288.z - _e290);
            let _e292 = p;
            let _e293 = step;
            p = (_e292 + _e293);
            let _e295 = k;
            let _e296 = dk;
            k = (_e295 + _e296);
            let _e298 = dz;
            let _e301 = k;
            let _e302 = k1_;
            let _e304 = dz;
            let _e306 = prevDz;
            stop = ((_e298 == 0f) || ((_e301 != _e302) && (sign(_e304) == -(sign(_e306)))));
        }
        let _e312 = k;
        let _e313 = k2_;
        let _e315 = stop;
        if !(((_e312 <= _e313) && !(_e315))) {
            break;
        }
    }
    let _e319 = stop;
    let _e320 = dz;
    let _e322 = dk;
    stop = (_e319 || (abs(_e320) < _e322));
    let _e325 = k2_;
    let _e326 = k1_;
    let _e328 = stop;
    if _e328 {
        local = 1f;
    } else {
        local = 0f;
    }
    let _e332 = local;
    let _e333 = k;
    let _e334 = k1_;
    let _e336 = k2_;
    let _e337 = k1_;
    return vec4<f32>((_e325 - _e326), _e332, ((_e333 - _e334) / (_e336 - _e337)), 1f);
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
    let _e73 = global.U[8];
    let _e76 = global.U[9];
    let _e79 = global.U[10];
    let _e103 = global.U[4];
    let _e105 = statisticalCube((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e9.x, _e9.y, _e9.z), vec3<f32>(_e13.x, _e13.y, _e13.z), vec3<f32>(_e17.x, _e17.y, _e17.z))) * vec3<f32>(_e44.x, _e44.y, 1f)).xy, (((_e51 - vec2(0.5f)) * 2f) * vec2<f32>(_e59.x, 1f)), _e66.x, mat4x4<f32>(vec4<f32>(_e70.x, _e70.y, _e70.z, _e70.w), vec4<f32>(_e73.x, _e73.y, _e73.z, _e73.w), vec4<f32>(_e76.x, _e76.y, _e76.z, _e76.w), vec4<f32>(_e79.x, _e79.y, _e79.z, _e79.w)), _e103.xy);
    fragColor = _e105;
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
