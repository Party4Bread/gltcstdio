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

fn _mirror_wrap(c: vec2<f32>) -> vec2<f32> {
    var c_1: vec2<f32>;

    c_1 = c;
    let _e9 = c_1;
    let _e11 = vec2(2f);
    return (vec2(1f) - abs(((_e9 - (floor((_e9 / _e11)) * _e11)) - vec2(1f))));
}

fn projEquirectangular(dir: vec3<f32>) -> vec2<f32> {
    var dir_1: vec3<f32>;
    var u: vec3<f32>;
    var lambda: f32;
    var phi: f32;

    dir_1 = dir;
    let _e8 = dir_1;
    u = normalize(_e8);
    let _e11 = u;
    let _e13 = u;
    lambda = atan2(_e11.z, _e13.x);
    let _e17 = u;
    phi = asin(_e17.y);
    let _e21 = lambda;
    let _e22 = phi;
    return vec2<f32>(_e21, _e22);
}

fn sphereGlobeGl(pos: vec2<f32>, outPos: vec2<f32>, sourceDim: vec2<f32>, model3DTransform: mat4x4<f32>, intensity: f32, balance: f32) -> vec4<f32> {
    var pos_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var sourceDim_1: vec2<f32>;
    var model3DTransform_1: mat4x4<f32>;
    var intensity_1: f32;
    var balance_1: f32;
    var inv: mat4x4<f32>;
    var cameraPos: vec3<f32>;
    var dir_2: vec3<f32>;
    var a: f32;
    var b: f32;
    var c_2: f32;
    var delta: f32;
    var l: f32 = -1f;
    var sqrtDelta: f32;
    var l1_: f32;
    var l2_: f32;
    var local: f32;
    var local_1: f32;
    var result: vec4<f32>;
    var intersection: vec3<f32>;
    var normal: vec3<f32>;
    var eta: f32;
    var incidence: f32;
    var refractedDir: vec3<f32>;
    var reflectedDir: vec3<f32>;
    var reflectedColor: vec4<f32>;
    var _n: vec3<f32>;
    var _ll: vec2<f32>;
    var _nX: f32 = 2f;
    var _nY: f32 = 1f;
    var _u: vec2<f32>;
    var _xa: f32;
    var local_2: f32;
    var _x: f32;
    var _y: f32;
    var _ratio: f32;
    var refractedColor: vec4<f32>;
    var _n_1: vec3<f32>;
    var _ll_1: vec2<f32>;
    var _nX_1: f32 = 2f;
    var _nY_1: f32 = 1f;
    var _u_1: vec2<f32>;
    var _xa_1: f32;
    var local_3: f32;
    var _x_1: f32;
    var _y_1: f32;
    var _ratio_1: f32;
    var bkg: vec4<f32>;
    var _n_2: vec3<f32>;
    var _ll_2: vec2<f32>;
    var _nX_2: f32 = 2f;
    var _nY_2: f32 = 1f;
    var _u_2: vec2<f32>;
    var _xa_2: f32;
    var local_4: f32;
    var _x_2: f32;
    var _y_2: f32;
    var _ratio_2: f32;

    pos_1 = pos;
    outPos_1 = outPos;
    sourceDim_1 = sourceDim;
    model3DTransform_1 = model3DTransform;
    intensity_1 = intensity;
    balance_1 = balance;
    let _e18 = model3DTransform_1;
    inv = _naga_inverse_4x4_f32(_e18);
    let _e21 = inv;
    cameraPos = (_e21 * vec4<f32>(0f, 0f, 0f, 1f)).xyz;
    let _e30 = pos_1;
    let _e32 = pos_1;
    dir_2 = normalize(vec3<f32>(_e30.x, _e32.y, -1f));
    let _e41 = inv[0];
    let _e42 = _e41.xyz;
    let _e45 = inv[1];
    let _e46 = _e45.xyz;
    let _e49 = inv[2];
    let _e50 = _e49.xyz;
    let _e64 = dir_2;
    dir_2 = (mat3x3<f32>(vec3<f32>(_e42.x, _e42.y, _e42.z), vec3<f32>(_e46.x, _e46.y, _e46.z), vec3<f32>(_e50.x, _e50.y, _e50.z)) * _e64);
    let _e66 = dir_2;
    let _e67 = dir_2;
    a = dot(_e66, _e67);
    let _e71 = dir_2;
    let _e72 = cameraPos;
    b = (2f * dot(_e71, _e72));
    let _e76 = cameraPos;
    let _e77 = cameraPos;
    c_2 = (dot(_e76, _e77) - 0.25f);
    let _e82 = b;
    let _e83 = b;
    let _e86 = a;
    let _e88 = c_2;
    delta = ((_e82 * _e83) - ((4f * _e86) * _e88));
    let _e95 = delta;
    if (_e95 >= 0f) {
        {
            let _e98 = delta;
            sqrtDelta = sqrt(_e98);
            let _e101 = b;
            let _e103 = sqrtDelta;
            let _e106 = a;
            l1_ = ((-(_e101) - _e103) / (2f * _e106));
            let _e110 = b;
            let _e112 = sqrtDelta;
            let _e115 = a;
            l2_ = ((-(_e110) + _e112) / (2f * _e115));
            let _e119 = l1_;
            if (_e119 > 0f) {
                let _e122 = l1_;
                local_1 = _e122;
            } else {
                let _e123 = l2_;
                if (_e123 > 0f) {
                    let _e126 = l2_;
                    local = _e126;
                } else {
                    local = -1f;
                }
                let _e130 = local;
                local_1 = _e130;
            }
            let _e132 = local_1;
            l = _e132;
        }
    }
    let _e134 = l;
    if (_e134 > 0f) {
        {
            let _e137 = cameraPos;
            let _e138 = l;
            let _e139 = dir_2;
            intersection = (_e137 + (_e138 * _e139));
            let _e143 = intersection;
            normal = normalize(_e143);
            let _e146 = intensity_1;
            eta = _e146;
            let _e148 = normal;
            let _e149 = dir_2;
            incidence = abs(dot(_e148, _e149));
            let _e153 = dir_2;
            let _e154 = normal;
            let _e155 = eta;
            refractedDir = refract(_e153, _e154, _e155);
            let _e158 = dir_2;
            let _e159 = normal;
            reflectedDir = reflect(_e158, _e159);
            {
                let _e163 = reflectedDir;
                _n = normalize(_e163);
                let _e166 = _n;
                let _e167 = projEquirectangular(_e166);
                _ll = _e167;
                let _e173 = _ll;
                let _e180 = _nX;
                let _e183 = _ll;
                let _e185 = _nY;
                _u = vec2<f32>((((-(_e173.x) / 3.1415927f) * 0.5f) * _e180), (0.5f + ((_e183.y * _e185) / 3.1415927f)));
                let _e192 = _u;
                _xa = abs(_e192.x);
                let _e196 = _xa;
                let _e198 = _xa;
                _xa = (_e196 - (2f * floor((_e198 * 0.5f))));
                let _e204 = _xa;
                if (_e204 > 1f) {
                    let _e208 = _xa;
                    local_2 = (2f - _e208);
                } else {
                    let _e210 = _xa;
                    local_2 = _e210;
                }
                let _e212 = local_2;
                _x = _e212;
                let _e214 = _u;
                _y = clamp(_e214.y, 0f, 1f);
                let _e220 = sourceDim_1;
                let _e222 = sourceDim_1;
                _ratio = (_e220.x / _e222.y);
                let _e226 = _x;
                let _e231 = _ratio;
                let _e233 = _y;
                let _e242 = global.U[0];
                let _e245 = _x;
                let _e250 = _ratio;
                let _e252 = _y;
                let _e266 = _mirror_wrap(((vec2<f32>((vec2<f32>((((_e226 - 0.5f) * 2f) * _e231), ((_e233 - 0.5f) * 2f)).x / _e242.x), vec2<f32>((((_e245 - 0.5f) * 2f) * _e250), ((_e252 - 0.5f) * 2f)).y) / vec2(2f)) + vec2(0.5f)));
                let _e268 = textureSampleLevel(t_source, samp, _e266, 0f);
                reflectedColor = _e268;
            }
            {
                let _e270 = refractedDir;
                _n_1 = normalize(_e270);
                let _e273 = _n_1;
                let _e274 = projEquirectangular(_e273);
                _ll_1 = _e274;
                let _e280 = _ll_1;
                let _e287 = _nX_1;
                let _e290 = _ll_1;
                let _e292 = _nY_1;
                _u_1 = vec2<f32>((((-(_e280.x) / 3.1415927f) * 0.5f) * _e287), (0.5f + ((_e290.y * _e292) / 3.1415927f)));
                let _e299 = _u_1;
                _xa_1 = abs(_e299.x);
                let _e303 = _xa_1;
                let _e305 = _xa_1;
                _xa_1 = (_e303 - (2f * floor((_e305 * 0.5f))));
                let _e311 = _xa_1;
                if (_e311 > 1f) {
                    let _e315 = _xa_1;
                    local_3 = (2f - _e315);
                } else {
                    let _e317 = _xa_1;
                    local_3 = _e317;
                }
                let _e319 = local_3;
                _x_1 = _e319;
                let _e321 = _u_1;
                _y_1 = clamp(_e321.y, 0f, 1f);
                let _e327 = sourceDim_1;
                let _e329 = sourceDim_1;
                _ratio_1 = (_e327.x / _e329.y);
                let _e333 = _x_1;
                let _e338 = _ratio_1;
                let _e340 = _y_1;
                let _e349 = global.U[0];
                let _e352 = _x_1;
                let _e357 = _ratio_1;
                let _e359 = _y_1;
                let _e373 = _mirror_wrap(((vec2<f32>((vec2<f32>((((_e333 - 0.5f) * 2f) * _e338), ((_e340 - 0.5f) * 2f)).x / _e349.x), vec2<f32>((((_e352 - 0.5f) * 2f) * _e357), ((_e359 - 0.5f) * 2f)).y) / vec2(2f)) + vec2(0.5f)));
                let _e375 = textureSampleLevel(t_source, samp, _e373, 0f);
                refractedColor = _e375;
            }
            let _e376 = reflectedColor;
            let _e377 = refractedColor;
            let _e378 = incidence;
            let _e379 = balance_1;
            result = mix(_e376, _e377, vec4(clamp((_e378 + _e379), 0f, 1f)));
        }
    } else {
        {
            {
                let _e387 = dir_2;
                _n_2 = normalize(_e387);
                let _e390 = _n_2;
                let _e391 = projEquirectangular(_e390);
                _ll_2 = _e391;
                let _e397 = _ll_2;
                let _e404 = _nX_2;
                let _e407 = _ll_2;
                let _e409 = _nY_2;
                _u_2 = vec2<f32>((((-(_e397.x) / 3.1415927f) * 0.5f) * _e404), (0.5f + ((_e407.y * _e409) / 3.1415927f)));
                let _e416 = _u_2;
                _xa_2 = abs(_e416.x);
                let _e420 = _xa_2;
                let _e422 = _xa_2;
                _xa_2 = (_e420 - (2f * floor((_e422 * 0.5f))));
                let _e428 = _xa_2;
                if (_e428 > 1f) {
                    let _e432 = _xa_2;
                    local_4 = (2f - _e432);
                } else {
                    let _e434 = _xa_2;
                    local_4 = _e434;
                }
                let _e436 = local_4;
                _x_2 = _e436;
                let _e438 = _u_2;
                _y_2 = clamp(_e438.y, 0f, 1f);
                let _e444 = sourceDim_1;
                let _e446 = sourceDim_1;
                _ratio_2 = (_e444.x / _e446.y);
                let _e450 = _x_2;
                let _e455 = _ratio_2;
                let _e457 = _y_2;
                let _e466 = global.U[0];
                let _e469 = _x_2;
                let _e474 = _ratio_2;
                let _e476 = _y_2;
                let _e490 = _mirror_wrap(((vec2<f32>((vec2<f32>((((_e450 - 0.5f) * 2f) * _e455), ((_e457 - 0.5f) * 2f)).x / _e466.x), vec2<f32>((((_e469 - 0.5f) * 2f) * _e474), ((_e476 - 0.5f) * 2f)).y) / vec2(2f)) + vec2(0.5f)));
                let _e492 = textureSampleLevel(t_source, samp, _e490, 0f);
                bkg = _e492;
            }
            let _e493 = bkg;
            result = _e493;
        }
    }
    let _e494 = result;
    return _e494;
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
    let _e66 = global.U[4];
    let _e70 = global.U[6];
    let _e73 = global.U[7];
    let _e76 = global.U[8];
    let _e79 = global.U[9];
    let _e103 = global.U[10];
    let _e107 = global.U[11];
    let _e109 = sphereGlobeGl((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e9.x, _e9.y, _e9.z), vec3<f32>(_e13.x, _e13.y, _e13.z), vec3<f32>(_e17.x, _e17.y, _e17.z))) * vec3<f32>(_e44.x, _e44.y, 1f)).xy, (((_e51 - vec2(0.5f)) * 2f) * vec2<f32>(_e59.x, 1f)), _e66.xy, mat4x4<f32>(vec4<f32>(_e70.x, _e70.y, _e70.z, _e70.w), vec4<f32>(_e73.x, _e73.y, _e73.z, _e73.w), vec4<f32>(_e76.x, _e76.y, _e76.z, _e76.w), vec4<f32>(_e79.x, _e79.y, _e79.z, _e79.w)), _e103.x, _e107.x);
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
