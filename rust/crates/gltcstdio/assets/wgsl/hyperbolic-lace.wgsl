struct Params {
    U: array<vec4<f32>, 33>,
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

fn chooseColor(found: bool, count: i32, orb: f32, color1_: vec4<f32>, color2_: vec4<f32>, color3_: vec4<f32>, glow: f32, iterations: i32) -> vec4<f32> {
    var found_1: bool;
    var count_1: i32;
    var orb_1: f32;
    var color1_1: vec4<f32>;
    var color2_1: vec4<f32>;
    var color3_1: vec4<f32>;
    var glow_1: f32;
    var iterations_1: i32;
    var col: vec4<f32>;
    var local: vec4<f32>;
    var t: f32;

    found_1 = found;
    count_1 = count;
    orb_1 = orb;
    color1_1 = color1_;
    color2_1 = color2_;
    color3_1 = color3_;
    glow_1 = glow;
    iterations_1 = iterations;
    let _e23 = found_1;
    if _e23 {
        {
            let _e24 = count_1;
            if (_e24 >= 300i) {
                let _e27 = color3_1;
                col = _e27;
            } else {
                let _e28 = count_1;
                if ((_e28 % 2i) == 0i) {
                    let _e33 = color1_1;
                    local = _e33;
                } else {
                    let _e34 = color2_1;
                    local = _e34;
                }
                let _e36 = local;
                col = _e36;
            }
        }
    } else {
        let _e37 = color3_1;
        col = _e37;
    }
    let _e39 = count_1;
    let _e47 = iterations_1;
    t = (((4f * f32(_e39)) / 4f) / f32(_e47));
    let _e51 = col;
    let _e53 = color3_1;
    let _e55 = glow_1;
    let _e57 = col;
    let _e60 = t;
    let _e63 = orb_1;
    let _e71 = mix((_e53.xyz * _e55), _e57.xyz, vec3((1f - (_e60 * smoothstep(0f, 1f, (log(_e63) / 32f))))));
    col.x = _e71.x;
    col.y = _e71.y;
    col.z = _e71.z;
    let _e78 = col;
    return _e78;
}

fn dihedral(x: f32) -> f32 {
    var x_1: f32;
    var local_1: f32;

    x_1 = x;
    let _e8 = x_1;
    if (_e8 == -1f) {
        local_1 = 1f;
    } else {
        let _e14 = x_1;
        local_1 = cos((3.1415927f / _e14));
    }
    let _e18 = local_1;
    return _e18;
}

fn distABCD(p: vec3<f32>, A: vec3<f32>, B: vec3<f32>, C: vec4<f32>, D: vec3<f32>) -> f32 {
    var p_1: vec3<f32>;
    var A_1: vec3<f32>;
    var B_1: vec3<f32>;
    var C_1: vec4<f32>;
    var D_1: vec3<f32>;
    var dA: f32;
    var dB: f32;
    var dD: f32;
    var dC: f32;

    p_1 = p;
    A_1 = A;
    B_1 = B;
    C_1 = C;
    D_1 = D;
    let _e16 = p_1;
    let _e17 = A_1;
    dA = abs(dot(_e16, _e17));
    let _e21 = p_1;
    let _e22 = B_1;
    dB = abs(dot(_e21, _e22));
    let _e26 = p_1;
    let _e27 = D_1;
    dD = abs(dot(_e26, _e27));
    let _e31 = p_1;
    let _e32 = C_1;
    let _e36 = C_1;
    dC = abs((length((_e31 - _e32.xyz)) - _e36.w));
    let _e41 = dA;
    let _e42 = dB;
    let _e43 = dC;
    let _e44 = dD;
    return min(_e41, min(_e42, min(_e43, _e44)));
}

fn sdPlane(p_2: vec3<f32>, offset: f32) -> f32 {
    var p_3: vec3<f32>;
    var offset_1: f32;

    p_3 = p_2;
    offset_1 = offset;
    let _e10 = p_3;
    let _e12 = offset_1;
    return -((_e10.y - _e12));
}

fn sdSphere(p_4: vec3<f32>, radius: f32) -> f32 {
    var p_5: vec3<f32>;
    var radius_1: f32;

    p_5 = p_4;
    radius_1 = radius;
    let _e10 = p_5;
    let _e12 = radius_1;
    return (length(_e10) - _e12);
}

fn sdf(p_6: vec3<f32>, modelControl: f32) -> vec2<f32> {
    var p_7: vec3<f32>;
    var modelControl_1: f32;
    var d1_: f32;
    var d2_: f32;
    var local_2: f32;
    var id: f32;

    p_7 = p_6;
    modelControl_1 = modelControl;
    let _e10 = p_7;
    let _e12 = sdSphere(_e10, 1f);
    d1_ = _e12;
    let _e14 = p_7;
    let _e16 = sdPlane(_e14, 1f);
    d2_ = _e16;
    let _e18 = d1_;
    let _e19 = d2_;
    if (_e18 < _e19) {
        local_2 = 0f;
    } else {
        local_2 = 1f;
    }
    let _e24 = local_2;
    id = _e24;
    let _e26 = d1_;
    let _e27 = d2_;
    let _e29 = id;
    return vec2<f32>(min(_e26, _e27), _e29);
}

fn calcOcclusion(p_8: vec3<f32>, n: vec3<f32>, modelControl_2: f32) -> f32 {
    var p_9: vec3<f32>;
    var n_1: vec3<f32>;
    var modelControl_3: f32;
    var occ: f32 = 0f;
    var sca: f32 = 1f;
    var i: i32 = 0i;
    var h: f32;
    var d: f32;

    p_9 = p_8;
    n_1 = n;
    modelControl_3 = modelControl_2;
    loop {
        let _e18 = i;
        if !((_e18 < 5i)) {
            break;
        }
        {
            let _e27 = i;
            h = (0.01f + ((0.15f * f32(_e27)) / 4f));
            let _e34 = p_9;
            let _e35 = h;
            let _e36 = n_1;
            let _e39 = modelControl_3;
            let _e40 = sdf((_e34 + (_e35 * _e36)), _e39);
            d = _e40.x;
            let _e43 = occ;
            let _e44 = h;
            let _e45 = d;
            let _e47 = sca;
            occ = (_e43 + ((_e44 - _e45) * _e47));
            let _e50 = sca;
            sca = (_e50 * 0.75f);
        }
        continuing {
            let _e22 = i;
            i = (_e22 + 1i);
        }
    }
    let _e54 = occ;
    return clamp((1f - _e54), 0f, 1f);
}

fn softShadow(ro: vec3<f32>, rd: vec3<f32>, tmin: f32, tmax: f32, k: f32, modelControl_4: f32) -> f32 {
    var ro_1: vec3<f32>;
    var rd_1: vec3<f32>;
    var tmin_1: f32;
    var tmax_1: f32;
    var k_1: f32;
    var modelControl_5: f32;
    var res: f32 = 1f;
    var t_1: f32;
    var i_1: i32 = 0i;
    var h_1: f32;

    ro_1 = ro;
    rd_1 = rd;
    tmin_1 = tmin;
    tmax_1 = tmax;
    k_1 = k;
    modelControl_5 = modelControl_4;
    let _e20 = tmin_1;
    t_1 = _e20;
    loop {
        let _e24 = i_1;
        if !((_e24 < 12i)) {
            break;
        }
        {
            let _e31 = ro_1;
            let _e32 = rd_1;
            let _e33 = t_1;
            let _e36 = modelControl_5;
            let _e37 = sdf((_e31 + (_e32 * _e33)), _e36);
            h_1 = _e37.x;
            let _e40 = res;
            let _e41 = k_1;
            let _e42 = h_1;
            let _e44 = t_1;
            res = min(_e40, ((_e41 * _e42) / _e44));
            let _e47 = t_1;
            let _e48 = h_1;
            t_1 = (_e47 + clamp(_e48, 0.01f, 0.2f));
            let _e53 = h_1;
            let _e56 = t_1;
            let _e57 = tmax_1;
            if ((_e53 < 0.0001f) || (_e56 > _e57)) {
                break;
            }
        }
        continuing {
            let _e28 = i_1;
            i_1 = (_e28 + 1i);
        }
    }
    let _e60 = res;
    return clamp(_e60, 0f, 1f);
}

fn getColor(ro_2: vec3<f32>, rd_2: vec3<f32>, pos: vec3<f32>, nor: vec3<f32>, lp: vec3<f32>, basecol: vec4<f32>, colorSpecular: vec4<f32>, modelControl_6: f32) -> vec4<f32> {
    var ro_3: vec3<f32>;
    var rd_3: vec3<f32>;
    var pos_1: vec3<f32>;
    var nor_1: vec3<f32>;
    var lp_1: vec3<f32>;
    var basecol_1: vec4<f32>;
    var colorSpecular_1: vec4<f32>;
    var modelControl_7: f32;
    var col_1: vec4<f32>;
    var ld: vec3<f32>;
    var lDist: f32;
    var ao: f32;
    var sh: f32;
    var diff: f32;
    var atten: f32;
    var spec: f32;
    var fres: f32;

    ro_3 = ro_2;
    rd_3 = rd_2;
    pos_1 = pos;
    nor_1 = nor;
    lp_1 = lp;
    basecol_1 = basecol;
    colorSpecular_1 = colorSpecular;
    modelControl_7 = modelControl_6;
    let _e25 = basecol_1;
    col_1 = vec4<f32>(0f, 0f, 0f, _e25.w);
    let _e29 = lp_1;
    let _e30 = pos_1;
    ld = (_e29 - _e30);
    let _e33 = ld;
    lDist = max(length(_e33), 0.001f);
    let _e38 = ld;
    let _e39 = lDist;
    ld = (_e38 / vec3(_e39));
    let _e42 = pos_1;
    let _e43 = nor_1;
    let _e44 = modelControl_7;
    let _e45 = calcOcclusion(_e42, _e43, _e44);
    ao = _e45;
    let _e47 = pos_1;
    let _e49 = nor_1;
    let _e52 = ld;
    let _e54 = lDist;
    let _e56 = modelControl_7;
    let _e57 = softShadow((_e47 + (0.001f * _e49)), _e52, 0.02f, _e54, 32f, _e56);
    sh = _e57;
    let _e59 = nor_1;
    let _e60 = ld;
    diff = clamp(dot(_e59, _e60), 0f, 1f);
    let _e68 = lDist;
    let _e69 = lDist;
    atten = (2f / (1f + ((_e68 * _e69) * 0.01f)));
    let _e76 = ld;
    let _e78 = nor_1;
    let _e80 = rd_3;
    spec = pow(max(dot(reflect(-(_e76), _e78), -(_e80)), 0f), 32f);
    let _e89 = rd_3;
    let _e90 = nor_1;
    fres = clamp((1f + dot(_e89, _e90)), 0f, 1f);
    let _e97 = col_1;
    let _e99 = col_1;
    let _e101 = basecol_1;
    let _e103 = diff;
    let _e105 = (_e99.xyz + (_e101.xyz * _e103));
    col_1.x = _e105.x;
    col_1.y = _e105.y;
    col_1.z = _e105.z;
    let _e112 = col_1;
    let _e114 = col_1;
    let _e116 = basecol_1;
    let _e118 = colorSpecular_1;
    let _e121 = colorSpecular_1;
    let _e124 = spec;
    let _e128 = (_e114.xyz + ((((_e116.xyz * _e118.xyz) * _e121.w) * _e124) * 4f));
    col_1.x = _e128.x;
    col_1.y = _e128.y;
    col_1.z = _e128.z;
    let _e135 = col_1;
    let _e137 = col_1;
    let _e139 = basecol_1;
    let _e144 = fres;
    let _e146 = fres;
    let _e150 = (_e137.xyz + ((((_e139.xyz * vec3(0.8f)) * _e144) * _e146) * 2f));
    col_1.x = _e150.x;
    col_1.y = _e150.y;
    col_1.z = _e150.z;
    let _e157 = col_1;
    let _e159 = col_1;
    let _e161 = ao;
    let _e162 = atten;
    let _e164 = sh;
    let _e166 = (_e159.xyz * ((_e161 * _e162) * _e164));
    col_1.x = _e166.x;
    col_1.y = _e166.y;
    col_1.z = _e166.z;
    let _e173 = col_1;
    let _e175 = col_1;
    let _e177 = basecol_1;
    let _e181 = nor_1;
    let _e191 = (_e175.xyz + ((_e177.xyz * clamp((0.8f + (0.2f * _e181.y)), 0f, 1f)) * 0.5f));
    col_1.x = _e191.x;
    col_1.y = _e191.y;
    col_1.z = _e191.z;
    let _e198 = col_1;
    return _e198;
}

fn try_reflect(p_10: ptr<function, vec3<f32>>, n_2: vec3<f32>, count_2: ptr<function, i32>) -> bool {
    var n_3: vec3<f32>;
    var k_2: f32;

    n_3 = n_2;
    let _e10 = (*p_10);
    let _e11 = n_3;
    k_2 = dot(_e10, _e11);
    let _e14 = k_2;
    if (_e14 >= 0f) {
        return true;
    }
    let _e18 = (*p_10);
    let _e20 = k_2;
    let _e22 = n_3;
    (*p_10) = (_e18 - ((2f * _e20) * _e22));
    let _e25 = (*count_2);
    (*count_2) = (_e25 + 1i);
    return false;
}

fn try_reflect_1(p_11: ptr<function, vec3<f32>>, sphere: vec4<f32>, count_3: ptr<function, i32>, orb_2: ptr<function, f32>) -> bool {
    var sphere_1: vec4<f32>;
    var cen: vec3<f32>;
    var r: f32;
    var q: vec3<f32>;
    var d2_1: f32;
    var k_3: f32;

    sphere_1 = sphere;
    let _e11 = sphere_1;
    cen = _e11.xyz;
    let _e14 = sphere_1;
    r = _e14.w;
    let _e17 = (*p_11);
    let _e18 = cen;
    q = (_e17 - _e18);
    let _e21 = q;
    let _e22 = q;
    d2_1 = dot(_e21, _e22);
    let _e25 = d2_1;
    if (_e25 == 0f) {
        return true;
    }
    let _e29 = r;
    let _e30 = r;
    let _e32 = d2_1;
    k_3 = ((_e29 * _e30) / _e32);
    let _e35 = k_3;
    if (_e35 < 1f) {
        return true;
    }
    let _e39 = k_3;
    let _e40 = q;
    let _e42 = cen;
    (*p_11) = ((_e39 * _e40) + _e42);
    let _e44 = (*count_3);
    (*count_3) = (_e44 + 1i);
    let _e47 = (*orb_2);
    let _e48 = k_3;
    (*orb_2) = (_e47 * _e48);
    return false;
}

fn iterateSpherePoint(p_12: ptr<function, vec3<f32>>, count_4: ptr<function, i32>, A_2: vec3<f32>, B_2: vec3<f32>, C_2: vec4<f32>, D_2: vec3<f32>, orb_3: ptr<function, f32>, iterations_2: i32) -> bool {
    var A_3: vec3<f32>;
    var B_3: vec3<f32>;
    var C_3: vec4<f32>;
    var D_3: vec3<f32>;
    var iterations_3: i32;
    var inA: bool;
    var inB: bool;
    var inC: bool;
    var inD: bool;
    var iter: i32 = 0i;

    A_3 = A_2;
    B_3 = B_2;
    C_3 = C_2;
    D_3 = D_2;
    iterations_3 = iterations_2;
    loop {
        let _e25 = iter;
        let _e26 = iterations_3;
        if !((_e25 < _e26)) {
            break;
        }
        {
            let _e33 = A_3;
            let _e37 = try_reflect(p_12, _e33, count_4);
            inA = _e37;
            let _e39 = B_3;
            let _e43 = try_reflect(p_12, _e39, count_4);
            inB = _e43;
            let _e45 = C_3;
            let _e51 = try_reflect_1(p_12, _e45, count_4, orb_3);
            inC = _e51;
            let _e53 = D_3;
            let _e57 = try_reflect(p_12, _e53, count_4);
            inD = _e57;
            let _e58 = (*p_12);
            (*p_12) = normalize(_e58);
            let _e60 = inA;
            let _e61 = inB;
            let _e63 = inC;
            let _e65 = inD;
            if (((_e60 && _e61) && _e63) && _e65) {
                return true;
            }
        }
        continuing {
            let _e29 = iter;
            iter = (_e29 + 1i);
        }
    }
    return false;
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

fn planeToSphere(p_13: vec2<f32>) -> vec3<f32> {
    var p_14: vec2<f32>;
    var pp: f32;
    var q_1: vec3<f32>;

    p_14 = p_13;
    let _e8 = p_14;
    let _e9 = p_14;
    pp = dot(_e8, _e9);
    let _e13 = p_14;
    let _e14 = (2f * _e13);
    let _e15 = pp;
    let _e23 = pp;
    q_1 = (vec3<f32>(_e14.x, _e14.y, (_e15 - 1f)).xzy / vec3((1f + _e23)));
    let _e28 = q_1;
    let _e30 = q_1;
    let _e33 = q_1;
    return vec3<f32>(_e28.x, -(_e30.y), _e33.z);
}

fn raymarch(ro_4: vec3<f32>, rd_4: vec3<f32>, modelControl_8: f32) -> vec2<f32> {
    var ro_5: vec3<f32>;
    var rd_5: vec3<f32>;
    var modelControl_9: f32;
    var t_2: f32 = 0.1f;
    var h_2: vec2<f32>;
    var i_2: i32 = 0i;

    ro_5 = ro_4;
    rd_5 = rd_4;
    modelControl_9 = modelControl_8;
    loop {
        let _e17 = i_2;
        if !((_e17 < 100i)) {
            break;
        }
        {
            let _e24 = ro_5;
            let _e25 = t_2;
            let _e26 = rd_5;
            let _e29 = modelControl_9;
            let _e30 = sdf((_e24 + (_e25 * _e26)), _e29);
            h_2 = _e30;
            let _e31 = h_2;
            let _e34 = t_2;
            if (_e31.x < (0.0001f * _e34)) {
                let _e37 = t_2;
                let _e38 = h_2;
                return vec2<f32>(_e37, _e38.y);
            }
            let _e41 = t_2;
            if (_e41 > 100f) {
                break;
            }
            let _e44 = t_2;
            let _e45 = h_2;
            t_2 = (_e44 + _e45.x);
        }
        continuing {
            let _e21 = i_2;
            i_2 = (_e21 + 1i);
        }
    }
    return vec2(-1f);
}

fn rot2d(p_15: vec2<f32>, a: f32) -> vec2<f32> {
    var p_16: vec2<f32>;
    var a_1: f32;

    p_16 = p_15;
    a_1 = a;
    let _e10 = p_16;
    let _e11 = a_1;
    let _e14 = p_16;
    let _e17 = p_16;
    let _e20 = a_1;
    return ((_e10 * cos(_e11)) + (vec2<f32>(-(_e14.y), _e17.x) * sin(_e20)));
}

fn sphMat(theta: f32, phi: f32) -> mat3x3<f32> {
    var theta_1: f32;
    var phi_1: f32;
    var cx: f32;
    var cy: f32;
    var sx: f32;
    var sy: f32;

    theta_1 = theta;
    phi_1 = phi;
    let _e10 = theta_1;
    cx = cos(_e10);
    let _e13 = phi_1;
    cy = cos(_e13);
    let _e16 = theta_1;
    sx = sin(_e16);
    let _e19 = phi_1;
    sy = sin(_e19);
    let _e22 = cy;
    let _e23 = sy;
    let _e25 = sx;
    let _e28 = sy;
    let _e30 = cx;
    let _e33 = cx;
    let _e34 = sx;
    let _e35 = sy;
    let _e36 = cy;
    let _e37 = sx;
    let _e40 = cy;
    let _e41 = cx;
    return mat3x3<f32>(vec3<f32>(_e22, (-(_e23) * -(_e25)), (-(_e28) * _e30)), vec3<f32>(0f, _e33, _e34), vec3<f32>(_e35, (_e36 * -(_e37)), (_e40 * _e41)));
}

fn sphereToPlane(p_17: vec3<f32>, c: vec3<f32>) -> vec2<f32> {
    var p_18: vec3<f32>;
    var c_1: vec3<f32>;
    var delta: vec3<f32>;
    var dy: f32;

    p_18 = p_17;
    c_1 = c;
    let _e10 = p_18;
    let _e11 = c_1;
    delta = normalize((_e10 - _e11));
    let _e15 = delta;
    dy = (_e15.y + 1f);
    let _e20 = dy;
    if (_e20 == 0f) {
        return vec2(0f);
    }
    let _e26 = delta;
    let _e29 = dy;
    let _e32 = c_1;
    return (((1f * _e26.xz) / vec2(_e29)) + _e32.xz);
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

fn hyperbolicGroupLimit(uv: vec2<f32>, outPos: vec2<f32>, iterations_4: i32, color1_2: vec4<f32>, color2_2: vec4<f32>, color3_2: vec4<f32>, glow_2: f32, paramP: i32, paramQ: i32, paramR: i32, offset_2: f32, border: f32, borderColor: vec4<f32>, colorSpecular_2: vec4<f32>, modelControl_10: f32, mode: i32, modelTransform: mat3x3<f32>, texTransform: mat3x3<f32>, model3DTransform: mat4x4<f32>, lightSourceTransform: mat4x4<f32>) -> vec4<f32> {
    var uv_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var iterations_5: i32;
    var color1_3: vec4<f32>;
    var color2_3: vec4<f32>;
    var color3_3: vec4<f32>;
    var glow_3: f32;
    var paramP_1: i32;
    var paramQ_1: i32;
    var paramR_1: i32;
    var offset_3: f32;
    var border_1: f32;
    var borderColor_1: vec4<f32>;
    var colorSpecular_3: vec4<f32>;
    var modelControl_11: f32;
    var mode_1: i32;
    var modelTransform_1: mat3x3<f32>;
    var texTransform_1: mat3x3<f32>;
    var model3DTransform_1: mat4x4<f32>;
    var lightSourceTransform_1: mat4x4<f32>;
    var finalcol: vec4<f32> = vec4(0f);
    var count_5: i32 = 0i;
    var m_2: vec2<f32>;
    var rx: f32;
    var ry: f32;
    var mouRot: mat3x3<f32>;
    var P: f32;
    var Q: f32;
    var R: f32;
    var cp: f32;
    var sp: f32;
    var cq: f32;
    var cr: f32;
    var A_4: vec3<f32> = vec3<f32>(0f, 0f, 1f);
    var B_4: vec3<f32>;
    var D_4: vec3<f32> = vec3<f32>(1f, 0f, 0f);
    var r_1: f32;
    var k_4: f32;
    var cen_1: vec3<f32>;
    var C_4: vec4<f32>;
    var local_3: f32;
    var glowFactor: f32;
    var lp_2: vec3<f32>;
    var focalD: f32 = 1f;
    var cameraPos: vec3<f32> = vec3<f32>(0f, 0f, 0f);
    var inverseModel3DTransform: mat4x4<f32>;
    var dir: vec3<f32>;
    var camera: vec3<f32>;
    var rd_6: vec3<f32>;
    var orb_4: f32 = 1f;
    var res_1: vec2<f32>;
    var t_3: f32;
    var id_1: f32;
    var pos_2: vec3<f32>;
    var found_2: bool;
    var edist: f32;
    var col_2: vec4<f32>;
    var nor_2: vec3<f32>;
    var hPos: vec3<f32>;
    var q_2: vec3<f32>;
    var basecol_2: vec4<f32>;
    var texUV: vec2<f32>;
    var nor_3: vec3<f32> = vec3<f32>(0f, 1f, 0f);
    var q_3: vec3<f32>;
    var basecol_3: vec4<f32>;
    var texUV_1: vec2<f32>;

    uv_1 = uv;
    outPos_1 = outPos;
    iterations_5 = iterations_4;
    color1_3 = color1_2;
    color2_3 = color2_2;
    color3_3 = color3_2;
    glow_3 = glow_2;
    paramP_1 = paramP;
    paramQ_1 = paramQ;
    paramR_1 = paramR;
    offset_3 = offset_2;
    border_1 = border;
    borderColor_1 = borderColor;
    colorSpecular_3 = colorSpecular_2;
    modelControl_11 = modelControl_10;
    mode_1 = mode;
    modelTransform_1 = modelTransform;
    texTransform_1 = texTransform;
    model3DTransform_1 = model3DTransform;
    lightSourceTransform_1 = lightSourceTransform;
    let _e51 = modelTransform_1;
    let _e55 = tf(_naga_inverse_3x3_f32(_e51), vec2(0f));
    m_2 = _e55;
    let _e57 = m_2;
    rx = (_e57.y * 3.1415927f);
    let _e62 = m_2;
    ry = ((-(_e62.x) * 2f) * 3.1415927f);
    let _e70 = rx;
    let _e71 = ry;
    let _e72 = sphMat(_e70, _e71);
    mouRot = _e72;
    let _e74 = paramP_1;
    P = f32(_e74);
    let _e77 = paramQ_1;
    Q = f32(_e77);
    let _e80 = paramR_1;
    R = f32(_e80);
    let _e83 = P;
    let _e84 = dihedral(_e83);
    cp = _e84;
    let _e87 = cp;
    let _e88 = cp;
    sp = sqrt((1f - (_e87 * _e88)));
    let _e93 = Q;
    let _e94 = dihedral(_e93);
    cq = _e94;
    let _e96 = R;
    let _e97 = dihedral(_e96);
    cr = _e97;
    let _e108 = sp;
    let _e109 = cp;
    B_4 = vec3<f32>(0f, _e108, -(_e109));
    let _e123 = cr;
    r_1 = (1f / _e123);
    let _e126 = r_1;
    let _e127 = cq;
    let _e129 = sp;
    k_4 = ((_e126 * _e127) / _e129);
    let _e133 = k_4;
    cen_1 = vec3<f32>(1f, _e133, 0f);
    let _e139 = cen_1;
    let _e140 = r_1;
    let _e145 = cen_1;
    let _e146 = cen_1;
    let _e148 = r_1;
    let _e149 = r_1;
    C_4 = (vec4<f32>(_e139.x, _e139.y, _e139.z, _e140) / vec4(sqrt((dot(_e145, _e146) - (_e148 * _e149)))));
    let _e156 = glow_3;
    if (_e156 < 0.01f) {
        let _e159 = glow_3;
        local_3 = (_e159 * 100f);
    } else {
        let _e163 = glow_3;
        local_3 = pow(1000f, _e163);
    }
    let _e166 = local_3;
    glowFactor = _e166;
    let _e168 = lightSourceTransform_1;
    lp_2 = (_e168 * vec4<f32>(0f, 0f, 0f, 1f)).xyz;
    let _e184 = model3DTransform_1;
    inverseModel3DTransform = _naga_inverse_4x4_f32(_e184);
    let _e187 = inverseModel3DTransform;
    let _e188 = cameraPos;
    cameraPos = (_e187 * vec4<f32>(_e188.x, _e188.y, _e188.z, 1f)).xyz;
    let _e196 = uv_1;
    let _e198 = focalD;
    let _e200 = uv_1;
    let _e202 = focalD;
    dir = vec3<f32>((_e196.x * _e198), (_e200.y * _e202), -1f);
    let _e208 = inverseModel3DTransform;
    let _e218 = dir;
    dir = normalize((mat3x3<f32>(_e208[0].xyz, _e208[1].xyz, _e208[2].xyz) * _e218));
    let _e221 = cameraPos;
    camera = _e221;
    let _e223 = dir;
    rd_6 = _e223;
    let _e227 = camera;
    let _e228 = rd_6;
    let _e229 = modelControl_11;
    let _e230 = raymarch(_e227, _e228, _e229);
    res_1 = _e230;
    let _e232 = res_1;
    t_3 = _e232.x;
    let _e235 = res_1;
    id_1 = _e235.y;
    let _e238 = camera;
    let _e239 = t_3;
    let _e240 = rd_6;
    pos_2 = (_e238 + (_e239 * _e240));
    let _e247 = id_1;
    if (_e247 == 0f) {
        {
            let _e250 = pos_2;
            nor_2 = _e250;
            let _e252 = pos_2;
            let _e254 = pos_2;
            let _e256 = pos_2;
            hPos = vec3<f32>(_e252.x, _e254.y, _e256.z);
            let _e260 = hPos;
            let _e261 = mouRot;
            q_2 = (_e260 * _e261);
            let _e266 = A_4;
            let _e267 = B_4;
            let _e268 = C_4;
            let _e269 = D_4;
            let _e271 = iterations_5;
            let _e275 = iterateSpherePoint((&q_2), (&count_5), _e266, _e267, _e268, _e269, (&orb_4), _e271);
            found_2 = _e275;
            let _e276 = q_2;
            let _e277 = A_4;
            let _e278 = B_4;
            let _e279 = C_4;
            let _e280 = D_4;
            let _e281 = distABCD(_e276, _e277, _e278, _e279, _e280);
            edist = _e281;
            let _e282 = found_2;
            let _e283 = count_5;
            let _e284 = orb_4;
            let _e285 = color1_3;
            let _e286 = color2_3;
            let _e287 = color3_3;
            let _e288 = glowFactor;
            let _e289 = iterations_5;
            let _e290 = chooseColor(_e282, _e283, _e284, _e285, _e286, _e287, _e288, _e289);
            basecol_2 = _e290;
            let _e292 = q_2;
            texUV = _e292.xy;
            let _e295 = offset_3;
            if (_e295 != 0f) {
                {
                    let _e298 = texUV;
                    let _e299 = offset_3;
                    let _e300 = pos_2;
                    let _e305 = sphereToPlane(_e300, vec3<f32>(0f, 0f, 0f));
                    texUV = (_e298 + (_e299 * _e305));
                }
            }
            let _e308 = texTransform_1;
            let _e310 = texUV;
            let _e311 = tf(_naga_inverse_3x3_f32(_e308), _e310);
            let _e315 = global.U[0];
            let _e318 = texTransform_1;
            let _e320 = texUV;
            let _e321 = tf(_naga_inverse_3x3_f32(_e318), _e320);
            let _e330 = textureSample(t_source, samp, ((vec2<f32>((_e311.x / _e315.x), _e321.y) / vec2(2f)) + vec2(0.5f)));
            let _e331 = basecol_2;
            let _e332 = mergeColor(_e330, _e331);
            basecol_2 = _e332;
            let _e333 = camera;
            let _e334 = rd_6;
            let _e335 = pos_2;
            let _e336 = nor_2;
            let _e337 = lp_2;
            let _e338 = basecol_2;
            let _e339 = colorSpecular_3;
            let _e340 = modelControl_11;
            let _e341 = getColor(_e333, _e334, _e335, _e336, _e337, _e338, _e339, _e340);
            col_2 = _e341;
        }
    } else {
        let _e342 = id_1;
        if (_e342 == 1f) {
            {
                let _e350 = pos_2;
                let _e352 = planeToSphere(_e350.xz);
                q_3 = _e352;
                let _e354 = q_3;
                let _e355 = mouRot;
                q_3 = (_e354 * _e355);
                let _e359 = A_4;
                let _e360 = B_4;
                let _e361 = C_4;
                let _e362 = D_4;
                let _e364 = iterations_5;
                let _e368 = iterateSpherePoint((&q_3), (&count_5), _e359, _e360, _e361, _e362, (&orb_4), _e364);
                found_2 = _e368;
                let _e369 = q_3;
                let _e370 = A_4;
                let _e371 = B_4;
                let _e372 = C_4;
                let _e373 = D_4;
                let _e374 = distABCD(_e369, _e370, _e371, _e372, _e373);
                edist = _e374;
                let _e375 = found_2;
                let _e376 = count_5;
                let _e377 = orb_4;
                let _e378 = color1_3;
                let _e379 = color2_3;
                let _e380 = color3_3;
                let _e381 = glowFactor;
                let _e382 = iterations_5;
                let _e383 = chooseColor(_e375, _e376, _e377, _e378, _e379, _e380, _e381, _e382);
                basecol_3 = _e383;
                let _e385 = q_3;
                texUV_1 = _e385.xy;
                let _e388 = offset_3;
                if (_e388 != 0f) {
                    let _e391 = texUV_1;
                    let _e392 = offset_3;
                    let _e393 = pos_2;
                    texUV_1 = (_e391 + (_e392 * _e393.xz));
                }
                let _e397 = texTransform_1;
                let _e399 = texUV_1;
                let _e400 = tf(_naga_inverse_3x3_f32(_e397), _e399);
                let _e404 = global.U[0];
                let _e407 = texTransform_1;
                let _e409 = texUV_1;
                let _e410 = tf(_naga_inverse_3x3_f32(_e407), _e409);
                let _e419 = textureSample(t_source, samp, ((vec2<f32>((_e400.x / _e404.x), _e410.y) / vec2(2f)) + vec2(0.5f)));
                let _e420 = basecol_3;
                let _e421 = mergeColor(_e419, _e420);
                basecol_3 = _e421;
                let _e422 = camera;
                let _e423 = rd_6;
                let _e424 = pos_2;
                let _e425 = nor_3;
                let _e426 = lp_2;
                let _e427 = basecol_3;
                let _e428 = colorSpecular_3;
                let _e429 = modelControl_11;
                let _e430 = getColor(_e422, _e423, _e424, _e425, _e426, _e427, _e428, _e429);
                col_2 = _e430;
                let _e431 = col_2;
                let _e433 = col_2;
                let _e436 = (_e433.xyz * 0.9f);
                col_2.x = _e436.x;
                col_2.y = _e436.y;
                col_2.z = _e436.z;
            }
        } else {
            col_2 = vec4<f32>(0f, 0f, 0f, 1f);
        }
    }
    let _e448 = border_1;
    if (_e448 != 0f) {
        let _e451 = col_2;
        let _e452 = borderColor_1;
        let _e455 = border_1;
        let _e460 = border_1;
        let _e462 = edist;
        col_2 = mix(_e451, _e452, vec4(((1f - smoothstep(((0.05f * _e455) - 0.0025f), (0.1f * _e460), _e462)) * 0.85f)));
    }
    let _e469 = col_2;
    let _e471 = col_2;
    let _e478 = t_3;
    let _e480 = t_3;
    let _e485 = mix(_e471.xyz, vec3(0f), vec3((1f - exp(((-0.01f * _e478) * _e480)))));
    col_2.x = _e485.x;
    col_2.y = _e485.y;
    col_2.z = _e485.z;
    let _e492 = finalcol;
    let _e493 = col_2;
    finalcol = (_e492 + _e493);
    let _e495 = finalcol;
    let _e497 = finalcol;
    let _e500 = finalcol;
    let _e508 = mix(_e497.xyz, (vec3(1f) - exp(-(_e500.xyz))), vec3(0.35f));
    finalcol.x = _e508.x;
    finalcol.y = _e508.y;
    finalcol.z = _e508.z;
    let _e515 = finalcol;
    let _e520 = sqrt(max(_e515.xyz, vec3(0f)));
    let _e521 = finalcol;
    return vec4<f32>(_e520.x, _e520.y, _e520.z, _e521.w);
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
    let _e71 = global.U[6];
    let _e74 = global.U[7];
    let _e77 = global.U[8];
    let _e80 = global.U[9];
    let _e84 = global.U[10];
    let _e89 = global.U[11];
    let _e94 = global.U[12];
    let _e99 = global.U[13];
    let _e103 = global.U[14];
    let _e107 = global.U[15];
    let _e110 = global.U[16];
    let _e113 = global.U[17];
    let _e117 = global.U[18];
    let _e122 = global.U[19];
    let _e123 = _e122.xyz;
    let _e126 = global.U[20];
    let _e127 = _e126.xyz;
    let _e130 = global.U[21];
    let _e131 = _e130.xyz;
    let _e147 = global.U[22];
    let _e148 = _e147.xyz;
    let _e151 = global.U[23];
    let _e152 = _e151.xyz;
    let _e155 = global.U[24];
    let _e156 = _e155.xyz;
    let _e172 = global.U[25];
    let _e175 = global.U[26];
    let _e178 = global.U[27];
    let _e181 = global.U[28];
    let _e205 = global.U[29];
    let _e208 = global.U[30];
    let _e211 = global.U[31];
    let _e214 = global.U[32];
    let _e236 = hyperbolicGroupLimit((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e9.x, _e9.y, _e9.z), vec3<f32>(_e13.x, _e13.y, _e13.z), vec3<f32>(_e17.x, _e17.y, _e17.z))) * vec3<f32>(_e44.x, _e44.y, 1f)).xy, (((_e51 - vec2(0.5f)) * 2f) * vec2<f32>(_e59.x, 1f)), i32(_e66.x), _e71, _e74, _e77, _e80.x, i32(_e84.x), i32(_e89.x), i32(_e94.x), _e99.x, _e103.x, _e107, _e110, _e113.x, i32(_e117.x), mat3x3<f32>(vec3<f32>(_e123.x, _e123.y, _e123.z), vec3<f32>(_e127.x, _e127.y, _e127.z), vec3<f32>(_e131.x, _e131.y, _e131.z)), mat3x3<f32>(vec3<f32>(_e148.x, _e148.y, _e148.z), vec3<f32>(_e152.x, _e152.y, _e152.z), vec3<f32>(_e156.x, _e156.y, _e156.z)), mat4x4<f32>(vec4<f32>(_e172.x, _e172.y, _e172.z, _e172.w), vec4<f32>(_e175.x, _e175.y, _e175.z, _e175.w), vec4<f32>(_e178.x, _e178.y, _e178.z, _e178.w), vec4<f32>(_e181.x, _e181.y, _e181.z, _e181.w)), mat4x4<f32>(vec4<f32>(_e205.x, _e205.y, _e205.z, _e205.w), vec4<f32>(_e208.x, _e208.y, _e208.z, _e208.w), vec4<f32>(_e211.x, _e211.y, _e211.z, _e211.w), vec4<f32>(_e214.x, _e214.y, _e214.z, _e214.w)));
    fragColor = _e236;
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
