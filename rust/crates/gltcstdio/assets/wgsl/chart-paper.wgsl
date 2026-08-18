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

fn cpXform(sx: f32, sy: f32, rot: f32, tx: f32, ty: f32) -> mat3x3<f32> {
    var sx_1: f32;
    var sy_1: f32;
    var rot_1: f32;
    var tx_1: f32;
    var ty_1: f32;
    var c: f32;
    var s: f32;

    sx_1 = sx;
    sy_1 = sy;
    rot_1 = rot;
    tx_1 = tx;
    ty_1 = ty;
    let _e16 = rot_1;
    c = cos(_e16);
    let _e19 = rot_1;
    s = sin(_e19);
    let _e22 = sx_1;
    let _e23 = c;
    let _e25 = sx_1;
    let _e26 = s;
    let _e29 = vec3<f32>((_e22 * _e23), (_e25 * _e26), 0f);
    let _e30 = sy_1;
    let _e32 = s;
    let _e34 = sy_1;
    let _e35 = c;
    let _e38 = vec3<f32>((-(_e30) * _e32), (_e34 * _e35), 0f);
    let _e39 = tx_1;
    let _e40 = ty_1;
    let _e42 = vec3<f32>(_e39, _e40, 1f);
    return mat3x3<f32>(vec3<f32>(_e29.x, _e29.y, _e29.z), vec3<f32>(_e38.x, _e38.y, _e38.z), vec3<f32>(_e42.x, _e42.y, _e42.z));
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

fn hash22b(u: vec2<f32>) -> vec2<f32> {
    var u_1: vec2<f32>;

    u_1 = u;
    let _e8 = u_1;
    let _e18 = u_1;
    return vec2<f32>(fract((sin(dot(_e8.xy, vec2<f32>(13.7545f, 78.224f))) * 43758.547f)), fract((sin(dot(_e18.xy, vec2<f32>(15.7545f, 73.224f))) * 43758.547f)));
}

fn rndUnit(p: vec2<f32>) -> vec2<f32> {
    var p_1: vec2<f32>;
    var rnd: vec2<f32>;
    var len: f32;

    p_1 = p;
    let _e8 = p_1;
    let _e9 = hash22b(_e8);
    rnd = (_e9 - vec2(0.5f));
    let _e14 = rnd;
    len = length(_e14);
    let _e17 = len;
    if (_e17 == 0f) {
        return vec2<f32>(0f, 1f);
    } else {
        let _e23 = rnd;
        let _e24 = len;
        return (_e23 / vec2(_e24));
    }
}

fn dotGridGradient(g: vec2<f32>, u_2: vec2<f32>) -> f32 {
    var g_1: vec2<f32>;
    var u_3: vec2<f32>;

    g_1 = g;
    u_3 = u_2;
    let _e10 = u_3;
    let _e11 = g_1;
    let _e13 = g_1;
    let _e14 = rndUnit(_e13);
    return dot((_e10 - _e11), _e14);
}

fn smix(a: f32, b: f32, k: f32) -> f32 {
    var a_1: f32;
    var b_1: f32;
    var k_1: f32;

    a_1 = a;
    b_1 = b;
    k_1 = k;
    let _e12 = a_1;
    let _e13 = b_1;
    let _e16 = k_1;
    return mix(_e12, _e13, smoothstep(0f, 1f, _e16));
}

fn perlinNoise(p_2: vec2<f32>) -> f32 {
    var p_3: vec2<f32>;
    var s_1: vec2<f32> = vec2<f32>(1f, 0f);
    var f: vec2<f32>;
    var d: vec2<f32>;
    var ix0_: f32;
    var ix1_: f32;

    p_3 = p_2;
    let _e12 = p_3;
    f = floor(_e12);
    let _e15 = p_3;
    let _e16 = f;
    d = (_e15 - _e16);
    let _e19 = f;
    let _e20 = p_3;
    let _e21 = dotGridGradient(_e19, _e20);
    let _e22 = f;
    let _e23 = s_1;
    let _e25 = p_3;
    let _e26 = dotGridGradient((_e22 + _e23), _e25);
    let _e27 = d;
    let _e29 = smix(_e21, _e26, _e27.x);
    ix0_ = _e29;
    let _e31 = f;
    let _e32 = s_1;
    let _e35 = p_3;
    let _e36 = dotGridGradient((_e31 + _e32.yx), _e35);
    let _e37 = f;
    let _e38 = s_1;
    let _e41 = p_3;
    let _e42 = dotGridGradient((_e37 + _e38.xx), _e41);
    let _e43 = d;
    let _e45 = smix(_e36, _e42, _e43.x);
    ix1_ = _e45;
    let _e48 = ix0_;
    let _e49 = ix1_;
    let _e50 = d;
    let _e52 = smix(_e48, _e49, _e50.y);
    return (0.5f + (_e52 * 0.5f));
}

fn perlinOctaveNoise(uv: vec2<f32>, n: i32) -> f32 {
    var uv_1: vec2<f32>;
    var n_1: i32;
    var transform: mat2x2<f32> = mat2x2<f32>(vec2<f32>(1.7764293f, 1.1406322f), vec2<f32>(-1.1406322f, 1.7764293f));
    var k_2: f32 = 1f;
    var x: f32 = 0f;
    var total: f32 = 0f;
    var i: i32 = 0i;

    uv_1 = uv;
    n_1 = n;
    loop {
        let _e44 = i;
        let _e45 = n_1;
        if !((_e44 < _e45)) {
            break;
        }
        {
            let _e51 = x;
            let _e52 = k_2;
            let _e53 = uv_1;
            let _e54 = perlinNoise(_e53);
            x = (_e51 + (_e52 * _e54));
            let _e57 = total;
            let _e58 = k_2;
            total = (_e57 + _e58);
            let _e60 = k_2;
            k_2 = (_e60 * 0.5f);
            let _e63 = transform;
            let _e64 = uv_1;
            uv_1 = (_e63 * _e64);
        }
        continuing {
            let _e48 = i;
            i = (_e48 + 1i);
        }
    }
    let _e66 = x;
    let _e67 = total;
    x = (_e66 / _e67);
    let _e69 = x;
    return _e69;
}

fn sdSegment(u_4: vec2<f32>, a_2: vec2<f32>, b_2: vec2<f32>) -> f32 {
    var u_5: vec2<f32>;
    var a_3: vec2<f32>;
    var b_3: vec2<f32>;
    var ua: vec2<f32>;
    var ba: vec2<f32>;
    var h: f32;

    u_5 = u_4;
    a_3 = a_2;
    b_3 = b_2;
    let _e12 = u_5;
    let _e13 = a_3;
    ua = (_e12 - _e13);
    let _e16 = b_3;
    let _e17 = a_3;
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

fn tf(m: mat3x3<f32>, u_6: vec2<f32>) -> vec2<f32> {
    var m_1: mat3x3<f32>;
    var u_7: vec2<f32>;

    m_1 = m;
    u_7 = u_6;
    let _e10 = m_1;
    let _e11 = u_7;
    return (_e10 * vec3<f32>(_e11.x, _e11.y, 1f)).xy;
}

fn simpleVignette(vignette: f32, uv_2: vec2<f32>, vignetteTransform: mat3x3<f32>) -> f32 {
    var vignette_1: f32;
    var uv_3: vec2<f32>;
    var vignetteTransform_1: mat3x3<f32>;
    var d_1: f32;

    vignette_1 = vignette;
    uv_3 = uv_2;
    vignetteTransform_1 = vignetteTransform;
    let _e12 = vignetteTransform_1;
    let _e13 = uv_3;
    let _e14 = tf(_e12, _e13);
    d_1 = length(_e14);
    let _e18 = vignette_1;
    let _e23 = d_1;
    return mix((1f - _e18), 1f, smoothstep(0.5f, 1f, _e23));
}

fn chartPaper(uv_4: vec2<f32>, outPos: vec2<f32>, outDim: vec2<f32>, source_specified: i32, color: vec4<f32>, gridColor: vec4<f32>, thickness: f32, grain: f32, humidity: f32, modelTransform: mat3x3<f32>) -> vec4<f32> {
    var uv_5: vec2<f32>;
    var outPos_1: vec2<f32>;
    var outDim_1: vec2<f32>;
    var source_specified_1: i32;
    var color_1: vec4<f32>;
    var gridColor_1: vec4<f32>;
    var thickness_1: f32;
    var grain_1: f32;
    var humidity_1: f32;
    var modelTransform_1: mat3x3<f32>;
    var grainMT: mat3x3<f32>;
    var humMT: mat3x3<f32>;
    var layerXf: mat3x3<f32> = mat3x3<f32>(vec3<f32>(0.5f, 0.4f, 0f), vec3<f32>(-0.4f, 0.5f, 0f), vec3<f32>(10.3f, 4.4f, 1f));
    var axisXf: mat3x3<f32> = mat3x3<f32>(vec3<f32>(0.2f, 0f, 0f), vec3<f32>(0f, 0.2f, 0f), vec3<f32>(0f, 0f, 1f));
    var humColor: vec4<f32> = vec4<f32>(0.205f, 0.164f, 0.084f, 1f);
    var humColor2_: vec4<f32> = vec4<f32>(0.556f, 0.45f, 0.247f, 1f);
    var col: vec4<f32>;
    var gu: vec2<f32>;
    var pn: f32;
    var hu: vec2<f32>;
    var totalHum: f32 = 0f;
    var k_3: f32 = 1f;
    var totalK: f32 = 0f;
    var invLayer: mat3x3<f32>;
    var i_1: i32 = 0i;
    var hum: f32;
    var local: vec4<f32>;
    var targetCol: vec4<f32>;
    var pageFill: f32 = 0.9486f;
    var outAR: f32;
    var ar: f32;
    var s_2: f32;
    var fit: mat3x3<f32>;
    var M: mat3x3<f32>;
    var im: mat3x3<f32>;
    var u_8: vec2<f32>;
    var pixel: f32;
    var aa: f32;
    var modelScale: f32;
    var vb: f32;
    var lineHalf: f32;
    var gridHalf: f32;
    var atF: mat3x3<f32>;
    var iat: mat3x3<f32>;
    var dpos: vec2<f32>;
    var sxLen: f32;
    var syLen: f32;
    var size: f32 = 0.5f;
    var minLabelV: f32;
    var unitVx: f32;
    var unitVy: f32;
    var rawx: f32;
    var bx: f32;
    var mxn: f32;
    var local_1: f32;
    var local_2: f32;
    var local_3: f32;
    var Lx: f32;
    var rawy: f32;
    var by: f32;
    var myn: f32;
    var local_4: f32;
    var local_5: f32;
    var local_6: f32;
    var Ly: f32;
    var minorX: f32;
    var minorY: f32;
    var inBox: bool;
    var dLine: f32 = 1000000000f;
    var covGrid: f32 = 0f;
    var dxM: f32;
    var dyM: f32;
    var dMajor: f32;
    var ci: vec2<f32>;
    var dDot: f32;
    var local_7: f32;
    var covLine: f32;
    var cov: f32;

    uv_5 = uv_4;
    outPos_1 = outPos;
    outDim_1 = outDim;
    source_specified_1 = source_specified;
    color_1 = color;
    gridColor_1 = gridColor;
    thickness_1 = thickness;
    grain_1 = grain;
    humidity_1 = humidity;
    modelTransform_1 = modelTransform;
    let _e31 = cpXform(0.89405024f, 0.89405024f, 1.8886724f, 0.0042433357f, 0.00067456224f);
    grainMT = _e31;
    let _e39 = cpXform(1.0422206f, 1.0422206f, 0f, -0.37128782f, 0.29456925f);
    humMT = _e39;
    let _e88 = color_1;
    col = _e88;
    {
        let _e90 = grainMT;
        let _e92 = uv_5;
        let _e93 = tf(_naga_inverse_3x3_f32(_e90), _e92);
        gu = (_e93 * 300f);
        let _e98 = gu;
        let _e100 = perlinOctaveNoise(_e98, 8i);
        pn = (2f * (_e100 - 0.5f));
        let _e105 = col;
        let _e107 = col;
        let _e110 = grain_1;
        let _e113 = pn;
        let _e116 = (_e107.xyz * (1f + ((_e110 * 4f) * _e113)));
        col.x = _e116.x;
        col.y = _e116.y;
        col.z = _e116.z;
    }
    {
        let _e123 = humMT;
        let _e125 = uv_5;
        let _e126 = tf(_naga_inverse_3x3_f32(_e123), _e125);
        hu = _e126;
        let _e134 = layerXf;
        invLayer = _naga_inverse_3x3_f32(_e134);
        loop {
            let _e139 = i_1;
            if !((_e139 < 3i)) {
                break;
            }
            {
                let _e147 = hu;
                let _e149 = perlinOctaveNoise(_e147, 10i);
                hum = (2f * (_e149 - 0.5f));
                let _e154 = hum;
                let _e156 = (_e154 * 8f);
                hum = ((_e156 - (floor((_e156 / 2f)) * 2f)) * 0.5f);
                let _e164 = hum;
                if (_e164 < 0.9f) {
                    let _e167 = hum;
                    hum = (_e167 / 0.9f);
                } else {
                    let _e171 = hum;
                    hum = (1f - ((_e171 - 0.9f) / 0.100000024f));
                }
                let _e179 = hum;
                hum = pow(_e179, 9f);
                let _e182 = totalHum;
                let _e183 = hum;
                let _e184 = k_3;
                totalHum = (_e182 + (_e183 * _e184));
                let _e187 = totalK;
                let _e188 = k_3;
                totalK = (_e187 + _e188);
                let _e190 = k_3;
                k_3 = (_e190 * 0.6f);
                let _e193 = invLayer;
                let _e194 = hu;
                let _e195 = tf(_e193, _e194);
                hu = _e195;
            }
            continuing {
                let _e143 = i_1;
                i_1 = (_e143 + 1i);
            }
        }
        let _e196 = totalHum;
        let _e198 = totalK;
        totalHum = (_e196 / mix(1f, _e198, 0.001953125f));
        let _e204 = totalHum;
        if (_e204 < 0.5f) {
            let _e207 = col;
            let _e208 = col;
            let _e209 = humColor2_;
            let _e210 = mergeColor(_e208, _e209);
            let _e211 = totalHum;
            local = mix(_e207, _e210, vec4((_e211 / 0.5f)));
        } else {
            let _e216 = col;
            let _e217 = humColor2_;
            let _e218 = mergeColor(_e216, _e217);
            let _e219 = col;
            let _e220 = humColor;
            let _e221 = mergeColor(_e219, _e220);
            let _e222 = totalHum;
            local = mix(_e218, _e221, vec4(((_e222 - 0.5f) / 0.5f)));
        }
        let _e230 = local;
        targetCol = _e230;
        let _e232 = col;
        let _e233 = targetCol;
        let _e234 = humidity_1;
        let _e236 = uv_5;
        let _e243 = simpleVignette(0.53083974f, _e236, mat3x3<f32>(vec3<f32>(1f, 0f, 0f), vec3<f32>(0f, 1f, 0f), vec3<f32>(0f, 0f, 1f)));
        col = mix(_e232, _e233, vec4((_e234 * _e243)));
    }
    {
        let _e249 = outDim_1;
        let _e251 = outDim_1;
        outAR = (_e249.x / _e251.y);
        let _e256 = outAR;
        ar = (1f / _e256);
        let _e259 = outAR;
        let _e260 = pageFill;
        s_2 = (_e259 * _e260);
        let _e263 = s_2;
        let _e266 = vec3<f32>(_e263, 0f, 0f);
        let _e268 = s_2;
        let _e270 = vec3<f32>(0f, _e268, 0f);
        fit = mat3x3<f32>(vec3<f32>(_e266.x, _e266.y, _e266.z), vec3<f32>(_e270.x, _e270.y, _e270.z), vec3<f32>(0f, 0f, 1f));
        let _e286 = fit;
        let _e287 = modelTransform_1;
        M = (_e286 * _e287);
        let _e290 = M;
        im = _naga_inverse_3x3_f32(_e290);
        let _e293 = im;
        let _e294 = uv_5;
        let _e295 = tf(_e293, _e294);
        u_8 = _e295;
        let _e298 = outDim_1;
        pixel = (2f / _e298.y);
        let _e302 = im;
        let _e303 = uv_5;
        let _e304 = pixel;
        let _e308 = tf(_e302, (_e303 + vec2<f32>(_e304, 0f)));
        let _e309 = u_8;
        aa = (length((_e308 - _e309)) * 0.75f);
        let _e319 = M[0][0];
        let _e324 = M[0][1];
        modelScale = length(vec2<f32>(_e319, _e324));
        let _e328 = modelScale;
        if (_e328 < 0.00001f) {
            modelScale = 0.00001f;
        }
        let _e333 = modelScale;
        vb = (1f / _e333);
        let _e336 = thickness_1;
        let _e339 = vb;
        lineHalf = ((_e336 * 0.025f) * _e339);
        let _e342 = lineHalf;
        gridHalf = (_e342 * 0.5f);
        let _e350 = axisXf[0][0];
        let _e355 = axisXf[0][1];
        let _e360 = axisXf[0][2];
        let _e361 = vec3<f32>(_e350, _e355, _e360);
        let _e366 = axisXf[1][0];
        let _e372 = axisXf[1][1];
        let _e378 = axisXf[1][2];
        let _e380 = vec3<f32>(-(_e366), -(_e372), -(_e378));
        let _e385 = axisXf[2][0];
        let _e390 = axisXf[2][1];
        let _e395 = axisXf[2][2];
        let _e396 = vec3<f32>(_e385, _e390, _e395);
        atF = mat3x3<f32>(vec3<f32>(_e361.x, _e361.y, _e361.z), vec3<f32>(_e380.x, _e380.y, _e380.z), vec3<f32>(_e396.x, _e396.y, _e396.z));
        let _e411 = atF;
        iat = _naga_inverse_3x3_f32(_e411);
        let _e414 = iat;
        let _e415 = u_8;
        let _e416 = tf(_e414, _e415);
        dpos = _e416;
        let _e422 = atF[0][0];
        let _e427 = atF[0][1];
        sxLen = length(vec2<f32>(_e422, _e427));
        let _e435 = atF[1][0];
        let _e440 = atF[1][1];
        syLen = length(vec2<f32>(_e435, _e440));
        let _e444 = sxLen;
        if (_e444 < 0.00001f) {
            sxLen = 1f;
        }
        let _e448 = syLen;
        if (_e448 < 0.00001f) {
            syLen = 1f;
        }
        let _e455 = size;
        minLabelV = max((0.3f * _e455), 0.04f);
        let _e460 = sxLen;
        let _e461 = modelScale;
        unitVx = (_e460 * _e461);
        let _e464 = syLen;
        let _e465 = modelScale;
        unitVy = (_e464 * _e465);
        let _e468 = minLabelV;
        let _e469 = unitVx;
        rawx = (_e468 / max(_e469, 0.000001f));
        let _e475 = rawx;
        bx = pow(10f, floor((log(max(_e475, 1f)) / 2.3025851f)));
        let _e485 = rawx;
        let _e486 = bx;
        mxn = (_e485 / _e486);
        let _e489 = mxn;
        if (_e489 <= 1f) {
            local_3 = 1f;
        } else {
            let _e493 = mxn;
            if (_e493 <= 2f) {
                local_2 = 2f;
            } else {
                let _e497 = mxn;
                if (_e497 <= 5f) {
                    local_1 = 5f;
                } else {
                    local_1 = 10f;
                }
                let _e503 = local_1;
                local_2 = _e503;
            }
            let _e505 = local_2;
            local_3 = _e505;
        }
        let _e507 = local_3;
        let _e508 = bx;
        Lx = max((_e507 * _e508), 1f);
        let _e513 = minLabelV;
        let _e514 = unitVy;
        rawy = (_e513 / max(_e514, 0.000001f));
        let _e520 = rawy;
        by = pow(10f, floor((log(max(_e520, 1f)) / 2.3025851f)));
        let _e530 = rawy;
        let _e531 = by;
        myn = (_e530 / _e531);
        let _e534 = myn;
        if (_e534 <= 1f) {
            local_6 = 1f;
        } else {
            let _e538 = myn;
            if (_e538 <= 2f) {
                local_5 = 2f;
            } else {
                let _e542 = myn;
                if (_e542 <= 5f) {
                    local_4 = 5f;
                } else {
                    local_4 = 10f;
                }
                let _e548 = local_4;
                local_5 = _e548;
            }
            let _e550 = local_5;
            local_6 = _e550;
        }
        let _e552 = local_6;
        let _e553 = by;
        Ly = max((_e552 * _e553), 1f);
        let _e558 = Lx;
        minorX = (_e558 / 5f);
        let _e562 = Ly;
        minorY = (_e562 / 5f);
        let _e566 = u_8;
        let _e570 = aa;
        let _e573 = u_8;
        let _e576 = ar;
        let _e577 = aa;
        inBox = ((abs(_e566.x) <= (1f + _e570)) && (abs(_e573.y) <= (_e576 + _e577)));
        let _e586 = dLine;
        let _e587 = u_8;
        let _e590 = ar;
        let _e594 = ar;
        let _e597 = sdSegment(_e587, vec2<f32>(-1f, -(_e590)), vec2<f32>(1f, -(_e594)));
        dLine = min(_e586, _e597);
        let _e599 = dLine;
        let _e600 = u_8;
        let _e603 = ar;
        let _e606 = ar;
        let _e608 = sdSegment(_e600, vec2<f32>(-1f, _e603), vec2<f32>(1f, _e606));
        dLine = min(_e599, _e608);
        let _e610 = dLine;
        let _e611 = u_8;
        let _e614 = ar;
        let _e619 = ar;
        let _e621 = sdSegment(_e611, vec2<f32>(-1f, -(_e614)), vec2<f32>(-1f, _e619));
        dLine = min(_e610, _e621);
        let _e623 = dLine;
        let _e624 = u_8;
        let _e626 = ar;
        let _e630 = ar;
        let _e632 = sdSegment(_e624, vec2<f32>(1f, -(_e626)), vec2<f32>(1f, _e630));
        dLine = min(_e623, _e632);
        let _e634 = inBox;
        if _e634 {
            {
                let _e635 = dpos;
                let _e637 = dpos;
                let _e639 = Lx;
                let _e644 = Lx;
                let _e648 = sxLen;
                dxM = (abs((_e635.x - (floor(((_e637.x / _e639) + 0.5f)) * _e644))) * _e648);
                let _e651 = dpos;
                let _e653 = dpos;
                let _e655 = Ly;
                let _e660 = Ly;
                let _e664 = syLen;
                dyM = (abs((_e651.y - (floor(((_e653.y / _e655) + 0.5f)) * _e660))) * _e664);
                let _e667 = dxM;
                let _e668 = dyM;
                dMajor = min(_e667, _e668);
                let _e671 = covGrid;
                let _e673 = gridHalf;
                let _e674 = aa;
                let _e676 = gridHalf;
                let _e677 = aa;
                let _e679 = dMajor;
                covGrid = max(_e671, (1f - smoothstep((_e673 - _e674), (_e676 + _e677), _e679)));
                let _e683 = atF;
                let _e684 = dpos;
                let _e686 = minorX;
                let _e691 = minorX;
                let _e693 = dpos;
                let _e695 = minorY;
                let _e700 = minorY;
                let _e703 = tf(_e683, vec2<f32>((floor(((_e684.x / _e686) + 0.5f)) * _e691), (floor(((_e693.y / _e695) + 0.5f)) * _e700)));
                ci = _e703;
                let _e705 = u_8;
                let _e707 = ci;
                let _e711 = u_8;
                let _e713 = ci;
                dDot = max(abs((_e705.x - _e707.x)), abs((_e711.y - _e713.y)));
                let _e719 = covGrid;
                let _e721 = gridHalf;
                let _e722 = aa;
                let _e724 = gridHalf;
                let _e725 = aa;
                let _e727 = dDot;
                covGrid = max(_e719, (1f - smoothstep((_e721 - _e722), (_e724 + _e725), _e727)));
            }
        }
        let _e731 = lineHalf;
        if (_e731 <= 0f) {
            local_7 = 0f;
        } else {
            let _e736 = lineHalf;
            let _e737 = aa;
            let _e739 = lineHalf;
            let _e740 = aa;
            let _e742 = dLine;
            local_7 = (1f - smoothstep((_e736 - _e737), (_e739 + _e740), _e742));
        }
        let _e746 = local_7;
        covLine = _e746;
        let _e748 = lineHalf;
        if (_e748 <= 0f) {
            covGrid = 0f;
        }
        let _e752 = covLine;
        let _e753 = covGrid;
        cov = max(_e752, _e753);
        let _e756 = col;
        let _e757 = gridColor_1;
        let _e758 = _e757.xyz;
        let _e759 = gridColor_1;
        let _e761 = cov;
        let _e767 = mergeColor(_e756, vec4<f32>(_e758.x, _e758.y, _e758.z, (_e759.w * _e761)));
        col = _e767;
    }
    let _e768 = source_specified_1;
    if (_e768 == 1i) {
        let _e771 = uv_5;
        let _e775 = global.U[0];
        let _e778 = uv_5;
        let _e787 = textureSample(t_source, samp, ((vec2<f32>((_e771.x / _e775.x), _e778.y) / vec2(2f)) + vec2(0.5f)));
        let _e788 = col;
        let _e789 = mergeColor(_e787, _e788);
        col = _e789;
    }
    let _e790 = col;
    return _e790;
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
    let _e70 = global.U[5];
    let _e75 = global.U[6];
    let _e78 = global.U[7];
    let _e81 = global.U[8];
    let _e85 = global.U[9];
    let _e89 = global.U[10];
    let _e93 = global.U[11];
    let _e94 = _e93.xyz;
    let _e97 = global.U[12];
    let _e98 = _e97.xyz;
    let _e101 = global.U[13];
    let _e102 = _e101.xyz;
    let _e116 = chartPaper((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e9.x, _e9.y, _e9.z), vec3<f32>(_e13.x, _e13.y, _e13.z), vec3<f32>(_e17.x, _e17.y, _e17.z))) * vec3<f32>(_e44.x, _e44.y, 1f)).xy, (((_e51 - vec2(0.5f)) * 2f) * vec2<f32>(_e59.x, 1f)), _e66.xy, i32(_e70.x), _e75, _e78, _e81.x, _e85.x, _e89.x, mat3x3<f32>(vec3<f32>(_e94.x, _e94.y, _e94.z), vec3<f32>(_e98.x, _e98.y, _e98.z), vec3<f32>(_e102.x, _e102.y, _e102.z)));
    fragColor = _e116;
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
