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

fn sdDisk(u: vec2<f32>, r: f32) -> f32 {
    var u_1: vec2<f32>;
    var r_1: f32;

    u_1 = u;
    r_1 = r;
    let _e10 = u_1;
    let _e12 = r_1;
    return (length(_e10) - _e12);
}

fn sdSegment(u_2: vec2<f32>, a: vec2<f32>, b: vec2<f32>) -> f32 {
    var u_3: vec2<f32>;
    var a_1: vec2<f32>;
    var b_1: vec2<f32>;
    var ua: vec2<f32>;
    var ba: vec2<f32>;
    var h: f32;

    u_3 = u_2;
    a_1 = a;
    b_1 = b;
    let _e12 = u_3;
    let _e13 = a_1;
    ua = (_e12 - _e13);
    let _e16 = b_1;
    let _e17 = a_1;
    ba = (_e16 - _e17);
    let _e20 = ua;
    let _e21 = ba;
    let _e23 = ba;
    let _e24 = ba;
    h = clamp((dot(_e20, _e21) / dot(_e23, _e24)), 0f, 1f);
    let _e31 = ua;
    let _e32 = ba;
    let _e33 = h;
    return length((_e31 - (_e32 * _e33)));
}

fn vfTriangle(p: vec2<f32>, p0_: vec2<f32>, p1_: vec2<f32>, p2_: vec2<f32>) -> f32 {
    var p_1: vec2<f32>;
    var p0_1: vec2<f32>;
    var p1_1: vec2<f32>;
    var p2_1: vec2<f32>;
    var e0_: vec2<f32>;
    var e1_: vec2<f32>;
    var e2_: vec2<f32>;
    var v0_: vec2<f32>;
    var v1_: vec2<f32>;
    var v2_: vec2<f32>;
    var pq0_: vec2<f32>;
    var pq1_: vec2<f32>;
    var pq2_: vec2<f32>;
    var s: f32;
    var d: vec2<f32>;

    p_1 = p;
    p0_1 = p0_;
    p1_1 = p1_;
    p2_1 = p2_;
    let _e14 = p1_1;
    let _e15 = p0_1;
    e0_ = (_e14 - _e15);
    let _e18 = p2_1;
    let _e19 = p1_1;
    e1_ = (_e18 - _e19);
    let _e22 = p0_1;
    let _e23 = p2_1;
    e2_ = (_e22 - _e23);
    let _e26 = p_1;
    let _e27 = p0_1;
    v0_ = (_e26 - _e27);
    let _e30 = p_1;
    let _e31 = p1_1;
    v1_ = (_e30 - _e31);
    let _e34 = p_1;
    let _e35 = p2_1;
    v2_ = (_e34 - _e35);
    let _e38 = v0_;
    let _e39 = e0_;
    let _e40 = v0_;
    let _e41 = e0_;
    let _e43 = e0_;
    let _e44 = e0_;
    pq0_ = (_e38 - (_e39 * clamp((dot(_e40, _e41) / dot(_e43, _e44)), 0f, 1f)));
    let _e53 = v1_;
    let _e54 = e1_;
    let _e55 = v1_;
    let _e56 = e1_;
    let _e58 = e1_;
    let _e59 = e1_;
    pq1_ = (_e53 - (_e54 * clamp((dot(_e55, _e56) / dot(_e58, _e59)), 0f, 1f)));
    let _e68 = v2_;
    let _e69 = e2_;
    let _e70 = v2_;
    let _e71 = e2_;
    let _e73 = e2_;
    let _e74 = e2_;
    pq2_ = (_e68 - (_e69 * clamp((dot(_e70, _e71) / dot(_e73, _e74)), 0f, 1f)));
    let _e83 = e0_;
    let _e85 = e2_;
    let _e88 = e0_;
    let _e90 = e2_;
    s = sign(((_e83.x * _e85.y) - (_e88.y * _e90.x)));
    let _e96 = pq0_;
    let _e97 = pq0_;
    let _e99 = s;
    let _e100 = v0_;
    let _e102 = e0_;
    let _e105 = v0_;
    let _e107 = e0_;
    let _e113 = pq1_;
    let _e114 = pq1_;
    let _e116 = s;
    let _e117 = v1_;
    let _e119 = e1_;
    let _e122 = v1_;
    let _e124 = e1_;
    let _e131 = pq2_;
    let _e132 = pq2_;
    let _e134 = s;
    let _e135 = v2_;
    let _e137 = e2_;
    let _e140 = v2_;
    let _e142 = e2_;
    d = min(min(vec2<f32>(dot(_e96, _e97), (_e99 * ((_e100.x * _e102.y) - (_e105.y * _e107.x)))), vec2<f32>(dot(_e113, _e114), (_e116 * ((_e117.x * _e119.y) - (_e122.y * _e124.x))))), vec2<f32>(dot(_e131, _e132), (_e134 * ((_e135.x * _e137.y) - (_e140.y * _e142.x)))));
    let _e150 = d;
    let _e154 = d;
    return (-(sqrt(_e150.x)) * sign(_e154.y));
}

