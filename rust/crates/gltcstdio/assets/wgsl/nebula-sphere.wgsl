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
var t_sourceBkg: texture_2d<f32>;

fn hash31_(u: vec3<f32>) -> f32 {
    var u_1: vec3<f32>;

    u_1 = u;
    let _e8 = u_1;
    let _e12 = u_1;
    let _e17 = u_1;
    return fract((sin((((_e8.x * 776.45f) + (_e12.y * 453.24f)) + (_e17.z * 553.25f))) * 45.77f));
}

fn noise(x: vec3<f32>) -> f32 {
    var x_1: vec3<f32>;
    var i: vec3<f32>;
    var f: vec3<f32>;

    x_1 = x;
    let _e8 = x_1;
    i = floor(_e8);
    let _e11 = x_1;
    f = fract(_e11);
    let _e14 = f;
    let _e15 = f;
    let _e19 = f;
    f = ((_e14 * _e15) * (vec3(3f) - (2f * _e19)));
    let _e24 = i;
    let _e33 = hash31_((_e24 + vec3<f32>(0f, 0f, 0f)));
    let _e34 = i;
    let _e43 = hash31_((_e34 + vec3<f32>(1f, 0f, 0f)));
    let _e44 = f;
    let _e47 = i;
    let _e56 = hash31_((_e47 + vec3<f32>(0f, 1f, 0f)));
    let _e57 = i;
    let _e66 = hash31_((_e57 + vec3<f32>(1f, 1f, 0f)));
    let _e67 = f;
    let _e70 = f;
    let _e73 = i;
    let _e82 = hash31_((_e73 + vec3<f32>(0f, 0f, 1f)));
    let _e83 = i;
    let _e92 = hash31_((_e83 + vec3<f32>(1f, 0f, 1f)));
    let _e93 = f;
    let _e96 = i;
    let _e105 = hash31_((_e96 + vec3<f32>(0f, 1f, 1f)));
    let _e106 = i;
    let _e115 = hash31_((_e106 + vec3<f32>(1f, 1f, 1f)));
    let _e116 = f;
    let _e119 = f;
    let _e122 = f;
    return mix(mix(mix(_e33, _e43, _e44.x), mix(_e56, _e66, _e67.x), _e70.y), mix(mix(_e82, _e92, _e93.x), mix(_e105, _e115, _e116.x), _e119.y), _e122.z);
}

fn fbm(p: vec3<f32>) -> f32 {
    var p_1: vec3<f32>;
    var f_1: f32 = 0f;
    var amp: f32 = 0.5f;
    var i_1: i32 = 0i;

    p_1 = p;
    loop {
        let _e14 = i_1;
        if !((_e14 < 4i)) {
            break;
        }
        {
            let _e21 = f_1;
            let _e22 = amp;
            let _e23 = p_1;
            let _e24 = noise(_e23);
            f_1 = (_e21 + (_e22 * _e24));
            let _e27 = p_1;
            p_1 = (_e27 * 2f);
            let _e30 = amp;
            amp = (_e30 * 0.5f);
        }
        continuing {
            let _e18 = i_1;
            i_1 = (_e18 + 1i);
        }
    }
    let _e33 = f_1;
    return _e33;
}

fn getDetailedNoise(p_2: vec3<f32>, time: f32) -> f32 {
    var p_3: vec3<f32>;
    var time_1: f32;
    var q: vec3<f32>;
    var strength: f32 = 1f;
    var n: f32;

    p_3 = p_2;
    time_1 = time;
    let _e10 = p_3;
    let _e14 = fbm((_e10 + vec3(0f)));
    let _e15 = p_3;
    let _e21 = fbm((_e15 + vec3<f32>(5.2f, 1.3f, 2.8f)));
    let _e22 = p_3;
    let _e28 = fbm((_e22 + vec3<f32>(1.8f, 5.2f, 2.1f)));
    q = vec3<f32>(_e14, _e21, _e28);
    let _e31 = q;
    let _e32 = time_1;
    q = (_e31 + vec3((_e32 * 0.1f)));
    let _e39 = p_3;
    let _e40 = q;
    let _e41 = strength;
    let _e44 = fbm((_e39 + (_e40 * _e41)));
    n = _e44;
    let _e48 = n;
    return smoothstep(0.45f, 0.85f, _e48);
}

