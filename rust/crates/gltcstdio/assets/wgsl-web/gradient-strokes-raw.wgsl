struct Params {
    U: array<vec4<f32>, 20>,
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
var t_gradientMap: texture_2d<f32>;
@group(0) @binding(3) 
var t_source: texture_2d<f32>;

fn _mirror_wrap(c: vec2<f32>) -> vec2<f32> {
    var c_1: vec2<f32>;

    c_1 = c;
    let _e10 = c_1;
    let _e12 = vec2(2f);
    return (vec2(1f) - abs(((_e10 - (floor((_e10 / _e12)) * _e12)) - vec2(1f))));
}

fn perturbate(p: vec2<f32>, dir: vec2<f32>, variability: f32) -> vec2<f32> {
    var p_1: vec2<f32>;
    var dir_1: vec2<f32>;
    var variability_1: f32;
    var local: f32;
    var M: f32;
    var len: f32;
    var ort: vec2<f32>;
    var x: f32;
    var y: f32;

    p_1 = p;
    dir_1 = dir;
    variability_1 = variability;
    let _e13 = variability_1;
    if (_e13 == 0f) {
        let _e16 = p_1;
        return _e16;
    }
    let _e17 = variability_1;
    if (_e17 < 0f) {
        local = 1f;
    } else {
        local = 5f;
    }
    let _e23 = local;
    M = _e23;
    let _e25 = dir_1;
    len = length(_e25);
    let _e28 = dir_1;
    let _e30 = dir_1;
    ort = vec2<f32>(_e28.y, -(_e30.x));
    let _e35 = p_1;
    let _e36 = dir_1;
    let _e38 = len;
    let _e39 = len;
    let _e42 = M;
    x = ((dot(_e35, _e36) / (_e38 * _e39)) * _e42);
    let _e45 = p_1;
    let _e46 = ort;
    let _e48 = len;
    let _e49 = len;
    y = (dot(_e45, _e46) / (_e48 * _e49));
    let _e53 = p_1;
    let _e54 = variability_1;
    let _e57 = dir_1;
    let _e60 = x;
    let _e67 = y;
    p_1 = (_e53 + ((((_e54 * 0.4f) * _e57) * sin(((1f * _e60) + 21.54f))) * cos(((5f * _e67) + 5245.24f))));
    let _e74 = p_1;
    let _e75 = variability_1;
    let _e78 = dir_1;
    let _e81 = x;
    let _e88 = y;
    p_1 = (_e74 + ((((_e75 * 0.2f) * _e78) * sin(((3f * _e81) + 0.21f))) * cos(((15f * _e88) + 0.575f))));
    let _e95 = p_1;
    let _e96 = variability_1;
    let _e99 = dir_1;
    let _e102 = x;
    let _e109 = y;
    p_1 = (_e95 + ((((_e96 * 0.1f) * _e99) * sin(((10f * _e102) - 1f))) * cos(((50f * _e109) + 1.255f))));
    let _e116 = p_1;
    let _e117 = variability_1;
    let _e120 = ort;
    let _e123 = x;
    let _e130 = y;
    p_1 = (_e116 + ((((_e117 * 0.2f) * _e120) * sin(((1.2f * _e123) + 21.4f))) * cos(((4.52f * _e130) + 525.24f))));
    let _e137 = p_1;
    let _e138 = variability_1;
    let _e141 = ort;
    let _e144 = x;
    let _e151 = y;
    p_1 = (_e137 + ((((_e138 * 0.1f) * _e141) * sin(((3.4f * _e144) + 0.1f))) * cos(((17f * _e151) + 0.75f))));
    let _e158 = p_1;
    let _e159 = variability_1;
    let _e162 = ort;
    let _e165 = x;
    let _e172 = y;
    p_1 = (_e158 + ((((_e159 * 0.05f) * _e162) * sin(((10.7f * _e165) - 1f))) * cos(((47.7f * _e172) + 1.25f))));
    let _e179 = p_1;
    return _e179;
}

fn getStroke(p_2: vec2<f32>, c_2: vec2<f32>, dir_2: vec2<f32>, thickness: f32, variability_2: f32) -> vec2<f32> {
    var p_3: vec2<f32>;
    var c_3: vec2<f32>;
    var dir_3: vec2<f32>;
    var thickness_1: f32;
    var variability_3: f32;
    var d: vec2<f32>;
    var len_1: f32;
    var l: f32;
    var k: f32;
    var local_1: f32;

    p_3 = p_2;
    c_3 = c_2;
    dir_3 = dir_2;
    thickness_1 = thickness;
    variability_3 = variability_2;
    let _e17 = dir_3;
    let _e21 = dir_3;
    if ((_e17.x == 0f) && (_e21.y == 0f)) {
        return vec2<f32>(0f, 0f);
    }
    let _e29 = dir_3;
    d = normalize(_e29);
    let _e32 = dir_3;
    len_1 = length(_e32);
    let _e35 = p_3;
    let _e36 = dir_3;
    let _e37 = variability_3;
    let _e38 = perturbate(_e35, _e36, _e37);
    p_3 = _e38;
    let _e39 = d;
    let _e41 = d;
    let _e44 = vec2<f32>(_e39.x, -(_e41.y));
    let _e45 = d;
    let _e46 = _e45.yx;
    let _e54 = p_3;
    let _e55 = c_3;
    p_3 = (mat2x2<f32>(vec2<f32>(_e44.x, _e44.y), vec2<f32>(_e46.x, _e46.y)) * (_e54 - _e55));
    let _e59 = p_3;
    let _e62 = len_1;
    let _e65 = p_3;
    l = length(vec2<f32>(max(0f, (abs(_e59.x) - _e62)), _e65.y));
    let _e70 = p_3;
    let _e72 = len_1;
    let _e75 = len_1;
    k = clamp(((_e70.x + _e72) / (2f * _e75)), 0f, 1f);
    let _e82 = l;
    let _e83 = thickness_1;
    if (_e82 < _e83) {
        local_1 = 1f;
    } else {
        local_1 = 0f;
    }
    let _e88 = local_1;
    let _e89 = k;
    return vec2<f32>(_e88, _e89);
}

fn luma(c_4: vec3<f32>) -> f32 {
    var c_5: vec3<f32>;

    c_5 = c_4;
    let _e10 = c_5;
    let _e14 = c_5;
    let _e19 = c_5;
    return (((0.2989f * _e10.x) + (0.587f * _e14.y)) + (0.114f * _e19.z));
}

fn response(u: vec2<f32>) -> vec2<f32> {
    var u_1: vec2<f32>;
    var len_2: f32;
    var n: vec2<f32>;

    u_1 = u;
    let _e9 = u_1;
    let _e13 = u_1;
    if ((_e9.x == 0f) && (_e13.y == 0f)) {
        let _e18 = u_1;
        return _e18;
    }
    let _e19 = u_1;
    len_2 = length(_e19);
    len_2 = 1f;
    let _e23 = u_1;
    n = normalize(_e23);
    let _e26 = len_2;
    let _e27 = n;
    return (_e26 * _e27);
}

fn rotation2_(angle: f32) -> mat2x2<f32> {
    var angle_1: f32;
    var ca: f32;
    var sa: f32;

    angle_1 = angle;
    let _e9 = angle_1;
    ca = cos(_e9);
    let _e12 = angle_1;
    sa = sin(_e12);
    let _e15 = ca;
    let _e16 = sa;
    let _e17 = sa;
    let _e19 = ca;
    return mat2x2<f32>(vec2<f32>(_e15, _e16), vec2<f32>(-(_e17), _e19));
}

fn gradientStrokes(pos: vec2<f32>, outPos: vec2<f32>, gradient: f32, size: i32, thickness_2: f32, variability_4: f32, angle_2: f32, colorBkg: vec4<f32>, color2_: vec4<f32>, color3_: vec4<f32>, gradientMap_specified: i32, modelTransform: mat3x3<f32>) -> vec4<f32> {
    var pos_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var gradient_1: f32;
    var size_1: i32;
    var thickness_3: f32;
    var variability_5: f32;
    var angle_3: f32;
    var colorBkg_1: vec4<f32>;
    var color2_1: vec4<f32>;
    var color3_1: vec4<f32>;
    var gradientMap_specified_1: i32;
    var modelTransform_1: mat3x3<f32>;
    var strokeIntensity: f32 = 0f;
    var inverseModelTransform: mat3x3<f32>;
    var resolution: f32;
    var sp: vec2<f32>;
    var delta: f32 = 0.02f;
    var step: f32;
    var curColor: vec4<f32> = vec4<f32>(0f, 0f, 0f, 1f);
    var n_1: f32 = 0f;
    var ang: f32;
    var rot: mat2x2<f32>;
    var N: f32;
    var j: f32;
    var i: f32;
    var pp: vec2<f32>;
    var d_1: vec2<f32>;
    var local_2: vec4<f32>;
    var sample00_: f32;
    var local_3: vec4<f32>;
    var sample01_: f32;
    var local_4: vec4<f32>;
    var sample10_: f32;
    var local_5: vec4<f32>;
    var sample11_: f32;
    var grad: vec2<f32>;
    var g: vec2<f32>;
    var st: vec2<f32>;
    var kGrad: f32;
    var alpha: f32;
    var color: vec4<f32>;
    var bkgCol: vec4<f32>;
    var bkgCol_1: vec4<f32>;

    pos_1 = pos;
    outPos_1 = outPos;
    gradient_1 = gradient;
    size_1 = size;
    thickness_3 = thickness_2;
    variability_5 = variability_4;
    angle_3 = angle_2;
    colorBkg_1 = colorBkg;
    color2_1 = color2_;
    color3_1 = color3_;
    gradientMap_specified_1 = gradientMap_specified;
    modelTransform_1 = modelTransform;
    let _e33 = modelTransform_1;
    inverseModelTransform = _naga_inverse_3x3_f32(_e33);
    let _e38 = inverseModelTransform[0];
    resolution = length(_e38.xy);
    let _e42 = pos_1;
    let _e43 = resolution;
    let _e49 = resolution;
    let _e54 = inverseModelTransform[2];
    let _e57 = resolution;
    sp = ((floor(((_e42 * _e43) + vec2(0.5f))) / vec2(_e49)) - (fract(_e54.xy) / vec2(_e57)));
    let _e65 = resolution;
    step = (1f / _e65);
    let _e76 = angle_3;
    ang = (_e76 + 1.5707964f);
    let _e80 = ang;
    let _e81 = rotation2_(_e80);
    rot = _e81;
    let _e83 = size_1;
    N = f32(_e83);
    let _e86 = N;
    j = -(_e86);
    loop {
        let _e89 = j;
        let _e90 = N;
        if !((_e89 <= _e90)) {
            break;
        }
        {
            let _e96 = N;
            i = -(_e96);
            loop {
                let _e99 = i;
                let _e100 = N;
                if !((_e99 <= _e100)) {
                    break;
                }
                {
                    let _e106 = sp;
                    let _e107 = i;
                    let _e108 = j;
                    let _e110 = step;
                    pp = (_e106 + (vec2<f32>(_e107, _e108) * _e110));
                    let _e114 = delta;
                    d_1 = vec2<f32>(_e114, 0f);
                    let _e118 = gradientMap_specified_1;
                    if (_e118 == 0i) {
                        let _e121 = pp;
                        let _e122 = d_1;
                        let _e128 = global.U[0];
                        let _e131 = pp;
                        let _e132 = d_1;
                        let _e143 = _mirror_wrap(((vec2<f32>(((_e121 + _e122.xy).x / _e128.x), (_e131 + _e132.xy).y) / vec2(2f)) + vec2(0.5f)));
                        let _e145 = textureSampleLevel(t_source, samp, _e143, 0f);
                        local_2 = _e145;
                    } else {
                        let _e146 = pp;
                        let _e147 = d_1;
                        let _e153 = global.U[0];
                        let _e156 = pp;
                        let _e157 = d_1;
                        let _e168 = _mirror_wrap(((vec2<f32>(((_e146 + _e147.xy).x / _e153.x), (_e156 + _e157.xy).y) / vec2(2f)) + vec2(0.5f)));
                        let _e170 = textureSampleLevel(t_gradientMap, samp, _e168, 0f);
                        local_2 = _e170;
                    }
                    let _e172 = local_2;
                    let _e174 = luma(_e172.xyz);
                    sample00_ = _e174;
                    let _e176 = gradientMap_specified_1;
                    if (_e176 == 0i) {
                        let _e179 = pp;
                        let _e180 = d_1;
                        let _e186 = global.U[0];
                        let _e189 = pp;
                        let _e190 = d_1;
                        let _e201 = _mirror_wrap(((vec2<f32>(((_e179 - _e180.xy).x / _e186.x), (_e189 - _e190.xy).y) / vec2(2f)) + vec2(0.5f)));
                        let _e203 = textureSampleLevel(t_source, samp, _e201, 0f);
                        local_3 = _e203;
                    } else {
                        let _e204 = pp;
                        let _e205 = d_1;
                        let _e211 = global.U[0];
                        let _e214 = pp;
                        let _e215 = d_1;
                        let _e226 = _mirror_wrap(((vec2<f32>(((_e204 - _e205.xy).x / _e211.x), (_e214 - _e215.xy).y) / vec2(2f)) + vec2(0.5f)));
                        let _e228 = textureSampleLevel(t_gradientMap, samp, _e226, 0f);
                        local_3 = _e228;
                    }
                    let _e230 = local_3;
                    let _e232 = luma(_e230.xyz);
                    sample01_ = _e232;
                    let _e234 = gradientMap_specified_1;
                    if (_e234 == 0i) {
                        let _e237 = pp;
                        let _e238 = d_1;
                        let _e244 = global.U[0];
                        let _e247 = pp;
                        let _e248 = d_1;
                        let _e259 = _mirror_wrap(((vec2<f32>(((_e237 + _e238.yx).x / _e244.x), (_e247 + _e248.yx).y) / vec2(2f)) + vec2(0.5f)));
                        let _e261 = textureSampleLevel(t_source, samp, _e259, 0f);
                        local_4 = _e261;
                    } else {
                        let _e262 = pp;
                        let _e263 = d_1;
                        let _e269 = global.U[0];
                        let _e272 = pp;
                        let _e273 = d_1;
                        let _e284 = _mirror_wrap(((vec2<f32>(((_e262 + _e263.yx).x / _e269.x), (_e272 + _e273.yx).y) / vec2(2f)) + vec2(0.5f)));
                        let _e286 = textureSampleLevel(t_gradientMap, samp, _e284, 0f);
                        local_4 = _e286;
                    }
                    let _e288 = local_4;
                    let _e290 = luma(_e288.xyz);
                    sample10_ = _e290;
                    let _e292 = gradientMap_specified_1;
                    if (_e292 == 0i) {
                        let _e295 = pp;
                        let _e296 = d_1;
                        let _e302 = global.U[0];
                        let _e305 = pp;
                        let _e306 = d_1;
                        let _e317 = _mirror_wrap(((vec2<f32>(((_e295 - _e296.yx).x / _e302.x), (_e305 - _e306.yx).y) / vec2(2f)) + vec2(0.5f)));
                        let _e319 = textureSampleLevel(t_source, samp, _e317, 0f);
                        local_5 = _e319;
                    } else {
                        let _e320 = pp;
                        let _e321 = d_1;
                        let _e327 = global.U[0];
                        let _e330 = pp;
                        let _e331 = d_1;
                        let _e342 = _mirror_wrap(((vec2<f32>(((_e320 - _e321.yx).x / _e327.x), (_e330 - _e331.yx).y) / vec2(2f)) + vec2(0.5f)));
                        let _e344 = textureSampleLevel(t_gradientMap, samp, _e342, 0f);
                        local_5 = _e344;
                    }
                    let _e346 = local_5;
                    let _e348 = luma(_e346.xyz);
                    sample11_ = _e348;
                    let _e350 = sample00_;
                    let _e351 = sample01_;
                    let _e353 = delta;
                    let _e357 = sample10_;
                    let _e358 = sample11_;
                    let _e360 = delta;
                    let _e365 = delta;
                    grad = ((vec2<f32>(((_e350 - _e351) / (_e353 * 2f)), ((_e357 - _e358) / (_e360 * 2f))) * _e365) / vec2(2f));
                    let _e371 = rot;
                    let _e372 = grad;
                    let _e373 = response(_e372);
                    let _e374 = resolution;
                    let _e380 = N;
                    g = (_e371 * (((_e373 / vec2(_e374)) / vec2(2f)) * _e380));
                    let _e384 = pos_1;
                    let _e385 = pp;
                    let _e386 = g;
                    let _e387 = thickness_3;
                    let _e388 = resolution;
                    let _e390 = variability_5;
                    let _e391 = getStroke(_e384, _e385, _e386, (_e387 / _e388), _e390);
                    st = _e391;
                    let _e393 = st;
                    if (_e393.x > 0f) {
                        {
                            let _e397 = n_1;
                            n_1 = (_e397 + 1f);
                            let _e400 = strokeIntensity;
                            let _e401 = st;
                            strokeIntensity = max(_e400, _e401.x);
                            let _e404 = st;
                            let _e408 = gradient_1;
                            kGrad = (((_e404.y - 0.5f) * _e408) + 0.5f);
                            let _e413 = color2_1;
                            let _e415 = color3_1;
                            let _e417 = st;
                            alpha = mix(_e413.w, _e415.w, _e417.y);
                            let _e421 = color2_1;
                            let _e423 = color3_1;
                            let _e425 = st;
                            let _e427 = kGrad;
                            let _e428 = color2_1;
                            let _e430 = color3_1;
                            let _e435 = mix(_e421.xyz, _e423.xyz, vec3(mix(_e425.y, _e427, min(_e428.w, _e430.w))));
                            let _e436 = alpha;
                            color = vec4<f32>(_e435.x, _e435.y, _e435.z, _e436);
                            let _e442 = color;
                            if (_e442.w < 1f) {
                                {
                                    let _e446 = pp;
                                    let _e447 = g;
                                    let _e450 = gradient_1;
                                    let _e456 = global.U[0];
                                    let _e459 = pp;
                                    let _e460 = g;
                                    let _e463 = gradient_1;
                                    let _e474 = _mirror_wrap(((vec2<f32>(((_e446 - ((_e447 * 0.5f) * _e450)).x / _e456.x), (_e459 - ((_e460 * 0.5f) * _e463)).y) / vec2(2f)) + vec2(0.5f)));
                                    let _e476 = textureSampleLevel(t_source, samp, _e474, 0f);
                                    let _e477 = pp;
                                    let _e478 = g;
                                    let _e481 = gradient_1;
                                    let _e487 = global.U[0];
                                    let _e490 = pp;
                                    let _e491 = g;
                                    let _e494 = gradient_1;
                                    let _e505 = _mirror_wrap(((vec2<f32>(((_e477 + ((_e478 * 0.5f) * _e481)).x / _e487.x), (_e490 + ((_e491 * 0.5f) * _e494)).y) / vec2(2f)) + vec2(0.5f)));
                                    let _e507 = textureSampleLevel(t_source, samp, _e505, 0f);
                                    bkgCol = mix(_e476, _e507, vec4(0.5f));
                                    let _e512 = bkgCol;
                                    let _e514 = color;
                                    let _e516 = color;
                                    let _e519 = mix(_e512.xyz, _e514.xyz, vec3(_e516.w));
                                    let _e520 = bkgCol;
                                    color = vec4<f32>(_e519.x, _e519.y, _e519.z, _e520.w);
                                }
                            }
                            let _e526 = color;
                            let _e528 = luma(_e526.xyz);
                            let _e529 = curColor;
                            let _e531 = luma(_e529.xyz);
                            if (_e528 >= _e531) {
                                let _e533 = color;
                                curColor = _e533;
                            }
                        }
                    }
                }
                continuing {
                    let _e103 = i;
                    i = (_e103 + 1f);
                }
            }
        }
        continuing {
            let _e93 = j;
            j = (_e93 + 1f);
        }
    }
    let _e534 = pos_1;
    let _e538 = global.U[0];
    let _e541 = pos_1;
    let _e550 = _mirror_wrap(((vec2<f32>((_e534.x / _e538.x), _e541.y) / vec2(2f)) + vec2(0.5f)));
    let _e552 = textureSampleLevel(t_source, samp, _e550, 0f);
    bkgCol_1 = _e552;
    let _e554 = colorBkg_1;
    let _e555 = curColor;
    let _e556 = strokeIntensity;
    curColor = mix(_e554, _e555, vec4(_e556));
    let _e559 = bkgCol_1;
    let _e561 = curColor;
    let _e563 = curColor;
    let _e566 = mix(_e559.xyz, _e561.xyz, vec3(_e563.w));
    let _e567 = bkgCol_1;
    let _e569 = curColor;
    let _e571 = curColor;
    curColor = vec4<f32>(_e566.x, _e566.y, _e566.z, mix(_e567.w, _e569.w, _e571.w));
    let _e578 = curColor;
    return _e578;
}

fn main_1() {
    let _e9 = global.U[1];
    let _e10 = _e9.xyz;
    let _e13 = global.U[2];
    let _e14 = _e13.xyz;
    let _e17 = global.U[3];
    let _e18 = _e17.xyz;
    let _e33 = v_uv_1;
    let _e41 = global.U[0];
    let _e45 = (((_e33 - vec2(0.5f)) * 2f) * vec2<f32>(_e41.x, 1f));
    let _e52 = v_uv_1;
    let _e60 = global.U[0];
    let _e67 = global.U[9];
    let _e71 = global.U[10];
    let _e76 = global.U[11];
    let _e80 = global.U[12];
    let _e84 = global.U[13];
    let _e88 = global.U[14];
    let _e91 = global.U[15];
    let _e94 = global.U[16];
    let _e97 = global.U[4];
    let _e102 = global.U[17];
    let _e103 = _e102.xyz;
    let _e106 = global.U[18];
    let _e107 = _e106.xyz;
    let _e110 = global.U[19];
    let _e111 = _e110.xyz;
    let _e125 = gradientStrokes((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e10.x, _e10.y, _e10.z), vec3<f32>(_e14.x, _e14.y, _e14.z), vec3<f32>(_e18.x, _e18.y, _e18.z))) * vec3<f32>(_e45.x, _e45.y, 1f)).xy, (((_e52 - vec2(0.5f)) * 2f) * vec2<f32>(_e60.x, 1f)), _e67.x, i32(_e71.x), _e76.x, _e80.x, _e84.x, _e88, _e91, _e94, i32(_e97.x), mat3x3<f32>(vec3<f32>(_e103.x, _e103.y, _e103.z), vec3<f32>(_e107.x, _e107.y, _e107.z), vec3<f32>(_e111.x, _e111.y, _e111.z)));
    fragColor = _e125;
    return;
}

@fragment 
fn main(@location(0) v_uv: vec2<f32>) -> FragmentOutput {
    v_uv_1 = v_uv;
    main_1();
    let _e15 = fragColor;
    return FragmentOutput(_e15);
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
