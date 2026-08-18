struct Params {
    U: array<vec4<f32>, 22>,
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

fn distSegSeg(S1P0_: vec3<f32>, S1P1_: vec3<f32>, S2P0_: vec3<f32>, S2P1_: vec3<f32>) -> vec4<f32> {
    var S1P0_1: vec3<f32>;
    var S1P1_1: vec3<f32>;
    var S2P0_1: vec3<f32>;
    var S2P1_1: vec3<f32>;
    var u: vec3<f32>;
    var v: vec3<f32>;
    var w: vec3<f32>;
    var a: f32;
    var b: f32;
    var c: f32;
    var d: f32;
    var e: f32;
    var D: f32;
    var sc: f32;
    var sN: f32;
    var sD: f32;
    var tc: f32;
    var tN: f32;
    var tD: f32;
    var local: f32;
    var local_1: f32;
    var dP: vec3<f32>;

    S1P0_1 = S1P0_;
    S1P1_1 = S1P1_;
    S2P0_1 = S2P0_;
    S2P1_1 = S2P1_;
    let _e16 = S1P1_1;
    let _e17 = S1P0_1;
    u = (_e16 - _e17);
    let _e20 = S2P1_1;
    let _e21 = S2P0_1;
    v = (_e20 - _e21);
    let _e24 = S1P0_1;
    let _e25 = S2P0_1;
    w = (_e24 - _e25);
    let _e28 = u;
    let _e29 = u;
    a = dot(_e28, _e29);
    let _e32 = u;
    let _e33 = v;
    b = dot(_e32, _e33);
    let _e36 = v;
    let _e37 = v;
    c = dot(_e36, _e37);
    let _e40 = u;
    let _e41 = w;
    d = dot(_e40, _e41);
    let _e44 = v;
    let _e45 = w;
    e = dot(_e44, _e45);
    let _e48 = a;
    let _e49 = c;
    let _e51 = b;
    let _e52 = b;
    D = ((_e48 * _e49) - (_e51 * _e52));
    let _e58 = D;
    sD = _e58;
    let _e62 = D;
    tD = _e62;
    let _e64 = D;
    if (_e64 < 0.00001f) {
        {
            sN = 0f;
            sD = 1f;
            let _e69 = e;
            tN = _e69;
            let _e70 = c;
            tD = _e70;
        }
    } else {
        {
            let _e71 = b;
            let _e72 = e;
            let _e74 = c;
            let _e75 = d;
            sN = ((_e71 * _e72) - (_e74 * _e75));
            let _e78 = a;
            let _e79 = e;
            let _e81 = b;
            let _e82 = d;
            tN = ((_e78 * _e79) - (_e81 * _e82));
            let _e85 = sN;
            if (_e85 < 0f) {
                {
                    sN = 0f;
                    let _e89 = e;
                    tN = _e89;
                    let _e90 = c;
                    tD = _e90;
                }
            } else {
                let _e91 = sN;
                let _e92 = sD;
                if (_e91 > _e92) {
                    {
                        let _e94 = sD;
                        sN = _e94;
                        let _e95 = e;
                        let _e96 = b;
                        tN = (_e95 + _e96);
                        let _e98 = c;
                        tD = _e98;
                    }
                }
            }
        }
    }
    let _e99 = tN;
    if (_e99 < 0f) {
        {
            tN = 0f;
            let _e103 = d;
            if (-(_e103) < 0f) {
                sN = 0f;
            } else {
                let _e108 = d;
                let _e110 = a;
                if (-(_e108) > _e110) {
                    let _e112 = sD;
                    sN = _e112;
                } else {
                    {
                        let _e113 = d;
                        sN = -(_e113);
                        let _e115 = a;
                        sD = _e115;
                    }
                }
            }
        }
    } else {
        let _e116 = tN;
        let _e117 = tD;
        if (_e116 > _e117) {
            {
                let _e119 = tD;
                tN = _e119;
                let _e120 = d;
                let _e122 = b;
                if ((-(_e120) + _e122) < 0f) {
                    sN = 0f;
                } else {
                    let _e127 = d;
                    let _e129 = b;
                    let _e131 = a;
                    if ((-(_e127) + _e129) > _e131) {
                        let _e133 = sD;
                        sN = _e133;
                    } else {
                        {
                            let _e134 = d;
                            let _e136 = b;
                            sN = (-(_e134) + _e136);
                            let _e138 = a;
                            sD = _e138;
                        }
                    }
                }
            }
        }
    }
    let _e139 = sN;
    if (abs(_e139) < 0.00001f) {
        local = 0f;
    } else {
        let _e144 = sN;
        let _e145 = sD;
        local = (_e144 / _e145);
    }
    let _e148 = local;
    sc = _e148;
    let _e149 = tN;
    if (abs(_e149) < 0.00001f) {
        local_1 = 0f;
    } else {
        let _e154 = tN;
        let _e155 = tD;
        local_1 = (_e154 / _e155);
    }
    let _e158 = local_1;
    tc = _e158;
    let _e159 = w;
    let _e160 = sc;
    let _e161 = u;
    let _e164 = tc;
    let _e165 = v;
    dP = ((_e159 + (_e160 * _e161)) - (_e164 * _e165));
    let _e169 = S1P0_1;
    let _e170 = sc;
    let _e171 = u;
    let _e173 = (_e169 + (_e170 * _e171));
    let _e174 = dP;
    return vec4<f32>(_e173.x, _e173.y, _e173.z, length(_e174));
}

fn distSegSegZ(S1P0_2: vec3<f32>, S1P1_2: vec3<f32>, S2P0_2: vec3<f32>, S2P1_2: vec3<f32>, cameraPos: vec3<f32>, dir: vec3<f32>) -> vec4<f32> {
    var S1P0_3: vec3<f32>;
    var S1P1_3: vec3<f32>;
    var S2P0_3: vec3<f32>;
    var S2P1_3: vec3<f32>;
    var cameraPos_1: vec3<f32>;
    var dir_1: vec3<f32>;
    var d_1: vec4<f32>;
    var Z: f32;
    var local_2: f32;

    S1P0_3 = S1P0_2;
    S1P1_3 = S1P1_2;
    S2P0_3 = S2P0_2;
    S2P1_3 = S2P1_2;
    cameraPos_1 = cameraPos;
    dir_1 = dir;
    let _e20 = S1P0_3;
    let _e21 = S1P1_3;
    let _e22 = S2P0_3;
    let _e23 = S2P1_3;
    let _e24 = distSegSeg(_e20, _e21, _e22, _e23);
    d_1 = _e24;
    let _e26 = dir_1;
    let _e27 = d_1;
    let _e29 = cameraPos_1;
    Z = dot(_e26, (_e27.xyz - _e29));
    let _e33 = d_1;
    let _e34 = _e33.xyz;
    let _e35 = Z;
    if (_e35 < 0.0001f) {
        local_2 = 10000000000f;
    } else {
        let _e39 = d_1;
        let _e41 = Z;
        local_2 = (_e39.w / _e41);
    }
    let _e44 = local_2;
    return vec4<f32>(_e34.x, _e34.y, _e34.z, _e44);
}

fn getBackground(pos: vec2<f32>) -> vec4<f32> {
    var pos_1: vec2<f32>;

    pos_1 = pos;
    return vec4<f32>(0f, 0f, 0f, 1f);
}

fn height(intensity: f32, color: vec4<f32>) -> f32 {
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

fn wireframe(pos_2: vec2<f32>, outPos: vec2<f32>, intensity_2: f32, mode: i32, rezolution: i32, thickness: f32, glow: f32, model3DTransform: mat4x4<f32>, sourceDim: vec2<f32>, sourceElevationDim: vec2<f32>, sourceBkg_specified: i32, sourceElevation_specified: i32, transparencyMode: i32, colorBkg: vec4<f32>, colorLines: vec4<f32>, colorFog: vec4<f32>) -> vec4<f32> {
    var pos_3: vec2<f32>;
    var outPos_1: vec2<f32>;
    var intensity_3: f32;
    var mode_1: i32;
    var rezolution_1: i32;
    var thickness_1: f32;
    var glow_1: f32;
    var model3DTransform_1: mat4x4<f32>;
    var sourceDim_1: vec2<f32>;
    var sourceElevationDim_1: vec2<f32>;
    var sourceBkg_specified_1: i32;
    var sourceElevation_specified_1: i32;
    var transparencyMode_1: i32;
    var colorBkg_1: vec4<f32>;
    var colorLines_1: vec4<f32>;
    var colorFog_1: vec4<f32>;
    var backgroundColor: vec4<f32> = vec4<f32>(0f, 0f, 0f, 1f);
    var D_1: f32 = 1f;
    var cameraPos_2: vec3<f32> = vec3<f32>(0f, 0f, 0f);
    var m: mat4x4<f32>;
    var dir_2: vec3<f32>;
    var heightMap: bool;
    var maxZ: f32;
    var local_3: f32;
    var ratio: f32;
    var local_4: f32;
    var dk: f32;
    var step: vec3<f32>;
    var squareSize: f32;
    var surfaceWidth: f32;
    var surfaceHeight: f32 = 2f;
    var countX: f32;
    var countY: f32;
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
    var local_5: vec4<f32>;
    var local_6: vec4<f32>;
    var k: f32;
    var p: vec3<f32>;
    var local_7: vec4<f32>;
    var local_8: vec4<f32>;
    var color_2: vec4<f32>;
    var h: f32 = 0f;
    var dz: f32 = 0f;
    var prevDz: f32;
    var prevColor: vec4<f32>;
    var prevH: f32;
    var stop: bool;
    var intersected: f32 = 0f;
    var intersDist: f32 = 1000000000f;
    var triangleIntersection: vec3<f32>;
    var outColor: vec4<f32> = vec4<f32>(0f, 0f, 0f, 0f);
    var nextLines: vec2<f32>;
    var maxIter: i32 = 1000i;
    var frameDist: f32 = 10000000000f;
    var th: f32;
    var glowAcc: f32 = 0f;
    var transparentToBackground: bool;
    var local_9: f32;
    var underlyingColor: f32;
    var local_10: vec4<f32>;
    var local_11: vec4<f32>;
    var frameColor: vec4<f32>;
    var horizontals: bool = true;
    var verticals: bool = true;
    var solidSurface: bool = true;
    var indexX: f32;
    var indexY: f32;
    var fX: f32;
    var fY: f32;
    var squareCenter: vec2<f32>;
    var bottomLeft: vec2<f32>;
    var square: bool;
    var rnd: f32;
    var triangles: bool;
    var frameDistVec: vec4<f32>;
    var origin: vec3<f32>;
    var p_1: vec2<f32>;
    var step_1: f32;
    var s_3: vec2<f32>;
    var p11_: vec2<f32>;
    var local_12: vec4<f32>;
    var c00_: vec4<f32>;
    var h00_: f32;
    var A: vec3<f32>;
    var local_13: vec4<f32>;
    var c10_: vec4<f32>;
    var h10_: f32;
    var B: vec3<f32>;
    var local_14: vec4<f32>;
    var c01_: vec4<f32>;
    var h01_: f32;
    var C: vec3<f32>;
    var local_15: vec4<f32>;
    var c11_: vec4<f32>;
    var h11_: f32;
    var D_2: vec3<f32>;
    var dzx1_: f32;
    var dzy1_: f32;
    var k1_1: f32;
    var dzx2_: f32;
    var dzy2_: f32;
    var k2_1: f32;
    var intersection: vec3<f32>;
    var relInt: vec2<f32>;
    var intersection_1: vec3<f32>;
    var relInt_1: vec2<f32>;
    var inf: vec3<f32>;
    var W: f32;
    var H: f32;
    var fdAB: vec4<f32>;
    var fdCD: vec4<f32>;
    var fdAC: vec4<f32>;
    var fdBD: vec4<f32>;
    var inters: mat3x3<f32>;
    var local_16: f32;
    var currentColor: vec4<f32>;
    var next: vec2<f32>;
    var deltaK: vec2<f32>;
    var minK: f32;
    var local_17: f32;
    var frameK: f32;
    var nearDist: f32;
    var farDist: f32;
    var kFog: f32;

    pos_3 = pos_2;
    outPos_1 = outPos;
    intensity_3 = intensity_2;
    mode_1 = mode;
    rezolution_1 = rezolution;
    thickness_1 = thickness;
    glow_1 = glow;
    model3DTransform_1 = model3DTransform;
    sourceDim_1 = sourceDim;
    sourceElevationDim_1 = sourceElevationDim;
    sourceBkg_specified_1 = sourceBkg_specified;
    sourceElevation_specified_1 = sourceElevation_specified;
    transparencyMode_1 = transparencyMode;
    colorBkg_1 = colorBkg;
    colorLines_1 = colorLines;
    colorFog_1 = colorFog;
    let _e53 = model3DTransform_1;
    m = _naga_inverse_4x4_f32(_e53);
    let _e56 = m;
    let _e57 = cameraPos_2;
    cameraPos_2 = (_e56 * vec4<f32>(_e57.x, _e57.y, _e57.z, 1f)).xyz;
    let _e65 = pos_3;
    let _e67 = D_1;
    let _e69 = pos_3;
    let _e71 = D_1;
    dir_2 = normalize(vec3<f32>((_e65.x * _e67), (_e69.y * _e71), -1f));
    let _e78 = m;
    let _e88 = dir_2;
    dir_2 = (mat3x3<f32>(_e78[0].xyz, _e78[1].xyz, _e78[2].xyz) * _e88);
    let _e90 = sourceElevation_specified_1;
    heightMap = (_e90 == 1i);
    let _e94 = intensity_3;
    maxZ = (abs(_e94) * 0.02f);
    let _e99 = heightMap;
    if _e99 {
        let _e100 = sourceElevationDim_1;
        let _e102 = sourceElevationDim_1;
        local_3 = (_e100.x / _e102.y);
    } else {
        let _e105 = sourceDim_1;
        let _e107 = sourceDim_1;
        local_3 = (_e105.x / _e107.y);
    }
    let _e111 = local_3;
    ratio = _e111;
    let _e113 = heightMap;
    if _e113 {
        let _e115 = sourceElevationDim_1;
        local_4 = (2f / _e115.y);
    } else {
        let _e119 = sourceDim_1;
        local_4 = (2f / _e119.y);
    }
    let _e123 = local_4;
    dk = _e123;
    let _e125 = dir_2;
    let _e126 = dk;
    step = (_e125 * _e126);
    let _e130 = rezolution_1;
    squareSize = (2f / f32(_e130));
    let _e135 = ratio;
    let _e137 = squareSize;
    let _e140 = squareSize;
    surfaceWidth = (round(((2f * _e135) / _e137)) * _e140);
    let _e145 = surfaceWidth;
    let _e146 = squareSize;
    countX = floor(((_e145 / _e146) + 0.5f));
    let _e152 = rezolution_1;
    countY = f32(_e152);
    let _e159 = dir_2;
    if (_e159.x != 0f) {
        {
            let _e163 = dir_2;
            s = sign(_e163.x);
            let _e167 = s;
            let _e169 = surfaceWidth;
            let _e173 = cameraPos_2;
            let _e176 = dir_2;
            k3_ = ((((-(_e167) * _e169) / 2f) - _e173.x) / _e176.x);
            let _e180 = s;
            let _e181 = surfaceWidth;
            let _e185 = cameraPos_2;
            let _e188 = dir_2;
            k4_ = ((((_e180 * _e181) / 2f) - _e185.x) / _e188.x);
            let _e192 = k1_;
            let _e193 = k3_;
            k1_ = max(_e192, _e193);
            let _e195 = k2_;
            let _e196 = k4_;
            k2_ = min(_e195, _e196);
        }
    }
    let _e198 = dir_2;
    if (_e198.y != 0f) {
        {
            let _e202 = dir_2;
            s_1 = sign(_e202.y);
            let _e206 = s_1;
            let _e208 = cameraPos_2;
            let _e211 = dir_2;
            k3_1 = ((-(_e206) - _e208.y) / _e211.y);
            let _e215 = s_1;
            let _e216 = cameraPos_2;
            let _e219 = dir_2;
            k4_1 = ((_e215 - _e216.y) / _e219.y);
            let _e223 = k1_;
            let _e224 = k3_1;
            k1_ = max(_e223, _e224);
            let _e226 = k2_;
            let _e227 = k4_1;
            k2_ = min(_e226, _e227);
        }
    }
    let _e229 = maxZ;
    maxZ2_ = (_e229 + 0.0001f);
    let _e233 = dir_2;
    if (_e233.z != 0f) {
        {
            let _e237 = dir_2;
            s_2 = sign(_e237.z);
            let _e241 = s_2;
            let _e243 = maxZ2_;
            let _e245 = cameraPos_2;
            let _e248 = dir_2;
            k3_2 = (((-(_e241) * _e243) - _e245.z) / _e248.z);
            let _e252 = s_2;
            let _e253 = maxZ2_;
            let _e255 = cameraPos_2;
            let _e258 = dir_2;
            k4_2 = (((_e252 * _e253) - _e255.z) / _e258.z);
            let _e262 = k1_;
            let _e263 = k3_2;
            k1_ = max(_e262, _e263);
            let _e265 = k2_;
            let _e266 = k4_2;
            k2_ = min(_e265, _e266);
        }
    }
    let _e268 = k1_;
    let _e269 = k2_;
    if (_e268 > _e269) {
        let _e271 = colorFog_1;
        if (_e271.w != 0f) {
            let _e275 = colorFog_1;
            let _e276 = _e275.xyz;
            local_6 = vec4<f32>(_e276.x, _e276.y, _e276.z, 1f);
        } else {
            let _e282 = sourceBkg_specified_1;
            if (_e282 == 1i) {
                let _e285 = outPos_1;
                let _e289 = global.U[0];
                let _e292 = outPos_1;
                let _e301 = textureSample(t_sourceBkg, samp, ((vec2<f32>((_e285.x / _e289.x), _e292.y) / vec2(2f)) + vec2(0.5f)));
                local_5 = _e301;
            } else {
                let _e302 = colorBkg_1;
                local_5 = _e302;
            }
            let _e304 = local_5;
            local_6 = _e304;
        }
        let _e306 = local_6;
        return _e306;
    }
    let _e307 = k1_;
    k = _e307;
    let _e309 = cameraPos_2;
    let _e310 = k;
    let _e311 = dir_2;
    p = (_e309 + (_e310 * _e311));
    let _e315 = colorFog_1;
    if (_e315.w != 0f) {
        let _e319 = colorFog_1;
        let _e320 = _e319.xyz;
        local_8 = vec4<f32>(_e320.x, _e320.y, _e320.z, 1f);
    } else {
        let _e326 = sourceBkg_specified_1;
        if (_e326 == 1i) {
            let _e329 = outPos_1;
            let _e333 = global.U[0];
            let _e336 = outPos_1;
            let _e345 = textureSample(t_sourceBkg, samp, ((vec2<f32>((_e329.x / _e333.x), _e336.y) / vec2(2f)) + vec2(0.5f)));
            local_7 = _e345;
        } else {
            let _e346 = colorBkg_1;
            local_7 = _e346;
        }
        let _e348 = local_7;
        local_8 = _e348;
    }
    let _e350 = local_8;
    color_2 = _e350;
    let _e371 = dir_2;
    let _e374 = squareSize;
    nextLines = ((sign(_e371.xy) * _e374) / vec2(2f));
    let _e385 = thickness_1;
    let _e387 = cameraPos_2;
    th = ((0.01f * _e385) / length(_e387));
    let _e393 = transparencyMode_1;
    transparentToBackground = (_e393 == 0i);
    let _e397 = transparentToBackground;
    if _e397 {
        local_9 = 0f;
    } else {
        let _e400 = colorLines_1;
        local_9 = (1f - _e400.w);
    }
    let _e404 = local_9;
    underlyingColor = _e404;
    let _e406 = transparentToBackground;
    if _e406 {
        let _e407 = color_2;
        let _e409 = colorLines_1;
        let _e411 = colorLines_1;
        let _e414 = mix(_e407.xyz, _e409.xyz, vec3(_e411.w));
        let _e415 = color_2;
        local_11 = vec4<f32>(_e414.x, _e414.y, _e414.z, _e415.w);
    } else {
        let _e421 = underlyingColor;
        if (_e421 == 0f) {
            let _e424 = colorLines_1;
            local_10 = _e424;
        } else {
            local_10 = vec4<f32>(0f, 0f, 0f, 1f);
        }
        let _e431 = local_10;
        local_11 = _e431;
    }
    let _e433 = local_11;
    frameColor = _e433;
    let _e441 = mode_1;
    if (_e441 == 1i) {
        verticals = false;
    } else {
        let _e445 = mode_1;
        if (_e445 == 2i) {
            horizontals = false;
        } else {
            let _e449 = mode_1;
            if (_e449 == 3i) {
                solidSurface = false;
            } else {
                let _e453 = mode_1;
                if (_e453 == 4i) {
                    {
                        solidSurface = false;
                        verticals = false;
                    }
                } else {
                    let _e458 = mode_1;
                    if (_e458 == 5i) {
                        {
                            solidSurface = false;
                            horizontals = false;
                        }
                    } else {
                        let _e463 = mode_1;
                        if (_e463 == 7i) {
                            {
                                solidSurface = false;
                            }
                        } else {
                            let _e467 = mode_1;
                            if (_e467 == 8i) {
                                {
                                }
                            } else {
                                let _e470 = mode_1;
                                if (_e470 == 9i) {
                                    {
                                        verticals = false;
                                    }
                                } else {
                                    let _e474 = mode_1;
                                    if (_e474 == 10i) {
                                        {
                                            horizontals = false;
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    loop {
        let _e478 = intersected;
        let _e481 = k;
        let _e482 = k2_;
        let _e485 = maxIter;
        if !((((_e478 < 1f) && (_e481 <= _e482)) && (_e485 > 0i))) {
            break;
        }
        {
            let _e490 = p;
            let _e492 = surfaceWidth;
            let _e496 = squareSize;
            indexX = ((_e490.x + (_e492 / 2f)) / _e496);
            let _e499 = p;
            let _e501 = surfaceHeight;
            let _e505 = squareSize;
            indexY = ((_e499.y + (_e501 / 2f)) / _e505);
            let _e508 = indexX;
            fX = fract(_e508);
            let _e511 = indexY;
            fY = fract(_e511);
            let _e515 = fX;
            let _e518 = dir_2;
            if ((_e515 > 0.9999f) && (_e518.x > 0f)) {
                let _e524 = indexX;
                let _e528 = squareSize;
                squareCenter.x = ((ceil(_e524) + 0.5f) * _e528);
            } else {
                let _e530 = fX;
                let _e533 = dir_2;
                if ((_e530 < 0.0001f) && (_e533.x < 0f)) {
                    let _e539 = indexX;
                    let _e543 = squareSize;
                    squareCenter.x = ((floor(_e539) - 0.5f) * _e543);
                } else {
                    let _e546 = indexX;
                    let _e550 = squareSize;
                    squareCenter.x = ((floor(_e546) + 0.5f) * _e550);
                }
            }
            let _e553 = squareCenter;
            let _e555 = surfaceWidth;
            squareCenter.x = (_e553.x - (_e555 / 2f));
            let _e559 = fY;
            let _e562 = dir_2;
            if ((_e559 > 0.9999f) && (_e562.y > 0f)) {
                let _e568 = indexY;
                let _e572 = squareSize;
                squareCenter.y = ((ceil(_e568) + 0.5f) * _e572);
            } else {
                let _e574 = fY;
                let _e577 = dir_2;
                if ((_e574 < 0.0001f) && (_e577.y < 0f)) {
                    let _e583 = indexY;
                    let _e587 = squareSize;
                    squareCenter.y = ((floor(_e583) - 0.5f) * _e587);
                } else {
                    let _e590 = indexY;
                    let _e594 = squareSize;
                    squareCenter.y = ((floor(_e590) + 0.5f) * _e594);
                }
            }
            let _e597 = squareCenter;
            let _e599 = surfaceHeight;
            squareCenter.y = (_e597.y - (_e599 / 2f));
            let _e603 = squareCenter;
            let _e604 = squareSize;
            let _e605 = squareSize;
            bottomLeft = (_e603 - (vec2<f32>(_e604, _e605) / vec2(2f)));
            square = false;
            let _e614 = mode_1;
            let _e617 = mode_1;
            if ((_e614 == 6i) || (_e617 == 7i)) {
                {
                    let _e621 = bottomLeft;
                    let _e623 = squareSize;
                    let _e626 = bottomLeft;
                    let _e628 = squareSize;
                    let _e631 = (floor((_e621.x / _e623)) + floor((_e626.y / _e628)));
                    if ((_e631 - (floor((_e631 / 2f)) * 2f)) == 0f) {
                        square = true;
                    }
                }
            } else {
                let _e640 = mode_1;
                if (_e640 >= 8i) {
                    {
                        let _e643 = bottomLeft;
                        let _e645 = squareSize;
                        let _e653 = bottomLeft;
                        let _e655 = squareSize;
                        rnd = (sin(((floor((_e643.x / _e645)) * 78f) + 4f)) * sin(((floor((_e653.y / _e655)) * 45f) + 44f)));
                        let _e665 = rnd;
                        if (fract((_e665 * 10f)) < 0.1f) {
                            {
                                square = true;
                            }
                        }
                    }
                }
            }
            let _e672 = solidSurface;
            let _e673 = square;
            let _e675 = squareCenter;
            let _e678 = surfaceWidth;
            let _e682 = squareCenter;
            let _e685 = surfaceHeight;
            triangles = ((_e672 || _e673) && ((abs(_e675.x) < (_e678 / 2f)) && (abs(_e682.y) < (_e685 / 2f))));
            triangleIntersection = vec3<f32>(100000000000000000000f, 100000000000000000000f, 100000000000000000000f);
            frameDistVec = vec4<f32>(0f, 0f, 0f, 1000000000f);
            {
                let _e702 = p;
                origin = _e702;
                let _e704 = bottomLeft;
                p_1 = _e704;
                let _e706 = squareSize;
                step_1 = _e706;
                let _e708 = step_1;
                s_3 = vec2<f32>(_e708, 0f);
                let _e712 = p_1;
                let _e713 = s_3;
                p11_ = (_e712 + _e713.xx);
                let _e717 = heightMap;
                if _e717 {
                    let _e718 = p_1;
                    let _e722 = global.U[0];
                    let _e725 = p_1;
                    let _e734 = textureSample(t_sourceElevation, samp, ((vec2<f32>((_e718.x / _e722.x), _e725.y) / vec2(2f)) + vec2(0.5f)));
                    local_12 = _e734;
                } else {
                    let _e735 = p_1;
                    let _e739 = global.U[0];
                    let _e742 = p_1;
                    let _e751 = textureSample(t_source, samp, ((vec2<f32>((_e735.x / _e739.x), _e742.y) / vec2(2f)) + vec2(0.5f)));
                    local_12 = _e751;
                }
                let _e753 = local_12;
                c00_ = _e753;
                let _e755 = intensity_3;
                let _e756 = c00_;
                let _e757 = height(_e755, _e756);
                h00_ = _e757;
                let _e759 = p_1;
                let _e760 = h00_;
                A = vec3<f32>(_e759.x, _e759.y, _e760);
                let _e765 = heightMap;
                if _e765 {
                    let _e766 = p_1;
                    let _e767 = s_3;
                    let _e772 = global.U[0];
                    let _e775 = p_1;
                    let _e776 = s_3;
                    let _e786 = textureSample(t_sourceElevation, samp, ((vec2<f32>(((_e766 + _e767).x / _e772.x), (_e775 + _e776).y) / vec2(2f)) + vec2(0.5f)));
                    local_13 = _e786;
                } else {
                    let _e787 = p_1;
                    let _e788 = s_3;
                    let _e793 = global.U[0];
                    let _e796 = p_1;
                    let _e797 = s_3;
                    let _e807 = textureSample(t_source, samp, ((vec2<f32>(((_e787 + _e788).x / _e793.x), (_e796 + _e797).y) / vec2(2f)) + vec2(0.5f)));
                    local_13 = _e807;
                }
                let _e809 = local_13;
                c10_ = _e809;
                let _e811 = intensity_3;
                let _e812 = c10_;
                let _e813 = height(_e811, _e812);
                h10_ = _e813;
                let _e815 = p_1;
                let _e816 = s_3;
                let _e817 = (_e815 + _e816);
                let _e818 = h10_;
                B = vec3<f32>(_e817.x, _e817.y, _e818);
                let _e823 = heightMap;
                if _e823 {
                    let _e824 = p_1;
                    let _e825 = s_3;
                    let _e831 = global.U[0];
                    let _e834 = p_1;
                    let _e835 = s_3;
                    let _e846 = textureSample(t_sourceElevation, samp, ((vec2<f32>(((_e824 + _e825.yx).x / _e831.x), (_e834 + _e835.yx).y) / vec2(2f)) + vec2(0.5f)));
                    local_14 = _e846;
                } else {
                    let _e847 = p_1;
                    let _e848 = s_3;
                    let _e854 = global.U[0];
                    let _e857 = p_1;
                    let _e858 = s_3;
                    let _e869 = textureSample(t_source, samp, ((vec2<f32>(((_e847 + _e848.yx).x / _e854.x), (_e857 + _e858.yx).y) / vec2(2f)) + vec2(0.5f)));
                    local_14 = _e869;
                }
                let _e871 = local_14;
                c01_ = _e871;
                let _e873 = intensity_3;
                let _e874 = c01_;
                let _e875 = height(_e873, _e874);
                h01_ = _e875;
                let _e877 = p_1;
                let _e878 = s_3;
                let _e880 = (_e877 + _e878.yx);
                let _e881 = h01_;
                C = vec3<f32>(_e880.x, _e880.y, _e881);
                let _e886 = heightMap;
                if _e886 {
                    let _e887 = p11_;
                    let _e891 = global.U[0];
                    let _e894 = p11_;
                    let _e903 = textureSample(t_sourceElevation, samp, ((vec2<f32>((_e887.x / _e891.x), _e894.y) / vec2(2f)) + vec2(0.5f)));
                    local_15 = _e903;
                } else {
                    let _e904 = p11_;
                    let _e908 = global.U[0];
                    let _e911 = p11_;
                    let _e920 = textureSample(t_source, samp, ((vec2<f32>((_e904.x / _e908.x), _e911.y) / vec2(2f)) + vec2(0.5f)));
                    local_15 = _e920;
                }
                let _e922 = local_15;
                c11_ = _e922;
                let _e924 = intensity_3;
                let _e925 = c11_;
                let _e926 = height(_e924, _e925);
                h11_ = _e926;
                let _e928 = p11_;
                let _e929 = h11_;
                D_2 = vec3<f32>(_e928.x, _e928.y, _e929);
                let _e934 = triangles;
                if _e934 {
                    {
                        let _e935 = h10_;
                        let _e936 = h00_;
                        let _e938 = step_1;
                        dzx1_ = ((_e935 - _e936) / _e938);
                        let _e941 = h01_;
                        let _e942 = h00_;
                        let _e944 = step_1;
                        dzy1_ = ((_e941 - _e942) / _e944);
                        let _e947 = h00_;
                        let _e948 = origin;
                        let _e951 = origin;
                        let _e953 = p_1;
                        let _e956 = dzx1_;
                        let _e959 = origin;
                        let _e961 = p_1;
                        let _e964 = dzy1_;
                        let _e967 = dir_2;
                        let _e969 = dir_2;
                        let _e971 = dzx1_;
                        let _e974 = dir_2;
                        let _e976 = dzy1_;
                        k1_1 = ((((_e947 - _e948.z) + ((_e951.x - _e953.x) * _e956)) + ((_e959.y - _e961.y) * _e964)) / ((_e967.z - (_e969.x * _e971)) - (_e974.y * _e976)));
                        let _e981 = h01_;
                        let _e982 = h11_;
                        let _e985 = step_1;
                        dzx2_ = (-((_e981 - _e982)) / _e985);
                        let _e988 = h10_;
                        let _e989 = h11_;
                        let _e992 = step_1;
                        dzy2_ = (-((_e988 - _e989)) / _e992);
                        let _e995 = h11_;
                        let _e996 = origin;
                        let _e999 = origin;
                        let _e1001 = p11_;
                        let _e1004 = dzx2_;
                        let _e1007 = origin;
                        let _e1009 = p11_;
                        let _e1012 = dzy2_;
                        let _e1015 = dir_2;
                        let _e1017 = dir_2;
                        let _e1019 = dzx2_;
                        let _e1022 = dir_2;
                        let _e1024 = dzy2_;
                        k2_1 = ((((_e995 - _e996.z) + ((_e999.x - _e1001.x) * _e1004)) + ((_e1007.y - _e1009.y) * _e1012)) / ((_e1015.z - (_e1017.x * _e1019)) - (_e1022.y * _e1024)));
                        let _e1029 = k1_1;
                        if (_e1029 > 0f) {
                            {
                                let _e1032 = origin;
                                let _e1033 = k1_1;
                                let _e1034 = dir_2;
                                intersection = (_e1032 + (_e1033 * _e1034));
                                let _e1038 = intersection;
                                let _e1040 = p_1;
                                relInt = (_e1038.xy - _e1040.xy);
                                let _e1044 = relInt;
                                let _e1048 = relInt;
                                let _e1050 = step_1;
                                let _e1053 = relInt;
                                let _e1058 = relInt;
                                let _e1060 = step_1;
                                let _e1063 = step_1;
                                let _e1064 = relInt;
                                let _e1067 = relInt;
                                if (((((_e1044.x >= 0f) && (_e1048.x <= _e1050)) && (_e1053.y >= 0f)) && (_e1058.y <= _e1060)) && ((_e1063 - _e1064.x) >= _e1067.y)) {
                                    {
                                        let _e1071 = intersection;
                                        triangleIntersection = _e1071;
                                    }
                                }
                            }
                        }
                        let _e1072 = k2_1;
                        if (_e1072 > 0f) {
                            {
                                let _e1075 = origin;
                                let _e1076 = k2_1;
                                let _e1077 = dir_2;
                                intersection_1 = (_e1075 + (_e1076 * _e1077));
                                let _e1081 = intersection_1;
                                let _e1083 = p_1;
                                relInt_1 = (_e1081.xy - _e1083.xy);
                                let _e1087 = relInt_1;
                                let _e1091 = relInt_1;
                                let _e1093 = step_1;
                                let _e1096 = relInt_1;
                                let _e1101 = relInt_1;
                                let _e1103 = step_1;
                                let _e1106 = step_1;
                                let _e1107 = relInt_1;
                                let _e1110 = relInt_1;
                                if (((((_e1087.x >= 0f) && (_e1091.x <= _e1093)) && (_e1096.y >= 0f)) && (_e1101.y <= _e1103)) && ((_e1106 - _e1107.x) <= _e1110.y)) {
                                    {
                                        let _e1114 = intersection_1;
                                        triangleIntersection = _e1114;
                                    }
                                }
                            }
                        }
                    }
                }
                let _e1115 = origin;
                let _e1117 = dir_2;
                inf = (_e1115 + (1000000f * _e1117));
                let _e1121 = surfaceWidth;
                W = ((_e1121 / 2f) + 0.00001f);
                let _e1127 = surfaceHeight;
                H = ((_e1127 / 2f) + 0.00001f);
                let _e1133 = horizontals;
                if _e1133 {
                    {
                        let _e1134 = origin;
                        let _e1135 = inf;
                        let _e1136 = A;
                        let _e1137 = B;
                        let _e1138 = cameraPos_2;
                        let _e1139 = dir_2;
                        let _e1140 = distSegSegZ(_e1134, _e1135, _e1136, _e1137, _e1138, _e1139);
                        fdAB = _e1140;
                        let _e1142 = p_1;
                        let _e1144 = H;
                        let _e1147 = p_1;
                        let _e1149 = H;
                        let _e1153 = p11_;
                        let _e1155 = H;
                        let _e1158 = fdAB;
                        let _e1160 = frameDistVec;
                        if ((((_e1142.y >= -(_e1144)) && (_e1147.x >= -(_e1149))) && (_e1153.x <= _e1155)) && (_e1158.w < _e1160.w)) {
                            let _e1164 = fdAB;
                            frameDistVec = _e1164;
                        }
                        let _e1165 = origin;
                        let _e1166 = inf;
                        let _e1167 = C;
                        let _e1168 = D_2;
                        let _e1169 = cameraPos_2;
                        let _e1170 = dir_2;
                        let _e1171 = distSegSegZ(_e1165, _e1166, _e1167, _e1168, _e1169, _e1170);
                        fdCD = _e1171;
                        let _e1173 = p11_;
                        let _e1175 = H;
                        let _e1177 = p_1;
                        let _e1179 = H;
                        let _e1183 = p11_;
                        let _e1185 = H;
                        let _e1188 = fdCD;
                        let _e1190 = frameDistVec;
                        if ((((_e1173.y <= _e1175) && (_e1177.x >= -(_e1179))) && (_e1183.x <= _e1185)) && (_e1188.w < _e1190.w)) {
                            let _e1194 = fdCD;
                            frameDistVec = _e1194;
                        }
                    }
                }
                let _e1195 = verticals;
                if _e1195 {
                    {
                        let _e1196 = origin;
                        let _e1197 = inf;
                        let _e1198 = A;
                        let _e1199 = C;
                        let _e1200 = cameraPos_2;
                        let _e1201 = dir_2;
                        let _e1202 = distSegSegZ(_e1196, _e1197, _e1198, _e1199, _e1200, _e1201);
                        fdAC = _e1202;
                        let _e1204 = p_1;
                        let _e1206 = H;
                        let _e1209 = p_1;
                        let _e1211 = H;
                        let _e1215 = p11_;
                        let _e1217 = H;
                        let _e1220 = fdAC;
                        let _e1222 = frameDistVec;
                        if ((((_e1204.x >= -(_e1206)) && (_e1209.y >= -(_e1211))) && (_e1215.y <= _e1217)) && (_e1220.w < _e1222.w)) {
                            let _e1226 = fdAC;
                            frameDistVec = _e1226;
                        }
                        let _e1227 = origin;
                        let _e1228 = inf;
                        let _e1229 = B;
                        let _e1230 = D_2;
                        let _e1231 = cameraPos_2;
                        let _e1232 = dir_2;
                        let _e1233 = distSegSegZ(_e1227, _e1228, _e1229, _e1230, _e1231, _e1232);
                        fdBD = _e1233;
                        let _e1235 = p11_;
                        let _e1237 = H;
                        let _e1239 = p_1;
                        let _e1241 = H;
                        let _e1245 = p11_;
                        let _e1247 = H;
                        let _e1250 = fdBD;
                        let _e1252 = frameDistVec;
                        if ((((_e1235.x <= _e1237) && (_e1239.y >= -(_e1241))) && (_e1245.y <= _e1247)) && (_e1250.w < _e1252.w)) {
                            let _e1256 = fdBD;
                            frameDistVec = _e1256;
                        }
                    }
                }
            }
            let _e1257 = frameDistVec;
            let _e1258 = _e1257.xyz;
            let _e1259 = triangleIntersection;
            let _e1260 = frameDistVec;
            let _e1264 = vec3<f32>(_e1260.w, 0f, 0f);
            inters = mat3x3<f32>(vec3<f32>(_e1258.x, _e1258.y, _e1258.z), vec3<f32>(_e1259.x, _e1259.y, _e1259.z), vec3<f32>(_e1264.x, _e1264.y, _e1264.z));
            let _e1279 = square;
            let _e1282 = inters[1];
            if (_e1279 && (_e1282.x != 100000000000000000000f)) {
                local_16 = 0f;
            } else {
                let _e1290 = inters[2];
                local_16 = _e1290.x;
            }
            let _e1293 = local_16;
            intersDist = _e1293;
            let _e1294 = intersDist;
            let _e1295 = frameDist;
            if (_e1294 < _e1295) {
                {
                    let _e1297 = intersDist;
                    frameDist = _e1297;
                    let _e1298 = underlyingColor;
                    if (_e1298 > 0f) {
                        {
                            let _e1301 = colorLines_1;
                            let _e1304 = inters[0];
                            let _e1309 = global.U[0];
                            let _e1314 = inters[0];
                            let _e1324 = textureSample(t_source, samp, ((vec2<f32>((_e1304.x / _e1309.x), _e1314.y) / vec2(2f)) + vec2(0.5f)));
                            let _e1325 = underlyingColor;
                            currentColor = mix(_e1301, _e1324, vec4(_e1325));
                            let _e1329 = currentColor;
                            let _e1332 = frameColor;
                            if (length(_e1329.xyz) > length(_e1332.xyz)) {
                                let _e1336 = frameColor;
                                let _e1338 = currentColor;
                                let _e1339 = _e1338.xyz;
                                frameColor.x = _e1339.x;
                                frameColor.y = _e1339.y;
                                frameColor.z = _e1339.z;
                            }
                        }
                    }
                    let _e1346 = square;
                    let _e1349 = inters[1];
                    if (_e1346 && (_e1349.x != 100000000000000000000f)) {
                        break;
                    }
                }
            }
            let _e1354 = intersDist;
            let _e1355 = th;
            if (_e1354 < _e1355) {
                break;
            } else {
                let _e1357 = glow_1;
                if (_e1357 > 0f) {
                    {
                        let _e1360 = glowAcc;
                        let _e1362 = th;
                        let _e1363 = intersDist;
                        let _e1366 = glow_1;
                        let _e1372 = th;
                        let _e1374 = glow_1;
                        let _e1377 = th;
                        let _e1378 = intersDist;
                        glowAcc = (_e1360 + ((1f * pow((_e1362 / _e1363), (1f - (_e1366 * 0.75f)))) * smoothstep((_e1372 + (0.1f * _e1374)), _e1377, _e1378)));
                    }
                }
            }
            let _e1382 = solidSurface;
            let _e1385 = inters[1];
            if (_e1382 && (_e1385.x != 100000000000000000000f)) {
                break;
            }
            let _e1390 = squareCenter;
            let _e1392 = nextLines;
            next = (_e1390.xy + _e1392);
            let _e1395 = next;
            let _e1396 = p;
            let _e1399 = dir_2;
            deltaK = ((_e1395 - _e1396.xy) / _e1399.xy);
            let _e1403 = deltaK;
            let _e1405 = deltaK;
            minK = min(_e1403.x, _e1405.y);
            let _e1409 = k;
            let _e1410 = minK;
            k = (_e1409 + _e1410);
            let _e1412 = p;
            let _e1413 = minK;
            let _e1414 = dir_2;
            p = (_e1412 + (_e1413 * _e1414));
            let _e1417 = maxIter;
            maxIter = (_e1417 - 1i);
        }
    }
    let _e1420 = color_2;
    let _e1421 = outColor;
    let _e1422 = _e1421.xyz;
    let _e1423 = color_2;
    let _e1429 = outColor;
    outColor = mix(_e1420, vec4<f32>(_e1422.x, _e1422.y, _e1422.z, _e1423.w), vec4(_e1429.w));
    let _e1433 = frameDist;
    let _e1434 = th;
    if (_e1433 < _e1434) {
        local_17 = 1f;
    } else {
        let _e1437 = glowAcc;
        local_17 = clamp(_e1437, 0f, 1f);
    }
    let _e1442 = local_17;
    frameK = _e1442;
    let _e1444 = outColor;
    let _e1445 = frameColor;
    let _e1446 = frameK;
    outColor = mix(_e1444, _e1445, vec4(_e1446));
    let _e1449 = colorFog_1;
    if (_e1449.w != 0f) {
        {
            let _e1455 = colorFog_1;
            nearDist = (2f * (1f - _e1455.w));
            let _e1461 = nearDist;
            farDist = (2f * _e1461);
            let _e1464 = nearDist;
            let _e1465 = farDist;
            let _e1466 = cameraPos_2;
            let _e1467 = triangleIntersection;
            kFog = smoothstep(_e1464, _e1465, length((_e1466 - _e1467)));
            let _e1472 = outColor;
            let _e1474 = outColor;
            let _e1476 = colorFog_1;
            let _e1478 = kFog;
            let _e1480 = mix(_e1474.xyz, _e1476.xyz, vec3(_e1478));
            outColor.x = _e1480.x;
            outColor.y = _e1480.y;
            outColor.z = _e1480.z;
        }
    }
    let _e1487 = outColor;
    return _e1487;
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
    let _e68 = global.U[9];
    let _e72 = global.U[10];
    let _e77 = global.U[11];
    let _e82 = global.U[12];
    let _e86 = global.U[13];
    let _e90 = global.U[14];
    let _e93 = global.U[15];
    let _e96 = global.U[16];
    let _e99 = global.U[17];
    let _e123 = global.U[4];
    let _e127 = global.U[5];
    let _e131 = global.U[6];
    let _e136 = global.U[7];
    let _e141 = global.U[18];
    let _e146 = global.U[19];
    let _e149 = global.U[20];
    let _e152 = global.U[21];
    let _e153 = wireframe((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e11.x, _e11.y, _e11.z), vec3<f32>(_e15.x, _e15.y, _e15.z), vec3<f32>(_e19.x, _e19.y, _e19.z))) * vec3<f32>(_e46.x, _e46.y, 1f)).xy, (((_e53 - vec2(0.5f)) * 2f) * vec2<f32>(_e61.x, 1f)), _e68.x, i32(_e72.x), i32(_e77.x), _e82.x, _e86.x, mat4x4<f32>(vec4<f32>(_e90.x, _e90.y, _e90.z, _e90.w), vec4<f32>(_e93.x, _e93.y, _e93.z, _e93.w), vec4<f32>(_e96.x, _e96.y, _e96.z, _e96.w), vec4<f32>(_e99.x, _e99.y, _e99.z, _e99.w)), _e123.xy, _e127.xy, i32(_e131.x), i32(_e136.x), i32(_e141.x), _e146, _e149, _e152);
    fragColor = _e153;
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
