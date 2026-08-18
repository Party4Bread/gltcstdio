struct Params {
    U: array<vec4<f32>, 18>,
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

fn blend(mode: i32, a: vec4<f32>, b: vec4<f32>) -> vec4<f32> {
    var mode_1: i32;
    var a_1: vec4<f32>;
    var b_1: vec4<f32>;
    var aa: vec3<f32>;
    var bb: vec3<f32>;
    var cc: vec3<f32>;
    var _sw_sel: i32;

    mode_1 = mode;
    a_1 = a;
    b_1 = b;
    let _e12 = a_1;
    aa = _e12.xyz;
    let _e15 = b_1;
    bb = _e15.xyz;
    {
        let _e19 = mode_1;
        _sw_sel = i32(_e19);
        let _e22 = _sw_sel;
        if (_e22 == 1i) {
            {
                let _e26 = aa;
                let _e27 = bb;
                cc = (_e26 + _e27);
            }
        } else {
            let _e29 = _sw_sel;
            if (_e29 == 2i) {
                {
                    let _e33 = aa;
                    let _e34 = bb;
                    cc = (_e33 * _e34);
                }
            } else {
                let _e36 = _sw_sel;
                if (_e36 == 3i) {
                    {
                        let _e40 = aa;
                        let _e41 = bb;
                        cc = (_e40 - _e41);
                    }
                } else {
                    let _e43 = _sw_sel;
                    if (_e43 == 4i) {
                        {
                            let _e47 = aa;
                            let _e48 = bb;
                            cc = abs((_e47 - _e48));
                        }
                    } else {
                        let _e51 = _sw_sel;
                        if (_e51 == 5i) {
                            {
                                let _e55 = aa;
                                let _e56 = bb;
                                cc = (_e55 / _e56);
                            }
                        } else {
                            let _e58 = _sw_sel;
                            if (_e58 == 10i) {
                                {
                                    let _e62 = a_1;
                                    let _e63 = b_1;
                                    return max(_e62, _e63);
                                }
                            } else {
                                let _e65 = _sw_sel;
                                if (_e65 == 11i) {
                                    {
                                        let _e69 = a_1;
                                        let _e70 = b_1;
                                        return min(_e69, _e70);
                                    }
                                } else {
                                    {
                                        let _e72 = b_1;
                                        return _e72;
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    let _e73 = cc;
    let _e74 = a_1;
    let _e76 = b_1;
    return vec4<f32>(_e73.x, _e73.y, _e73.z, mix(_e74.w, _e76.w, 0.5f));
}

fn blend_1(a_2: vec4<f32>, b_2: vec4<f32>) -> vec4<f32> {
    var a_3: vec4<f32>;
    var b_3: vec4<f32>;

    a_3 = a_2;
    b_3 = b_2;
    let _e10 = a_3;
    let _e13 = b_3;
    let _e16 = b_3;
    let _e19 = mix(vec3<f32>(_e10.xyz), vec3<f32>(_e13.xyz), vec3(_e16.w));
    let _e20 = a_3;
    let _e22 = b_3;
    return vec4<f32>(_e19.x, _e19.y, _e19.z, max(_e20.w, _e22.w));
}

fn eqTriangleDist(p: vec2<f32>, r: f32) -> f32 {
    var p_1: vec2<f32>;
    var r_1: f32;
    var n: vec2<f32> = vec2<f32>(-0.8660254f, 0.5f);
    var d: f32;
    var Y: f32;

    p_1 = p;
    r_1 = r;
    let _e16 = p_1;
    p_1.y = abs(_e16.y);
    let _e19 = p_1;
    let _e20 = n;
    d = dot(_e19, _e20);
    let _e23 = d;
    if (_e23 > 0f) {
        {
            let _e26 = p_1;
            let _e28 = d;
            let _e30 = n;
            p_1 = (_e26 - ((2f * _e28) * _e30));
        }
    }
    let _e33 = r_1;
    Y = (_e33 * 0.8660254f);
    let _e37 = p_1;
    let _e39 = r_1;
    let _e42 = p_1;
    let _e43 = r_1;
    let _e44 = p_1;
    let _e46 = Y;
    let _e48 = Y;
    return (sign((_e37.x - _e39)) * length((_e42 - vec2<f32>(_e43, clamp(_e44.y, -(_e46), _e48)))));
}

fn lineDist(p_2: vec2<f32>, a_4: vec2<f32>, b_4: vec2<f32>) -> f32 {
    var p_3: vec2<f32>;
    var a_5: vec2<f32>;
    var b_5: vec2<f32>;
    var pa: vec2<f32>;
    var ba: vec2<f32>;
    var t: f32;

    p_3 = p_2;
    a_5 = a_4;
    b_5 = b_4;
    let _e12 = p_3;
    let _e13 = a_5;
    pa = (_e12 - _e13);
    let _e16 = b_5;
    let _e17 = a_5;
    ba = (_e16 - _e17);
    let _e20 = pa;
    let _e21 = ba;
    let _e23 = ba;
    let _e24 = ba;
    t = clamp((dot(_e20, _e21) / dot(_e23, _e24)), 0f, 1f);
    let _e31 = pa;
    let _e32 = ba;
    let _e33 = t;
    return length((_e31 - (_e32 * _e33)));
}

fn catDist(u: vec2<f32>) -> f32 {
    var u_1: vec2<f32>;
    var c: f32 = 100000f;
    var hr: f32 = 0.005f;
    var earL: vec2<f32> = vec2<f32>(0.003f, -0.0035f);
    var earR: vec2<f32> = vec2<f32>(-0.003f, -0.0035f);
    var br: f32 = 0.01f;
    var tr: f32 = 0.0015f;

    u_1 = u;
    let _e10 = u_1;
    u_1 = (_e10 + vec2<f32>(-0.015f, 0.03f));
    let _e18 = c;
    let _e19 = u_1;
    let _e21 = hr;
    c = min(_e18, (length(_e19) - _e21));
    let _e35 = c;
    let _e36 = u_1;
    let _e37 = earL;
    let _e41 = eqTriangleDist(-((_e36 + _e37)), 0.002f);
    c = min(_e35, _e41);
    let _e43 = c;
    let _e44 = u_1;
    let _e45 = earR;
    let _e48 = eqTriangleDist((_e44 + _e45), 0.002f);
    c = min(_e43, _e48);
    let _e51 = u_1;
    u_1.y = (_e51.y + 0.0125f);
    let _e57 = c;
    let _e58 = u_1;
    let _e60 = u_1;
    let _e69 = br;
    c = min(_e57, (length((_e58 * vec2<f32>((1.3f + (_e60.y * 15f)), 1f))) - _e69));
    let _e72 = u_1;
    u_1 = (_e72 + vec2(0.007f));
    let _e78 = c;
    let _e79 = u_1;
    let _e80 = hr;
    let _e84 = br;
    let _e87 = lineDist(_e79, vec2<f32>(-(_e80), 0f), vec2<f32>(_e84, 0f));
    let _e88 = tr;
    c = min(_e78, (_e87 - _e88));
    let _e91 = c;
    return _e91;
}

fn rand2rel(co: vec2<f32>) -> vec2<f32> {
    var co_1: vec2<f32>;
    var x: f32;
    var y: f32;

    co_1 = co;
    let _e8 = co_1;
    x = fract((sin(dot(_e8.xy, vec2<f32>(12.9898f, 78.233f))) * 43758.547f));
    let _e19 = x;
    let _e20 = co_1;
    y = fract((sin(dot(vec2<f32>(_e19, _e20.x), vec2<f32>(12.9898f, 78.233f))) * 43758.547f));
    let _e32 = x;
    let _e33 = y;
    return (vec2<f32>(_e32, _e33) - vec2<f32>(0.5f, 0.5f));
}

fn getHeight(i: f32, height: f32) -> f32 {
    var i_1: f32;
    var height_1: f32;
    var rnd: vec2<f32>;
    var h: f32;
    var growth: f32;
    var boost: f32;

    i_1 = i;
    height_1 = height;
    let _e10 = i_1;
    let _e11 = i_1;
    let _e13 = rand2rel(vec2<f32>(_e10, _e11));
    rnd = (_e13 + vec2(0.5f));
    let _e19 = rnd;
    h = (1f + (_e19.x * 10f));
    let _e27 = rnd;
    let _e31 = height_1;
    growth = smoothstep(0.5f, 1f, pow(_e27.y, (10f - (9f * _e31))));
    let _e41 = rnd;
    let _e43 = rnd;
    boost = (1f + (2f * smoothstep(0.9f, 1f, (_e41.x * _e43.y))));
    let _e50 = h;
    let _e51 = height_1;
    let _e52 = growth;
    let _e54 = boost;
    h = (_e50 + (((_e51 * _e52) * _e54) * 25f));
    let _e59 = h;
    return _e59;
}

fn mergeRect(a_6: f32, dist: f32, blur: f32) -> f32 {
    var a_7: f32;
    var dist_1: f32;
    var blur_1: f32;

    a_7 = a_6;
    dist_1 = dist;
    blur_1 = blur;
    let _e12 = blur_1;
    let _e14 = dist_1;
    let _e16 = a_7;
    return max(smoothstep(_e12, 0f, _e14), _e16);
}

fn rand21alt(u_2: vec2<f32>) -> f32 {
    var u_3: vec2<f32>;

    u_3 = u_2;
    let _e8 = u_3;
    let _e9 = rand2rel(_e8);
    return (_e9.x * 2f);
}

fn rand2_(v: vec2<f32>) -> vec2<f32> {
    var v_1: vec2<f32>;
    var x_1: f32;
    var y_1: f32;

    v_1 = v;
    let _e8 = v_1;
    x_1 = fract((sin(dot(_e8.xy, vec2<f32>(12.9898f, 78.233f))) * 43758.547f));
    let _e19 = x_1;
    let _e20 = v_1;
    y_1 = fract((sin(dot(vec2<f32>(_e19, _e20.x), vec2<f32>(12.9898f, 78.233f))) * 43758.547f));
    let _e32 = x_1;
    let _e33 = y_1;
    return vec2<f32>(_e32, _e33);
}

fn varyNoiseSmoothly(noise: f32, k: f32) -> f32 {
    var noise_1: f32;
    var k_1: f32;
    var phase: f32;
    var freq: f32;

    noise_1 = noise;
    k_1 = k;
    let _e11 = noise_1;
    phase = acos(((2f * _e11) - 1f));
    let _e17 = noise_1;
    freq = (fract((_e17 * 16f)) + 0.5f);
    let _e25 = phase;
    let _e26 = freq;
    let _e27 = k_1;
    return ((1f + cos((_e25 + (_e26 * _e27)))) * 0.5f);
}

fn varyVec2NoiseSmoothly(noise_2: vec2<f32>, k_2: f32) -> vec2<f32> {
    var noise_3: vec2<f32>;
    var k_3: f32;

    noise_3 = noise_2;
    k_3 = k_2;
    let _e10 = noise_3;
    let _e12 = k_3;
    let _e13 = varyNoiseSmoothly(_e10.x, _e12);
    let _e14 = noise_3;
    let _e16 = k_3;
    let _e17 = varyNoiseSmoothly(_e14.y, _e16);
    return vec2<f32>(_e13, _e17);
}

fn rand2relSeeded(co_2: vec2<f32>, seed: f32) -> vec2<f32> {
    var co_3: vec2<f32>;
    var seed_1: f32;

    co_3 = co_2;
    seed_1 = seed;
    let _e10 = co_3;
    let _e11 = rand2_(_e10);
    let _e12 = seed_1;
    let _e13 = varyVec2NoiseSmoothly(_e11, _e12);
    return (_e13 - vec2(0.5f));
}

fn rectDist(p_4: vec2<f32>, width: f32, height_2: f32) -> f32 {
    var p_5: vec2<f32>;
    var width_1: f32;
    var height_3: f32;

    p_5 = p_4;
    width_1 = width;
    height_3 = height_2;
    let _e12 = p_5;
    p_5 = abs(_e12);
    let _e14 = p_5;
    let _e15 = p_5;
    let _e18 = width_1;
    let _e22 = p_5;
    let _e25 = height_3;
    return length((_e14 - vec2<f32>(clamp(_e15.x, 0f, (_e18 / 2f)), clamp(_e22.y, 0f, (_e25 / 2f)))));
}

fn layer(u_4: vec2<f32>, color: vec4<f32>, windowColor: vec4<f32>, columnColor: vec4<f32>, blur_2: f32, ht: f32, seed_2: f32, lights: f32, columns: f32) -> vec4<f32> {
    var u_5: vec2<f32>;
    var color_1: vec4<f32>;
    var windowColor_1: vec4<f32>;
    var columnColor_1: vec4<f32>;
    var blur_3: f32;
    var ht_1: f32;
    var seed_3: f32;
    var lights_1: f32;
    var columns_1: f32;
    var a_8: f32;
    var id: vec2<f32>;
    var height_4: f32;
    var height1_: f32;
    var height2_: f32;
    var v_2: vec2<f32>;
    var col: vec4<f32>;
    var rnd_1: vec2<f32>;
    var occupied: f32;
    var lightColumn: f32 = 0f;
    var wRatio: vec2<f32> = vec2<f32>(5f, 3f);
    var v_3: vec2<f32>;
    var id_1: vec2<f32>;
    var windowSize: f32;
    var rndW: f32;
    var local: f32;
    var catDistance: f32;
    var windowLight: f32;

    u_5 = u_4;
    color_1 = color;
    windowColor_1 = windowColor;
    columnColor_1 = columnColor;
    blur_3 = blur_2;
    ht_1 = ht;
    seed_3 = seed_2;
    lights_1 = lights;
    columns_1 = columns;
    let _e24 = blur_3;
    let _e26 = u_5;
    a_8 = smoothstep(_e24, 0f, _e26.y);
    let _e30 = u_5;
    id = floor(_e30);
    let _e33 = id;
    let _e35 = ht_1;
    let _e36 = getHeight(_e33.x, _e35);
    height_4 = _e36;
    let _e38 = id;
    let _e42 = ht_1;
    let _e43 = getHeight((_e38.x - 1f), _e42);
    height1_ = _e43;
    let _e45 = id;
    let _e49 = ht_1;
    let _e50 = getHeight((_e45.x + 1f), _e49);
    height2_ = _e50;
    let _e52 = u_5;
    v_2 = fract(_e52);
    let _e55 = color_1;
    col = _e55;
    let _e57 = id;
    let _e61 = seed_3;
    let _e62 = rand2relSeeded((_e57.xx * 0.11f), _e61);
    rnd_1 = (_e62 * 2f);
    let _e66 = rnd_1;
    let _e68 = lights_1;
    let _e71 = rnd_1;
    let _e74 = rnd_1;
    let _e77 = lights_1;
    occupied = (((sign((_e66.x + _e68)) * _e71.x) * _e74.x) * _e77);
    let _e82 = u_5;
    let _e86 = u_5;
    let _e88 = height_4;
    if ((_e82.y > 0f) && (_e86.y < (_e88 / 2f))) {
        {
            let _e97 = u_5;
            let _e99 = height_4;
            let _e107 = wRatio;
            v_3 = (((_e97 - vec2<f32>(0f, (_e99 / 2f))) + vec2(0.5f)) * _e107);
            let _e110 = v_3;
            id_1 = floor((_e110 + vec2(0.5f)));
            let _e117 = blur_3;
            windowSize = (0.3f - _e117);
            let _e120 = id_1;
            let _e121 = rand21alt(_e120);
            rndW = abs(_e121);
            let _e124 = id_1;
            let _e126 = height_4;
            let _e135 = rndW;
            let _e137 = occupied;
            let _e140 = lights_1;
            if ((_e124.y > (((-(_e126) / 2f) * 3f) + 3f)) && (abs(_e135) < ((_e137 * 1f) * _e140))) {
                {
                    let _e144 = rndW;
                    if (fract((_e144 * 10f)) > 0.99f) {
                        let _e151 = v_3;
                        let _e152 = id_1;
                        let _e154 = wRatio;
                        let _e156 = catDist(((_e151 - _e152) / _e154));
                        local = (3f * _e156);
                    } else {
                        local = 10000f;
                    }
                    let _e160 = local;
                    catDistance = _e160;
                    let _e162 = blur_3;
                    let _e166 = catDistance;
                    let _e168 = v_3;
                    let _e169 = id_1;
                    let _e171 = windowSize;
                    let _e172 = windowSize;
                    let _e173 = rectDist((_e168 - _e169), _e171, _e172);
                    windowLight = smoothstep((_e162 * 3f), 0f, max(-(_e166), _e173));
                    let _e177 = col;
                    let _e178 = windowColor_1;
                    let _e179 = windowLight;
                    col = mix(_e177, _e178, vec4(clamp(_e179, 0f, 1f)));
                }
            }
        }
    } else {
        let _e185 = height_4;
        let _e188 = u_5;
        let _e190 = height_4;
        let _e195 = rnd_1;
        let _e199 = columns_1;
        if (((_e185 < 2f) && (_e188.y > (_e190 / 2f))) && (abs(_e195.y) > (1f - _e199))) {
            {
                let _e206 = u_5;
                let _e208 = height_4;
                let _e217 = u_5;
                let _e219 = u_5;
                lightColumn = (((20f / (10f + max(0f, (_e206.y - _e208)))) * 0.5f) * smoothstep(0.5f, 0.3f, abs(((_e217.x - floor(_e219.x)) - 0.5f))));
            }
        }
    }
    let _e228 = blur_3;
    let _e230 = u_5;
    let _e231 = id;
    let _e239 = height_4;
    let _e240 = rectDist((_e230 - vec2<f32>((_e231.x + 0.5f), 0f)), 1f, _e239);
    let _e242 = a_8;
    a_8 = max(smoothstep(_e228, 0f, _e240), _e242);
    let _e244 = blur_3;
    let _e246 = u_5;
    let _e247 = id;
    let _e255 = height1_;
    let _e256 = rectDist((_e246 - vec2<f32>((_e247.x - 0.5f), 0f)), 1f, _e255);
    let _e258 = a_8;
    a_8 = max(smoothstep(_e244, 0f, _e256), _e258);
    let _e260 = blur_3;
    let _e262 = u_5;
    let _e263 = id;
    let _e271 = height2_;
    let _e272 = rectDist((_e262 - vec2<f32>((_e263.x + 1.5f), 0f)), 1f, _e271);
    let _e274 = a_8;
    a_8 = max(smoothstep(_e260, 0f, _e272), _e274);
    let _e276 = height_4;
    if (_e276 > 11f) {
        {
            let _e279 = rnd_1;
            if (_e279.y < 0.3f) {
                {
                    let _e283 = a_8;
                    let _e284 = u_5;
                    let _e285 = id;
                    let _e293 = blur_3;
                    let _e295 = height_4;
                    let _e298 = rectDist((_e284 - vec2<f32>((_e285.x + 0.5f), 0f)), (0.125f - _e293), (_e295 + 4f));
                    let _e299 = blur_3;
                    let _e300 = mergeRect(_e283, _e298, _e299);
                    a_8 = _e300;
                    let _e301 = rnd_1;
                    if (_e301.x > 0.9f) {
                        {
                            let _e305 = blur_3;
                            let _e307 = u_5;
                            let _e308 = id;
                            let _e312 = rnd_1;
                            let _e317 = height_4;
                            let _e326 = catDist((_e307 - vec2<f32>(((_e308.x + 0.5f) + (_e312.y * 0.04f)), (((_e317 + 4f) / 2f) + 0.051f))));
                            let _e328 = a_8;
                            a_8 = max(smoothstep(_e305, 0f, _e326), _e328);
                        }
                    }
                }
            } else {
                let _e330 = rnd_1;
                if (_e330.y < 0.45f) {
                    {
                        let _e334 = a_8;
                        let _e335 = u_5;
                        let _e336 = id;
                        let _e344 = blur_3;
                        let _e346 = height_4;
                        let _e349 = rectDist((_e335 - vec2<f32>((_e336.x + 0.75f), 0f)), (0.125f - _e344), (_e346 + 3f));
                        let _e350 = blur_3;
                        let _e351 = mergeRect(_e334, _e349, _e350);
                        a_8 = _e351;
                        let _e352 = a_8;
                        let _e353 = u_5;
                        let _e354 = id;
                        let _e362 = blur_3;
                        let _e364 = height_4;
                        let _e367 = rectDist((_e353 - vec2<f32>((_e354.x + 0.25f), 0f)), (0.125f - _e362), (_e364 + 3f));
                        let _e368 = blur_3;
                        let _e369 = mergeRect(_e352, _e367, _e368);
                        a_8 = _e369;
                    }
                }
            }
        }
    }
    let _e370 = col;
    let _e371 = _e370.xyz;
    let _e372 = a_8;
    let _e378 = lightColumn;
    let _e380 = columnColor_1;
    return (vec4<f32>(_e371.x, _e371.y, _e371.z, _e372) + ((2.5f * _e378) * _e380));
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

fn rand11_(x_2: f32) -> f32 {
    var x_3: f32;

    x_3 = x_2;
    let _e8 = x_3;
    let _e9 = x_3;
    let _e11 = rand2rel(vec2<f32>(_e8, _e9));
    return (_e11.x * 2f);
}

fn stars(u_6: vec2<f32>, seed_4: f32) -> f32 {
    var u_7: vec2<f32>;
    var seed_5: f32;
    var id_2: vec2<f32>;
    var rnd_2: vec2<f32>;
    var r_2: f32;
    var delta: vec2<f32>;
    var radius: f32;
    var local_1: f32;

    u_7 = u_6;
    seed_5 = seed_4;
    let _e10 = u_7;
    u_7 = (_e10 * 100f);
    let _e13 = u_7;
    id_2 = floor(_e13);
    let _e16 = id_2;
    let _e17 = seed_5;
    let _e18 = rand2relSeeded(_e16, _e17);
    rnd_2 = _e18;
    let _e20 = rnd_2;
    let _e22 = rnd_2;
    r_2 = abs((_e20.x + _e22.y));
    let _e27 = rnd_2;
    delta = (_e27 * 0.35f);
    let _e31 = r_2;
    radius = (pow(_e31, 30f) * 0.5f);
    let _e37 = radius;
    if (_e37 <= 0f) {
        local_1 = 0f;
    } else {
        let _e41 = radius;
        let _e43 = u_7;
        let _e44 = id_2;
        let _e49 = delta;
        local_1 = smoothstep(_e41, 0f, length((((_e43 - _e44) - vec2(0.5f)) + _e49)));
    }
    let _e54 = local_1;
    return _e54;
}

fn citySkyline(uv: vec2<f32>, outPos: vec2<f32>, source_specified: i32, color1_: vec4<f32>, color2_: vec4<f32>, color3_: vec4<f32>, color4_: vec4<f32>, count: i32, randomSeed: f32, blur_4: f32, height_5: f32, reflectivity: f32, modelTransform: mat3x3<f32>) -> vec4<f32> {
    var uv_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var source_specified_1: i32;
    var color1_1: vec4<f32>;
    var color2_1: vec4<f32>;
    var color3_1: vec4<f32>;
    var color4_1: vec4<f32>;
    var count_1: i32;
    var randomSeed_1: f32;
    var blur_5: f32;
    var height_6: f32;
    var reflectivity_1: f32;
    var modelTransform_1: mat3x3<f32>;
    var lights_2: f32;
    var columns_2: f32;
    var sunColor: vec4<f32>;
    var buildingColor: vec4<f32>;
    var skyColor: vec4<f32>;
    var windowColor_2: vec4<f32>;
    var warmSkyColor: vec4<f32>;
    var panningSpeed: f32 = 8f;
    var Y_1: f32 = 0f;
    var inverseModelTransform: mat3x3<f32>;
    var panning: vec2<f32>;
    var cameraScale: f32;
    var reflected: f32 = 0f;
    var reflectY: f32;
    var bkg_2: vec4<f32>;
    var skyDamp: f32;
    var cloudDamp: f32 = 1f;
    var sunDist: f32;
    var color_2: vec4<f32>;
    var N: f32;
    var i_2: f32;
    var local_2: f32;
    var layerRatio: f32;
    var building: vec4<f32>;
    var window: vec4<f32>;
    var column: vec4<f32>;
    var scale: f32;
    var offset: f32;
    var outColor: vec4<f32>;

    uv_1 = uv;
    outPos_1 = outPos;
    source_specified_1 = source_specified;
    color1_1 = color1_;
    color2_1 = color2_;
    color3_1 = color3_;
    color4_1 = color4_;
    count_1 = count;
    randomSeed_1 = randomSeed;
    blur_5 = blur_4;
    height_6 = height_5;
    reflectivity_1 = reflectivity;
    modelTransform_1 = modelTransform;
    let _e32 = uv_1;
    uv_1 = -(_e32);
    let _e34 = randomSeed_1;
    lights_2 = ((sin(((_e34 - 12f) * 0.3f)) * 0.6f) + 0.4f);
    let _e46 = lights_2;
    lights_2 = max(0f, _e46);
    let _e48 = lights_2;
    let _e49 = lights_2;
    lights_2 = (_e48 * _e49);
    let _e51 = randomSeed_1;
    columns_2 = ((sin(((_e51 - 12f) * 0.7f)) * 0.8f) + 0.2f);
    let _e63 = columns_2;
    columns_2 = max(0f, _e63);
    let _e65 = columns_2;
    let _e66 = columns_2;
    columns_2 = (_e65 * _e66);
    let _e69 = blur_5;
    blur_5 = (max(0.0001f, _e69) * 0.2f);
    let _e73 = color1_1;
    sunColor = _e73;
    let _e75 = color2_1;
    buildingColor = _e75;
    let _e77 = color3_1;
    skyColor = _e77;
    let _e79 = color4_1;
    windowColor_2 = _e79;
    let _e81 = sunColor;
    let _e82 = skyColor;
    warmSkyColor = mix(_e81, _e82, vec4(0.5f));
    let _e91 = modelTransform_1;
    inverseModelTransform = _naga_inverse_3x3_f32(_e91);
    let _e98 = inverseModelTransform[2][0];
    let _e103 = inverseModelTransform[2][1];
    panning = (vec2<f32>(_e98, _e103) * 1f);
    let _e112 = inverseModelTransform[0][0];
    let _e117 = inverseModelTransform[0][1];
    cameraScale = length(vec2<f32>(_e112, _e117));
    let _e123 = Y_1;
    let _e124 = panning;
    let _e126 = panningSpeed;
    let _e132 = cameraScale;
    reflectY = ((-((_e123 + (_e124.y * _e126))) / 4f) / _e132);
    let _e135 = uv_1;
    let _e137 = reflectY;
    if (_e135.y < _e137) {
        {
            let _e141 = reflectY;
            let _e143 = uv_1;
            uv_1.y = ((2f * _e141) - _e143.y);
            let _e147 = reflectivity_1;
            reflected = (1f - (_e147 * 0.01f));
        }
    }
    let _e151 = warmSkyColor;
    let _e152 = skyColor;
    let _e153 = uv_1;
    bkg_2 = mix(_e151, _e152, vec4(clamp(((_e153.y * 2f) - 0.25f), 0f, 1f)));
    let _e167 = bkg_2;
    let _e169 = bkg_2;
    let _e172 = bkg_2;
    skyDamp = smoothstep(0.3f, 0.05f, (((_e167.x + _e169.y) + _e172.z) * 0.333f));
    let _e181 = bkg_2;
    let _e182 = windowColor_2;
    let _e185 = uv_1;
    let _e186 = randomSeed_1;
    let _e187 = stars(_e185, _e186);
    let _e188 = skyDamp;
    let _e190 = cloudDamp;
    bkg_2 = mix(_e181, (_e182 * 2f), vec4(((_e187 * _e188) * _e190)));
    let _e195 = blur_5;
    let _e200 = blur_5;
    let _e204 = uv_1;
    sunDist = smoothstep((0.275f + (_e195 * 0.2f)), (0.275f - (_e200 * 0.2f)), length(_e204));
    let _e208 = bkg_2;
    let _e209 = sunColor;
    let _e210 = sunDist;
    let _e211 = cloudDamp;
    bkg_2 = mix(_e208, _e209, vec4((_e210 * _e211)));
    let _e215 = uv_1;
    let _e216 = cameraScale;
    uv_1 = (_e215 * _e216);
    let _e218 = bkg_2;
    color_2 = _e218;
    let _e220 = count_1;
    N = f32(_e220);
    let _e223 = N;
    i_2 = _e223;
    loop {
        let _e225 = i_2;
        if !((_e225 > 0f)) {
            break;
        }
        {
            let _e232 = N;
            if (_e232 == 1f) {
                local_2 = 0f;
            } else {
                let _e236 = i_2;
                let _e239 = N;
                local_2 = ((_e236 - 1f) / (_e239 - 1f));
            }
            let _e244 = local_2;
            layerRatio = _e244;
            let _e246 = buildingColor;
            let _e247 = warmSkyColor;
            let _e248 = layerRatio;
            building = mix(_e246, _e247, vec4(_e248));
            let _e252 = windowColor_2;
            let _e253 = warmSkyColor;
            let _e254 = layerRatio;
            window = mix(_e252, _e253, vec4(_e254));
            let _e258 = windowColor_2;
            let _e259 = warmSkyColor;
            let _e260 = layerRatio;
            let _e265 = mix(_e258, _e259, vec4((_e260 * 0.3f))).xyz;
            let _e268 = layerRatio;
            column = vec4<f32>(_e265.x, _e265.y, _e265.z, max(0f, (0.6f - _e268)));
            let _e278 = i_2;
            scale = (2f + (2f * _e278));
            let _e283 = i_2;
            let _e284 = rand11_(_e283);
            offset = (415.24f * _e284);
            let _e287 = color_2;
            let _e288 = uv_1;
            let _e289 = scale;
            let _e291 = offset;
            let _e292 = Y_1;
            let _e295 = panning;
            let _e296 = panningSpeed;
            let _e299 = building;
            let _e300 = window;
            let _e301 = column;
            let _e302 = blur_5;
            let _e303 = height_6;
            let _e304 = randomSeed_1;
            let _e305 = lights_2;
            let _e306 = columns_2;
            let _e307 = layer((((_e288 * _e289) + vec2<f32>(_e291, _e292)) + (_e295 * _e296)), _e299, _e300, _e301, _e302, _e303, _e304, _e305, _e306);
            let _e308 = blend_1(_e287, _e307);
            color_2 = _e308;
        }
        continuing {
            let _e229 = i_2;
            i_2 = (_e229 - 1f);
        }
    }
    let _e309 = color_2;
    let _e310 = buildingColor;
    let _e311 = reflected;
    outColor = mix(_e309, _e310, vec4(_e311));
    let _e315 = source_specified_1;
    if (_e315 == 1i) {
        let _e318 = outPos_1;
        let _e322 = global.U[0];
        let _e325 = outPos_1;
        let _e334 = textureSample(t_source, samp, ((vec2<f32>((_e318.x / _e322.x), _e325.y) / vec2(2f)) + vec2(0.5f)));
        let _e335 = outColor;
        let _e336 = mergeColor(_e334, _e335);
        return _e336;
    } else {
        let _e337 = outColor;
        return _e337;
    }
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
    let _e83 = global.U[10];
    let _e88 = global.U[11];
    let _e92 = global.U[12];
    let _e96 = global.U[13];
    let _e100 = global.U[14];
    let _e104 = global.U[15];
    let _e105 = _e104.xyz;
    let _e108 = global.U[16];
    let _e109 = _e108.xyz;
    let _e112 = global.U[17];
    let _e113 = _e112.xyz;
    let _e127 = citySkyline((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e9.x, _e9.y, _e9.z), vec3<f32>(_e13.x, _e13.y, _e13.z), vec3<f32>(_e17.x, _e17.y, _e17.z))) * vec3<f32>(_e44.x, _e44.y, 1f)).xy, (((_e51 - vec2(0.5f)) * 2f) * vec2<f32>(_e59.x, 1f)), i32(_e66.x), _e71, _e74, _e77, _e80, i32(_e83.x), _e88.x, _e92.x, _e96.x, _e100.x, mat3x3<f32>(vec3<f32>(_e105.x, _e105.y, _e105.z), vec3<f32>(_e109.x, _e109.y, _e109.z), vec3<f32>(_e113.x, _e113.y, _e113.z)));
    fragColor = _e127;
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
