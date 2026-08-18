struct Params {
    U: array<vec4<f32>, 17>,
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

fn triangleWave(x: f32) -> f32 {
    var x_1: f32;
    var s: f32 = 1f;

    x_1 = x;
    let _e8 = x_1;
    x_1 = (_e8 - (floor((_e8 / 4f)) * 4f));
    let _e16 = x_1;
    if (_e16 > 2f) {
        {
            let _e19 = x_1;
            x_1 = (_e19 - 2f);
            s = -1f;
        }
    }
    let _e24 = s;
    let _e26 = x_1;
    return (_e24 * (1f - abs((_e26 - 1f))));
}

fn chan(k: f32, randomSeed: f32) -> f32 {
    var k_1: f32;
    var randomSeed_1: f32;

    k_1 = k;
    randomSeed_1 = randomSeed;
    let _e10 = k_1;
    let _e11 = randomSeed_1;
    let _e15 = k_1;
    let _e20 = triangleWave((((_e10 * _e11) + 0f) + fract((_e15 * 19f))));
    return ((_e20 * 0.5f) + 0.5f);
}

fn getLinCol(i: f32, size: f32, randomSeed_2: f32, c1_: vec4<f32>, c2_: vec4<f32>, c3_: vec4<f32>, c4_: vec4<f32>, c5_: vec4<f32>) -> vec4<f32> {
    var i_1: f32;
    var size_1: f32;
    var randomSeed_3: f32;
    var c1_1: vec4<f32>;
    var c2_1: vec4<f32>;
    var c3_1: vec4<f32>;
    var c4_1: vec4<f32>;
    var c5_1: vec4<f32>;
    var y1_: f32;
    var y2_: f32;
    var y3_: f32;
    var y4_: f32;
    var y5_: f32;
    var x_2: f32;

    i_1 = i;
    size_1 = size;
    randomSeed_3 = randomSeed_2;
    c1_1 = c1_;
    c2_1 = c2_;
    c3_1 = c3_;
    c4_1 = c4_;
    c5_1 = c5_;
    let _e23 = randomSeed_3;
    let _e24 = chan(0.4f, _e23);
    y1_ = _e24;
    let _e26 = y1_;
    let _e28 = randomSeed_3;
    let _e29 = chan(0.8f, _e28);
    y2_ = (_e26 + _e29);
    let _e32 = y2_;
    let _e34 = randomSeed_3;
    let _e35 = chan(1.232f, _e34);
    y3_ = (_e32 + _e35);
    let _e38 = y3_;
    let _e40 = randomSeed_3;
    let _e41 = chan(2.323f, _e40);
    y4_ = (_e38 + _e41);
    let _e44 = y4_;
    let _e46 = randomSeed_3;
    let _e47 = chan(2.44f, _e46);
    y5_ = (_e44 + _e47);
    let _e50 = i_1;
    let _e51 = size_1;
    let _e53 = (_e50 / round(_e51));
    let _e62 = y5_;
    x_2 = (abs(((_e53 - (floor((_e53 / 2f)) * 2f)) - 1f)) * _e62);
    let _e65 = x_2;
    let _e66 = y1_;
    if (_e65 < _e66) {
        let _e68 = c1_1;
        return _e68;
    } else {
        let _e69 = x_2;
        let _e70 = y2_;
        if (_e69 < _e70) {
            let _e72 = c2_1;
            return _e72;
        } else {
            let _e73 = x_2;
            let _e74 = y3_;
            if (_e73 < _e74) {
                let _e76 = c3_1;
                return _e76;
            } else {
                let _e77 = x_2;
                let _e78 = y4_;
                if (_e77 < _e78) {
                    let _e80 = c4_1;
                    return _e80;
                } else {
                    let _e81 = c5_1;
                    return _e81;
                }
            }
        }
    }
}

fn hash11_(x_3: f32) -> f32 {
    var x_4: f32;

    x_4 = x_3;
    let _e8 = x_4;
    return fract((sin(((_e8 * 45.34f) + 123.131f)) * 94.434f));
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

fn overUnder1_(uv: vec2<f32>) -> vec2<f32> {
    var uv_1: vec2<f32>;

    uv_1 = uv;
    return vec2<f32>(0.5f, 1f);
}

fn overUnder10_(uv_2: vec2<f32>, patternShape: f32) -> vec2<f32> {
    var uv_3: vec2<f32>;
    var patternShape_1: f32;
    var id: vec2<f32>;
    var mode: f32;
    var div: f32;
    var local: f32;
    var k_2: f32;

    uv_3 = uv_2;
    patternShape_1 = patternShape;
    let _e10 = uv_3;
    id = floor(_e10);
    let _e13 = patternShape_1;
    mode = _e13;
    let _e16 = patternShape_1;
    div = (2f / _e16);
    let _e19 = id;
    let _e22 = id;
    let _e26 = f32((i32(_e19.x) ^ i32(_e22.y)));
    let _e27 = mode;
    let _e32 = div;
    if (((_e26 - (floor((_e26 / _e27)) * _e27)) * _e32) >= 1f) {
        local = 1f;
    } else {
        local = 0f;
    }
    let _e39 = local;
    k_2 = _e39;
    let _e41 = k_2;
    return vec2<f32>(_e41, 1f);
}

fn overUnder11_(uv_4: vec2<f32>, patternShape_2: f32) -> vec2<f32> {
    var uv_5: vec2<f32>;
    var patternShape_3: f32;
    var id_1: vec2<f32>;
    var mode_1: f32;
    var div_1: f32;
    var k_3: f32;

    uv_5 = uv_4;
    patternShape_3 = patternShape_2;
    let _e10 = uv_5;
    id_1 = floor(_e10);
    let _e13 = patternShape_3;
    mode_1 = _e13;
    let _e16 = patternShape_3;
    div_1 = (2f / _e16);
    let _e19 = id_1;
    let _e22 = id_1;
    let _e26 = f32((i32(_e19.x) ^ i32(_e22.y)));
    let _e27 = mode_1;
    let _e32 = div_1;
    k_3 = ((_e26 - (floor((_e26 / _e27)) * _e27)) * _e32);
    let _e35 = k_3;
    return vec2<f32>(_e35, 1f);
}

fn overUnder2_(uv_6: vec2<f32>, patternShape_4: f32) -> vec2<f32> {
    var uv_7: vec2<f32>;
    var patternShape_5: f32;
    var id_2: vec2<f32>;
    var N: i32;
    var local_1: f32;
    var k_4: f32;

    uv_7 = uv_6;
    patternShape_5 = patternShape_4;
    let _e10 = uv_7;
    id_2 = floor(_e10);
    let _e13 = patternShape_5;
    N = i32(_e13);
    let _e16 = id_2;
    let _e18 = id_2;
    let _e20 = (_e16.x + _e18.y);
    let _e21 = N;
    let _e22 = f32(_e21);
    let _e27 = N;
    if ((_e20 - (floor((_e20 / _e22)) * _e22)) >= f32((_e27 / 2i))) {
        local_1 = 0f;
    } else {
        local_1 = 1f;
    }
    let _e35 = local_1;
    k_4 = _e35;
    let _e37 = k_4;
    return vec2<f32>(_e37, 1f);
}

fn overUnder2b(uv_8: vec2<f32>, patternShape_6: f32, shadows: f32) -> vec2<f32> {
    var uv_9: vec2<f32>;
    var patternShape_7: f32;
    var shadows_1: f32;
    var id_3: vec2<f32>;
    var N_1: i32;
    var kk: f32;
    var local_2: f32;
    var k_5: f32;
    var light: f32 = 1f;
    var d2_: f32 = 0.85f;
    var d1_: f32;
    var delta: vec2<f32>;
    var kkk: f32;
    var delta_1: vec2<f32>;
    var kkk_1: f32;

    uv_9 = uv_8;
    patternShape_7 = patternShape_6;
    shadows_1 = shadows;
    let _e12 = uv_9;
    id_3 = floor(_e12);
    let _e15 = patternShape_7;
    N_1 = i32(_e15);
    let _e18 = id_3;
    let _e20 = id_3;
    let _e22 = (_e18.x + _e20.y);
    let _e23 = N_1;
    let _e24 = f32(_e23);
    kk = (_e22 - (floor((_e22 / _e24)) * _e24));
    let _e30 = kk;
    let _e31 = N_1;
    if (_e30 >= f32((_e31 / 2i))) {
        local_2 = 0f;
    } else {
        local_2 = 1f;
    }
    let _e39 = local_2;
    k_5 = _e39;
    let _e46 = shadows_1;
    d1_ = (0.85f - _e46);
    let _e49 = k_5;
    if (_e49 == 0f) {
        {
            let _e52 = uv_9;
            delta = (fract(_e52) - vec2(0.5f));
            let _e58 = id_3;
            let _e60 = uv_9;
            let _e62 = (_e58.x + _e60.y);
            let _e63 = N_1;
            let _e64 = f32(_e63);
            kkk = (_e62 - (floor((_e62 / _e64)) * _e64));
            let _e70 = kkk;
            let _e71 = N_1;
            let _e78 = kkk;
            let _e79 = N_1;
            if ((_e70 < (f32((_e71 / 2i)) + 0.5f)) || (_e78 > (f32(_e79) - 0.5f))) {
                let _e85 = d2_;
                let _e86 = d1_;
                let _e87 = delta;
                light = smoothstep(_e85, _e86, length(_e87));
            } else {
                let _e90 = d2_;
                let _e91 = d1_;
                let _e92 = uv_9;
                light = smoothstep(_e90, _e91, abs((fract(_e92.x) - 0.5f)));
            }
        }
    } else {
        {
            let _e99 = uv_9;
            delta_1 = (fract(_e99) - vec2(0.5f));
            let _e105 = uv_9;
            let _e107 = id_3;
            let _e109 = (_e105.x + _e107.y);
            let _e110 = N_1;
            let _e111 = f32(_e110);
            kkk_1 = (_e109 - (floor((_e109 / _e111)) * _e111));
            let _e117 = kkk_1;
            let _e120 = kkk_1;
            let _e121 = N_1;
            if ((_e117 < 0.5f) || (_e120 > (f32((_e121 / 2i)) - 0.5f))) {
                let _e129 = d2_;
                let _e130 = d1_;
                let _e131 = delta_1;
                light = smoothstep(_e129, _e130, length(_e131));
            } else {
                let _e134 = d2_;
                let _e135 = d1_;
                let _e136 = uv_9;
                light = smoothstep(_e134, _e135, abs((fract(_e136.y) - 0.5f)));
            }
        }
    }
    let _e143 = k_5;
    let _e144 = light;
    return vec2<f32>(_e143, _e144);
}

fn overUnder3_(uv_10: vec2<f32>, patternShape_8: f32) -> vec2<f32> {
    var uv_11: vec2<f32>;
    var patternShape_9: f32;

    uv_11 = uv_10;
    patternShape_9 = patternShape_8;
    let _e10 = uv_11;
    let _e12 = patternShape_9;
    uv_11 = (_e10 / vec2(max(1f, round(_e12))));
    let _e17 = uv_11;
    let _e20 = uv_11;
    return vec2<f32>(((fract(_e17.x) + fract(_e20.y)) * 0.707f), 1f);
}

fn overUnder4_(uv_12: vec2<f32>, patternShape_10: f32) -> vec2<f32> {
    var uv_13: vec2<f32>;
    var patternShape_11: f32;
    var scale: f32;
    var u: vec2<f32>;

    uv_13 = uv_12;
    patternShape_11 = patternShape_10;
    let _e12 = patternShape_11;
    scale = (1f / max(1f, round(_e12)));
    let _e17 = uv_13;
    let _e18 = scale;
    u = abs((fract((_e17 * _e18)) - vec2(0.5f)));
    let _e26 = u;
    let _e28 = u;
    return vec2<f32>(((_e26.x + _e28.y) * 0.707f), 1f);
}

fn overUnder5_(uv_14: vec2<f32>, patternShape_12: f32) -> vec2<f32> {
    var uv_15: vec2<f32>;
    var patternShape_13: f32;
    var scale_1: f32;
    var delta_2: vec2<f32>;
    var k_6: f32;
    var light_1: f32 = 1f;

    uv_15 = uv_14;
    patternShape_13 = patternShape_12;
    let _e12 = patternShape_13;
    scale_1 = (1f / max(1f, round(_e12)));
    let _e17 = uv_15;
    let _e18 = scale_1;
    delta_2 = (fract((_e17 * _e18)) - vec2(0.5f));
    let _e27 = delta_2;
    k_6 = smoothstep(0.3f, 0.35f, length(_e27));
    let _e33 = k_6;
    let _e34 = light_1;
    return vec2<f32>(_e33, _e34);
}

fn overUnder6_(uv_16: vec2<f32>, patternShape_14: f32, shadows_2: f32) -> vec2<f32> {
    var uv_17: vec2<f32>;
    var patternShape_15: f32;
    var shadows_3: f32;
    var u_1: vec2<f32>;
    var waveFreq: f32;
    var waveStrength: f32;
    var k_7: f32;
    var local_3: f32;
    var light_2: f32;

    uv_17 = uv_16;
    patternShape_15 = patternShape_14;
    shadows_3 = shadows_2;
    let _e12 = uv_17;
    u_1 = (_e12 * 2f);
    let _e18 = patternShape_15;
    let _e21 = triangleWave((_e18 * 0.0551f));
    waveFreq = (0.2f * pow(0.3f, (_e21 * 5f)));
    let _e27 = patternShape_15;
    let _e30 = triangleWave((_e27 * 0.021f));
    let _e35 = waveFreq;
    waveStrength = (((_e30 + 1f) * 1f) / _e35);
    let _e38 = u_1;
    let _e40 = u_1;
    let _e43 = waveStrength;
    let _e44 = waveFreq;
    let _e45 = uv_17;
    let _e47 = uv_17;
    k_7 = ((sin(((_e38.x + _e40.y) + (_e43 * sin((_e44 * (_e45.x - _e47.y)))))) * 0.5f) + 0.5f);
    let _e60 = shadows_3;
    if (_e60 == 0f) {
        local_3 = 1f;
    } else {
        let _e64 = shadows_3;
        let _e68 = shadows_3;
        let _e71 = k_7;
        local_3 = smoothstep((-(_e64) * 0.25f), (_e68 * 0.5f), abs((_e71 - 0.5f)));
    }
    let _e77 = local_3;
    light_2 = _e77;
    let _e79 = k_7;
    let _e80 = light_2;
    return vec2<f32>(_e79, _e80);
}

fn getBitPattern(id_4: vec2<f32>, N_2: i32, mode_2: i32) -> f32 {
    var id_5: vec2<f32>;
    var N_3: i32;
    var mode_3: i32;
    var n: f32;
    var index: f32;
    var bit: i32;
    var local_4: f32;
    var k_8: f32;
    var local_5: f32;

    id_5 = id_4;
    N_3 = N_2;
    mode_3 = mode_2;
    let _e12 = N_3;
    n = f32(_e12);
    let _e15 = id_5;
    let _e17 = n;
    let _e22 = id_5;
    let _e24 = n;
    let _e29 = n;
    index = ((_e15.x - (floor((_e15.x / _e17)) * _e17)) + ((_e22.y - (floor((_e22.y / _e24)) * _e24)) * _e29));
    let _e34 = index;
    bit = i32(pow(2f, f32(_e34)));
    let _e39 = mode_3;
    let _e40 = bit;
    if ((_e39 ^ _e40) == 0i) {
        local_4 = 1f;
    } else {
        local_4 = 0f;
    }
    let _e47 = local_4;
    k_8 = _e47;
    let _e49 = mode_3;
    let _e52 = index;
    let _e54 = (f32(_e49) / pow(2f, _e52));
    if ((_e54 - (floor((_e54 / 2f)) * 2f)) >= 1f) {
        local_5 = 1f;
    } else {
        local_5 = 0f;
    }
    let _e65 = local_5;
    k_8 = _e65;
    let _e66 = k_8;
    return _e66;
}

fn overUnder7_(uv_18: vec2<f32>, patternShape_16: f32) -> vec2<f32> {
    var uv_19: vec2<f32>;
    var patternShape_17: f32;
    var id_6: vec2<f32>;
    var mode_4: i32;
    var N_4: i32 = 2i;
    var k_9: f32;

    uv_19 = uv_18;
    patternShape_17 = patternShape_16;
    let _e10 = uv_19;
    id_6 = floor(_e10);
    let _e13 = patternShape_17;
    mode_4 = i32((_e13 * 100f));
    let _e20 = mode_4;
    if (_e20 < 16i) {
        N_4 = 2i;
    } else {
        let _e24 = mode_4;
        if (_e24 < 528i) {
            {
                N_4 = 3i;
                let _e28 = mode_4;
                mode_4 = (_e28 - 16i);
            }
        } else {
            let _e31 = mode_4;
            if (_e31 < 66064i) {
                {
                    N_4 = 4i;
                    let _e35 = mode_4;
                    mode_4 = (_e35 - 528i);
                }
            } else {
                {
                    N_4 = 5i;
                    let _e39 = mode_4;
                    mode_4 = (_e39 - 66064i);
                }
            }
        }
    }
    let _e42 = id_6;
    let _e43 = N_4;
    let _e44 = mode_4;
    let _e45 = getBitPattern(_e42, _e43, _e44);
    k_9 = _e45;
    let _e47 = k_9;
    return vec2<f32>(_e47, 1f);
}

fn overUnder7b(uv_20: vec2<f32>, patternShape_18: f32, shadows_4: f32) -> vec2<f32> {
    var uv_21: vec2<f32>;
    var patternShape_19: f32;
    var shadows_5: f32;
    var id_7: vec2<f32>;
    var mode_5: i32;
    var N_5: i32 = 2i;
    var k_10: f32;
    var light_3: f32 = 1f;
    var ku: vec2<f32>;
    var du: vec2<f32>;
    var idx: vec2<f32>;
    var idy: vec2<f32>;
    var idxy: vec2<f32>;
    var d1_1: f32 = 0f;
    var d2_1: f32;
    var kx: f32;
    var ky: f32;
    var kxy: f32;

    uv_21 = uv_20;
    patternShape_19 = patternShape_18;
    shadows_5 = shadows_4;
    let _e12 = uv_21;
    id_7 = floor(_e12);
    let _e15 = patternShape_19;
    mode_5 = i32((_e15 * 100f));
    let _e22 = mode_5;
    if (_e22 < 16i) {
        N_5 = 2i;
    } else {
        let _e26 = mode_5;
        if (_e26 < 528i) {
            {
                N_5 = 3i;
                let _e30 = mode_5;
                mode_5 = (_e30 - 16i);
            }
        } else {
            let _e33 = mode_5;
            if (_e33 < 66064i) {
                {
                    N_5 = 4i;
                    let _e37 = mode_5;
                    mode_5 = (_e37 - 528i);
                }
            } else {
                {
                    N_5 = 5i;
                    let _e41 = mode_5;
                    mode_5 = (_e41 - 66064i);
                }
            }
        }
    }
    let _e44 = id_7;
    let _e45 = N_5;
    let _e46 = mode_5;
    let _e47 = getBitPattern(_e44, _e45, _e46);
    k_10 = _e47;
    let _e51 = shadows_5;
    if (_e51 > 0f) {
        {
            let _e54 = uv_21;
            ku = (fract(_e54) - vec2(0.5f));
            let _e60 = ku;
            du = sign(_e60);
            let _e63 = id_7;
            let _e64 = du;
            idx = (_e63 + vec2<f32>(_e64.x, 0f));
            let _e70 = id_7;
            let _e72 = du;
            idy = (_e70 + vec2<f32>(0f, _e72.y));
            let _e77 = id_7;
            let _e78 = du;
            idxy = (_e77 + _e78);
            let _e83 = shadows_5;
            d2_1 = (_e83 * 0.5f);
            let _e87 = idx;
            let _e88 = N_5;
            let _e89 = mode_5;
            let _e90 = getBitPattern(_e87, _e88, _e89);
            kx = _e90;
            let _e92 = idy;
            let _e93 = N_5;
            let _e94 = mode_5;
            let _e95 = getBitPattern(_e92, _e93, _e94);
            ky = _e95;
            let _e97 = idxy;
            let _e98 = N_5;
            let _e99 = mode_5;
            let _e100 = getBitPattern(_e97, _e98, _e99);
            kxy = _e100;
            let _e102 = k_10;
            let _e103 = kx;
            if (_e102 != _e103) {
                let _e105 = light_3;
                let _e106 = d1_1;
                let _e107 = d2_1;
                let _e108 = ku;
                light_3 = min(_e105, smoothstep(_e106, _e107, abs((abs(_e108.x) - 0.5f))));
            }
            let _e116 = k_10;
            let _e117 = ky;
            if (_e116 != _e117) {
                let _e119 = light_3;
                let _e120 = d1_1;
                let _e121 = d2_1;
                let _e122 = ku;
                light_3 = min(_e119, smoothstep(_e120, _e121, abs((abs(_e122.y) - 0.5f))));
            }
            let _e130 = k_10;
            let _e131 = kxy;
            if (_e130 != _e131) {
                let _e133 = light_3;
                let _e134 = d1_1;
                let _e135 = d2_1;
                let _e136 = ku;
                light_3 = min(_e133, smoothstep(_e134, _e135, length((abs(_e136) - vec2(0.5f)))));
            }
        }
    }
    let _e144 = k_10;
    let _e145 = light_3;
    return vec2<f32>(_e144, _e145);
}

fn overUnder8_(uv_22: vec2<f32>, patternShape_20: f32) -> vec2<f32> {
    var uv_23: vec2<f32>;
    var patternShape_21: f32;
    var id_8: vec2<f32>;
    var mode_6: f32;
    var N_6: i32 = 2i;
    var index_1: i32;
    var k_11: f32;

    uv_23 = uv_22;
    patternShape_21 = patternShape_20;
    let _e10 = uv_23;
    id_8 = floor(_e10);
    let _e13 = patternShape_21;
    mode_6 = (_e13 * 100f);
    let _e19 = mode_6;
    if (_e19 < 16f) {
        N_6 = 2i;
    } else {
        let _e23 = mode_6;
        if (_e23 < 528f) {
            {
                N_6 = 3i;
                let _e27 = mode_6;
                mode_6 = (_e27 - 16f);
            }
        } else {
            let _e30 = mode_6;
            if (_e30 < 66064f) {
                {
                    N_6 = 4i;
                    let _e34 = mode_6;
                    mode_6 = (_e34 - 528f);
                }
            } else {
                {
                    N_6 = 5i;
                    let _e38 = mode_6;
                    mode_6 = (_e38 - 66064f);
                }
            }
        }
    }
    let _e41 = id_8;
    let _e44 = N_6;
    let _e46 = id_8;
    let _e49 = N_6;
    let _e51 = N_6;
    index_1 = ((i32(_e41.x) % _e44) + ((i32(_e46.y) % _e49) * _e51));
    let _e55 = mode_6;
    let _e58 = index_1;
    let _e61 = (f32(_e55) / pow(2f, f32(_e58)));
    k_11 = (_e61 - (floor((_e61 / 2f)) * 2f));
    let _e68 = k_11;
    return vec2<f32>(_e68, 1f);
}

fn overUnder9_(uv_24: vec2<f32>, patternShape_22: f32, shadows_6: f32) -> vec2<f32> {
    var uv_25: vec2<f32>;
    var patternShape_23: f32;
    var shadows_7: f32;
    var kk_1: f32;
    var k_12: f32;
    var local_6: f32;
    var light_4: f32;

    uv_25 = uv_24;
    patternShape_23 = patternShape_22;
    shadows_7 = shadows_6;
    let _e12 = uv_25;
    let _e13 = patternShape_23;
    kk_1 = sin(length(((_e12 / vec2(_e13)) * 10f)));
    let _e24 = kk_1;
    k_12 = smoothstep(-0.02f, 0.02f, _e24);
    let _e27 = shadows_7;
    if (_e27 == 0f) {
        local_6 = 1f;
    } else {
        let _e33 = shadows_7;
        let _e34 = kk_1;
        local_6 = smoothstep(-0.01f, _e33, abs(_e34));
    }
    let _e38 = local_6;
    light_4 = _e38;
    let _e40 = k_12;
    let _e41 = light_4;
    return vec2<f32>(_e40, _e41);
}

fn overUnder(uv_26: vec2<f32>, ouMode: i32, shadows_8: f32, patternShape_24: f32) -> vec2<f32> {
    var uv_27: vec2<f32>;
    var ouMode_1: i32;
    var shadows_9: f32;
    var patternShape_25: f32;

    uv_27 = uv_26;
    ouMode_1 = ouMode;
    shadows_9 = shadows_8;
    patternShape_25 = patternShape_24;
    let _e14 = ouMode_1;
    if (_e14 < 6i) {
        {
            let _e17 = ouMode_1;
            if (_e17 < 3i) {
                {
                    let _e20 = ouMode_1;
                    if (_e20 == 0i) {
                        let _e23 = uv_27;
                        let _e24 = overUnder1_(_e23);
                        return _e24;
                    } else {
                        let _e25 = ouMode_1;
                        if (_e25 == 1i) {
                            let _e28 = uv_27;
                            let _e29 = patternShape_25;
                            let _e30 = overUnder2_(_e28, _e29);
                            return _e30;
                        } else {
                            let _e31 = uv_27;
                            let _e32 = patternShape_25;
                            let _e33 = shadows_9;
                            let _e34 = overUnder2b(_e31, _e32, _e33);
                            return _e34;
                        }
                    }
                }
            } else {
                {
                    let _e35 = ouMode_1;
                    if (_e35 == 3i) {
                        let _e38 = uv_27;
                        let _e39 = patternShape_25;
                        let _e40 = overUnder3_(_e38, _e39);
                        return _e40;
                    } else {
                        let _e41 = ouMode_1;
                        if (_e41 == 4i) {
                            let _e44 = uv_27;
                            let _e45 = patternShape_25;
                            let _e46 = overUnder4_(_e44, _e45);
                            return _e46;
                        } else {
                            let _e47 = uv_27;
                            let _e48 = patternShape_25;
                            let _e49 = overUnder5_(_e47, _e48);
                            return _e49;
                        }
                    }
                }
            }
        }
    } else {
        {
            let _e50 = ouMode_1;
            if (_e50 < 9i) {
                {
                    let _e53 = ouMode_1;
                    if (_e53 == 6i) {
                        let _e56 = uv_27;
                        let _e57 = patternShape_25;
                        let _e58 = shadows_9;
                        let _e59 = overUnder6_(_e56, _e57, _e58);
                        return _e59;
                    } else {
                        let _e60 = ouMode_1;
                        if (_e60 == 7i) {
                            let _e63 = uv_27;
                            let _e64 = patternShape_25;
                            let _e65 = overUnder7_(_e63, _e64);
                            return _e65;
                        } else {
                            let _e66 = uv_27;
                            let _e67 = patternShape_25;
                            let _e68 = shadows_9;
                            let _e69 = overUnder7b(_e66, _e67, _e68);
                            return _e69;
                        }
                    }
                }
            } else {
                {
                    let _e70 = ouMode_1;
                    if (_e70 == 9i) {
                        let _e73 = uv_27;
                        let _e74 = patternShape_25;
                        let _e75 = overUnder8_(_e73, _e74);
                        return _e75;
                    } else {
                        let _e76 = ouMode_1;
                        if (_e76 == 10i) {
                            let _e79 = uv_27;
                            let _e80 = patternShape_25;
                            let _e81 = shadows_9;
                            let _e82 = overUnder9_(_e79, _e80, _e81);
                            return _e82;
                        } else {
                            let _e83 = ouMode_1;
                            if (_e83 == 11i) {
                                let _e86 = uv_27;
                                let _e87 = patternShape_25;
                                let _e88 = overUnder10_(_e86, _e87);
                                return _e88;
                            } else {
                                let _e89 = uv_27;
                                let _e90 = patternShape_25;
                                let _e91 = overUnder11_(_e89, _e90);
                                return _e91;
                            }
                        }
                    }
                }
            }
        }
    }
}

fn plaid(uv_28: vec2<f32>, outPos: vec2<f32>, mode_7: i32, source_specified: i32, shadows_10: f32, size_2: f32, patternShape_26: f32, randomSeed_4: f32, colorVariability: f32, color1_: vec4<f32>, color2_: vec4<f32>, color3_: vec4<f32>, color4_: vec4<f32>, color5_: vec4<f32>) -> vec4<f32> {
    var uv_29: vec2<f32>;
    var outPos_1: vec2<f32>;
    var mode_8: i32;
    var source_specified_1: i32;
    var shadows_11: f32;
    var size_3: f32;
    var patternShape_27: f32;
    var randomSeed_5: f32;
    var colorVariability_1: f32;
    var color1_1: vec4<f32>;
    var color2_1: vec4<f32>;
    var color3_1: vec4<f32>;
    var color4_1: vec4<f32>;
    var color5_1: vec4<f32>;
    var id_9: vec2<f32>;
    var ou: vec2<f32>;
    var k_13: f32;
    var light_5: f32;
    var X: f32;
    var Y: f32;
    var vCol: vec4<f32>;
    var hCol: vec4<f32>;
    var col: vec4<f32>;

    uv_29 = uv_28;
    outPos_1 = outPos;
    mode_8 = mode_7;
    source_specified_1 = source_specified;
    shadows_11 = shadows_10;
    size_3 = size_2;
    patternShape_27 = patternShape_26;
    randomSeed_5 = randomSeed_4;
    colorVariability_1 = colorVariability;
    color1_1 = color1_;
    color2_1 = color2_;
    color3_1 = color3_;
    color4_1 = color4_;
    color5_1 = color5_;
    let _e34 = uv_29;
    id_9 = floor(_e34);
    let _e37 = uv_29;
    let _e38 = mode_8;
    let _e39 = shadows_11;
    let _e40 = patternShape_27;
    let _e41 = overUnder(_e37, _e38, _e39, _e40);
    ou = _e41;
    let _e43 = ou;
    k_13 = _e43.x;
    let _e46 = ou;
    light_5 = _e46.y;
    let _e50 = randomSeed_5;
    let _e51 = chan(1.23f, _e50);
    let _e53 = randomSeed_5;
    let _e54 = chan(0.553f, _e53);
    let _e56 = randomSeed_5;
    let _e57 = chan(1.83f, _e56);
    let _e60 = color1_1;
    let _e61 = mergeColor(vec4<f32>(_e51, _e54, _e57, 1f), _e60);
    color1_1 = _e61;
    let _e63 = randomSeed_5;
    let _e64 = chan(1.73f, _e63);
    let _e66 = randomSeed_5;
    let _e67 = chan(0.3153f, _e66);
    let _e69 = randomSeed_5;
    let _e70 = chan(1.03f, _e69);
    let _e73 = color2_1;
    let _e74 = mergeColor(vec4<f32>(_e64, _e67, _e70, 1f), _e73);
    color2_1 = _e74;
    let _e76 = randomSeed_5;
    let _e77 = chan(1.673f, _e76);
    let _e79 = randomSeed_5;
    let _e80 = chan(1.013f, _e79);
    let _e82 = randomSeed_5;
    let _e83 = chan(2.593f, _e82);
    let _e86 = color3_1;
    let _e87 = mergeColor(vec4<f32>(_e77, _e80, _e83, 1f), _e86);
    color3_1 = _e87;
    let _e89 = randomSeed_5;
    let _e90 = chan(0.53f, _e89);
    let _e92 = randomSeed_5;
    let _e93 = chan(2.253f, _e92);
    let _e95 = randomSeed_5;
    let _e96 = chan(0.823f, _e95);
    let _e99 = color4_1;
    let _e100 = mergeColor(vec4<f32>(_e90, _e93, _e96, 1f), _e99);
    color4_1 = _e100;
    let _e102 = randomSeed_5;
    let _e103 = chan(3.213f, _e102);
    let _e105 = randomSeed_5;
    let _e106 = chan(1.953f, _e105);
    let _e108 = randomSeed_5;
    let _e109 = chan(1.0863f, _e108);
    let _e112 = color5_1;
    let _e113 = mergeColor(vec4<f32>(_e103, _e106, _e109, 1f), _e112);
    color5_1 = _e113;
    let _e114 = id_9;
    X = floor(_e114.x);
    let _e118 = id_9;
    Y = floor(_e118.y);
    let _e122 = X;
    let _e123 = size_3;
    let _e124 = randomSeed_5;
    let _e125 = color1_1;
    let _e126 = color2_1;
    let _e127 = color3_1;
    let _e128 = color4_1;
    let _e129 = color5_1;
    let _e130 = getLinCol(_e122, _e123, _e124, _e125, _e126, _e127, _e128, _e129);
    let _e131 = colorVariability_1;
    let _e132 = X;
    let _e133 = hash11_(_e132);
    let _e136 = vec3((_e133 - 0.5f));
    vCol = (_e130 + (_e131 * vec4<f32>(_e136.x, _e136.y, _e136.z, 1f)));
    let _e145 = Y;
    let _e146 = size_3;
    let _e147 = randomSeed_5;
    let _e148 = color1_1;
    let _e149 = color2_1;
    let _e150 = color3_1;
    let _e151 = color4_1;
    let _e152 = color5_1;
    let _e153 = getLinCol(_e145, _e146, _e147, _e148, _e149, _e150, _e151, _e152);
    let _e154 = colorVariability_1;
    let _e155 = Y;
    let _e156 = hash11_(_e155);
    let _e159 = vec3((_e156 - 0.5f));
    hCol = (_e153 + (_e154 * vec4<f32>(_e159.x, _e159.y, _e159.z, 1f)));
    let _e168 = light_5;
    let _e169 = vec3(_e168);
    let _e175 = vCol;
    let _e176 = hCol;
    let _e177 = k_13;
    col = (vec4<f32>(_e169.x, _e169.y, _e169.z, 1f) * mix(_e175, _e176, vec4(_e177)));
    let _e182 = source_specified_1;
    let _e185 = col;
    if ((_e182 == 1i) && (_e185.w < 1f)) {
        {
            let _e190 = uv_29;
            let _e194 = global.U[0];
            let _e197 = uv_29;
            let _e206 = textureSample(t_source, samp, ((vec2<f32>((_e190.x / _e194.x), _e197.y) / vec2(2f)) + vec2(0.5f)));
            let _e207 = col;
            let _e208 = mergeColor(_e206, _e207);
            return _e208;
        }
    } else {
        {
            let _e209 = col;
            return _e209;
        }
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
    let _e66 = global.U[6];
    let _e71 = global.U[4];
    let _e76 = global.U[7];
    let _e80 = global.U[8];
    let _e84 = global.U[9];
    let _e88 = global.U[10];
    let _e92 = global.U[11];
    let _e96 = global.U[12];
    let _e99 = global.U[13];
    let _e102 = global.U[14];
    let _e105 = global.U[15];
    let _e108 = global.U[16];
    let _e109 = plaid((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e9.x, _e9.y, _e9.z), vec3<f32>(_e13.x, _e13.y, _e13.z), vec3<f32>(_e17.x, _e17.y, _e17.z))) * vec3<f32>(_e44.x, _e44.y, 1f)).xy, (((_e51 - vec2(0.5f)) * 2f) * vec2<f32>(_e59.x, 1f)), i32(_e66.x), i32(_e71.x), _e76.x, _e80.x, _e84.x, _e88.x, _e92.x, _e96, _e99, _e102, _e105, _e108);
    fragColor = _e109;
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
