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
                let _e302 = textureSampleLevel(t_sourceBkg, samp, ((vec2<f32>((_e285.x / _e289.x), _e292.y) / vec2(2f)) + vec2(0.5f)), 0f);
                local_5 = _e302;
            } else {
                let _e303 = colorBkg_1;
                local_5 = _e303;
            }
            let _e305 = local_5;
            local_6 = _e305;
        }
        let _e307 = local_6;
        return _e307;
    }
    let _e308 = k1_;
    k = _e308;
    let _e310 = cameraPos_2;
    let _e311 = k;
    let _e312 = dir_2;
    p = (_e310 + (_e311 * _e312));
    let _e316 = colorFog_1;
    if (_e316.w != 0f) {
        let _e320 = colorFog_1;
        let _e321 = _e320.xyz;
        local_8 = vec4<f32>(_e321.x, _e321.y, _e321.z, 1f);
    } else {
        let _e327 = sourceBkg_specified_1;
        if (_e327 == 1i) {
            let _e330 = outPos_1;
            let _e334 = global.U[0];
            let _e337 = outPos_1;
            let _e347 = textureSampleLevel(t_sourceBkg, samp, ((vec2<f32>((_e330.x / _e334.x), _e337.y) / vec2(2f)) + vec2(0.5f)), 0f);
            local_7 = _e347;
        } else {
            let _e348 = colorBkg_1;
            local_7 = _e348;
        }
        let _e350 = local_7;
        local_8 = _e350;
    }
    let _e352 = local_8;
    color_2 = _e352;
    let _e373 = dir_2;
    let _e376 = squareSize;
    nextLines = ((sign(_e373.xy) * _e376) / vec2(2f));
    let _e387 = thickness_1;
    let _e389 = cameraPos_2;
    th = ((0.01f * _e387) / length(_e389));
    let _e395 = transparencyMode_1;
    transparentToBackground = (_e395 == 0i);
    let _e399 = transparentToBackground;
    if _e399 {
        local_9 = 0f;
    } else {
        let _e402 = colorLines_1;
        local_9 = (1f - _e402.w);
    }
    let _e406 = local_9;
    underlyingColor = _e406;
    let _e408 = transparentToBackground;
    if _e408 {
        let _e409 = color_2;
        let _e411 = colorLines_1;
        let _e413 = colorLines_1;
        let _e416 = mix(_e409.xyz, _e411.xyz, vec3(_e413.w));
        let _e417 = color_2;
        local_11 = vec4<f32>(_e416.x, _e416.y, _e416.z, _e417.w);
    } else {
        let _e423 = underlyingColor;
        if (_e423 == 0f) {
            let _e426 = colorLines_1;
            local_10 = _e426;
        } else {
            local_10 = vec4<f32>(0f, 0f, 0f, 1f);
        }
        let _e433 = local_10;
        local_11 = _e433;
    }
    let _e435 = local_11;
    frameColor = _e435;
    let _e443 = mode_1;
    if (_e443 == 1i) {
        verticals = false;
    } else {
        let _e447 = mode_1;
        if (_e447 == 2i) {
            horizontals = false;
        } else {
            let _e451 = mode_1;
            if (_e451 == 3i) {
                solidSurface = false;
            } else {
                let _e455 = mode_1;
                if (_e455 == 4i) {
                    {
                        solidSurface = false;
                        verticals = false;
                    }
                } else {
                    let _e460 = mode_1;
                    if (_e460 == 5i) {
                        {
                            solidSurface = false;
                            horizontals = false;
                        }
                    } else {
                        let _e465 = mode_1;
                        if (_e465 == 7i) {
                            {
                                solidSurface = false;
                            }
                        } else {
                            let _e469 = mode_1;
                            if (_e469 == 8i) {
                                {
                                }
                            } else {
                                let _e472 = mode_1;
                                if (_e472 == 9i) {
                                    {
                                        verticals = false;
                                    }
                                } else {
                                    let _e476 = mode_1;
                                    if (_e476 == 10i) {
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
        let _e480 = intersected;
        let _e483 = k;
        let _e484 = k2_;
        let _e487 = maxIter;
        if !((((_e480 < 1f) && (_e483 <= _e484)) && (_e487 > 0i))) {
            break;
        }
        {
            let _e492 = p;
            let _e494 = surfaceWidth;
            let _e498 = squareSize;
            indexX = ((_e492.x + (_e494 / 2f)) / _e498);
            let _e501 = p;
            let _e503 = surfaceHeight;
            let _e507 = squareSize;
            indexY = ((_e501.y + (_e503 / 2f)) / _e507);
            let _e510 = indexX;
            fX = fract(_e510);
            let _e513 = indexY;
            fY = fract(_e513);
            let _e517 = fX;
            let _e520 = dir_2;
            if ((_e517 > 0.9999f) && (_e520.x > 0f)) {
                let _e526 = indexX;
                let _e530 = squareSize;
                squareCenter.x = ((ceil(_e526) + 0.5f) * _e530);
            } else {
                let _e532 = fX;
                let _e535 = dir_2;
                if ((_e532 < 0.0001f) && (_e535.x < 0f)) {
                    let _e541 = indexX;
                    let _e545 = squareSize;
                    squareCenter.x = ((floor(_e541) - 0.5f) * _e545);
                } else {
                    let _e548 = indexX;
                    let _e552 = squareSize;
                    squareCenter.x = ((floor(_e548) + 0.5f) * _e552);
                }
            }
            let _e555 = squareCenter;
            let _e557 = surfaceWidth;
            squareCenter.x = (_e555.x - (_e557 / 2f));
            let _e561 = fY;
            let _e564 = dir_2;
            if ((_e561 > 0.9999f) && (_e564.y > 0f)) {
                let _e570 = indexY;
                let _e574 = squareSize;
                squareCenter.y = ((ceil(_e570) + 0.5f) * _e574);
            } else {
                let _e576 = fY;
                let _e579 = dir_2;
                if ((_e576 < 0.0001f) && (_e579.y < 0f)) {
                    let _e585 = indexY;
                    let _e589 = squareSize;
                    squareCenter.y = ((floor(_e585) - 0.5f) * _e589);
                } else {
                    let _e592 = indexY;
                    let _e596 = squareSize;
                    squareCenter.y = ((floor(_e592) + 0.5f) * _e596);
                }
            }
            let _e599 = squareCenter;
            let _e601 = surfaceHeight;
            squareCenter.y = (_e599.y - (_e601 / 2f));
            let _e605 = squareCenter;
            let _e606 = squareSize;
            let _e607 = squareSize;
            bottomLeft = (_e605 - (vec2<f32>(_e606, _e607) / vec2(2f)));
            square = false;
            let _e616 = mode_1;
            let _e619 = mode_1;
            if ((_e616 == 6i) || (_e619 == 7i)) {
                {
                    let _e623 = bottomLeft;
                    let _e625 = squareSize;
                    let _e628 = bottomLeft;
                    let _e630 = squareSize;
                    let _e633 = (floor((_e623.x / _e625)) + floor((_e628.y / _e630)));
                    if ((_e633 - (floor((_e633 / 2f)) * 2f)) == 0f) {
                        square = true;
                    }
                }
            } else {
                let _e642 = mode_1;
                if (_e642 >= 8i) {
                    {
                        let _e645 = bottomLeft;
                        let _e647 = squareSize;
                        let _e655 = bottomLeft;
                        let _e657 = squareSize;
                        rnd = (sin(((floor((_e645.x / _e647)) * 78f) + 4f)) * sin(((floor((_e655.y / _e657)) * 45f) + 44f)));
                        let _e667 = rnd;
                        if (fract((_e667 * 10f)) < 0.1f) {
                            {
                                square = true;
                            }
                        }
                    }
                }
            }
            let _e674 = solidSurface;
            let _e675 = square;
            let _e677 = squareCenter;
            let _e680 = surfaceWidth;
            let _e684 = squareCenter;
            let _e687 = surfaceHeight;
            triangles = ((_e674 || _e675) && ((abs(_e677.x) < (_e680 / 2f)) && (abs(_e684.y) < (_e687 / 2f))));
            triangleIntersection = vec3<f32>(100000000000000000000f, 100000000000000000000f, 100000000000000000000f);
            frameDistVec = vec4<f32>(0f, 0f, 0f, 1000000000f);
            {
                let _e704 = p;
                origin = _e704;
                let _e706 = bottomLeft;
                p_1 = _e706;
                let _e708 = squareSize;
                step_1 = _e708;
                let _e710 = step_1;
                s_3 = vec2<f32>(_e710, 0f);
                let _e714 = p_1;
                let _e715 = s_3;
                p11_ = (_e714 + _e715.xx);
                let _e719 = heightMap;
                if _e719 {
                    let _e720 = p_1;
                    let _e724 = global.U[0];
                    let _e727 = p_1;
                    let _e737 = textureSampleLevel(t_sourceElevation, samp, ((vec2<f32>((_e720.x / _e724.x), _e727.y) / vec2(2f)) + vec2(0.5f)), 0f);
                    local_12 = _e737;
                } else {
                    let _e738 = p_1;
                    let _e742 = global.U[0];
                    let _e745 = p_1;
                    let _e755 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e738.x / _e742.x), _e745.y) / vec2(2f)) + vec2(0.5f)), 0f);
                    local_12 = _e755;
                }
                let _e757 = local_12;
                c00_ = _e757;
                let _e759 = intensity_3;
                let _e760 = c00_;
                let _e761 = height(_e759, _e760);
                h00_ = _e761;
                let _e763 = p_1;
                let _e764 = h00_;
                A = vec3<f32>(_e763.x, _e763.y, _e764);
                let _e769 = heightMap;
                if _e769 {
                    let _e770 = p_1;
                    let _e771 = s_3;
                    let _e776 = global.U[0];
                    let _e779 = p_1;
                    let _e780 = s_3;
                    let _e791 = textureSampleLevel(t_sourceElevation, samp, ((vec2<f32>(((_e770 + _e771).x / _e776.x), (_e779 + _e780).y) / vec2(2f)) + vec2(0.5f)), 0f);
                    local_13 = _e791;
                } else {
                    let _e792 = p_1;
                    let _e793 = s_3;
                    let _e798 = global.U[0];
                    let _e801 = p_1;
                    let _e802 = s_3;
                    let _e813 = textureSampleLevel(t_source, samp, ((vec2<f32>(((_e792 + _e793).x / _e798.x), (_e801 + _e802).y) / vec2(2f)) + vec2(0.5f)), 0f);
                    local_13 = _e813;
                }
                let _e815 = local_13;
                c10_ = _e815;
                let _e817 = intensity_3;
                let _e818 = c10_;
                let _e819 = height(_e817, _e818);
                h10_ = _e819;
                let _e821 = p_1;
                let _e822 = s_3;
                let _e823 = (_e821 + _e822);
                let _e824 = h10_;
                B = vec3<f32>(_e823.x, _e823.y, _e824);
                let _e829 = heightMap;
                if _e829 {
                    let _e830 = p_1;
                    let _e831 = s_3;
                    let _e837 = global.U[0];
                    let _e840 = p_1;
                    let _e841 = s_3;
                    let _e853 = textureSampleLevel(t_sourceElevation, samp, ((vec2<f32>(((_e830 + _e831.yx).x / _e837.x), (_e840 + _e841.yx).y) / vec2(2f)) + vec2(0.5f)), 0f);
                    local_14 = _e853;
                } else {
                    let _e854 = p_1;
                    let _e855 = s_3;
                    let _e861 = global.U[0];
                    let _e864 = p_1;
                    let _e865 = s_3;
                    let _e877 = textureSampleLevel(t_source, samp, ((vec2<f32>(((_e854 + _e855.yx).x / _e861.x), (_e864 + _e865.yx).y) / vec2(2f)) + vec2(0.5f)), 0f);
                    local_14 = _e877;
                }
                let _e879 = local_14;
                c01_ = _e879;
                let _e881 = intensity_3;
                let _e882 = c01_;
                let _e883 = height(_e881, _e882);
                h01_ = _e883;
                let _e885 = p_1;
                let _e886 = s_3;
                let _e888 = (_e885 + _e886.yx);
                let _e889 = h01_;
                C = vec3<f32>(_e888.x, _e888.y, _e889);
                let _e894 = heightMap;
                if _e894 {
                    let _e895 = p11_;
                    let _e899 = global.U[0];
                    let _e902 = p11_;
                    let _e912 = textureSampleLevel(t_sourceElevation, samp, ((vec2<f32>((_e895.x / _e899.x), _e902.y) / vec2(2f)) + vec2(0.5f)), 0f);
                    local_15 = _e912;
                } else {
                    let _e913 = p11_;
                    let _e917 = global.U[0];
                    let _e920 = p11_;
                    let _e930 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e913.x / _e917.x), _e920.y) / vec2(2f)) + vec2(0.5f)), 0f);
                    local_15 = _e930;
                }
                let _e932 = local_15;
                c11_ = _e932;
                let _e934 = intensity_3;
                let _e935 = c11_;
                let _e936 = height(_e934, _e935);
                h11_ = _e936;
                let _e938 = p11_;
                let _e939 = h11_;
                D_2 = vec3<f32>(_e938.x, _e938.y, _e939);
                let _e944 = triangles;
                if _e944 {
                    {
                        let _e945 = h10_;
                        let _e946 = h00_;
                        let _e948 = step_1;
                        dzx1_ = ((_e945 - _e946) / _e948);
                        let _e951 = h01_;
                        let _e952 = h00_;
                        let _e954 = step_1;
                        dzy1_ = ((_e951 - _e952) / _e954);
                        let _e957 = h00_;
                        let _e958 = origin;
                        let _e961 = origin;
                        let _e963 = p_1;
                        let _e966 = dzx1_;
                        let _e969 = origin;
                        let _e971 = p_1;
                        let _e974 = dzy1_;
                        let _e977 = dir_2;
                        let _e979 = dir_2;
                        let _e981 = dzx1_;
                        let _e984 = dir_2;
                        let _e986 = dzy1_;
                        k1_1 = ((((_e957 - _e958.z) + ((_e961.x - _e963.x) * _e966)) + ((_e969.y - _e971.y) * _e974)) / ((_e977.z - (_e979.x * _e981)) - (_e984.y * _e986)));
                        let _e991 = h01_;
                        let _e992 = h11_;
                        let _e995 = step_1;
                        dzx2_ = (-((_e991 - _e992)) / _e995);
                        let _e998 = h10_;
                        let _e999 = h11_;
                        let _e1002 = step_1;
                        dzy2_ = (-((_e998 - _e999)) / _e1002);
                        let _e1005 = h11_;
                        let _e1006 = origin;
                        let _e1009 = origin;
                        let _e1011 = p11_;
                        let _e1014 = dzx2_;
                        let _e1017 = origin;
                        let _e1019 = p11_;
                        let _e1022 = dzy2_;
                        let _e1025 = dir_2;
                        let _e1027 = dir_2;
                        let _e1029 = dzx2_;
                        let _e1032 = dir_2;
                        let _e1034 = dzy2_;
                        k2_1 = ((((_e1005 - _e1006.z) + ((_e1009.x - _e1011.x) * _e1014)) + ((_e1017.y - _e1019.y) * _e1022)) / ((_e1025.z - (_e1027.x * _e1029)) - (_e1032.y * _e1034)));
                        let _e1039 = k1_1;
                        if (_e1039 > 0f) {
                            {
                                let _e1042 = origin;
                                let _e1043 = k1_1;
                                let _e1044 = dir_2;
                                intersection = (_e1042 + (_e1043 * _e1044));
                                let _e1048 = intersection;
                                let _e1050 = p_1;
                                relInt = (_e1048.xy - _e1050.xy);
                                let _e1054 = relInt;
                                let _e1058 = relInt;
                                let _e1060 = step_1;
                                let _e1063 = relInt;
                                let _e1068 = relInt;
                                let _e1070 = step_1;
                                let _e1073 = step_1;
                                let _e1074 = relInt;
                                let _e1077 = relInt;
                                if (((((_e1054.x >= 0f) && (_e1058.x <= _e1060)) && (_e1063.y >= 0f)) && (_e1068.y <= _e1070)) && ((_e1073 - _e1074.x) >= _e1077.y)) {
                                    {
                                        let _e1081 = intersection;
                                        triangleIntersection = _e1081;
                                    }
                                }
                            }
                        }
                        let _e1082 = k2_1;
                        if (_e1082 > 0f) {
                            {
                                let _e1085 = origin;
                                let _e1086 = k2_1;
                                let _e1087 = dir_2;
                                intersection_1 = (_e1085 + (_e1086 * _e1087));
                                let _e1091 = intersection_1;
                                let _e1093 = p_1;
                                relInt_1 = (_e1091.xy - _e1093.xy);
                                let _e1097 = relInt_1;
                                let _e1101 = relInt_1;
                                let _e1103 = step_1;
                                let _e1106 = relInt_1;
                                let _e1111 = relInt_1;
                                let _e1113 = step_1;
                                let _e1116 = step_1;
                                let _e1117 = relInt_1;
                                let _e1120 = relInt_1;
                                if (((((_e1097.x >= 0f) && (_e1101.x <= _e1103)) && (_e1106.y >= 0f)) && (_e1111.y <= _e1113)) && ((_e1116 - _e1117.x) <= _e1120.y)) {
                                    {
                                        let _e1124 = intersection_1;
                                        triangleIntersection = _e1124;
                                    }
                                }
                            }
                        }
                    }
                }
                let _e1125 = origin;
                let _e1127 = dir_2;
                inf = (_e1125 + (1000000f * _e1127));
                let _e1131 = surfaceWidth;
                W = ((_e1131 / 2f) + 0.00001f);
                let _e1137 = surfaceHeight;
                H = ((_e1137 / 2f) + 0.00001f);
                let _e1143 = horizontals;
                if _e1143 {
                    {
                        let _e1144 = origin;
                        let _e1145 = inf;
                        let _e1146 = A;
                        let _e1147 = B;
                        let _e1148 = cameraPos_2;
                        let _e1149 = dir_2;
                        let _e1150 = distSegSegZ(_e1144, _e1145, _e1146, _e1147, _e1148, _e1149);
                        fdAB = _e1150;
                        let _e1152 = p_1;
                        let _e1154 = H;
                        let _e1157 = p_1;
                        let _e1159 = H;
                        let _e1163 = p11_;
                        let _e1165 = H;
                        let _e1168 = fdAB;
                        let _e1170 = frameDistVec;
                        if ((((_e1152.y >= -(_e1154)) && (_e1157.x >= -(_e1159))) && (_e1163.x <= _e1165)) && (_e1168.w < _e1170.w)) {
                            let _e1174 = fdAB;
                            frameDistVec = _e1174;
                        }
                        let _e1175 = origin;
                        let _e1176 = inf;
                        let _e1177 = C;
                        let _e1178 = D_2;
                        let _e1179 = cameraPos_2;
                        let _e1180 = dir_2;
                        let _e1181 = distSegSegZ(_e1175, _e1176, _e1177, _e1178, _e1179, _e1180);
                        fdCD = _e1181;
                        let _e1183 = p11_;
                        let _e1185 = H;
                        let _e1187 = p_1;
                        let _e1189 = H;
                        let _e1193 = p11_;
                        let _e1195 = H;
                        let _e1198 = fdCD;
                        let _e1200 = frameDistVec;
                        if ((((_e1183.y <= _e1185) && (_e1187.x >= -(_e1189))) && (_e1193.x <= _e1195)) && (_e1198.w < _e1200.w)) {
                            let _e1204 = fdCD;
                            frameDistVec = _e1204;
                        }
                    }
                }
                let _e1205 = verticals;
                if _e1205 {
                    {
                        let _e1206 = origin;
                        let _e1207 = inf;
                        let _e1208 = A;
                        let _e1209 = C;
                        let _e1210 = cameraPos_2;
                        let _e1211 = dir_2;
                        let _e1212 = distSegSegZ(_e1206, _e1207, _e1208, _e1209, _e1210, _e1211);
                        fdAC = _e1212;
                        let _e1214 = p_1;
                        let _e1216 = H;
                        let _e1219 = p_1;
                        let _e1221 = H;
                        let _e1225 = p11_;
                        let _e1227 = H;
                        let _e1230 = fdAC;
                        let _e1232 = frameDistVec;
                        if ((((_e1214.x >= -(_e1216)) && (_e1219.y >= -(_e1221))) && (_e1225.y <= _e1227)) && (_e1230.w < _e1232.w)) {
                            let _e1236 = fdAC;
                            frameDistVec = _e1236;
                        }
                        let _e1237 = origin;
                        let _e1238 = inf;
                        let _e1239 = B;
                        let _e1240 = D_2;
                        let _e1241 = cameraPos_2;
                        let _e1242 = dir_2;
                        let _e1243 = distSegSegZ(_e1237, _e1238, _e1239, _e1240, _e1241, _e1242);
                        fdBD = _e1243;
                        let _e1245 = p11_;
                        let _e1247 = H;
                        let _e1249 = p_1;
                        let _e1251 = H;
                        let _e1255 = p11_;
                        let _e1257 = H;
                        let _e1260 = fdBD;
                        let _e1262 = frameDistVec;
                        if ((((_e1245.x <= _e1247) && (_e1249.y >= -(_e1251))) && (_e1255.y <= _e1257)) && (_e1260.w < _e1262.w)) {
                            let _e1266 = fdBD;
                            frameDistVec = _e1266;
                        }
                    }
                }
            }
            let _e1267 = frameDistVec;
            let _e1268 = _e1267.xyz;
            let _e1269 = triangleIntersection;
            let _e1270 = frameDistVec;
            let _e1274 = vec3<f32>(_e1270.w, 0f, 0f);
            inters = mat3x3<f32>(vec3<f32>(_e1268.x, _e1268.y, _e1268.z), vec3<f32>(_e1269.x, _e1269.y, _e1269.z), vec3<f32>(_e1274.x, _e1274.y, _e1274.z));
            let _e1289 = square;
            let _e1292 = inters[1];
            if (_e1289 && (_e1292.x != 100000000000000000000f)) {
                local_16 = 0f;
            } else {
                let _e1300 = inters[2];
                local_16 = _e1300.x;
            }
            let _e1303 = local_16;
            intersDist = _e1303;
            let _e1304 = intersDist;
            let _e1305 = frameDist;
            if (_e1304 < _e1305) {
                {
                    let _e1307 = intersDist;
                    frameDist = _e1307;
                    let _e1308 = underlyingColor;
                    if (_e1308 > 0f) {
                        {
                            let _e1311 = colorLines_1;
                            let _e1314 = inters[0];
                            let _e1319 = global.U[0];
                            let _e1324 = inters[0];
                            let _e1335 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e1314.x / _e1319.x), _e1324.y) / vec2(2f)) + vec2(0.5f)), 0f);
                            let _e1336 = underlyingColor;
                            currentColor = mix(_e1311, _e1335, vec4(_e1336));
                            let _e1340 = currentColor;
                            let _e1343 = frameColor;
                            if (length(_e1340.xyz) > length(_e1343.xyz)) {
                                let _e1347 = frameColor;
                                let _e1349 = currentColor;
                                let _e1350 = _e1349.xyz;
                                frameColor.x = _e1350.x;
                                frameColor.y = _e1350.y;
                                frameColor.z = _e1350.z;
                            }
                        }
                    }
                    let _e1357 = square;
                    let _e1360 = inters[1];
                    if (_e1357 && (_e1360.x != 100000000000000000000f)) {
                        break;
                    }
                }
            }
            let _e1365 = intersDist;
            let _e1366 = th;
            if (_e1365 < _e1366) {
                break;
            } else {
                let _e1368 = glow_1;
                if (_e1368 > 0f) {
                    {
                        let _e1371 = glowAcc;
                        let _e1373 = th;
                        let _e1374 = intersDist;
                        let _e1377 = glow_1;
                        let _e1383 = th;
                        let _e1385 = glow_1;
                        let _e1388 = th;
                        let _e1389 = intersDist;
                        glowAcc = (_e1371 + ((1f * pow((_e1373 / _e1374), (1f - (_e1377 * 0.75f)))) * smoothstep((_e1383 + (0.1f * _e1385)), _e1388, _e1389)));
                    }
                }
            }
            let _e1393 = solidSurface;
            let _e1396 = inters[1];
            if (_e1393 && (_e1396.x != 100000000000000000000f)) {
                break;
            }
            let _e1401 = squareCenter;
            let _e1403 = nextLines;
            next = (_e1401.xy + _e1403);
            let _e1406 = next;
            let _e1407 = p;
            let _e1410 = dir_2;
            deltaK = ((_e1406 - _e1407.xy) / _e1410.xy);
            let _e1414 = deltaK;
            let _e1416 = deltaK;
            minK = min(_e1414.x, _e1416.y);
            let _e1420 = k;
            let _e1421 = minK;
            k = (_e1420 + _e1421);
            let _e1423 = p;
            let _e1424 = minK;
            let _e1425 = dir_2;
            p = (_e1423 + (_e1424 * _e1425));
            let _e1428 = maxIter;
            maxIter = (_e1428 - 1i);
        }
    }
    let _e1431 = color_2;
    let _e1432 = outColor;
    let _e1433 = _e1432.xyz;
    let _e1434 = color_2;
    let _e1440 = outColor;
    outColor = mix(_e1431, vec4<f32>(_e1433.x, _e1433.y, _e1433.z, _e1434.w), vec4(_e1440.w));
    let _e1444 = frameDist;
    let _e1445 = th;
    if (_e1444 < _e1445) {
        local_17 = 1f;
    } else {
        let _e1448 = glowAcc;
        local_17 = clamp(_e1448, 0f, 1f);
    }
    let _e1453 = local_17;
    frameK = _e1453;
    let _e1455 = outColor;
    let _e1456 = frameColor;
    let _e1457 = frameK;
    outColor = mix(_e1455, _e1456, vec4(_e1457));
    let _e1460 = colorFog_1;
    if (_e1460.w != 0f) {
        {
            let _e1466 = colorFog_1;
            nearDist = (2f * (1f - _e1466.w));
            let _e1472 = nearDist;
            farDist = (2f * _e1472);
            let _e1475 = nearDist;
            let _e1476 = farDist;
            let _e1477 = cameraPos_2;
            let _e1478 = triangleIntersection;
            kFog = smoothstep(_e1475, _e1476, length((_e1477 - _e1478)));
            let _e1483 = outColor;
            let _e1485 = outColor;
            let _e1487 = colorFog_1;
            let _e1489 = kFog;
            let _e1491 = mix(_e1485.xyz, _e1487.xyz, vec3(_e1489));
            outColor.x = _e1491.x;
            outColor.y = _e1491.y;
            outColor.z = _e1491.z;
        }
    }
    let _e1498 = outColor;
    return _e1498;
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