fn getDensity(p_4: vec3<f32>, time_2: f32) -> f32 {
    var p_5: vec3<f32>;
    var time_3: f32;
    var center: vec3<f32> = vec3(0f);
    var radius: f32 = 0.95f;
    var dist: f32;
    var shapeMask: f32;
    var noisePos: vec3<f32>;
    var cloud: f32;

    p_5 = p_4;
    time_3 = time_2;
    let _e15 = p_5;
    let _e16 = center;
    dist = length((_e15 - _e16));
    let _e21 = radius;
    let _e24 = radius;
    let _e25 = dist;
    shapeMask = (1f - smoothstep((_e21 - 0.1f), _e24, _e25));
    let _e29 = shapeMask;
    if (_e29 <= 0f) {
        return 0f;
    }
    let _e33 = p_5;
    noisePos = (_e33 * 1.5f);
    let _e37 = noisePos;
    let _e38 = time_3;
    let _e39 = getDetailedNoise(_e37, _e38);
    cloud = _e39;
    let _e41 = cloud;
    let _e42 = shapeMask;
    return ((_e41 * _e42) * 2f);
}

fn getPointLight(p_6: vec3<f32>, lightPos: vec3<f32>, lightCol: vec3<f32>, range: f32) -> vec3<f32> {
    var p_7: vec3<f32>;
    var lightPos_1: vec3<f32>;
    var lightCol_1: vec3<f32>;
    var range_1: f32;
    var d: f32;
    var atten: f32;

    p_7 = p_6;
    lightPos_1 = lightPos;
    lightCol_1 = lightCol;
    range_1 = range;
    let _e14 = p_7;
    let _e15 = lightPos_1;
    d = distance(_e14, _e15);
    let _e20 = range_1;
    let _e21 = d;
    atten = (1f - smoothstep(0f, _e20, _e21));
    let _e25 = lightCol_1;
    let _e26 = atten;
    let _e28 = atten;
    return (((_e25 * _e26) * _e28) * 3.5f);
}

fn hash21_(p_8: vec2<f32>) -> f32 {
    var p_9: vec2<f32>;
    var a: vec2<f32>;
    var b: vec2<f32>;

    p_9 = p_8;
    let _e10 = p_9;
    a = fract((-45.3277f * _e10.xy));
    let _e15 = a;
    let _e16 = a;
    let _e17 = a;
    b = (_e15 + vec2(dot(_e16, (_e17 + vec2(123.3371f)))));
    let _e25 = b;
    let _e27 = b;
    return fract((_e25.x * _e27.y));
}

