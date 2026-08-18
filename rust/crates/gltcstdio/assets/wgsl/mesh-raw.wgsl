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
            let _e292 = textureSample(t_sourceBkg, samp, ((vec2<f32>((_e274.x / _e279.x), _e282.y) / vec2(2f)) + vec2(0.5f)));
            let _e293 = bkgDir;
            let _e295 = vec3(_e293.z);
            color_2 = (_e292 * vec4<f32>(_e295.x, _e295.y, _e295.z, 1f));
        }
    }
    let _e302 = k1_;
    let _e303 = k2_;
    if (_e302 > _e303) {
        let _e305 = colorFog_1;
        if (_e305.w != 0f) {
            let _e309 = colorFog_1;
            let _e310 = _e309.xyz;
            local_3 = vec4<f32>(_e310.x, _e310.y, _e310.z, 1f);
        } else {
            let _e316 = color_2;
            local_3 = _e316;
        }
        let _e318 = local_3;
        return _e318;
    }
    let _e323 = color_2;
    outColor = _e323;
    let _e325 = dir_10;
    let _e328 = squareSize;
    nextLines = ((sign(_e325.xy) * _e328) / vec2(2f));
    loop {
        let _e338 = intersected;
        let _e341 = k;
        let _e342 = k2_;
        let _e345 = maxIter;
        if !((((_e338 < 1f) && (_e341 <= _e342)) && (_e345 > 0i))) {
            break;
        }
        {
            let _e350 = p;
            let _e352 = surfaceWidth;
            let _e356 = squareSize;
            indexX = ((_e350.x + (_e352 / 2f)) / _e356);
            let _e359 = p;
            let _e361 = surfaceHeight;
            let _e365 = squareSize;
            indexY = ((_e359.y + (_e361 / 2f)) / _e365);
            let _e368 = indexX;
            fX = fract(_e368);
            let _e371 = indexY;
            fY = fract(_e371);
            let _e375 = fX;
            let _e378 = dir_10;
            if ((_e375 > 0.9999f) && (_e378.x > 0f)) {
                let _e384 = indexX;
                let _e388 = squareSize;
                squareCenter.x = ((ceil(_e384) + 0.5f) * _e388);
            } else {
                let _e390 = fX;
                let _e393 = dir_10;
                if ((_e390 < 0.0001f) && (_e393.x < 0f)) {
                    let _e399 = indexX;
                    let _e403 = squareSize;
                    squareCenter.x = ((floor(_e399) - 0.5f) * _e403);
                } else {
                    let _e406 = indexX;
                    let _e410 = squareSize;
                    squareCenter.x = ((floor(_e406) + 0.5f) * _e410);
                }
            }
            let _e413 = squareCenter;
            let _e415 = surfaceWidth;
            squareCenter.x = (_e413.x - (_e415 / 2f));
            let _e419 = fY;
            let _e422 = dir_10;
            if ((_e419 > 0.9999f) && (_e422.y > 0f)) {
                let _e428 = indexY;
                let _e432 = squareSize;
                squareCenter.y = ((ceil(_e428) + 0.5f) * _e432);
            } else {
                let _e434 = fY;
                let _e437 = dir_10;
                if ((_e434 < 0.0001f) && (_e437.y < 0f)) {
                    let _e443 = indexY;
                    let _e447 = squareSize;
                    squareCenter.y = ((floor(_e443) - 0.5f) * _e447);
                } else {
                    let _e450 = indexY;
                    let _e454 = squareSize;
                    squareCenter.y = ((floor(_e450) + 0.5f) * _e454);
                }
            }
            let _e457 = squareCenter;
            let _e459 = surfaceHeight;
            squareCenter.y = (_e457.y - (_e459 / 2f));
            let _e463 = squareCenter;
            let _e466 = surfaceWidth;
            let _e470 = squareCenter;
            let _e473 = surfaceHeight;
            if ((abs(_e463.x) < (_e466 / 2f)) && (abs(_e470.y) < (_e473 / 2f))) {
                {
                    let _e478 = squareCenter;
                    let _e479 = squareSize;
                    let _e480 = squareSize;
                    bottomLeft = (_e478 - (vec2<f32>(_e479, _e480) / vec2(2f)));
                    let _e488 = squareSize;
                    s_3 = vec2<f32>(_e488, 0f);
                    let _e492 = bottomLeft;
                    let _e493 = s_3;
                    p11_ = (_e492 + _e493.xx);
                    let _e497 = heightMap;
                    if _e497 {
                        let _e498 = bottomLeft;
                        let _e502 = global.U[0];
                        let _e505 = bottomLeft;
                        let _e514 = textureSample(t_sourceElevation, samp, ((vec2<f32>((_e498.x / _e502.x), _e505.y) / vec2(2f)) + vec2(0.5f)));
                        local_4 = _e514;
                    } else {
                        let _e515 = bottomLeft;
                        let _e519 = global.U[0];
                        let _e522 = bottomLeft;
                        let _e531 = textureSample(t_source, samp, ((vec2<f32>((_e515.x / _e519.x), _e522.y) / vec2(2f)) + vec2(0.5f)));
                        local_4 = _e531;
                    }
                    let _e533 = local_4;
                    c00_ = _e533;
                    let _e535 = intensity_3;
                    let _e536 = c00_;
                    let _e537 = height(_e535, _e536);
                    h00_ = _e537;
                    let _e539 = bottomLeft;
                    let _e540 = h00_;
                    A = vec3<f32>(_e539.x, _e539.y, _e540);
                    let _e545 = heightMap;
                    if _e545 {
                        let _e546 = bottomLeft;
                        let _e547 = s_3;
                        let _e552 = global.U[0];
                        let _e555 = bottomLeft;
                        let _e556 = s_3;
                        let _e566 = textureSample(t_sourceElevation, samp, ((vec2<f32>(((_e546 + _e547).x / _e552.x), (_e555 + _e556).y) / vec2(2f)) + vec2(0.5f)));
                        local_5 = _e566;
                    } else {
                        let _e567 = bottomLeft;
                        let _e568 = s_3;
                        let _e573 = global.U[0];
                        let _e576 = bottomLeft;
                        let _e577 = s_3;
                        let _e587 = textureSample(t_source, samp, ((vec2<f32>(((_e567 + _e568).x / _e573.x), (_e576 + _e577).y) / vec2(2f)) + vec2(0.5f)));
                        local_5 = _e587;
                    }
                    let _e589 = local_5;
                    c10_ = _e589;
                    let _e591 = intensity_3;
                    let _e592 = c10_;
                    let _e593 = height(_e591, _e592);
                    h10_ = _e593;
                    let _e595 = bottomLeft;
                    let _e596 = s_3;
                    let _e597 = (_e595 + _e596);
                    let _e598 = h10_;
                    B = vec3<f32>(_e597.x, _e597.y, _e598);
                    let _e603 = heightMap;
                    if _e603 {
                        let _e604 = bottomLeft;
                        let _e605 = s_3;
                        let _e611 = global.U[0];
                        let _e614 = bottomLeft;
                        let _e615 = s_3;
                        let _e626 = textureSample(t_sourceElevation, samp, ((vec2<f32>(((_e604 + _e605.yx).x / _e611.x), (_e614 + _e615.yx).y) / vec2(2f)) + vec2(0.5f)));
                        local_6 = _e626;
                    } else {
                        let _e627 = bottomLeft;
                        let _e628 = s_3;
                        let _e634 = global.U[0];
                        let _e637 = bottomLeft;
                        let _e638 = s_3;
                        let _e649 = textureSample(t_source, samp, ((vec2<f32>(((_e627 + _e628.yx).x / _e634.x), (_e637 + _e638.yx).y) / vec2(2f)) + vec2(0.5f)));
                        local_6 = _e649;
                    }
                    let _e651 = local_6;
                    c01_ = _e651;
                    let _e653 = intensity_3;
                    let _e654 = c01_;
                    let _e655 = height(_e653, _e654);
                    h01_ = _e655;
                    let _e657 = bottomLeft;
                    let _e658 = s_3;
                    let _e660 = (_e657 + _e658.yx);
                    let _e661 = h01_;
                    C = vec3<f32>(_e660.x, _e660.y, _e661);
                    let _e666 = heightMap;
                    if _e666 {
                        let _e667 = p11_;
                        let _e671 = global.U[0];
                        let _e674 = p11_;
                        let _e683 = textureSample(t_sourceElevation, samp, ((vec2<f32>((_e667.x / _e671.x), _e674.y) / vec2(2f)) + vec2(0.5f)));
                        local_7 = _e683;
                    } else {
                        let _e684 = p11_;
                        let _e688 = global.U[0];
                        let _e691 = p11_;
                        let _e700 = textureSample(t_source, samp, ((vec2<f32>((_e684.x / _e688.x), _e691.y) / vec2(2f)) + vec2(0.5f)));
                        local_7 = _e700;
                    }
                    let _e702 = local_7;
                    c11_ = _e702;
                    let _e704 = intensity_3;
                    let _e705 = c11_;
                    let _e706 = height(_e704, _e705);
                    h11_ = _e706;
                    let _e708 = p11_;
                    let _e709 = h11_;
                    D_2 = vec3<f32>(_e708.x, _e708.y, _e709);
                    let _e714 = p;
                    let _e716 = dir_10;
                    inf = (_e714 + (1000000f * _e716));
                    let _e720 = thickness_1;
                    if (_e720 == 0f) {
                        local_8 = 1000000000f;
                    } else {
                        let _e724 = p;
                        let _e725 = inf;
                        let _e726 = A;
                        let _e727 = B;
                        let _e728 = distSegSeg(_e724, _e725, _e726, _e727);
                        let _e729 = p;
                        let _e730 = inf;
                        let _e731 = C;
                        let _e732 = D_2;
                        let _e733 = distSegSeg(_e729, _e730, _e731, _e732);
                        let _e735 = p;
                        let _e736 = inf;
                        let _e737 = A;
                        let _e738 = C;
                        let _e739 = distSegSeg(_e735, _e736, _e737, _e738);
                        let _e740 = p;
                        let _e741 = inf;
                        let _e742 = B;
                        let _e743 = D_2;
                        let _e744 = distSegSeg(_e740, _e741, _e742, _e743);
                        local_8 = min(min(_e728, _e733), min(_e739, _e744));
                    }
                    let _e748 = local_8;
                    _frameDist = _e748;
                    let _e750 = h10_;
                    let _e751 = h00_;
                    let _e753 = squareSize;
                    dzx1_ = ((_e750 - _e751) / _e753);
                    let _e756 = h01_;
                    let _e757 = h00_;
                    let _e759 = squareSize;
                    dzy1_ = ((_e756 - _e757) / _e759);
                    let _e762 = h00_;
                    let _e763 = p;
                    let _e766 = p;
                    let _e768 = bottomLeft;
                    let _e771 = dzx1_;
                    let _e774 = p;
                    let _e776 = bottomLeft;
                    let _e779 = dzy1_;
                    let _e782 = dir_10;
                    let _e784 = dir_10;
                    let _e786 = dzx1_;
                    let _e789 = dir_10;
                    let _e791 = dzy1_;
                    k1_1 = ((((_e762 - _e763.z) + ((_e766.x - _e768.x) * _e771)) + ((_e774.y - _e776.y) * _e779)) / ((_e782.z - (_e784.x * _e786)) - (_e789.y * _e791)));
                    let _e796 = h01_;
                    let _e797 = h11_;
                    let _e800 = squareSize;
                    dzx2_ = (-((_e796 - _e797)) / _e800);
                    let _e803 = h10_;
                    let _e804 = h11_;
                    let _e807 = squareSize;
                    dzy2_ = (-((_e803 - _e804)) / _e807);
                    let _e810 = h11_;
                    let _e811 = p;
                    let _e814 = p;
                    let _e816 = p11_;
                    let _e819 = dzx2_;
                    let _e822 = p;
                    let _e824 = p11_;
                    let _e827 = dzy2_;
                    let _e830 = dir_10;
                    let _e832 = dir_10;
                    let _e834 = dzx2_;
                    let _e837 = dir_10;
                    let _e839 = dzy2_;
                    k2_1 = ((((_e810 - _e811.z) + ((_e814.x - _e816.x) * _e819)) + ((_e822.y - _e824.y) * _e827)) / ((_e830.z - (_e832.x * _e834)) - (_e837.y * _e839)));
                    normal = vec3<f32>(0f, 0f, 0f);
                    _intersection = vec3<f32>(100000000000000000000f, 100000000000000000000f, 100000000000000000000f);
                    let _e862 = _frameDist;
                    let _e865 = vec3<f32>(_e862, 0f, 0f);
                    intersection = mat3x3<f32>(vec3<f32>(100000000000000000000f, 100000000000000000000f, 100000000000000000000f), vec3<f32>(0f, 0f, 0f), vec3<f32>(_e865.x, _e865.y, _e865.z));
                    let _e873 = k1_1;
                    if (_e873 > 0f) {
                        {
                            let _e876 = p;
                            let _e877 = k1_1;
                            let _e878 = dir_10;
                            _intersection = (_e876 + (_e877 * _e878));
                            let _e881 = _intersection;
                            let _e883 = bottomLeft;
                            relInt = (_e881.xy - _e883.xy);
                            let _e887 = relInt;
                            let _e891 = relInt;
                            let _e893 = squareSize;
                            let _e896 = relInt;
                            let _e901 = relInt;
                            let _e903 = squareSize;
                            let _e906 = squareSize;
                            let _e907 = relInt;
                            let _e910 = relInt;
                            if (((((_e887.x >= 0f) && (_e891.x <= _e893)) && (_e896.y >= 0f)) && (_e901.y <= _e903)) && ((_e906 - _e907.x) >= _e910.y)) {
                                {
                                    let _e914 = squareSize;
                                    let _e916 = h10_;
                                    let _e917 = h00_;
                                    let _e921 = squareSize;
                                    let _e922 = h01_;
                                    let _e923 = h00_;
                                    let _e928 = squareSize;
                                    let _e931 = h01_;
                                    let _e932 = h11_;
                                    let _e936 = squareSize;
                                    let _e938 = h10_;
                                    let _e939 = h11_;
                                    normal = normalize(mix(normalize(cross(vec3<f32>(_e914, 0f, (_e916 - _e917)), vec3<f32>(0f, _e921, (_e922 - _e923)))), normalize(cross(vec3<f32>(-(_e928), 0f, (_e931 - _e932)), vec3<f32>(0f, -(_e936), (_e938 - _e939)))), vec3(0.5f)));
                                    let _e948 = normalSmoothing_1;
                                    if (_e948 != 0f) {
                                        {
                                            deltaX = 0.0005f;
                                            let _e955 = heightMap;
                                            if !(_e955) {
                                                let _e957 = intensity_3;
                                                let _e958 = _intersection;
                                                let _e960 = deltaX;
                                                let _e962 = _intersection;
                                                let _e968 = global.U[0];
                                                let _e971 = _intersection;
                                                let _e973 = deltaX;
                                                let _e975 = _intersection;
                                                let _e986 = textureSample(t_source, samp, ((vec2<f32>((vec2<f32>((_e958.x + _e960), _e962.y).x / _e968.x), vec2<f32>((_e971.x + _e973), _e975.y).y) / vec2(2f)) + vec2(0.5f)));
                                                let _e987 = height(_e957, _e986);
                                                let _e988 = intensity_3;
                                                let _e989 = _intersection;
                                                let _e991 = deltaX;
                                                let _e993 = _intersection;
                                                let _e999 = global.U[0];
                                                let _e1002 = _intersection;
                                                let _e1004 = deltaX;
                                                let _e1006 = _intersection;
                                                let _e1017 = textureSample(t_source, samp, ((vec2<f32>((vec2<f32>((_e989.x - _e991), _e993.y).x / _e999.x), vec2<f32>((_e1002.x - _e1004), _e1006.y).y) / vec2(2f)) + vec2(0.5f)));
                                                let _e1018 = height(_e988, _e1017);
                                                dzdx = (_e987 - _e1018);
                                            } else {
                                                let _e1020 = intensity_3;
                                                let _e1021 = _intersection;
                                                let _e1023 = deltaX;
                                                let _e1025 = _intersection;
                                                let _e1031 = global.U[0];
                                                let _e1034 = _intersection;
                                                let _e1036 = deltaX;
                                                let _e1038 = _intersection;
                                                let _e1049 = textureSample(t_sourceElevation, samp, ((vec2<f32>((vec2<f32>((_e1021.x + _e1023), _e1025.y).x / _e1031.x), vec2<f32>((_e1034.x + _e1036), _e1038.y).y) / vec2(2f)) + vec2(0.5f)));
                                                let _e1050 = height(_e1020, _e1049);
                                                let _e1051 = intensity_3;
                                                let _e1052 = _intersection;
                                                let _e1054 = deltaX;
                                                let _e1056 = _intersection;
                                                let _e1062 = global.U[0];
                                                let _e1065 = _intersection;
                                                let _e1067 = deltaX;
                                                let _e1069 = _intersection;
                                                let _e1080 = textureSample(t_sourceElevation, samp, ((vec2<f32>((vec2<f32>((_e1052.x - _e1054), _e1056.y).x / _e1062.x), vec2<f32>((_e1065.x - _e1067), _e1069.y).y) / vec2(2f)) + vec2(0.5f)));
                                                let _e1081 = height(_e1051, _e1080);
                                                dzdx = (_e1050 - _e1081);
                                            }
                                            deltaY = 0.0005f;
                                            let _e1085 = heightMap;
                                            if !(_e1085) {
                                                let _e1087 = intensity_3;
                                                let _e1088 = _intersection;
                                                let _e1090 = _intersection;
                                                let _e1092 = deltaY;
                                                let _e1098 = global.U[0];
                                                let _e1101 = _intersection;
                                                let _e1103 = _intersection;
                                                let _e1105 = deltaY;
                                                let _e1116 = textureSample(t_source, samp, ((vec2<f32>((vec2<f32>(_e1088.x, (_e1090.y + _e1092)).x / _e1098.x), vec2<f32>(_e1101.x, (_e1103.y + _e1105)).y) / vec2(2f)) + vec2(0.5f)));
                                                let _e1117 = height(_e1087, _e1116);
                                                let _e1118 = intensity_3;
                                                let _e1119 = _intersection;
                                                let _e1121 = _intersection;
                                                let _e1123 = deltaY;
                                                let _e1129 = global.U[0];
                                                let _e1132 = _intersection;
                                                let _e1134 = _intersection;
                                                let _e1136 = deltaY;
                                                let _e1147 = textureSample(t_source, samp, ((vec2<f32>((vec2<f32>(_e1119.x, (_e1121.y - _e1123)).x / _e1129.x), vec2<f32>(_e1132.x, (_e1134.y - _e1136)).y) / vec2(2f)) + vec2(0.5f)));
                                                let _e1148 = height(_e1118, _e1147);
                                                dzdy = (_e1117 - _e1148);
                                            } else {
                                                let _e1150 = intensity_3;
                                                let _e1151 = _intersection;
                                                let _e1153 = _intersection;
                                                let _e1155 = deltaY;
                                                let _e1161 = global.U[0];
                                                let _e1164 = _intersection;
                                                let _e1166 = _intersection;
                                                let _e1168 = deltaY;
                                                let _e1179 = textureSample(t_sourceElevation, samp, ((vec2<f32>((vec2<f32>(_e1151.x, (_e1153.y + _e1155)).x / _e1161.x), vec2<f32>(_e1164.x, (_e1166.y + _e1168)).y) / vec2(2f)) + vec2(0.5f)));
                                                let _e1180 = height(_e1150, _e1179);
                                                let _e1181 = intensity_3;
                                                let _e1182 = _intersection;
                                                let _e1184 = _intersection;
                                                let _e1186 = deltaY;
                                                let _e1192 = global.U[0];
                                                let _e1195 = _intersection;
                                                let _e1197 = _intersection;
                                                let _e1199 = deltaY;
                                                let _e1210 = textureSample(t_sourceElevation, samp, ((vec2<f32>((vec2<f32>(_e1182.x, (_e1184.y - _e1186)).x / _e1192.x), vec2<f32>(_e1195.x, (_e1197.y - _e1199)).y) / vec2(2f)) + vec2(0.5f)));
                                                let _e1211 = height(_e1181, _e1210);
                                                dzdy = (_e1180 - _e1211);
                                            }
                                            let _e1214 = dzdx;
                                            let _e1216 = deltaX;
                                            let _e1219 = dzdy;
                                            let _e1221 = deltaY;
                                            unormal = vec3<f32>(((0.5f * _e1214) / _e1216), ((0.5f * _e1219) / _e1221), 1f);
                                            let _e1226 = unormal;
                                            let _e1230 = unormal;
                                            let _e1235 = unormal;
                                            if (((_e1226.x == 0f) && (_e1230.y == 0f)) && (_e1235.z == 0f)) {
                                                local_9 = vec3<f32>(0f, 0f, 1f);
                                            } else {
                                                let _e1244 = unormal;
                                                local_9 = normalize(_e1244);
                                            }
                                            let _e1247 = local_9;
                                            smoothNormal = _e1247;
                                            let _e1249 = normal;
                                            let _e1250 = smoothNormal;
                                            let _e1251 = normalSmoothing_1;
                                            normal = mix(_e1249, _e1250, vec3(_e1251));
                                        }
                                    }
                                    let _e1254 = _intersection;
                                    let _e1255 = normal;
                                    let _e1256 = frameDist;
                                    let _e1259 = vec3<f32>(_e1256, 0f, 0f);
                                    intersection = mat3x3<f32>(vec3<f32>(_e1254.x, _e1254.y, _e1254.z), vec3<f32>(_e1255.x, _e1255.y, _e1255.z), vec3<f32>(_e1259.x, _e1259.y, _e1259.z));
                                }
                            }
                        }
                    }
                    let _e1273 = k2_1;
                    if (_e1273 > 0f) {
                        {
                            let _e1276 = p;
                            let _e1277 = k2_1;
                            let _e1278 = dir_10;
                            _intersection = (_e1276 + (_e1277 * _e1278));
                            let _e1281 = _intersection;
                            let _e1283 = bottomLeft;
                            relInt_1 = (_e1281.xy - _e1283.xy);
                            let _e1287 = relInt_1;
                            let _e1291 = relInt_1;
                            let _e1293 = squareSize;
                            let _e1296 = relInt_1;
                            let _e1301 = relInt_1;
                            let _e1303 = squareSize;
                            let _e1306 = squareSize;
                            let _e1307 = relInt_1;
                            let _e1310 = relInt_1;
                            if (((((_e1287.x >= 0f) && (_e1291.x <= _e1293)) && (_e1296.y >= 0f)) && (_e1301.y <= _e1303)) && ((_e1306 - _e1307.x) <= _e1310.y)) {
                                {
                                    let _e1314 = squareSize;
                                    let _e1316 = h10_;
                                    let _e1317 = h00_;
                                    let _e1321 = squareSize;
                                    let _e1322 = h01_;
                                    let _e1323 = h00_;
                                    let _e1328 = squareSize;
                                    let _e1331 = h01_;
                                    let _e1332 = h11_;
                                    let _e1336 = squareSize;
                                    let _e1338 = h10_;
                                    let _e1339 = h11_;
                                    normal = normalize(mix(normalize(cross(vec3<f32>(_e1314, 0f, (_e1316 - _e1317)), vec3<f32>(0f, _e1321, (_e1322 - _e1323)))), normalize(cross(vec3<f32>(-(_e1328), 0f, (_e1331 - _e1332)), vec3<f32>(0f, -(_e1336), (_e1338 - _e1339)))), vec3(0.5f)));
                                    let _e1348 = normalSmoothing_1;
                                    if (_e1348 != 0f) {
                                        {
                                            deltaX_1 = 0.0005f;
                                            let _e1355 = heightMap;
                                            if !(_e1355) {
                                                let _e1357 = intensity_3;
                                                let _e1358 = _intersection;
                                                let _e1360 = deltaX_1;
                                                let _e1362 = _intersection;
                                                let _e1368 = global.U[0];
                                                let _e1371 = _intersection;
                                                let _e1373 = deltaX_1;
                                                let _e1375 = _intersection;
                                                let _e1386 = textureSample(t_source, samp, ((vec2<f32>((vec2<f32>((_e1358.x + _e1360), _e1362.y).x / _e1368.x), vec2<f32>((_e1371.x + _e1373), _e1375.y).y) / vec2(2f)) + vec2(0.5f)));
                                                let _e1387 = height(_e1357, _e1386);
                                                let _e1388 = intensity_3;
                                                let _e1389 = _intersection;
                                                let _e1391 = deltaX_1;
                                                let _e1393 = _intersection;
                                                let _e1399 = global.U[0];
                                                let _e1402 = _intersection;
                                                let _e1404 = deltaX_1;
                                                let _e1406 = _intersection;
                                                let _e1417 = textureSample(t_source, samp, ((vec2<f32>((vec2<f32>((_e1389.x - _e1391), _e1393.y).x / _e1399.x), vec2<f32>((_e1402.x - _e1404), _e1406.y).y) / vec2(2f)) + vec2(0.5f)));
                                                let _e1418 = height(_e1388, _e1417);
                                                dzdx_1 = (_e1387 - _e1418);
                                            } else {
                                                let _e1420 = intensity_3;
                                                let _e1421 = _intersection;
                                                let _e1423 = deltaX_1;
                                                let _e1425 = _intersection;
                                                let _e1431 = global.U[0];
                                                let _e1434 = _intersection;
                                                let _e1436 = deltaX_1;
                                                let _e1438 = _intersection;
                                                let _e1449 = textureSample(t_sourceElevation, samp, ((vec2<f32>((vec2<f32>((_e1421.x + _e1423), _e1425.y).x / _e1431.x), vec2<f32>((_e1434.x + _e1436), _e1438.y).y) / vec2(2f)) + vec2(0.5f)));
                                                let _e1450 = height(_e1420, _e1449);
                                                let _e1451 = intensity_3;
                                                let _e1452 = _intersection;
                                                let _e1454 = deltaX_1;
                                                let _e1456 = _intersection;
                                                let _e1462 = global.U[0];
                                                let _e1465 = _intersection;
                                                let _e1467 = deltaX_1;
                                                let _e1469 = _intersection;
                                                let _e1480 = textureSample(t_sourceElevation, samp, ((vec2<f32>((vec2<f32>((_e1452.x - _e1454), _e1456.y).x / _e1462.x), vec2<f32>((_e1465.x - _e1467), _e1469.y).y) / vec2(2f)) + vec2(0.5f)));
                                                let _e1481 = height(_e1451, _e1480);
                                                dzdx_1 = (_e1450 - _e1481);
                                            }
                                            deltaY_1 = 0.0005f;
                                            let _e1485 = heightMap;
                                            if !(_e1485) {
                                                let _e1487 = intensity_3;
                                                let _e1488 = _intersection;
                                                let _e1490 = _intersection;
                                                let _e1492 = deltaY_1;
                                                let _e1498 = global.U[0];
                                                let _e1501 = _intersection;
                                                let _e1503 = _intersection;
                                                let _e1505 = deltaY_1;
                                                let _e1516 = textureSample(t_source, samp, ((vec2<f32>((vec2<f32>(_e1488.x, (_e1490.y + _e1492)).x / _e1498.x), vec2<f32>(_e1501.x, (_e1503.y + _e1505)).y) / vec2(2f)) + vec2(0.5f)));
                                                let _e1517 = height(_e1487, _e1516);
                                                let _e1518 = intensity_3;
                                                let _e1519 = _intersection;
                                                let _e1521 = _intersection;
                                                let _e1523 = deltaY_1;
                                                let _e1529 = global.U[0];
                                                let _e1532 = _intersection;
                                                let _e1534 = _intersection;
                                                let _e1536 = deltaY_1;
                                                let _e1547 = textureSample(t_source, samp, ((vec2<f32>((vec2<f32>(_e1519.x, (_e1521.y - _e1523)).x / _e1529.x), vec2<f32>(_e1532.x, (_e1534.y - _e1536)).y) / vec2(2f)) + vec2(0.5f)));
                                                let _e1548 = height(_e1518, _e1547);
                                                dzdy_1 = (_e1517 - _e1548);
                                            } else {
                                                let _e1550 = intensity_3;
                                                let _e1551 = _intersection;
                                                let _e1553 = _intersection;
                                                let _e1555 = deltaY_1;
                                                let _e1561 = global.U[0];
                                                let _e1564 = _intersection;
                                                let _e1566 = _intersection;
                                                let _e1568 = deltaY_1;
                                                let _e1579 = textureSample(t_sourceElevation, samp, ((vec2<f32>((vec2<f32>(_e1551.x, (_e1553.y + _e1555)).x / _e1561.x), vec2<f32>(_e1564.x, (_e1566.y + _e1568)).y) / vec2(2f)) + vec2(0.5f)));
                                                let _e1580 = height(_e1550, _e1579);
                                                let _e1581 = intensity_3;
                                                let _e1582 = _intersection;
                                                let _e1584 = _intersection;
                                                let _e1586 = deltaY_1;
                                                let _e1592 = global.U[0];
                                                let _e1595 = _intersection;
                                                let _e1597 = _intersection;
                                                let _e1599 = deltaY_1;
                                                let _e1610 = textureSample(t_sourceElevation, samp, ((vec2<f32>((vec2<f32>(_e1582.x, (_e1584.y - _e1586)).x / _e1592.x), vec2<f32>(_e1595.x, (_e1597.y - _e1599)).y) / vec2(2f)) + vec2(0.5f)));
                                                let _e1611 = height(_e1581, _e1610);
                                                dzdy_1 = (_e1580 - _e1611);
                                            }
                                            let _e1614 = dzdx_1;
                                            let _e1616 = deltaX_1;
                                            let _e1619 = dzdy_1;
                                            let _e1621 = deltaY_1;
                                            unormal_1 = vec3<f32>(((0.5f * _e1614) / _e1616), ((0.5f * _e1619) / _e1621), 1f);
                                            let _e1626 = unormal_1;
                                            let _e1630 = unormal_1;
                                            let _e1635 = unormal_1;
                                            if (((_e1626.x == 0f) && (_e1630.y == 0f)) && (_e1635.z == 0f)) {
                                                local_10 = vec3<f32>(0f, 0f, 1f);
                                            } else {
                                                let _e1644 = unormal_1;
                                                local_10 = normalize(_e1644);
                                            }
                                            let _e1647 = local_10;
                                            smoothNormal_1 = _e1647;
                                            let _e1649 = normal;
                                            let _e1650 = smoothNormal_1;
                                            let _e1651 = normalSmoothing_1;
                                            normal = mix(_e1649, _e1650, vec3(_e1651));
                                        }
                                    }
                                    let _e1654 = _intersection;
                                    let _e1655 = normal;
                                    let _e1656 = frameDist;
                                    let _e1659 = vec3<f32>(_e1656, 0f, 0f);
                                    intersection = mat3x3<f32>(vec3<f32>(_e1654.x, _e1654.y, _e1654.z), vec3<f32>(_e1655.x, _e1655.y, _e1655.z), vec3<f32>(_e1659.x, _e1659.y, _e1659.z));
                                }
                            }
                        }
                    }
                    let _e1675 = intersection[2];
                    let _e1677 = frameDist;
                    frameDist = min(_e1675.x, _e1677);
                    let _e1683 = intersection[0][0];
                    if (_e1683 != 100000000000000000000f) {
                        {
                            let _e1686 = intersectDist;
                            let _e1687 = cameraPos;
                            let _e1690 = intersection[0];
                            intersectDist = min(_e1686, length((_e1687 - _e1690)));
                            let _e1694 = colorScheme_1;
                            if (_e1694 == 0f) {
                                let _e1697 = squareCenter;
                                let _e1702 = global.U[0];
                                let _e1705 = squareCenter;
                                let _e1715 = textureSample(t_source, samp, ((vec2<f32>((_e1697.x / _e1702.x), _e1705.y) / vec2(2f)) + vec2(0.5f)));
                                local_12 = _e1715;
                            } else {
                                let _e1716 = colorScheme_1;
                                if (_e1716 == 1f) {
                                    let _e1721 = intersection[0];
                                    let _e1726 = global.U[0];
                                    let _e1731 = intersection[0];
                                    let _e1741 = textureSample(t_source, samp, ((vec2<f32>((_e1721.x / _e1726.x), _e1731.y) / vec2(2f)) + vec2(0.5f)));
                                    local_11 = _e1741;
                                } else {
                                    let _e1742 = squareCenter;
                                    let _e1747 = global.U[0];
                                    let _e1750 = squareCenter;
                                    let _e1760 = textureSample(t_source, samp, ((vec2<f32>((_e1742.x / _e1747.x), _e1750.y) / vec2(2f)) + vec2(0.5f)));
                                    let _e1763 = intersection[0];
                                    let _e1768 = global.U[0];
                                    let _e1773 = intersection[0];
                                    let _e1783 = textureSample(t_source, samp, ((vec2<f32>((_e1763.x / _e1768.x), _e1773.y) / vec2(2f)) + vec2(0.5f)));
                                    let _e1784 = colorScheme_1;
                                    local_11 = mix(_e1760, _e1783, vec4(_e1784));
                                }
                                let _e1788 = local_11;
                                local_12 = _e1788;
                            }
                            let _e1790 = local_12;
                            col = _e1790;
                            let _e1792 = col;
                            let _e1793 = colorAmbient_1;
                            let _e1796 = (_e1793.xyz * 2f);
                            let _e1797 = colorAmbient_1;
                            sampled = (_e1792 * vec4<f32>(_e1796.x, _e1796.y, _e1796.z, _e1797.w));
                            let _e1805 = colorSource_1;
                            if (length(_e1805.xyz) != 0f) {
                                {
                                    let _e1812 = intersection[1];
                                    normal_1 = _e1812;
                                    let _e1814 = normal_1;
                                    if (length(_e1814) > 0f) {
                                        {
                                            let _e1818 = sampled;
                                            alpha_1 = _e1818.w;
                                            let _e1821 = normal_1;
                                            normal_1 = normalize(_e1821);
                                            lightDir = normalize(vec3<f32>(1f, 1f, 1f));
                                            let _e1829 = sampled;
                                            let _e1830 = col;
                                            let _e1831 = colorSource_1;
                                            let _e1834 = (_e1831.xyz * 2f);
                                            let _e1841 = lightDir;
                                            let _e1842 = normal_1;
                                            sampled = (_e1829 + ((_e1830 * vec4<f32>(_e1834.x, _e1834.y, _e1834.z, 1f)) * clamp(dot(_e1841, _e1842), 0f, 1f)));
                                            let _e1849 = specular_1;
                                            if (_e1849 != 0f) {
                                                {
                                                    let _e1852 = lightDir;
                                                    let _e1853 = normal_1;
                                                    reflectLightDir = reflect(_e1852, _e1853);
                                                    let _e1856 = colorSource_1;
                                                    let _e1857 = specular_1;
                                                    if (_e1857 < 0.25f) {
                                                        let _e1860 = specular_1;
                                                        local_13 = (_e1860 * 4f);
                                                    } else {
                                                        local_13 = 1f;
                                                    }
                                                    let _e1865 = local_13;
                                                    let _e1867 = dir_10;
                                                    let _e1868 = reflectLightDir;
                                                    let _e1874 = specular_1;
                                                    specularColor = ((_e1856 * _e1865) * pow(clamp(dot(_e1867, _e1868), 0f, 1f), (10f - (_e1874 * 10f))));
                                                    let _e1881 = sampled;
                                                    let _e1882 = specularColor;
                                                    sampled = (_e1881 + _e1882);
                                                }
                                            }
                                            let _e1885 = alpha_1;
                                            sampled.w = _e1885;
                                        }
                                    }
                                }
                            }
                            let _e1886 = reflectivity_1;
                            if (_e1886 != 0f) {
                                {
                                    let _e1891 = intersection[1];
                                    normal_2 = _e1891;
                                    let _e1893 = dir_10;
                                    let _e1894 = normal_2;
                                    reflectDir = reflect(_e1893, _e1894);
                                    reflected = vec4<f32>(0f, 0f, 0f, 1f);
                                    let _e1903 = sourceBkg_specified_1;
                                    if (_e1903 == 1i) {
                                        {
                                            let _e1906 = reflectDir;
                                            let _e1907 = sourceBkgDim_11;
                                            let _e1908 = backgroundMode_5;
                                            let _e1909 = backgroundForReflection(_e1906, _e1907, _e1908);
                                            refDir = _e1909;
                                            let _e1911 = refDir;
                                            let _e1916 = global.U[0];
                                            let _e1919 = refDir;
                                            let _e1929 = textureSample(t_sourceBkg, samp, ((vec2<f32>((_e1911.x / _e1916.x), _e1919.y) / vec2(2f)) + vec2(0.5f)));
                                            let _e1930 = refDir;
                                            let _e1932 = vec3(_e1930.z);
                                            reflected = (_e1929 * vec4<f32>(_e1932.x, _e1932.y, _e1932.z, 1f));
                                        }
                                    }
                                    let _e1939 = reflected;
                                    let _e1941 = reflected;
                                    let _e1944 = reflected;
                                    lum = (((_e1939.x + _e1941.y) + _e1944.z) * 0.3333333f);
                                    let _e1951 = lum;
                                    let _e1952 = reflectivity_1;
                                    k_1 = min(1f, ((_e1951 * _e1952) * 10f));
                                    let _e1958 = sampled;
                                    let _e1959 = reflected;
                                    let _e1960 = k_1;
                                    sampled = mix(_e1958, _e1959, vec4(_e1960));
                                }
                            }
                            let _e1963 = intersected;
                            if (_e1963 == 0f) {
                                let _e1966 = sampled;
                                local_14 = _e1966;
                            } else {
                                let _e1967 = outColor;
                                let _e1969 = sampled;
                                let _e1971 = intersected;
                                let _e1972 = intersected;
                                let _e1973 = sampled;
                                let _e1978 = mix(_e1967.xyz, _e1969.xyz, vec3((_e1971 / (_e1972 + _e1973.w))));
                                let _e1979 = outColor;
                                let _e1982 = outColor;
                                let _e1985 = sampled;
                                local_14 = vec4<f32>(_e1978.x, _e1978.y, _e1978.z, (_e1979.w + ((1f - _e1982.w) * _e1985.w)));
                            }
                            let _e1994 = local_14;
                            outColor = _e1994;
                            let _e1995 = intersected;
                            let _e1996 = sampled;
                            intersected = (_e1995 + _e1996.w);
                        }
                    }
                }
            }
            let _e1999 = squareCenter;
            let _e2001 = nextLines;
            next = (_e1999.xy + _e2001);
            let _e2004 = next;
            let _e2005 = p;
            let _e2008 = dir_10;
            deltaK = ((_e2004 - _e2005.xy) / _e2008.xy);
            let _e2012 = deltaK;
            let _e2014 = deltaK;
            minK = min(_e2012.x, _e2014.y);
            let _e2018 = k;
            let _e2019 = minK;
            k = (_e2018 + _e2019);
            let _e2021 = p;
            let _e2022 = minK;
            let _e2023 = dir_10;
            p = (_e2021 + (_e2022 * _e2023));
            let _e2026 = maxIter;
            maxIter = (_e2026 - 1i);
        }
    }
    let _e2029 = color_2;
    let _e2030 = outColor;
    let _e2031 = _e2030.xyz;
    let _e2032 = color_2;
    let _e2038 = outColor;
    outColor = mix(_e2029, vec4<f32>(_e2031.x, _e2031.y, _e2031.z, _e2032.w), vec4(_e2038.w));
    let _e2042 = outColor;
    let _e2044 = colorLines_1;
    let _e2046 = colorLines_1;
    let _e2049 = mix(_e2042.xyz, _e2044.xyz, vec3(_e2046.w));
    frameColor = vec4<f32>(_e2049.x, _e2049.y, _e2049.z, 1f);
    let _e2056 = thickness_1;
    if (_e2056 == 0f) {
        local_16 = 0f;
    } else {
        let _e2063 = thickness_1;
        let _e2066 = frameDist;
        let _e2069 = glow_1;
        if (_e2069 == 0f) {
            local_15 = 0f;
        } else {
            let _e2074 = glow_1;
            let _e2077 = frameDist;
            local_15 = smoothstep((0.2f * _e2074), 0f, _e2077);
        }
        let _e2080 = local_15;
        local_16 = smoothstep(0f, 1f, (smoothstep((0.02f * _e2063), 0f, _e2066) + (0.4f * _e2080)));
    }
    let _e2085 = local_16;
    frameK = _e2085;
    let _e2087 = outColor;
    let _e2088 = frameColor;
    let _e2089 = frameK;
    outColor = mix(_e2087, _e2088, vec4(_e2089));
    let _e2092 = colorFog_1;
    if (_e2092.w != 0f) {
        {
            let _e2098 = colorFog_1;
            nearDist = (2f * (1f - _e2098.w));
            let _e2104 = nearDist;
            farDist = (2f * _e2104);
            let _e2107 = nearDist;
            let _e2108 = farDist;
            let _e2109 = intersectDist;
            kFog = smoothstep(_e2107, _e2108, _e2109);
            let _e2112 = outColor;
            let _e2114 = outColor;
            let _e2116 = colorFog_1;
            let _e2118 = kFog;
            let _e2120 = mix(_e2114.xyz, _e2116.xyz, vec3(_e2118));
            outColor.x = _e2120.x;
            outColor.y = _e2120.y;
            outColor.z = _e2120.z;
        }
    }
    let _e2127 = outColor;
    return _e2127;
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
