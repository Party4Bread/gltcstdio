struct Params {
    U: array<vec4<f32>, 28>,
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

fn boxMap(dir: vec3<f32>, sourceBkgDim: vec2<f32>) -> vec3<f32> {
    var dir_1: vec3<f32>;
    var sourceBkgDim_1: vec2<f32>;
    var ratio: f32;
    var X: f32 = 0.5f;
    var Y: f32 = 0.5f;

    dir_1 = dir;
    sourceBkgDim_1 = sourceBkgDim;
    let _e12 = sourceBkgDim_1;
    let _e14 = sourceBkgDim_1;
    ratio = (_e12.y / _e14.x);
    let _e22 = dir_1;
    let _e25 = dir_1;
    let _e28 = ratio;
    let _e31 = dir_1;
    let _e34 = dir_1;
    let _e37 = ratio;
    if ((abs(_e22.y) > (abs(_e25.z) * _e28)) && (abs(_e31.y) > (abs(_e34.x) * _e37))) {
        {
            let _e41 = X;
            let _e42 = dir_1;
            let _e45 = dir_1;
            X = (_e41 + ((-(_e42.x) / _e45.y) * 0.5f));
            let _e51 = Y;
            let _e52 = dir_1;
            let _e55 = dir_1;
            Y = (_e51 + ((-(_e52.z) / _e55.y) * 0.5f));
        }
    } else {
        let _e61 = dir_1;
        let _e64 = dir_1;
        if (abs(_e61.x) < abs(_e64.z)) {
            {
                let _e68 = X;
                let _e69 = dir_1;
                let _e71 = dir_1;
                let _e75 = ratio;
                let _e79 = dir_1;
                X = (_e68 + ((((_e69.x / abs(_e71.z)) * _e75) * 0.5f) * -(sign(_e79.z))));
                let _e85 = Y;
                let _e86 = dir_1;
                let _e88 = dir_1;
                Y = (_e85 + ((_e86.y / abs(_e88.z)) * 0.5f));
            }
        } else {
            {
                let _e95 = X;
                let _e96 = dir_1;
                let _e98 = dir_1;
                let _e102 = ratio;
                let _e106 = dir_1;
                X = (_e95 + ((((_e96.z / abs(_e98.x)) * _e102) * 0.5f) * -(sign(_e106.x))));
                let _e112 = Y;
                let _e113 = dir_1;
                let _e115 = dir_1;
                Y = (_e112 + ((_e113.y / abs(_e115.x)) * 0.5f));
            }
        }
    }
    let _e122 = X;
    let _e123 = Y;
    return vec3<f32>(_e122, _e123, 1f);
}

fn planeMap(dir_2: vec3<f32>, sourceBkgDim_2: vec2<f32>) -> vec3<f32> {
    var dir_3: vec3<f32>;
    var sourceBkgDim_3: vec2<f32>;
    var pos: vec2<f32>;
    var m: f32;
    var darken: f32;

    dir_3 = dir_2;
    sourceBkgDim_3 = sourceBkgDim_2;
    let _e12 = dir_3;
    let _e15 = dir_3;
    let _e18 = sourceBkgDim_3;
    let _e21 = sourceBkgDim_3;
    let _e24 = dir_3;
    let _e27 = dir_3;
    pos = ((vec2<f32>((((-(_e12.x) / _e15.z) * _e18.y) / _e21.x), (-(_e24.y) / _e27.z)) * 0.5f) + vec2<f32>(0.5f, 0.5f));
    let _e38 = pos;
    let _e41 = pos;
    m = max(abs(_e38.x), abs(_e41.y));
    let _e48 = m;
    darken = (4f / max(4f, _e48));
    let _e52 = pos;
    let _e53 = darken;
    return vec3<f32>(_e52.x, _e52.y, _e53);
}

fn sphereMap(dir_4: vec3<f32>, sourceBkgDim_4: vec2<f32>) -> vec3<f32> {
    var dir_5: vec3<f32>;
    var sourceBkgDim_5: vec2<f32>;
    var n: vec3<f32>;
    var alpha: f32;
    var beta: f32;
    var nX: f32 = 1f;
    var nY: f32 = 1f;

    dir_5 = dir_4;
    sourceBkgDim_5 = sourceBkgDim_4;
    let _e12 = dir_5;
    n = normalize(_e12);
    let _e15 = n;
    let _e17 = n;
    alpha = atan2(_e15.x, _e17.z);
    let _e21 = n;
    beta = asin(_e21.y);
    let _e29 = alpha;
    let _e33 = nX;
    let _e36 = nY;
    let _e37 = beta;
    return vec3<f32>(((-(_e29) / 3.1415927f) * _e33), (0.5f + ((_e36 * _e37) / 3.1415927f)), 1f);
}

fn backgroundDirect(dir_6: vec3<f32>, outPos: vec2<f32>, sourceBkgDim_6: vec2<f32>, backgroundMode: i32) -> vec3<f32> {
    var dir_7: vec3<f32>;
    var outPos_1: vec2<f32>;
    var sourceBkgDim_7: vec2<f32>;
    var backgroundMode_1: i32;

    dir_7 = dir_6;
    outPos_1 = outPos;
    sourceBkgDim_7 = sourceBkgDim_6;
    backgroundMode_1 = backgroundMode;
    let _e16 = backgroundMode_1;
    if (_e16 == 1i) {
        let _e19 = dir_7;
        let _e20 = sourceBkgDim_7;
        let _e21 = planeMap(_e19, _e20);
        return _e21;
    } else {
        let _e22 = backgroundMode_1;
        if (_e22 == 2i) {
            let _e25 = dir_7;
            let _e26 = sourceBkgDim_7;
            let _e27 = boxMap(_e25, _e26);
            return _e27;
        } else {
            let _e28 = backgroundMode_1;
            if (_e28 == 3i) {
                let _e31 = outPos_1;
                return vec3<f32>(_e31.x, _e31.y, 1f);
            } else {
                let _e36 = dir_7;
                let _e37 = sourceBkgDim_7;
                let _e38 = sphereMap(_e36, _e37);
                return _e38;
            }
        }
    }
}

fn backgroundForReflection(dir_8: vec3<f32>, sourceBkgDim_8: vec2<f32>, backgroundMode_2: i32) -> vec3<f32> {
    var dir_9: vec3<f32>;
    var sourceBkgDim_9: vec2<f32>;
    var backgroundMode_3: i32;

    dir_9 = dir_8;
    sourceBkgDim_9 = sourceBkgDim_8;
    backgroundMode_3 = backgroundMode_2;
    let _e14 = backgroundMode_3;
    if (_e14 == 1i) {
        let _e17 = dir_9;
        let _e18 = sourceBkgDim_9;
        let _e19 = planeMap(_e17, _e18);
        return _e19;
    } else {
        let _e20 = backgroundMode_3;
        if (_e20 == 2i) {
            let _e23 = dir_9;
            let _e24 = sourceBkgDim_9;
            let _e25 = boxMap(_e23, _e24);
            return _e25;
        } else {
            let _e26 = dir_9;
            let _e27 = sourceBkgDim_9;
            let _e28 = sphereMap(_e26, _e27);
            return _e28;
        }
    }
}

fn distSegSeg(S1P0_: vec3<f32>, S1P1_: vec3<f32>, S2P0_: vec3<f32>, S2P1_: vec3<f32>) -> f32 {
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
    let _e169 = dP;
    return length(_e169);
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

fn mesh3d(pos_1: vec2<f32>, outPos_2: vec2<f32>, intensity_2: f32, rezolution: i32, thickness: f32, glow: f32, specular: f32, normalSmoothing: f32, model3DTransform: mat4x4<f32>, sourceDim: vec2<f32>, sourceBkgDim_10: vec2<f32>, sourceElevationDim: vec2<f32>, sourceBkg_specified: i32, sourceElevation_specified: i32, backgroundMode_4: i32, colorScheme: f32, reflectivity: f32, colorBkg: vec4<f32>, colorLines: vec4<f32>, colorFog: vec4<f32>, colorSource: vec4<f32>, colorAmbient: vec4<f32>) -> vec4<f32> {
    var pos_2: vec2<f32>;
    var outPos_3: vec2<f32>;
    var intensity_3: f32;
    var rezolution_1: i32;
    var thickness_1: f32;
    var glow_1: f32;
    var specular_1: f32;
    var normalSmoothing_1: f32;
    var model3DTransform_1: mat4x4<f32>;
    var sourceDim_1: vec2<f32>;
    var sourceBkgDim_11: vec2<f32>;
    var sourceElevationDim_1: vec2<f32>;
    var sourceBkg_specified_1: i32;
    var sourceElevation_specified_1: i32;
    var backgroundMode_5: i32;
    var colorScheme_1: f32;
    var reflectivity_1: f32;
    var colorBkg_1: vec4<f32>;
    var colorLines_1: vec4<f32>;
    var colorFog_1: vec4<f32>;
    var colorSource_1: vec4<f32>;
    var colorAmbient_1: vec4<f32>;
    var D_1: f32 = 1f;
    var cameraPos: vec3<f32> = vec3<f32>(0f, 0f, 0f);
    var m_1: mat4x4<f32>;
    var dir_10: vec3<f32>;
    var heightMap: bool;
    var maxZ: f32;
    var local_2: f32;
    var ratio_1: f32;
    var squareSize: f32;
    var surfaceWidth: f32;
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
    var k: f32;
    var p: vec3<f32>;
    var color_2: vec4<f32> = vec4<f32>(0f, 0f, 0f, 1f);
    var bkgDir: vec3<f32>;
    var local_3: vec4<f32>;
    var intersectDist: f32 = 1000000000f;
    var intersected: f32 = 0f;
    var outColor: vec4<f32>;
    var nextLines: vec2<f32>;
    var maxIter: i32 = 1000i;
    var frameDist: f32 = 10000000000f;
    var indexX: f32;
    var indexY: f32;
    var fX: f32;
    var fY: f32;
    var squareCenter: vec2<f32>;
    var bottomLeft: vec2<f32>;
    var intersection: mat3x3<f32>;
    var s_3: vec2<f32>;
    var p11_: vec2<f32>;
    var local_4: vec4<f32>;
    var c00_: vec4<f32>;
    var h00_: f32;
    var A: vec3<f32>;
    var local_5: vec4<f32>;
    var c10_: vec4<f32>;
    var h10_: f32;
    var B: vec3<f32>;
    var local_6: vec4<f32>;
    var c01_: vec4<f32>;
    var h01_: f32;
    var C: vec3<f32>;
    var local_7: vec4<f32>;
    var c11_: vec4<f32>;
    var h11_: f32;
    var D_2: vec3<f32>;
    var inf: vec3<f32>;
    var local_8: f32;
    var _frameDist: f32;
    var dzx1_: f32;
    var dzy1_: f32;
    var k1_1: f32;
    var dzx2_: f32;
    var dzy2_: f32;
    var k2_1: f32;
    var normal: vec3<f32>;
    var _intersection: vec3<f32>;
    var relInt: vec2<f32>;
    var deltaX: f32;
    var dzdx: f32;
    var dzdy: f32;
    var deltaY: f32;
    var unormal: vec3<f32>;
    var local_9: vec3<f32>;
    var smoothNormal: vec3<f32>;
    var relInt_1: vec2<f32>;
    var deltaX_1: f32;
    var dzdx_1: f32;
    var dzdy_1: f32;
    var deltaY_1: f32;
    var unormal_1: vec3<f32>;
    var local_10: vec3<f32>;
    var smoothNormal_1: vec3<f32>;
    var local_11: vec4<f32>;
    var local_12: vec4<f32>;
    var col: vec4<f32>;
    var sampled: vec4<f32>;
    var normal_1: vec3<f32>;
    var alpha_1: f32;
    var lightDir: vec3<f32>;
    var reflectLightDir: vec3<f32>;
    var local_13: f32;
    var specularColor: vec4<f32>;
    var normal_2: vec3<f32>;
    var reflectDir: vec3<f32>;
    var reflected: vec4<f32>;
    var refDir: vec3<f32>;
    var lum: f32;
    var k_1: f32;
    var local_14: vec4<f32>;
    var next: vec2<f32>;
    var deltaK: vec2<f32>;
    var minK: f32;
    var frameColor: vec4<f32>;
    var local_15: f32;
    var local_16: f32;
    var frameK: f32;
    var nearDist: f32;
    var farDist: f32;
    var kFog: f32;

    pos_2 = pos_1;
    outPos_3 = outPos_2;
    intensity_3 = intensity_2;
    rezolution_1 = rezolution;
    thickness_1 = thickness;
    glow_1 = glow;
    specular_1 = specular;
    normalSmoothing_1 = normalSmoothing;
    model3DTransform_1 = model3DTransform;
    sourceDim_1 = sourceDim;
    sourceBkgDim_11 = sourceBkgDim_10;
    sourceElevationDim_1 = sourceElevationDim;
    sourceBkg_specified_1 = sourceBkg_specified;
    sourceElevation_specified_1 = sourceElevation_specified;
    backgroundMode_5 = backgroundMode_4;
    colorScheme_1 = colorScheme;
    reflectivity_1 = reflectivity;
    colorBkg_1 = colorBkg;
    colorLines_1 = colorLines;
    colorFog_1 = colorFog;
    colorSource_1 = colorSource;
    colorAmbient_1 = colorAmbient;
    let _e59 = model3DTransform_1;
    m_1 = _naga_inverse_4x4_f32(_e59);
    let _e62 = m_1;
    let _e63 = cameraPos;
    cameraPos = (_e62 * vec4<f32>(_e63.x, _e63.y, _e63.z, 1f)).xyz;
    let _e71 = pos_2;
    let _e73 = D_1;
    let _e75 = pos_2;
    let _e77 = D_1;
    dir_10 = normalize(vec3<f32>((_e71.x * _e73), (_e75.y * _e77), -1f));
    let _e84 = m_1;
    let _e94 = dir_10;
    dir_10 = (mat3x3<f32>(_e84[0].xyz, _e84[1].xyz, _e84[2].xyz) * _e94);
    let _e96 = sourceElevation_specified_1;
    heightMap = (_e96 == 1i);
    let _e100 = intensity_3;
    maxZ = (abs(_e100) * 0.02f);
    let _e105 = heightMap;
    if _e105 {
        let _e106 = sourceElevationDim_1;
        let _e108 = sourceElevationDim_1;
        local_2 = (_e106.x / _e108.y);
    } else {
        let _e111 = sourceDim_1;
        let _e113 = sourceDim_1;
        local_2 = (_e111.x / _e113.y);
    }
    let _e117 = local_2;
    ratio_1 = _e117;
    let _e120 = rezolution_1;
    squareSize = (2f / f32(_e120));
    let _e124 = maxZ;
    let _e125 = squareSize;
    maxZ = (_e124 + _e125);
    let _e128 = ratio_1;
    let _e130 = squareSize;
    let _e133 = squareSize;
    surfaceWidth = (round(((2f * _e128) / _e130)) * _e133);
    let _e142 = dir_10;
    if (_e142.x != 0f) {
        {
            let _e146 = dir_10;
            s = sign(_e146.x);
            let _e150 = s;
            let _e152 = surfaceWidth;
            let _e156 = cameraPos;
            let _e159 = dir_10;
            k3_ = ((((-(_e150) * _e152) / 2f) - _e156.x) / _e159.x);
            let _e163 = s;
            let _e164 = surfaceWidth;
            let _e168 = cameraPos;
            let _e171 = dir_10;
            k4_ = ((((_e163 * _e164) / 2f) - _e168.x) / _e171.x);
            let _e175 = k1_;
            let _e176 = k3_;
            k1_ = max(_e175, _e176);
            let _e178 = k2_;
            let _e179 = k4_;
            k2_ = min(_e178, _e179);
        }
    }
    let _e181 = dir_10;
    if (_e181.y != 0f) {
        {
            let _e185 = dir_10;
            s_1 = sign(_e185.y);
            let _e189 = s_1;
            let _e191 = cameraPos;
            let _e194 = dir_10;
            k3_1 = ((-(_e189) - _e191.y) / _e194.y);
            let _e198 = s_1;
            let _e199 = cameraPos;
            let _e202 = dir_10;
            k4_1 = ((_e198 - _e199.y) / _e202.y);
            let _e206 = k1_;
            let _e207 = k3_1;
            k1_ = max(_e206, _e207);
            let _e209 = k2_;
            let _e210 = k4_1;
            k2_ = min(_e209, _e210);
        }
    }
    let _e212 = maxZ;
    maxZ2_ = (_e212 + 0.0001f);
    let _e216 = dir_10;
    if (_e216.z != 0f) {
        {
            let _e220 = dir_10;
            s_2 = sign(_e220.z);
            let _e224 = s_2;
            let _e226 = maxZ2_;
            let _e228 = cameraPos;
            let _e231 = dir_10;
            k3_2 = (((-(_e224) * _e226) - _e228.z) / _e231.z);
            let _e235 = s_2;
            let _e236 = maxZ2_;
            let _e238 = cameraPos;
            let _e241 = dir_10;
            k4_2 = (((_e235 * _e236) - _e238.z) / _e241.z);
            let _e245 = k1_;
            let _e246 = k3_2;
            k1_ = max(_e245, _e246);
            let _e248 = k2_;
            let _e249 = k4_2;
            k2_ = min(_e248, _e249);
        }
    }
    let _e251 = k1_;
    k = _e251;
    let _e253 = cameraPos;
    let _e254 = k;
    let _e255 = dir_10;
    p = (_e253 + (_e254 * _e255));
    let _e265 = sourceBkg_specified_1;
    if (_e265 == 1i) {
        {
            let _e268 = dir_10;
            let _e269 = outPos_3;
            let _e270 = sourceBkgDim_11;
            let _e271 = backgroundMode_5;
            let _e272 = backgroundDirect(_e268, _e269, _e270, _e271);
            bkgDir = _e272;
            let _e274 = bkgDir;
            let _e279 = global.U[0];
            let _e282 = bkgDir;
            let _e293 = textureSampleLevel(t_sourceBkg, samp, ((vec2<f32>((_e274.x / _e279.x), _e282.y) / vec2(2f)) + vec2(0.5f)), 0f);
            let _e294 = bkgDir;
            let _e296 = vec3(_e294.z);
            color_2 = (_e293 * vec4<f32>(_e296.x, _e296.y, _e296.z, 1f));
        }
    }
    let _e303 = k1_;
    let _e304 = k2_;
    if (_e303 > _e304) {
        let _e306 = colorFog_1;
        if (_e306.w != 0f) {
            let _e310 = colorFog_1;
            let _e311 = _e310.xyz;
            local_3 = vec4<f32>(_e311.x, _e311.y, _e311.z, 1f);
        } else {
            let _e317 = color_2;
            local_3 = _e317;
        }
        let _e319 = local_3;
        return _e319;
    }
    let _e324 = color_2;
    outColor = _e324;
    let _e326 = dir_10;
    let _e329 = squareSize;
    nextLines = ((sign(_e326.xy) * _e329) / vec2(2f));
    loop {
        let _e339 = intersected;
        let _e342 = k;
        let _e343 = k2_;
        let _e346 = maxIter;
        if !((((_e339 < 1f) && (_e342 <= _e343)) && (_e346 > 0i))) {
            break;
        }
        {
            let _e351 = p;
            let _e353 = surfaceWidth;
            let _e357 = squareSize;
            indexX = ((_e351.x + (_e353 / 2f)) / _e357);
            let _e360 = p;
            let _e362 = surfaceHeight;
            let _e366 = squareSize;
            indexY = ((_e360.y + (_e362 / 2f)) / _e366);
            let _e369 = indexX;
            fX = fract(_e369);
            let _e372 = indexY;
            fY = fract(_e372);
            let _e376 = fX;
            let _e379 = dir_10;
            if ((_e376 > 0.9999f) && (_e379.x > 0f)) {
                let _e385 = indexX;
                let _e389 = squareSize;
                squareCenter.x = ((ceil(_e385) + 0.5f) * _e389);
            } else {
                let _e391 = fX;
                let _e394 = dir_10;
                if ((_e391 < 0.0001f) && (_e394.x < 0f)) {
                    let _e400 = indexX;
                    let _e404 = squareSize;
                    squareCenter.x = ((floor(_e400) - 0.5f) * _e404);
                } else {
                    let _e407 = indexX;
                    let _e411 = squareSize;
                    squareCenter.x = ((floor(_e407) + 0.5f) * _e411);
                }
            }
            let _e414 = squareCenter;
            let _e416 = surfaceWidth;
            squareCenter.x = (_e414.x - (_e416 / 2f));
            let _e420 = fY;
            let _e423 = dir_10;
            if ((_e420 > 0.9999f) && (_e423.y > 0f)) {
                let _e429 = indexY;
                let _e433 = squareSize;
                squareCenter.y = ((ceil(_e429) + 0.5f) * _e433);
            } else {
                let _e435 = fY;
                let _e438 = dir_10;
                if ((_e435 < 0.0001f) && (_e438.y < 0f)) {
                    let _e444 = indexY;
                    let _e448 = squareSize;
                    squareCenter.y = ((floor(_e444) - 0.5f) * _e448);
                } else {
                    let _e451 = indexY;
                    let _e455 = squareSize;
                    squareCenter.y = ((floor(_e451) + 0.5f) * _e455);
                }
            }
            let _e458 = squareCenter;
            let _e460 = surfaceHeight;
            squareCenter.y = (_e458.y - (_e460 / 2f));
            let _e464 = squareCenter;
            let _e467 = surfaceWidth;
            let _e471 = squareCenter;
            let _e474 = surfaceHeight;
            if ((abs(_e464.x) < (_e467 / 2f)) && (abs(_e471.y) < (_e474 / 2f))) {
                {
                    let _e479 = squareCenter;
                    let _e480 = squareSize;
                    let _e481 = squareSize;
                    bottomLeft = (_e479 - (vec2<f32>(_e480, _e481) / vec2(2f)));
                    let _e489 = squareSize;
                    s_3 = vec2<f32>(_e489, 0f);
                    let _e493 = bottomLeft;
                    let _e494 = s_3;
                    p11_ = (_e493 + _e494.xx);
                    let _e498 = heightMap;
                    if _e498 {
                        let _e499 = bottomLeft;
                        let _e503 = global.U[0];
                        let _e506 = bottomLeft;
                        let _e516 = textureSampleLevel(t_sourceElevation, samp, ((vec2<f32>((_e499.x / _e503.x), _e506.y) / vec2(2f)) + vec2(0.5f)), 0f);
                        local_4 = _e516;
                    } else {
                        let _e517 = bottomLeft;
                        let _e521 = global.U[0];
                        let _e524 = bottomLeft;
                        let _e534 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e517.x / _e521.x), _e524.y) / vec2(2f)) + vec2(0.5f)), 0f);
                        local_4 = _e534;
                    }
                    let _e536 = local_4;
                    c00_ = _e536;
                    let _e538 = intensity_3;
                    let _e539 = c00_;
                    let _e540 = height(_e538, _e539);
                    h00_ = _e540;
                    let _e542 = bottomLeft;
                    let _e543 = h00_;
                    A = vec3<f32>(_e542.x, _e542.y, _e543);
                    let _e548 = heightMap;
                    if _e548 {
                        let _e549 = bottomLeft;
                        let _e550 = s_3;
                        let _e555 = global.U[0];
                        let _e558 = bottomLeft;
                        let _e559 = s_3;
                        let _e570 = textureSampleLevel(t_sourceElevation, samp, ((vec2<f32>(((_e549 + _e550).x / _e555.x), (_e558 + _e559).y) / vec2(2f)) + vec2(0.5f)), 0f);
                        local_5 = _e570;
                    } else {
                        let _e571 = bottomLeft;
                        let _e572 = s_3;
                        let _e577 = global.U[0];
                        let _e580 = bottomLeft;
                        let _e581 = s_3;
                        let _e592 = textureSampleLevel(t_source, samp, ((vec2<f32>(((_e571 + _e572).x / _e577.x), (_e580 + _e581).y) / vec2(2f)) + vec2(0.5f)), 0f);
                        local_5 = _e592;
                    }
                    let _e594 = local_5;
                    c10_ = _e594;
                    let _e596 = intensity_3;
                    let _e597 = c10_;
                    let _e598 = height(_e596, _e597);
                    h10_ = _e598;
                    let _e600 = bottomLeft;
                    let _e601 = s_3;
                    let _e602 = (_e600 + _e601);
                    let _e603 = h10_;
                    B = vec3<f32>(_e602.x, _e602.y, _e603);
                    let _e608 = heightMap;
                    if _e608 {
                        let _e609 = bottomLeft;
                        let _e610 = s_3;
                        let _e616 = global.U[0];
                        let _e619 = bottomLeft;
                        let _e620 = s_3;
                        let _e632 = textureSampleLevel(t_sourceElevation, samp, ((vec2<f32>(((_e609 + _e610.yx).x / _e616.x), (_e619 + _e620.yx).y) / vec2(2f)) + vec2(0.5f)), 0f);
                        local_6 = _e632;
                    } else {
                        let _e633 = bottomLeft;
                        let _e634 = s_3;
                        let _e640 = global.U[0];
                        let _e643 = bottomLeft;
                        let _e644 = s_3;
                        let _e656 = textureSampleLevel(t_source, samp, ((vec2<f32>(((_e633 + _e634.yx).x / _e640.x), (_e643 + _e644.yx).y) / vec2(2f)) + vec2(0.5f)), 0f);
                        local_6 = _e656;
                    }
                    let _e658 = local_6;
                    c01_ = _e658;
                    let _e660 = intensity_3;
                    let _e661 = c01_;
                    let _e662 = height(_e660, _e661);
                    h01_ = _e662;
                    let _e664 = bottomLeft;
                    let _e665 = s_3;
                    let _e667 = (_e664 + _e665.yx);
                    let _e668 = h01_;
                    C = vec3<f32>(_e667.x, _e667.y, _e668);
                    let _e673 = heightMap;
                    if _e673 {
                        let _e674 = p11_;
                        let _e678 = global.U[0];
                        let _e681 = p11_;
                        let _e691 = textureSampleLevel(t_sourceElevation, samp, ((vec2<f32>((_e674.x / _e678.x), _e681.y) / vec2(2f)) + vec2(0.5f)), 0f);
                        local_7 = _e691;
                    } else {
                        let _e692 = p11_;
                        let _e696 = global.U[0];
                        let _e699 = p11_;
                        let _e709 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e692.x / _e696.x), _e699.y) / vec2(2f)) + vec2(0.5f)), 0f);
                        local_7 = _e709;
                    }
                    let _e711 = local_7;
                    c11_ = _e711;
                    let _e713 = intensity_3;
                    let _e714 = c11_;
                    let _e715 = height(_e713, _e714);
                    h11_ = _e715;
                    let _e717 = p11_;
                    let _e718 = h11_;
                    D_2 = vec3<f32>(_e717.x, _e717.y, _e718);
                    let _e723 = p;
                    let _e725 = dir_10;
                    inf = (_e723 + (1000000f * _e725));
                    let _e729 = thickness_1;
                    if (_e729 == 0f) {
                        local_8 = 1000000000f;
                    } else {
                        let _e733 = p;
                        let _e734 = inf;
                        let _e735 = A;
                        let _e736 = B;
                        let _e737 = distSegSeg(_e733, _e734, _e735, _e736);
                        let _e738 = p;
                        let _e739 = inf;
                        let _e740 = C;
                        let _e741 = D_2;
                        let _e742 = distSegSeg(_e738, _e739, _e740, _e741);
                        let _e744 = p;
                        let _e745 = inf;
                        let _e746 = A;
                        let _e747 = C;
                        let _e748 = distSegSeg(_e744, _e745, _e746, _e747);
                        let _e749 = p;
                        let _e750 = inf;
                        let _e751 = B;
                        let _e752 = D_2;
                        let _e753 = distSegSeg(_e749, _e750, _e751, _e752);
                        local_8 = min(min(_e737, _e742), min(_e748, _e753));
                    }
                    let _e757 = local_8;
                    _frameDist = _e757;
                    let _e759 = h10_;
                    let _e760 = h00_;
                    let _e762 = squareSize;
                    dzx1_ = ((_e759 - _e760) / _e762);
                    let _e765 = h01_;
                    let _e766 = h00_;
                    let _e768 = squareSize;
                    dzy1_ = ((_e765 - _e766) / _e768);
                    let _e771 = h00_;
                    let _e772 = p;
                    let _e775 = p;
                    let _e777 = bottomLeft;
                    let _e780 = dzx1_;
                    let _e783 = p;
                    let _e785 = bottomLeft;
                    let _e788 = dzy1_;
                    let _e791 = dir_10;
                    let _e793 = dir_10;
                    let _e795 = dzx1_;
                    let _e798 = dir_10;
                    let _e800 = dzy1_;
                    k1_1 = ((((_e771 - _e772.z) + ((_e775.x - _e777.x) * _e780)) + ((_e783.y - _e785.y) * _e788)) / ((_e791.z - (_e793.x * _e795)) - (_e798.y * _e800)));
                    let _e805 = h01_;
                    let _e806 = h11_;
                    let _e809 = squareSize;
                    dzx2_ = (-((_e805 - _e806)) / _e809);
                    let _e812 = h10_;
                    let _e813 = h11_;
                    let _e816 = squareSize;
                    dzy2_ = (-((_e812 - _e813)) / _e816);
                    let _e819 = h11_;
                    let _e820 = p;
                    let _e823 = p;
                    let _e825 = p11_;
                    let _e828 = dzx2_;
                    let _e831 = p;
                    let _e833 = p11_;
                    let _e836 = dzy2_;
                    let _e839 = dir_10;
                    let _e841 = dir_10;
                    let _e843 = dzx2_;
                    let _e846 = dir_10;
                    let _e848 = dzy2_;
                    k2_1 = ((((_e819 - _e820.z) + ((_e823.x - _e825.x) * _e828)) + ((_e831.y - _e833.y) * _e836)) / ((_e839.z - (_e841.x * _e843)) - (_e846.y * _e848)));
                    normal = vec3<f32>(0f, 0f, 0f);
                    _intersection = vec3<f32>(100000000000000000000f, 100000000000000000000f, 100000000000000000000f);
                    let _e871 = _frameDist;
                    let _e874 = vec3<f32>(_e871, 0f, 0f);
                    intersection = mat3x3<f32>(vec3<f32>(100000000000000000000f, 100000000000000000000f, 100000000000000000000f), vec3<f32>(0f, 0f, 0f), vec3<f32>(_e874.x, _e874.y, _e874.z));
                    let _e882 = k1_1;
                    if (_e882 > 0f) {
                        {
                            let _e885 = p;
                            let _e886 = k1_1;
                            let _e887 = dir_10;
                            _intersection = (_e885 + (_e886 * _e887));
                            let _e890 = _intersection;
                            let _e892 = bottomLeft;
                            relInt = (_e890.xy - _e892.xy);
                            let _e896 = relInt;
                            let _e900 = relInt;
                            let _e902 = squareSize;
                            let _e905 = relInt;
                            let _e910 = relInt;
                            let _e912 = squareSize;
                            let _e915 = squareSize;
                            let _e916 = relInt;
                            let _e919 = relInt;
                            if (((((_e896.x >= 0f) && (_e900.x <= _e902)) && (_e905.y >= 0f)) && (_e910.y <= _e912)) && ((_e915 - _e916.x) >= _e919.y)) {
                                {
                                    let _e923 = squareSize;
                                    let _e925 = h10_;
                                    let _e926 = h00_;
                                    let _e930 = squareSize;
                                    let _e931 = h01_;
                                    let _e932 = h00_;
                                    let _e937 = squareSize;
                                    let _e940 = h01_;
                                    let _e941 = h11_;
                                    let _e945 = squareSize;
                                    let _e947 = h10_;
                                    let _e948 = h11_;
                                    normal = normalize(mix(normalize(cross(vec3<f32>(_e923, 0f, (_e925 - _e926)), vec3<f32>(0f, _e930, (_e931 - _e932)))), normalize(cross(vec3<f32>(-(_e937), 0f, (_e940 - _e941)), vec3<f32>(0f, -(_e945), (_e947 - _e948)))), vec3(0.5f)));
                                    let _e957 = normalSmoothing_1;
                                    if (_e957 != 0f) {
                                        {
                                            deltaX = 0.0005f;
                                            let _e964 = heightMap;
                                            if !(_e964) {
                                                let _e966 = intensity_3;
                                                let _e967 = _intersection;
                                                let _e969 = deltaX;
                                                let _e971 = _intersection;
                                                let _e977 = global.U[0];
                                                let _e980 = _intersection;
                                                let _e982 = deltaX;
                                                let _e984 = _intersection;
                                                let _e996 = textureSampleLevel(t_source, samp, ((vec2<f32>((vec2<f32>((_e967.x + _e969), _e971.y).x / _e977.x), vec2<f32>((_e980.x + _e982), _e984.y).y) / vec2(2f)) + vec2(0.5f)), 0f);
                                                let _e997 = height(_e966, _e996);
                                                let _e998 = intensity_3;
                                                let _e999 = _intersection;
                                                let _e1001 = deltaX;
                                                let _e1003 = _intersection;
                                                let _e1009 = global.U[0];
                                                let _e1012 = _intersection;
                                                let _e1014 = deltaX;
                                                let _e1016 = _intersection;
                                                let _e1028 = textureSampleLevel(t_source, samp, ((vec2<f32>((vec2<f32>((_e999.x - _e1001), _e1003.y).x / _e1009.x), vec2<f32>((_e1012.x - _e1014), _e1016.y).y) / vec2(2f)) + vec2(0.5f)), 0f);
                                                let _e1029 = height(_e998, _e1028);
                                                dzdx = (_e997 - _e1029);
                                            } else {
                                                let _e1031 = intensity_3;
                                                let _e1032 = _intersection;
                                                let _e1034 = deltaX;
                                                let _e1036 = _intersection;
                                                let _e1042 = global.U[0];
                                                let _e1045 = _intersection;
                                                let _e1047 = deltaX;
                                                let _e1049 = _intersection;
                                                let _e1061 = textureSampleLevel(t_sourceElevation, samp, ((vec2<f32>((vec2<f32>((_e1032.x + _e1034), _e1036.y).x / _e1042.x), vec2<f32>((_e1045.x + _e1047), _e1049.y).y) / vec2(2f)) + vec2(0.5f)), 0f);
                                                let _e1062 = height(_e1031, _e1061);
                                                let _e1063 = intensity_3;
                                                let _e1064 = _intersection;
                                                let _e1066 = deltaX;
                                                let _e1068 = _intersection;
                                                let _e1074 = global.U[0];
                                                let _e1077 = _intersection;
                                                let _e1079 = deltaX;
                                                let _e1081 = _intersection;
                                                let _e1093 = textureSampleLevel(t_sourceElevation, samp, ((vec2<f32>((vec2<f32>((_e1064.x - _e1066), _e1068.y).x / _e1074.x), vec2<f32>((_e1077.x - _e1079), _e1081.y).y) / vec2(2f)) + vec2(0.5f)), 0f);
                                                let _e1094 = height(_e1063, _e1093);
                                                dzdx = (_e1062 - _e1094);
                                            }
                                            deltaY = 0.0005f;
                                            let _e1098 = heightMap;
                                            if !(_e1098) {
                                                let _e1100 = intensity_3;
                                                let _e1101 = _intersection;
                                                let _e1103 = _intersection;
                                                let _e1105 = deltaY;
                                                let _e1111 = global.U[0];
                                                let _e1114 = _intersection;
                                                let _e1116 = _intersection;
                                                let _e1118 = deltaY;
                                                let _e1130 = textureSampleLevel(t_source, samp, ((vec2<f32>((vec2<f32>(_e1101.x, (_e1103.y + _e1105)).x / _e1111.x), vec2<f32>(_e1114.x, (_e1116.y + _e1118)).y) / vec2(2f)) + vec2(0.5f)), 0f);
                                                let _e1131 = height(_e1100, _e1130);
                                                let _e1132 = intensity_3;
                                                let _e1133 = _intersection;
                                                let _e1135 = _intersection;
                                                let _e1137 = deltaY;
                                                let _e1143 = global.U[0];
                                                let _e1146 = _intersection;
                                                let _e1148 = _intersection;
                                                let _e1150 = deltaY;
                                                let _e1162 = textureSampleLevel(t_source, samp, ((vec2<f32>((vec2<f32>(_e1133.x, (_e1135.y - _e1137)).x / _e1143.x), vec2<f32>(_e1146.x, (_e1148.y - _e1150)).y) / vec2(2f)) + vec2(0.5f)), 0f);
                                                let _e1163 = height(_e1132, _e1162);
                                                dzdy = (_e1131 - _e1163);
                                            } else {
                                                let _e1165 = intensity_3;
                                                let _e1166 = _intersection;
                                                let _e1168 = _intersection;
                                                let _e1170 = deltaY;
                                                let _e1176 = global.U[0];
                                                let _e1179 = _intersection;
                                                let _e1181 = _intersection;
                                                let _e1183 = deltaY;
                                                let _e1195 = textureSampleLevel(t_sourceElevation, samp, ((vec2<f32>((vec2<f32>(_e1166.x, (_e1168.y + _e1170)).x / _e1176.x), vec2<f32>(_e1179.x, (_e1181.y + _e1183)).y) / vec2(2f)) + vec2(0.5f)), 0f);
                                                let _e1196 = height(_e1165, _e1195);
                                                let _e1197 = intensity_3;
                                                let _e1198 = _intersection;
                                                let _e1200 = _intersection;
                                                let _e1202 = deltaY;
                                                let _e1208 = global.U[0];
                                                let _e1211 = _intersection;
                                                let _e1213 = _intersection;
                                                let _e1215 = deltaY;
                                                let _e1227 = textureSampleLevel(t_sourceElevation, samp, ((vec2<f32>((vec2<f32>(_e1198.x, (_e1200.y - _e1202)).x / _e1208.x), vec2<f32>(_e1211.x, (_e1213.y - _e1215)).y) / vec2(2f)) + vec2(0.5f)), 0f);
                                                let _e1228 = height(_e1197, _e1227);
                                                dzdy = (_e1196 - _e1228);
                                            }
                                            let _e1231 = dzdx;
                                            let _e1233 = deltaX;
                                            let _e1236 = dzdy;
                                            let _e1238 = deltaY;
                                            unormal = vec3<f32>(((0.5f * _e1231) / _e1233), ((0.5f * _e1236) / _e1238), 1f);
                                            let _e1243 = unormal;
                                            let _e1247 = unormal;
                                            let _e1252 = unormal;
                                            if (((_e1243.x == 0f) && (_e1247.y == 0f)) && (_e1252.z == 0f)) {
                                                local_9 = vec3<f32>(0f, 0f, 1f);
                                            } else {
                                                let _e1261 = unormal;
                                                local_9 = normalize(_e1261);
                                            }
                                            let _e1264 = local_9;
                                            smoothNormal = _e1264;
                                            let _e1266 = normal;
                                            let _e1267 = smoothNormal;
                                            let _e1268 = normalSmoothing_1;
                                            normal = mix(_e1266, _e1267, vec3(_e1268));
                                        }
                                    }
                                    let _e1271 = _intersection;
                                    let _e1272 = normal;
                                    let _e1273 = frameDist;
                                    let _e1276 = vec3<f32>(_e1273, 0f, 0f);
                                    intersection = mat3x3<f32>(vec3<f32>(_e1271.x, _e1271.y, _e1271.z), vec3<f32>(_e1272.x, _e1272.y, _e1272.z), vec3<f32>(_e1276.x, _e1276.y, _e1276.z));
                                }
                            }
                        }
                    }
                    let _e1290 = k2_1;
                    if (_e1290 > 0f) {
                        {
                            let _e1293 = p;
                            let _e1294 = k2_1;
                            let _e1295 = dir_10;
                            _intersection = (_e1293 + (_e1294 * _e1295));
                            let _e1298 = _intersection;
                            let _e1300 = bottomLeft;
                            relInt_1 = (_e1298.xy - _e1300.xy);
                            let _e1304 = relInt_1;
                            let _e1308 = relInt_1;
                            let _e1310 = squareSize;
                            let _e1313 = relInt_1;
                            let _e1318 = relInt_1;
                            let _e1320 = squareSize;
                            let _e1323 = squareSize;
                            let _e1324 = relInt_1;
                            let _e1327 = relInt_1;
                            if (((((_e1304.x >= 0f) && (_e1308.x <= _e1310)) && (_e1313.y >= 0f)) && (_e1318.y <= _e1320)) && ((_e1323 - _e1324.x) <= _e1327.y)) {
                                {
                                    let _e1331 = squareSize;
                                    let _e1333 = h10_;
                                    let _e1334 = h00_;
                                    let _e1338 = squareSize;
                                    let _e1339 = h01_;
                                    let _e1340 = h00_;
                                    let _e1345 = squareSize;
                                    let _e1348 = h01_;
                                    let _e1349 = h11_;
                                    let _e1353 = squareSize;
                                    let _e1355 = h10_;
                                    let _e1356 = h11_;
                                    normal = normalize(mix(normalize(cross(vec3<f32>(_e1331, 0f, (_e1333 - _e1334)), vec3<f32>(0f, _e1338, (_e1339 - _e1340)))), normalize(cross(vec3<f32>(-(_e1345), 0f, (_e1348 - _e1349)), vec3<f32>(0f, -(_e1353), (_e1355 - _e1356)))), vec3(0.5f)));
                                    let _e1365 = normalSmoothing_1;
                                    if (_e1365 != 0f) {
                                        {
                                            deltaX_1 = 0.0005f;
                                            let _e1372 = heightMap;
                                            if !(_e1372) {
                                                let _e1374 = intensity_3;
                                                let _e1375 = _intersection;
                                                let _e1377 = deltaX_1;
                                                let _e1379 = _intersection;
                                                let _e1385 = global.U[0];
                                                let _e1388 = _intersection;
                                                let _e1390 = deltaX_1;
                                                let _e1392 = _intersection;
                                                let _e1404 = textureSampleLevel(t_source, samp, ((vec2<f32>((vec2<f32>((_e1375.x + _e1377), _e1379.y).x / _e1385.x), vec2<f32>((_e1388.x + _e1390), _e1392.y).y) / vec2(2f)) + vec2(0.5f)), 0f);
                                                let _e1405 = height(_e1374, _e1404);
                                                let _e1406 = intensity_3;
                                                let _e1407 = _intersection;
                                                let _e1409 = deltaX_1;
                                                let _e1411 = _intersection;
                                                let _e1417 = global.U[0];
                                                let _e1420 = _intersection;
                                                let _e1422 = deltaX_1;
                                                let _e1424 = _intersection;
                                                let _e1436 = textureSampleLevel(t_source, samp, ((vec2<f32>((vec2<f32>((_e1407.x - _e1409), _e1411.y).x / _e1417.x), vec2<f32>((_e1420.x - _e1422), _e1424.y).y) / vec2(2f)) + vec2(0.5f)), 0f);
                                                let _e1437 = height(_e1406, _e1436);
                                                dzdx_1 = (_e1405 - _e1437);
                                            } else {
                                                let _e1439 = intensity_3;
                                                let _e1440 = _intersection;
                                                let _e1442 = deltaX_1;
                                                let _e1444 = _intersection;
                                                let _e1450 = global.U[0];
                                                let _e1453 = _intersection;
                                                let _e1455 = deltaX_1;
                                                let _e1457 = _intersection;
                                                let _e1469 = textureSampleLevel(t_sourceElevation, samp, ((vec2<f32>((vec2<f32>((_e1440.x + _e1442), _e1444.y).x / _e1450.x), vec2<f32>((_e1453.x + _e1455), _e1457.y).y) / vec2(2f)) + vec2(0.5f)), 0f);
                                                let _e1470 = height(_e1439, _e1469);
                                                let _e1471 = intensity_3;
                                                let _e1472 = _intersection;
                                                let _e1474 = deltaX_1;
                                                let _e1476 = _intersection;
                                                let _e1482 = global.U[0];
                                                let _e1485 = _intersection;
                                                let _e1487 = deltaX_1;
                                                let _e1489 = _intersection;
                                                let _e1501 = textureSampleLevel(t_sourceElevation, samp, ((vec2<f32>((vec2<f32>((_e1472.x - _e1474), _e1476.y).x / _e1482.x), vec2<f32>((_e1485.x - _e1487), _e1489.y).y) / vec2(2f)) + vec2(0.5f)), 0f);
                                                let _e1502 = height(_e1471, _e1501);
                                                dzdx_1 = (_e1470 - _e1502);
                                            }
                                            deltaY_1 = 0.0005f;
                                            let _e1506 = heightMap;
                                            if !(_e1506) {
                                                let _e1508 = intensity_3;
                                                let _e1509 = _intersection;
                                                let _e1511 = _intersection;
                                                let _e1513 = deltaY_1;
                                                let _e1519 = global.U[0];
                                                let _e1522 = _intersection;
                                                let _e1524 = _intersection;
                                                let _e1526 = deltaY_1;
                                                let _e1538 = textureSampleLevel(t_source, samp, ((vec2<f32>((vec2<f32>(_e1509.x, (_e1511.y + _e1513)).x / _e1519.x), vec2<f32>(_e1522.x, (_e1524.y + _e1526)).y) / vec2(2f)) + vec2(0.5f)), 0f);
                                                let _e1539 = height(_e1508, _e1538);
                                                let _e1540 = intensity_3;
                                                let _e1541 = _intersection;
                                                let _e1543 = _intersection;
                                                let _e1545 = deltaY_1;
                                                let _e1551 = global.U[0];
                                                let _e1554 = _intersection;
                                                let _e1556 = _intersection;
                                                let _e1558 = deltaY_1;
                                                let _e1570 = textureSampleLevel(t_source, samp, ((vec2<f32>((vec2<f32>(_e1541.x, (_e1543.y - _e1545)).x / _e1551.x), vec2<f32>(_e1554.x, (_e1556.y - _e1558)).y) / vec2(2f)) + vec2(0.5f)), 0f);
                                                let _e1571 = height(_e1540, _e1570);
                                                dzdy_1 = (_e1539 - _e1571);
                                            } else {
                                                let _e1573 = intensity_3;
                                                let _e1574 = _intersection;
                                                let _e1576 = _intersection;
                                                let _e1578 = deltaY_1;
                                                let _e1584 = global.U[0];
                                                let _e1587 = _intersection;
                                                let _e1589 = _intersection;
                                                let _e1591 = deltaY_1;
                                                let _e1603 = textureSampleLevel(t_sourceElevation, samp, ((vec2<f32>((vec2<f32>(_e1574.x, (_e1576.y + _e1578)).x / _e1584.x), vec2<f32>(_e1587.x, (_e1589.y + _e1591)).y) / vec2(2f)) + vec2(0.5f)), 0f);
                                                let _e1604 = height(_e1573, _e1603);
                                                let _e1605 = intensity_3;
                                                let _e1606 = _intersection;
                                                let _e1608 = _intersection;
                                                let _e1610 = deltaY_1;
                                                let _e1616 = global.U[0];
                                                let _e1619 = _intersection;
                                                let _e1621 = _intersection;
                                                let _e1623 = deltaY_1;
                                                let _e1635 = textureSampleLevel(t_sourceElevation, samp, ((vec2<f32>((vec2<f32>(_e1606.x, (_e1608.y - _e1610)).x / _e1616.x), vec2<f32>(_e1619.x, (_e1621.y - _e1623)).y) / vec2(2f)) + vec2(0.5f)), 0f);
                                                let _e1636 = height(_e1605, _e1635);
                                                dzdy_1 = (_e1604 - _e1636);
                                            }
                                            let _e1639 = dzdx_1;
                                            let _e1641 = deltaX_1;
                                            let _e1644 = dzdy_1;
                                            let _e1646 = deltaY_1;
                                            unormal_1 = vec3<f32>(((0.5f * _e1639) / _e1641), ((0.5f * _e1644) / _e1646), 1f);
                                            let _e1651 = unormal_1;
                                            let _e1655 = unormal_1;
                                            let _e1660 = unormal_1;
                                            if (((_e1651.x == 0f) && (_e1655.y == 0f)) && (_e1660.z == 0f)) {
                                                local_10 = vec3<f32>(0f, 0f, 1f);
                                            } else {
                                                let _e1669 = unormal_1;
                                                local_10 = normalize(_e1669);
                                            }
                                            let _e1672 = local_10;
                                            smoothNormal_1 = _e1672;
                                            let _e1674 = normal;
                                            let _e1675 = smoothNormal_1;
                                            let _e1676 = normalSmoothing_1;
                                            normal = mix(_e1674, _e1675, vec3(_e1676));
                                        }
                                    }
                                    let _e1679 = _intersection;
                                    let _e1680 = normal;
                                    let _e1681 = frameDist;
                                    let _e1684 = vec3<f32>(_e1681, 0f, 0f);
                                    intersection = mat3x3<f32>(vec3<f32>(_e1679.x, _e1679.y, _e1679.z), vec3<f32>(_e1680.x, _e1680.y, _e1680.z), vec3<f32>(_e1684.x, _e1684.y, _e1684.z));
                                }
                            }
                        }
                    }
                    let _e1700 = intersection[2];
                    let _e1702 = frameDist;
                    frameDist = min(_e1700.x, _e1702);
                    let _e1708 = intersection[0][0];
                    if (_e1708 != 100000000000000000000f) {
                        {
                            let _e1711 = intersectDist;
                            let _e1712 = cameraPos;
                            let _e1715 = intersection[0];
                            intersectDist = min(_e1711, length((_e1712 - _e1715)));
                            let _e1719 = colorScheme_1;
                            if (_e1719 == 0f) {
                                let _e1722 = squareCenter;
                                let _e1727 = global.U[0];
                                let _e1730 = squareCenter;
                                let _e1741 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e1722.x / _e1727.x), _e1730.y) / vec2(2f)) + vec2(0.5f)), 0f);
                                local_12 = _e1741;
                            } else {
                                let _e1742 = colorScheme_1;
                                if (_e1742 == 1f) {
                                    let _e1747 = intersection[0];
                                    let _e1752 = global.U[0];
                                    let _e1757 = intersection[0];
                                    let _e1768 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e1747.x / _e1752.x), _e1757.y) / vec2(2f)) + vec2(0.5f)), 0f);
                                    local_11 = _e1768;
                                } else {
                                    let _e1769 = squareCenter;
                                    let _e1774 = global.U[0];
                                    let _e1777 = squareCenter;
                                    let _e1788 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e1769.x / _e1774.x), _e1777.y) / vec2(2f)) + vec2(0.5f)), 0f);
                                    let _e1791 = intersection[0];
                                    let _e1796 = global.U[0];
                                    let _e1801 = intersection[0];
                                    let _e1812 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e1791.x / _e1796.x), _e1801.y) / vec2(2f)) + vec2(0.5f)), 0f);
                                    let _e1813 = colorScheme_1;
                                    local_11 = mix(_e1788, _e1812, vec4(_e1813));
                                }
                                let _e1817 = local_11;
                                local_12 = _e1817;
                            }
                            let _e1819 = local_12;
                            col = _e1819;
                            let _e1821 = col;
                            let _e1822 = colorAmbient_1;
                            let _e1825 = (_e1822.xyz * 2f);
                            let _e1826 = colorAmbient_1;
                            sampled = (_e1821 * vec4<f32>(_e1825.x, _e1825.y, _e1825.z, _e1826.w));
                            let _e1834 = colorSource_1;
                            if (length(_e1834.xyz) != 0f) {
                                {
                                    let _e1841 = intersection[1];
                                    normal_1 = _e1841;
                                    let _e1843 = normal_1;
                                    if (length(_e1843) > 0f) {
                                        {
                                            let _e1847 = sampled;
                                            alpha_1 = _e1847.w;
                                            let _e1850 = normal_1;
                                            normal_1 = normalize(_e1850);
                                            lightDir = normalize(vec3<f32>(1f, 1f, 1f));
                                            let _e1858 = sampled;
                                            let _e1859 = col;
                                            let _e1860 = colorSource_1;
                                            let _e1863 = (_e1860.xyz * 2f);
                                            let _e1870 = lightDir;
                                            let _e1871 = normal_1;
                                            sampled = (_e1858 + ((_e1859 * vec4<f32>(_e1863.x, _e1863.y, _e1863.z, 1f)) * clamp(dot(_e1870, _e1871), 0f, 1f)));
                                            let _e1878 = specular_1;
                                            if (_e1878 != 0f) {
                                                {
                                                    let _e1881 = lightDir;
                                                    let _e1882 = normal_1;
                                                    reflectLightDir = reflect(_e1881, _e1882);
                                                    let _e1885 = colorSource_1;
                                                    let _e1886 = specular_1;
                                                    if (_e1886 < 0.25f) {
                                                        let _e1889 = specular_1;
                                                        local_13 = (_e1889 * 4f);
                                                    } else {
                                                        local_13 = 1f;
                                                    }
                                                    let _e1894 = local_13;
                                                    let _e1896 = dir_10;
                                                    let _e1897 = reflectLightDir;
                                                    let _e1903 = specular_1;
                                                    specularColor = ((_e1885 * _e1894) * pow(clamp(dot(_e1896, _e1897), 0f, 1f), (10f - (_e1903 * 10f))));
                                                    let _e1910 = sampled;
                                                    let _e1911 = specularColor;
                                                    sampled = (_e1910 + _e1911);
                                                }
                                            }
                                            let _e1914 = alpha_1;
                                            sampled.w = _e1914;
                                        }
                                    }
                                }
                            }
                            let _e1915 = reflectivity_1;
                            if (_e1915 != 0f) {
                                {
                                    let _e1920 = intersection[1];
                                    normal_2 = _e1920;
                                    let _e1922 = dir_10;
                                    let _e1923 = normal_2;
                                    reflectDir = reflect(_e1922, _e1923);
                                    reflected = vec4<f32>(0f, 0f, 0f, 1f);
                                    let _e1932 = sourceBkg_specified_1;
                                    if (_e1932 == 1i) {
                                        {
                                            let _e1935 = reflectDir;
                                            let _e1936 = sourceBkgDim_11;
                                            let _e1937 = backgroundMode_5;
                                            let _e1938 = backgroundForReflection(_e1935, _e1936, _e1937);
                                            refDir = _e1938;
                                            let _e1940 = refDir;
                                            let _e1945 = global.U[0];
                                            let _e1948 = refDir;
                                            let _e1959 = textureSampleLevel(t_sourceBkg, samp, ((vec2<f32>((_e1940.x / _e1945.x), _e1948.y) / vec2(2f)) + vec2(0.5f)), 0f);
                                            let _e1960 = refDir;
                                            let _e1962 = vec3(_e1960.z);
                                            reflected = (_e1959 * vec4<f32>(_e1962.x, _e1962.y, _e1962.z, 1f));
                                        }
                                    }
                                    let _e1969 = reflected;
                                    let _e1971 = reflected;
                                    let _e1974 = reflected;
                                    lum = (((_e1969.x + _e1971.y) + _e1974.z) * 0.3333333f);
                                    let _e1981 = lum;
                                    let _e1982 = reflectivity_1;
                                    k_1 = min(1f, ((_e1981 * _e1982) * 10f));
                                    let _e1988 = sampled;
                                    let _e1989 = reflected;
                                    let _e1990 = k_1;
                                    sampled = mix(_e1988, _e1989, vec4(_e1990));
                                }
                            }
                            let _e1993 = intersected;
                            if (_e1993 == 0f) {
                                let _e1996 = sampled;
                                local_14 = _e1996;
                            } else {
                                let _e1997 = outColor;
                                let _e1999 = sampled;
                                let _e2001 = intersected;
                                let _e2002 = intersected;
                                let _e2003 = sampled;
                                let _e2008 = mix(_e1997.xyz, _e1999.xyz, vec3((_e2001 / (_e2002 + _e2003.w))));
                                let _e2009 = outColor;
                                let _e2012 = outColor;
                                let _e2015 = sampled;
                                local_14 = vec4<f32>(_e2008.x, _e2008.y, _e2008.z, (_e2009.w + ((1f - _e2012.w) * _e2015.w)));
                            }
                            let _e2024 = local_14;
                            outColor = _e2024;
                            let _e2025 = intersected;
                            let _e2026 = sampled;
                            intersected = (_e2025 + _e2026.w);
                        }
                    }
                }
            }
            let _e2029 = squareCenter;
            let _e2031 = nextLines;
            next = (_e2029.xy + _e2031);
            let _e2034 = next;
            let _e2035 = p;
            let _e2038 = dir_10;
            deltaK = ((_e2034 - _e2035.xy) / _e2038.xy);
            let _e2042 = deltaK;
            let _e2044 = deltaK;
            minK = min(_e2042.x, _e2044.y);
            let _e2048 = k;
            let _e2049 = minK;
            k = (_e2048 + _e2049);
            let _e2051 = p;
            let _e2052 = minK;
            let _e2053 = dir_10;
            p = (_e2051 + (_e2052 * _e2053));
            let _e2056 = maxIter;
            maxIter = (_e2056 - 1i);
        }
    }
    let _e2059 = color_2;
    let _e2060 = outColor;
    let _e2061 = _e2060.xyz;
    let _e2062 = color_2;
    let _e2068 = outColor;
    outColor = mix(_e2059, vec4<f32>(_e2061.x, _e2061.y, _e2061.z, _e2062.w), vec4(_e2068.w));
    let _e2072 = outColor;
    let _e2074 = colorLines_1;
    let _e2076 = colorLines_1;
    let _e2079 = mix(_e2072.xyz, _e2074.xyz, vec3(_e2076.w));
    frameColor = vec4<f32>(_e2079.x, _e2079.y, _e2079.z, 1f);
    let _e2086 = thickness_1;
    if (_e2086 == 0f) {
        local_16 = 0f;
    } else {
        let _e2093 = thickness_1;
        let _e2096 = frameDist;
        let _e2099 = glow_1;
        if (_e2099 == 0f) {
            local_15 = 0f;
        } else {
            let _e2104 = glow_1;
            let _e2107 = frameDist;
            local_15 = smoothstep((0.2f * _e2104), 0f, _e2107);
        }
        let _e2110 = local_15;
        local_16 = smoothstep(0f, 1f, (smoothstep((0.02f * _e2093), 0f, _e2096) + (0.4f * _e2110)));
    }
    let _e2115 = local_16;
    frameK = _e2115;
    let _e2117 = outColor;
    let _e2118 = frameColor;
    let _e2119 = frameK;
    outColor = mix(_e2117, _e2118, vec4(_e2119));
    let _e2122 = colorFog_1;
    if (_e2122.w != 0f) {
        {
            let _e2128 = colorFog_1;
            nearDist = (2f * (1f - _e2128.w));
            let _e2134 = nearDist;
            farDist = (2f * _e2134);
            let _e2137 = nearDist;
            let _e2138 = farDist;
            let _e2139 = intersectDist;
            kFog = smoothstep(_e2137, _e2138, _e2139);
            let _e2142 = outColor;
            let _e2144 = outColor;
            let _e2146 = colorFog_1;
            let _e2148 = kFog;
            let _e2150 = mix(_e2144.xyz, _e2146.xyz, vec3(_e2148));
            outColor.x = _e2150.x;
            outColor.y = _e2150.y;
            outColor.z = _e2150.z;
        }
    }
    let _e2157 = outColor;
    return _e2157;
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
    let _e68 = global.U[10];
    let _e72 = global.U[11];
    let _e77 = global.U[12];
    let _e81 = global.U[13];
    let _e85 = global.U[14];
    let _e89 = global.U[15];
    let _e93 = global.U[16];
    let _e96 = global.U[17];
    let _e99 = global.U[18];
    let _e102 = global.U[19];
    let _e126 = global.U[4];
    let _e130 = global.U[5];
    let _e134 = global.U[6];
    let _e138 = global.U[7];
    let _e143 = global.U[8];
    let _e148 = global.U[20];
    let _e153 = global.U[21];
    let _e157 = global.U[22];
    let _e161 = global.U[23];
    let _e164 = global.U[24];
    let _e167 = global.U[25];
    let _e170 = global.U[26];
    let _e173 = global.U[27];
    let _e174 = mesh3d((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e11.x, _e11.y, _e11.z), vec3<f32>(_e15.x, _e15.y, _e15.z), vec3<f32>(_e19.x, _e19.y, _e19.z))) * vec3<f32>(_e46.x, _e46.y, 1f)).xy, (((_e53 - vec2(0.5f)) * 2f) * vec2<f32>(_e61.x, 1f)), _e68.x, i32(_e72.x), _e77.x, _e81.x, _e85.x, _e89.x, mat4x4<f32>(vec4<f32>(_e93.x, _e93.y, _e93.z, _e93.w), vec4<f32>(_e96.x, _e96.y, _e96.z, _e96.w), vec4<f32>(_e99.x, _e99.y, _e99.z, _e99.w), vec4<f32>(_e102.x, _e102.y, _e102.z, _e102.w)), _e126.xy, _e130.xy, _e134.xy, i32(_e138.x), i32(_e143.x), i32(_e148.x), _e153.x, _e157.x, _e161, _e164, _e167, _e170, _e173);
    fragColor = _e174;
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