fn rayMarchCloud(ro: vec3<f32>, rd: vec3<f32>, bgCol: vec3<f32>, bounds: vec2<f32>, fragCoord: vec2<f32>, color1_: vec4<f32>, color2_: vec4<f32>, color3_: vec4<f32>, randomSeed: f32, densityMult: f32) -> vec3<f32> {
    var ro_1: vec3<f32>;
    var rd_1: vec3<f32>;
    var bgCol_1: vec3<f32>;
    var bounds_1: vec2<f32>;
    var fragCoord_1: vec2<f32>;
    var color1_1: vec4<f32>;
    var color2_1: vec4<f32>;
    var color3_1: vec4<f32>;
    var randomSeed_1: f32;
    var densityMult_1: f32;
    var t: f32;
    var l1Pos: vec3<f32>;
    var l1Col: vec3<f32>;
    var l2Pos: vec3<f32>;
    var l2Col: vec3<f32>;
    var l3Pos: vec3<f32>;
    var l3Col: vec3<f32>;
    var col: vec3<f32>;
    var STEPS: i32 = 32i;
    var stepSize: f32;
    var absorption: f32 = 8f;
    var dither: f32;
    var currentDist: f32;
    var i_2: i32 = 0i;
    var p_10: vec3<f32>;
    var dens: f32;
    var d1_: f32;
    var d2_: f32;
    var d3_: f32;
    var glow: vec3<f32>;
    var lightEnergy: vec3<f32>;
    var T: f32;
    var E: vec3<f32>;

    ro_1 = ro;
    rd_1 = rd;
    bgCol_1 = bgCol;
    bounds_1 = bounds;
    fragCoord_1 = fragCoord;
    color1_1 = color1_;
    color2_1 = color2_;
    color3_1 = color3_;
    randomSeed_1 = randomSeed;
    densityMult_1 = densityMult;
    let _e26 = randomSeed_1;
    t = _e26;
    let _e28 = t;
    let _e31 = t;
    l1Pos = (vec3<f32>(sin(_e28), 0f, cos(_e31)) * 0.5f);
    let _e37 = color1_1;
    l1Col = (_e37.xyz * 6f);
    let _e42 = t;
    let _e48 = t;
    l2Pos = vec3<f32>((cos((_e42 * 1.1f)) * 0.4f), (sin((_e48 * 1.4f)) * 0.6f), 0f);
    let _e57 = color2_1;
    l2Col = (_e57.xyz * 6f);
    let _e63 = t;
    let _e69 = t;
    l3Pos = vec3<f32>(0f, (cos((_e63 * 0.7f)) * 0.4f), (sin((_e69 * 0.9f)) * 0.5f));
    let _e77 = color3_1;
    l3Col = (_e77.xyz * 6f);
    let _e82 = bgCol_1;
    col = _e82;
    let _e86 = bounds_1;
    let _e88 = bounds_1;
    let _e91 = STEPS;
    stepSize = ((_e86.y - _e88.x) / f32(_e91));
    let _e97 = fragCoord_1;
    let _e98 = randomSeed_1;
    let _e103 = hash21_((_e97 + vec2((_e98 * 10f))));
    dither = _e103;
    let _e105 = bounds_1;
    let _e107 = stepSize;
    let _e108 = dither;
    currentDist = (_e105.y - (_e107 * _e108));
    loop {
        let _e114 = i_2;
        let _e115 = STEPS;
        if !((_e114 < _e115)) {
            break;
        }
        {
            let _e121 = currentDist;
            let _e122 = stepSize;
            currentDist = (_e121 - _e122);
            let _e124 = currentDist;
            let _e125 = bounds_1;
            if (_e124 < _e125.x) {
                break;
            }
            let _e128 = ro_1;
            let _e129 = rd_1;
            let _e130 = currentDist;
            p_10 = (_e128 + (_e129 * _e130));
            let _e134 = p_10;
            let _e135 = randomSeed_1;
            let _e136 = getDensity(_e134, _e135);
            let _e137 = densityMult_1;
            dens = (_e136 * _e137);
            let _e140 = p_10;
            let _e141 = l1Pos;
            d1_ = length((_e140 - _e141));
            let _e145 = p_10;
            let _e146 = l2Pos;
            d2_ = length((_e145 - _e146));
            let _e150 = p_10;
            let _e151 = l3Pos;
            d3_ = length((_e150 - _e151));
            glow = vec3(0f);
            let _e158 = glow;
            let _e159 = l1Col;
            let _e161 = d1_;
            let _e162 = d1_;
            glow = (_e158 + (_e159 / vec3((0.001f + ((_e161 * _e162) * 20f)))));
            let _e170 = glow;
            let _e171 = l2Col;
            let _e173 = d2_;
            let _e174 = d2_;
            glow = (_e170 + (_e171 / vec3((0.002f + ((_e173 * _e174) * 20f)))));
            let _e182 = glow;
            let _e183 = l3Col;
            let _e185 = d3_;
            let _e186 = d3_;
            glow = (_e182 + (_e183 / vec3((0.001f + ((_e185 * _e186) * 20f)))));
            lightEnergy = vec3(0f);
            let _e197 = dens;
            if (_e197 > 0.001f) {
                {
                    let _e200 = lightEnergy;
                    let _e201 = p_10;
                    let _e202 = l1Pos;
                    let _e203 = l1Col;
                    let _e205 = getPointLight(_e201, _e202, _e203, 1f);
                    lightEnergy = (_e200 + _e205);
                    let _e207 = lightEnergy;
                    let _e208 = p_10;
                    let _e209 = l2Pos;
                    let _e210 = l2Col;
                    let _e212 = getPointLight(_e208, _e209, _e210, 1f);
                    lightEnergy = (_e207 + _e212);
                    let _e214 = lightEnergy;
                    let _e215 = p_10;
                    let _e216 = l3Pos;
                    let _e217 = l3Col;
                    let _e219 = getPointLight(_e215, _e216, _e217, 1f);
                    lightEnergy = (_e214 + _e219);
                    let _e221 = lightEnergy;
                    lightEnergy = (_e221 + vec3(0.02f));
                }
            }
            let _e225 = dens;
            let _e227 = absorption;
            let _e229 = stepSize;
            T = exp(((-(_e225) * _e227) * _e229));
            let _e233 = dens;
            let _e234 = lightEnergy;
            let _e236 = glow;
            let _e240 = stepSize;
            E = (((_e233 * _e234) + (_e236 * 0.05f)) * _e240);
            let _e243 = col;
            let _e244 = T;
            let _e246 = E;
            col = ((_e243 * _e244) + _e246);
        }
        continuing {
            let _e118 = i_2;
            i_2 = (_e118 + 1i);
        }
    }
    let _e248 = col;
    return _e248;
}