fn vfArrowFill(rel: vec2<f32>, od: vec2<f32>, ah: f32) -> f32 {
    var rel_1: vec2<f32>;
    var od_1: vec2<f32>;
    var ah_1: f32;
    var perp: vec2<f32>;
    var base: vec2<f32>;

    rel_1 = rel;
    od_1 = od;
    ah_1 = ah;
    let _e12 = od_1;
    let _e15 = od_1;
    perp = vec2<f32>(-(_e12.y), _e15.x);
    let _e19 = od_1;
    let _e21 = ah_1;
    base = (-(_e19) * _e21);
    let _e24 = rel_1;
    let _e27 = base;
    let _e28 = perp;
    let _e29 = ah_1;
    let _e34 = base;
    let _e35 = perp;
    let _e36 = ah_1;
    let _e41 = vfTriangle(_e24, vec2(0f), (_e27 + ((_e28 * _e29) * 0.42f)), (_e34 - ((_e35 * _e36) * 0.42f)));
    return _e41;
}

fn vectorField(uv: vec2<f32>, outPos: vec2<f32>, mode: i32, count: i32, size: f32, scaling: f32, color1_: vec4<f32>, thickness: f32, glow: f32, modelTransform: mat3x3<f32>, outDim: vec2<f32>) -> vec4<f32> {
    var uv_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var mode_1: i32;
    var count_1: i32;
    var size_1: f32;
    var scaling_1: f32;
    var color1_1: vec4<f32>;
    var thickness_1: f32;
    var glow_1: f32;
    var modelTransform_1: mat3x3<f32>;
    var outDim_1: vec2<f32>;
    var bkg_2: vec4<f32>;
    var pixel: f32;
    var im: mat3x3<f32>;
    var modelScale: f32;
    var g: vec2<f32>;
    var cs: f32;
    var cell: vec2<f32>;
    var gc: vec2<f32>;
    var rel_2: vec2<f32>;
    var wc: vec2<f32>;
    var eps: f32;
    var lw: vec3<f32> = vec3<f32>(0.299f, 0.587f, 0.114f);
    var gx: f32;
    var gy: f32;
    var grad: vec2<f32>;
    var mag: f32;
    var local: vec2<f32>;
    var dir: vec2<f32>;
    var magN: f32;
    var h_1: f32;
    var fade: f32;
    var aa: f32;
    var thinHalf: f32;
    var dThin: f32 = 1000000000f;
    var dFill: f32 = 1000000000f;
    var tip: vec2<f32>;
    var ah_2: f32;
    var local_1: f32;
    var covThin: f32;
    var covFill: f32;
    var cov: f32;
    var dmin: f32;
    var local_2: f32;
    var g2_: f32;
    var outc: vec4<f32>;

    uv_1 = uv;
    outPos_1 = outPos;
    mode_1 = mode;
    count_1 = count;
    size_1 = size;
    scaling_1 = scaling;
    color1_1 = color1_;
    thickness_1 = thickness;
    glow_1 = glow;
    modelTransform_1 = modelTransform;
    outDim_1 = outDim;
    let _e28 = uv_1;
    let _e32 = global.U[0];
    let _e35 = uv_1;
    let _e44 = textureSample(t_source, samp, ((vec2<f32>((_e28.x / _e32.x), _e35.y) / vec2(2f)) + vec2(0.5f)));
    bkg_2 = _e44;
    let _e47 = outDim_1;
    pixel = (2f / _e47.y);
    let _e51 = modelTransform_1;
    im = _naga_inverse_3x3_f32(_e51);
    let _e58 = modelTransform_1[0][0];
    let _e63 = modelTransform_1[0][1];
    modelScale = max(length(vec2<f32>(_e58, _e63)), 0.000001f);
    let _e69 = im;
    let _e70 = uv_1;
    g = (_e69 * vec3<f32>(_e70.x, _e70.y, 1f)).xy;
    let _e79 = count_1;
    cs = (2f / f32(max(_e79, 1i)));
    let _e85 = g;
    let _e86 = cs;
    cell = floor((_e85 / vec2(_e86)));
    let _e91 = cell;
    let _e95 = cs;
    gc = ((_e91 + vec2(0.5f)) * _e95);
    let _e98 = g;
    let _e99 = gc;
    rel_2 = (_e98 - _e99);
    let _e102 = modelTransform_1;
    let _e103 = gc;
    wc = (_e102 * vec3<f32>(_e103.x, _e103.y, 1f)).xy;
    let _e111 = cs;
    let _e114 = modelScale;
    eps = ((_e111 * 0.5f) * _e114);
    let _e122 = wc;
    let _e123 = eps;
    let _e130 = global.U[0];
    let _e133 = wc;
    let _e134 = eps;
    let _e146 = textureSample(t_source, samp, ((vec2<f32>(((_e122 + vec2<f32>(_e123, 0f)).x / _e130.x), (_e133 + vec2<f32>(_e134, 0f)).y) / vec2(2f)) + vec2(0.5f)));
    let _e148 = lw;
    let _e150 = wc;
    let _e151 = eps;
    let _e158 = global.U[0];
    let _e161 = wc;
    let _e162 = eps;
    let _e174 = textureSample(t_source, samp, ((vec2<f32>(((_e150 - vec2<f32>(_e151, 0f)).x / _e158.x), (_e161 - vec2<f32>(_e162, 0f)).y) / vec2(2f)) + vec2(0.5f)));
    let _e176 = lw;
    gx = (dot(_e146.xyz, _e148) - dot(_e174.xyz, _e176));
    let _e180 = wc;
    let _e182 = eps;
    let _e188 = global.U[0];
    let _e191 = wc;
    let _e193 = eps;
    let _e204 = textureSample(t_source, samp, ((vec2<f32>(((_e180 + vec2<f32>(0f, _e182)).x / _e188.x), (_e191 + vec2<f32>(0f, _e193)).y) / vec2(2f)) + vec2(0.5f)));
    let _e206 = lw;
    let _e208 = wc;
    let _e210 = eps;
    let _e216 = global.U[0];
    let _e219 = wc;
    let _e221 = eps;
    let _e232 = textureSample(t_source, samp, ((vec2<f32>(((_e208 - vec2<f32>(0f, _e210)).x / _e216.x), (_e219 - vec2<f32>(0f, _e221)).y) / vec2(2f)) + vec2(0.5f)));
    let _e234 = lw;
    gy = (dot(_e204.xyz, _e206) - dot(_e232.xyz, _e234));
    let _e238 = gx;
    let _e239 = gy;
    grad = vec2<f32>(_e238, _e239);
    let _e242 = grad;
    mag = length(_e242);
    let _e245 = mag;
    if (_e245 > 0.00001f) {
        let _e248 = grad;
        let _e249 = mag;
        local = (_e248 / vec2(_e249));
    } else {
        local = vec2<f32>(1f, 0f);
    }
    let _e256 = local;
    dir = _e256;
    let _e258 = mode_1;
    if (_e258 == 1i) {
        let _e261 = dir;
        let _e264 = dir;
        dir = vec2<f32>(-(_e261.y), _e264.x);
    }
    let _e267 = mag;
    magN = clamp((_e267 * 2.5f), 0f, 1f);
    let _e274 = cs;
    let _e277 = size_1;
    let _e280 = magN;
    let _e281 = scaling_1;
    h_1 = (((_e274 * 0.42f) * _e277) * mix(1f, _e280, _e281));
    let _e287 = mag;
    fade = smoothstep(0.015f, 0.06f, _e287);
    let _e290 = pixel;
    aa = (_e290 * 0.75f);
    let _e294 = thickness_1;
    thinHalf = (_e294 * 0.011f);
    let _e302 = fade;
    let _e305 = h_1;
    if ((_e302 > 0f) && (_e305 > 0.0001f)) {
        {
            let _e309 = dir;
            let _e310 = h_1;
            tip = (_e309 * _e310);
            let _e313 = mode_1;
            if (_e313 == 2i) {
                {
                    let _e316 = rel_2;
                    let _e317 = tip;
                    let _e319 = tip;
                    let _e320 = sdSegment(_e316, -(_e317), _e319);
                    let _e321 = modelScale;
                    dThin = (_e320 * _e321);
                    let _e323 = rel_2;
                    let _e324 = cs;
                    let _e327 = sdDisk(_e323, (_e324 * 0.07f));
                    let _e328 = modelScale;
                    dFill = (_e327 * _e328);
                }
            } else {
                {
                    let _e330 = cs;
                    let _e333 = size_1;
                    let _e335 = h_1;
                    ah_2 = min(((_e330 * 0.3f) * _e333), (_e335 * 0.9f));
                    let _e340 = rel_2;
                    let _e341 = tip;
                    let _e343 = tip;
                    let _e344 = dir;
                    let _e345 = ah_2;
                    let _e350 = sdSegment(_e340, -(_e341), (_e343 - ((_e344 * _e345) * 0.5f)));
                    let _e351 = modelScale;
                    dThin = (_e350 * _e351);
                    let _e353 = rel_2;
                    let _e354 = tip;
                    let _e356 = dir;
                    let _e357 = ah_2;
                    let _e358 = vfArrowFill((_e353 - _e354), _e356, _e357);
                    let _e359 = modelScale;
                    dFill = (_e358 * _e359);
                }
            }
        }
    }
    let _e361 = thinHalf;
    if (_e361 <= 0f) {
        local_1 = 0f;
    } else {
        let _e366 = thinHalf;
        let _e367 = aa;
        let _e369 = thinHalf;
        let _e370 = aa;
        let _e372 = dThin;
        local_1 = (1f - smoothstep((_e366 - _e367), (_e369 + _e370), _e372));
    }
    let _e376 = local_1;
    covThin = _e376;
    let _e379 = aa;
    let _e381 = aa;
    let _e382 = dFill;
    covFill = (1f - smoothstep(-(_e379), _e381, _e382));
    let _e386 = covThin;
    let _e387 = covFill;
    let _e389 = fade;
    cov = (max(_e386, _e387) * _e389);
    let _e392 = dThin;
    let _e393 = dFill;
    dmin = min(_e392, _e393);
    let _e396 = glow_1;
    if (_e396 > 0f) {
        let _e399 = glow_1;
        let _e400 = dmin;
        let _e401 = thinHalf;
        let _e411 = cov;
        let _e414 = fade;
        local_2 = (((_e399 * exp((-(max((_e400 - _e401), 0f)) * 8f))) * (1f - _e411)) * _e414);
    } else {
        local_2 = 0f;
    }
    let _e418 = local_2;
    g2_ = _e418;
    let _e420 = cov;
    let _e423 = g2_;
    if ((_e420 <= 0f) && (_e423 <= 0.002f)) {
        let _e427 = bkg_2;
        return _e427;
    }
    let _e428 = bkg_2;
    let _e429 = color1_1;
    let _e430 = _e429.xyz;
    let _e431 = color1_1;
    let _e433 = cov;
    let _e439 = mergeColor(_e428, vec4<f32>(_e430.x, _e430.y, _e430.z, (_e431.w * _e433)));
    outc = _e439;
    let _e441 = outc;
    let _e443 = outc;
    let _e445 = color1_1;
    let _e447 = g2_;
    let _e449 = (_e443.xyz + (_e445.xyz * _e447));
    outc.x = _e449.x;
    outc.y = _e449.y;
    outc.z = _e449.z;
    let _e457 = outc;
    let _e459 = g2_;
    outc.w = max(_e457.w, min(_e459, 1f));
    let _e463 = outc;
    return _e463;
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
    let _e76 = global.U[7];
    let _e80 = global.U[8];
    let _e84 = global.U[9];
    let _e87 = global.U[10];
    let _e91 = global.U[11];
    let _e95 = global.U[12];
    let _e96 = _e95.xyz;
    let _e99 = global.U[13];
    let _e100 = _e99.xyz;
    let _e103 = global.U[14];
    let _e104 = _e103.xyz;
    let _e120 = global.U[4];
    let _e122 = vectorField((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e9.x, _e9.y, _e9.z), vec3<f32>(_e13.x, _e13.y, _e13.z), vec3<f32>(_e17.x, _e17.y, _e17.z))) * vec3<f32>(_e44.x, _e44.y, 1f)).xy, (((_e51 - vec2(0.5f)) * 2f) * vec2<f32>(_e59.x, 1f)), i32(_e66.x), i32(_e71.x), _e76.x, _e80.x, _e84, _e87.x, _e91.x, mat3x3<f32>(vec3<f32>(_e96.x, _e96.y, _e96.z), vec3<f32>(_e100.x, _e100.y, _e100.z), vec3<f32>(_e104.x, _e104.y, _e104.z)), _e120.xy);
    fragColor = _e122;
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