fn sphereIntersect(ro_2: vec3<f32>, rd_2: vec3<f32>, r: f32) -> vec2<f32> {
    var ro_3: vec3<f32>;
    var rd_3: vec3<f32>;
    var r_1: f32;
    var b_1: f32;
    var c: f32;
    var h: f32;

    ro_3 = ro_2;
    rd_3 = rd_2;
    r_1 = r;
    let _e12 = ro_3;
    let _e13 = rd_3;
    b_1 = dot(_e12, _e13);
    let _e16 = ro_3;
    let _e17 = ro_3;
    let _e19 = r_1;
    let _e20 = r_1;
    c = (dot(_e16, _e17) - (_e19 * _e20));
    let _e24 = b_1;
    let _e25 = b_1;
    let _e27 = c;
    h = ((_e24 * _e25) - _e27);
    let _e30 = h;
    if (_e30 < 0f) {
        return vec2(-1f);
    }
    let _e36 = h;
    h = sqrt(_e36);
    let _e38 = b_1;
    let _e40 = h;
    let _e42 = b_1;
    let _e44 = h;
    return vec2<f32>((-(_e38) - _e40), (-(_e42) + _e44));
}

fn nebulaSphere(pos: vec2<f32>, outPos: vec2<f32>, sourceBkg_specified: i32, color1_2: vec4<f32>, color2_2: vec4<f32>, color3_2: vec4<f32>, density: f32, model3DTransform: mat4x4<f32>, randomSeed_2: f32) -> vec4<f32> {
    var pos_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var sourceBkg_specified_1: i32;
    var color1_3: vec4<f32>;
    var color2_3: vec4<f32>;
    var color3_3: vec4<f32>;
    var density_1: f32;
    var model3DTransform_1: mat4x4<f32>;
    var randomSeed_3: f32;
    var D: f32 = 1f;
    var ro_4: vec3<f32> = vec3<f32>(0f, 0f, 0f);
    var m: mat4x4<f32>;
    var rd_4: vec3<f32>;
    var local: vec3<f32>;
    var bgCol_2: vec3<f32>;
    var col_1: vec3<f32>;
    var sphereRadius: f32 = 1f;
    var bounds_2: vec2<f32>;
    var volumeCol: vec3<f32>;
    var pSurface: vec3<f32>;
    var normal: vec3<f32>;
    var viewAngle: f32;
    var fresnel: f32;
    var extLightDir: vec3<f32>;
    var halfVec: vec3<f32>;
    var spec: f32;
    var reflection: vec3<f32>;

    pos_1 = pos;
    outPos_1 = outPos;
    sourceBkg_specified_1 = sourceBkg_specified;
    color1_3 = color1_2;
    color2_3 = color2_2;
    color3_3 = color3_2;
    density_1 = density;
    model3DTransform_1 = model3DTransform;
    randomSeed_3 = randomSeed_2;
    let _e31 = model3DTransform_1;
    m = _naga_inverse_4x4_f32(_e31);
    let _e34 = m;
    let _e35 = ro_4;
    ro_4 = (_e34 * vec4<f32>(_e35.x, _e35.y, _e35.z, 1f)).xyz;
    let _e43 = pos_1;
    let _e45 = D;
    let _e47 = pos_1;
    let _e49 = D;
    rd_4 = normalize(vec3<f32>((_e43.x * _e45), (_e47.y * _e49), -1f));
    let _e58 = m[0];
    let _e59 = _e58.xyz;
    let _e62 = m[1];
    let _e63 = _e62.xyz;
    let _e66 = m[2];
    let _e67 = _e66.xyz;
    let _e81 = rd_4;
    rd_4 = (mat3x3<f32>(vec3<f32>(_e59.x, _e59.y, _e59.z), vec3<f32>(_e63.x, _e63.y, _e63.z), vec3<f32>(_e67.x, _e67.y, _e67.z)) * _e81);
    let _e83 = sourceBkg_specified_1;
    if (_e83 == 1i) {
        let _e86 = pos_1;
        let _e90 = global.U[0];
        let _e93 = pos_1;
        let _e102 = textureSample(t_sourceBkg, samp, ((vec2<f32>((_e86.x / _e90.x), _e93.y) / vec2(2f)) + vec2(0.5f)));
        local = _e102.xyz;
    } else {
        local = vec3(0f);
    }
    let _e107 = local;
    bgCol_2 = _e107;
    let _e109 = bgCol_2;
    col_1 = _e109;
    let _e113 = ro_4;
    let _e114 = rd_4;
    let _e115 = sphereRadius;
    let _e116 = sphereIntersect(_e113, _e114, _e115);
    bounds_2 = _e116;
    let _e118 = bounds_2;
    if (_e118.x > 0f) {
        {
            let _e122 = ro_4;
            let _e123 = rd_4;
            let _e124 = bgCol_2;
            let _e125 = bounds_2;
            let _e126 = outPos_1;
            let _e127 = color1_3;
            let _e128 = color2_3;
            let _e129 = color3_3;
            let _e130 = randomSeed_3;
            let _e131 = density_1;
            let _e134 = rayMarchCloud(_e122, _e123, _e124, _e125, _e126, _e127, _e128, _e129, _e130, (_e131 * 0.1f));
            volumeCol = _e134;
            let _e136 = ro_4;
            let _e137 = rd_4;
            let _e138 = bounds_2;
            pSurface = (_e136 + (_e137 * _e138.x));
            let _e143 = pSurface;
            normal = normalize(_e143);
            let _e146 = normal;
            let _e147 = rd_4;
            viewAngle = clamp(dot(_e146, -(_e147)), 0f, 1f);
            let _e155 = viewAngle;
            fresnel = pow((1f - _e155), 3f);
            extLightDir = normalize(vec3<f32>(1f, 1f, -1f));
            let _e167 = extLightDir;
            let _e168 = rd_4;
            halfVec = normalize((_e167 - _e168));
            let _e172 = normal;
            let _e173 = halfVec;
            spec = pow(max(dot(_e172, _e173), 0f), 60f);
            let _e184 = fresnel;
            reflection = (vec3<f32>(0.6f, 0.8f, 1f) * _e184);
            let _e187 = volumeCol;
            let _e188 = reflection;
            let _e189 = fresnel;
            col_1 = mix(_e187, _e188, vec3((_e189 * 0.4f)));
            let _e194 = col_1;
            let _e197 = spec;
            col_1 = (_e194 + (vec3(1f) * _e197));
        }
    }
    let _e200 = col_1;
    let _e202 = col_1;
    col_1 = (_e200 / (vec3(1f) + _e202));
    let _e206 = col_1;
    col_1 = pow(_e206, vec3(0.4545f));
    let _e210 = col_1;
    return vec4<f32>(_e210.x, _e210.y, _e210.z, 1f);
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
    let _e71 = global.U[6];
    let _e74 = global.U[7];
    let _e77 = global.U[8];
    let _e80 = global.U[9];
    let _e84 = global.U[10];
    let _e87 = global.U[11];
    let _e90 = global.U[12];
    let _e93 = global.U[13];
    let _e117 = global.U[14];
    let _e119 = nebulaSphere((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e9.x, _e9.y, _e9.z), vec3<f32>(_e13.x, _e13.y, _e13.z), vec3<f32>(_e17.x, _e17.y, _e17.z))) * vec3<f32>(_e44.x, _e44.y, 1f)).xy, (((_e51 - vec2(0.5f)) * 2f) * vec2<f32>(_e59.x, 1f)), i32(_e66.x), _e71, _e74, _e77, _e80.x, mat4x4<f32>(vec4<f32>(_e84.x, _e84.y, _e84.z, _e84.w), vec4<f32>(_e87.x, _e87.y, _e87.z, _e87.w), vec4<f32>(_e90.x, _e90.y, _e90.z, _e90.w), vec4<f32>(_e93.x, _e93.y, _e93.z, _e93.w)), _e117.x);
    fragColor = _e119;
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
