struct Params {
    U: array<vec4<f32>, 12>,
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

fn combine(a: vec3<f32>, b: vec3<f32>) -> vec3<f32> {
    var a_1: vec3<f32>;
    var b_1: vec3<f32>;

    a_1 = a;
    b_1 = b;
    let _e9 = a_1;
    let _e11 = b_1;
    let _e14 = a_1;
    let _e16 = b_1;
    let _e19 = a_1;
    let _e21 = b_1;
    return vec3<f32>((_e9.x + _e11.x), min(_e14.y, _e16.y), min(_e19.z, _e21.z));
}

fn inCircle(c: vec2<f32>, r: f32, p: vec2<f32>) -> f32 {
    var c_1: vec2<f32>;
    var r_1: f32;
    var p_1: vec2<f32>;

    c_1 = c;
    r_1 = r;
    p_1 = p;
    let _e11 = c_1;
    let _e12 = p_1;
    let _e15 = r_1;
    return (length((_e11 - _e12)) - _e15);
}

fn inCircle2_(a_2: f32, d: f32, r_2: f32, p_2: vec2<f32>) -> f32 {
    var a_3: f32;
    var d_1: f32;
    var r_3: f32;
    var p_3: vec2<f32>;

    a_3 = a_2;
    d_1 = d;
    r_3 = r_2;
    p_3 = p_2;
    let _e13 = d_1;
    let _e14 = a_3;
    let _e17 = a_3;
    let _e21 = r_3;
    let _e22 = p_3;
    let _e23 = inCircle((_e13 * vec2<f32>(-(sin(_e14)), cos(_e17))), _e21, _e22);
    return _e23;
}

fn inRosace(r1_: f32, r2_: f32, N: i32, p_4: vec2<f32>) -> vec3<f32> {
    var r1_1: f32;
    var r2_1: f32;
    var N_1: i32;
    var p_5: vec2<f32>;
    var di: f32;
    var r_4: f32;
    var d_2: f32;
    var inside: vec3<f32> = vec3<f32>(0f, 1000000000f, 1000000000f);
    var i: i32 = 0i;
    var a_4: f32;
    var dist: f32;
    var local: f32;

    r1_1 = r1_;
    r2_1 = r2_;
    N_1 = N;
    p_5 = p_4;
    let _e13 = p_5;
    di = length(_e13);
    let _e16 = di;
    let _e17 = r1_1;
    if (_e16 < _e17) {
        let _e20 = r1_1;
        let _e21 = di;
        let _e23 = r1_1;
        let _e24 = di;
        return vec3<f32>(0f, (_e20 - _e21), (_e23 - _e24));
    } else {
        let _e27 = di;
        let _e28 = r2_1;
        if (_e27 > _e28) {
            let _e31 = di;
            let _e32 = r2_1;
            let _e34 = di;
            let _e35 = r2_1;
            return vec3<f32>(0f, (_e31 - _e32), (_e34 - _e35));
        }
    }
    let _e38 = r2_1;
    let _e39 = r1_1;
    r_4 = ((_e38 - _e39) / 2f);
    let _e44 = r2_1;
    let _e45 = r_4;
    d_2 = (_e44 - _e45);
    loop {
        let _e55 = i;
        let _e56 = N_1;
        if !((_e55 < _e56)) {
            break;
        }
        {
            let _e63 = i;
            let _e66 = N_1;
            a_4 = ((6.2831855f * f32(_e63)) / f32(_e66));
            let _e70 = a_4;
            let _e71 = d_2;
            let _e72 = r_4;
            let _e73 = p_5;
            let _e74 = inCircle2_(_e70, _e71, _e72, _e73);
            dist = _e74;
            let _e76 = inside;
            let _e77 = dist;
            if (_e77 < 0f) {
                local = 1f;
            } else {
                local = 0f;
            }
            let _e83 = local;
            let _e84 = dist;
            let _e85 = dist;
            let _e88 = combine(_e76, vec3<f32>(_e83, _e84, abs(_e85)));
            inside = _e88;
        }
        continuing {
            let _e59 = i;
            i = (_e59 + 1i);
        }
    }
    let _e89 = inside;
    return _e89;
}

fn makeDivisible(a_5: f32, b_2: f32) -> f32 {
    var a_6: f32;
    var b_3: f32;

    a_6 = a_5;
    b_3 = b_2;
    let _e9 = a_6;
    let _e10 = b_3;
    if (_e9 > _e10) {
        {
            let _e12 = b_3;
            let _e13 = a_6;
            let _e14 = b_3;
            return (_e12 * floor(((_e13 / _e14) + 0.5f)));
        }
    } else {
        {
            let _e20 = a_6;
            let _e21 = b_3;
            let _e22 = a_6;
            return (_e20 * floor(((_e21 / _e22) + 0.5f)));
        }
    }
}

fn rand2_(v: vec2<f32>) -> vec2<f32> {
    var v_1: vec2<f32>;
    var x: f32;
    var y: f32;

    v_1 = v;
    let _e7 = v_1;
    x = fract((sin(dot(_e7.xy, vec2<f32>(12.9898f, 78.233f))) * 43758.547f));
    let _e18 = x;
    let _e19 = v_1;
    y = fract((sin(dot(vec2<f32>(_e18, _e19.x), vec2<f32>(12.9898f, 78.233f))) * 43758.547f));
    let _e31 = x;
    let _e32 = y;
    return vec2<f32>(_e31, _e32);
}

fn varyNoiseSmoothly(noise: f32, k: f32) -> f32 {
    var noise_1: f32;
    var k_1: f32;
    var phase: f32;
    var freq: f32;

    noise_1 = noise;
    k_1 = k;
    let _e10 = noise_1;
    phase = acos(((2f * _e10) - 1f));
    let _e16 = noise_1;
    freq = (fract((_e16 * 16f)) + 0.5f);
    let _e24 = phase;
    let _e25 = freq;
    let _e26 = k_1;
    return ((1f + cos((_e24 + (_e25 * _e26)))) * 0.5f);
}

fn varyVec2NoiseSmoothly(noise_2: vec2<f32>, k_2: f32) -> vec2<f32> {
    var noise_3: vec2<f32>;
    var k_3: f32;

    noise_3 = noise_2;
    k_3 = k_2;
    let _e9 = noise_3;
    let _e11 = k_3;
    let _e12 = varyNoiseSmoothly(_e9.x, _e11);
    let _e13 = noise_3;
    let _e15 = k_3;
    let _e16 = varyNoiseSmoothly(_e13.y, _e15);
    return vec2<f32>(_e12, _e16);
}

fn rand2relSeeded(co: vec2<f32>, seed: f32) -> vec2<f32> {
    var co_1: vec2<f32>;
    var seed_1: f32;

    co_1 = co;
    seed_1 = seed;
    let _e9 = co_1;
    let _e10 = rand2_(_e9);
    let _e11 = seed_1;
    let _e12 = varyVec2NoiseSmoothly(_e10, _e11);
    return (_e12 - vec2(0.5f));
}

fn getInsideRosace(u: vec2<f32>, id: vec2<f32>, radius: f32, randomSeed: f32) -> vec3<f32> {
    var u_1: vec2<f32>;
    var id_1: vec2<f32>;
    var radius_1: f32;
    var randomSeed_1: f32;
    var pos: vec2<f32>;
    var l: f32;
    var inside_1: vec3<f32> = vec3<f32>(0f, 1000000000f, 1000000000f);
    var rnd: vec2<f32>;
    var levels: i32;
    var N_2: f32 = 1f;
    var r1_2: f32 = 0.75f;
    var r2_2: f32;
    var j: i32 = 0i;

    u_1 = u;
    id_1 = id;
    radius_1 = radius;
    randomSeed_1 = randomSeed;
    let _e13 = u_1;
    let _e14 = radius_1;
    pos = (_e13 / vec2(_e14));
    let _e18 = pos;
    l = length(_e18);
    let _e21 = l;
    if (_e21 > 0.75f) {
        let _e25 = l;
        let _e28 = l;
        return vec3<f32>(0f, (_e25 - 0.75f), abs((_e28 - 0.75f)));
    }
    let _e38 = id_1;
    let _e39 = randomSeed_1;
    let _e40 = rand2relSeeded(_e38, _e39);
    rnd = (_e40 + vec2<f32>(0.5f, 0.5f));
    let _e47 = rnd;
    levels = i32((1f + floor((_e47.x * 3f))));
    let _e60 = id_1;
    let _e64 = id_1;
    let _e69 = randomSeed_1;
    if (((_e60.x == 0f) && (_e64.y == 0f)) && (_e69 == 0f)) {
        {
            let _e73 = inside_1;
            let _e77 = pos;
            let _e78 = inRosace(0f, 0.25f, 24i, _e77);
            let _e79 = combine(_e73, _e78);
            inside_1 = _e79;
            let _e80 = inside_1;
            let _e84 = pos;
            let _e85 = inRosace(0.25f, 0.35f, 12i, _e84);
            let _e86 = combine(_e80, _e85);
            inside_1 = _e86;
            let _e87 = inside_1;
            let _e91 = pos;
            let _e92 = inRosace(0.35f, 0.75f, 60i, _e91);
            let _e93 = combine(_e87, _e92);
            inside_1 = _e93;
        }
    } else {
        loop {
            let _e96 = j;
            let _e97 = levels;
            if !((_e96 < _e97)) {
                break;
            }
            {
                let _e103 = rnd;
                let _e104 = randomSeed_1;
                let _e105 = rand2relSeeded(_e103, _e104);
                rnd = (_e105 + vec2<f32>(0.5f, 0.5f));
                let _e110 = r1_2;
                r2_2 = _e110;
                let _e111 = r1_2;
                let _e112 = rnd;
                r1_2 = (_e111 * _e112.x);
                let _e115 = r1_2;
                let _e116 = r2_2;
                if ((_e115 / _e116) > 0.9f) {
                    let _e120 = r2_2;
                    r1_2 = (_e120 * 0.9f);
                }
                let _e123 = r1_2;
                if (_e123 < 0.05f) {
                    r1_2 = 0f;
                }
                let _e127 = N_2;
                let _e128 = rnd;
                let _e130 = rnd;
                let _e138 = makeDivisible(_e127, (floor(((_e128.y * _e130.y) * 60f)) + 2f));
                N_2 = _e138;
                let _e139 = inside_1;
                let _e140 = r1_2;
                let _e141 = r2_2;
                let _e142 = N_2;
                let _e144 = pos;
                let _e145 = inRosace(_e140, _e141, i32(_e142), _e144);
                let _e146 = combine(_e139, _e145);
                inside_1 = _e146;
            }
            continuing {
                let _e100 = j;
                j = (_e100 + 1i);
            }
        }
    }
    let _e147 = inside_1;
    return _e147;
}

fn getShapeOverlapColor(inside_2: vec3<f32>, mode: i32, thickness: f32, color1_: vec4<f32>, color2_: vec4<f32>, colorBorder: vec4<f32>) -> vec4<f32> {
    var inside_3: vec3<f32>;
    var mode_1: i32;
    var thickness_1: f32;
    var color1_1: vec4<f32>;
    var color2_1: vec4<f32>;
    var colorBorder_1: vec4<f32>;
    var count: f32;
    var dist_1: f32;
    var borderDist: f32;
    var k_4: f32;
    var local_1: f32;
    var local_2: f32;
    var color: vec4<f32>;

    inside_3 = inside_2;
    mode_1 = mode;
    thickness_1 = thickness;
    color1_1 = color1_;
    color2_1 = color2_;
    colorBorder_1 = colorBorder;
    let _e17 = inside_3;
    count = _e17.x;
    let _e20 = inside_3;
    dist_1 = _e20.y;
    let _e23 = inside_3;
    borderDist = _e23.z;
    let _e27 = mode_1;
    if (_e27 == 0i) {
        let _e30 = count;
        if ((_e30 - (floor((_e30 / 2f)) * 2f)) < 1f) {
            local_1 = 1f;
        } else {
            local_1 = 0f;
        }
        let _e41 = local_1;
        k_4 = _e41;
    } else {
        let _e42 = mode_1;
        if (_e42 == 1i) {
            let _e46 = count;
            k_4 = pow(0.8f, _e46);
        } else {
            let _e48 = mode_1;
            if (_e48 == 2i) {
                let _e51 = count;
                if ((_e51 - (floor((_e51 / 2f)) * 2f)) < 1f) {
                    let _e60 = count;
                    local_2 = pow(0.8f, _e60);
                } else {
                    let _e64 = count;
                    local_2 = (1f - pow(0.8f, _e64));
                }
                let _e68 = local_2;
                k_4 = _e68;
            } else {
                let _e69 = mode_1;
                if (_e69 == 3i) {
                    let _e72 = dist_1;
                    k_4 = _e72;
                } else {
                    let _e73 = mode_1;
                    if (_e73 == 4i) {
                        let _e78 = dist_1;
                        k_4 = (-2f * _e78);
                    } else {
                        k_4 = 0.5f;
                    }
                }
            }
        }
    }
    let _e81 = color2_1;
    let _e82 = color1_1;
    let _e83 = k_4;
    color = mix(_e81, _e82, vec4(_e83));
    let _e87 = borderDist;
    let _e88 = thickness_1;
    if (_e87 < (_e88 * 0.005f)) {
        let _e92 = colorBorder_1;
        return _e92;
    } else {
        let _e93 = color;
        return _e93;
    }
}

fn hexCoords(v_2: vec2<f32>) -> vec4<f32> {
    var v_3: vec2<f32>;
    var r_5: vec2<f32> = vec2<f32>(1f, 1.7320508f);
    var h: vec2<f32>;
    var a_7: vec2<f32>;
    var b_4: vec2<f32>;
    var local_3: vec2<f32>;
    var hv: vec2<f32>;
    var id_2: vec2<f32>;

    v_3 = v_2;
    let _e11 = r_5;
    h = (_e11 / vec2(2f));
    let _e16 = v_3;
    let _e18 = r_5;
    let _e24 = v_3;
    let _e26 = r_5;
    let _e33 = h;
    a_7 = (vec2<f32>((_e16.x - (floor((_e16.x / _e18.x)) * _e18.x)), (_e24.y - (floor((_e24.y / _e26.y)) * _e26.y))) - _e33);
    let _e36 = v_3;
    let _e38 = h;
    let _e40 = (_e36.x - _e38.x);
    let _e41 = r_5;
    let _e47 = v_3;
    let _e49 = h;
    let _e51 = (_e47.y - _e49.y);
    let _e52 = r_5;
    let _e59 = h;
    b_4 = (vec2<f32>((_e40 - (floor((_e40 / _e41.x)) * _e41.x)), (_e51 - (floor((_e51 / _e52.y)) * _e52.y))) - _e59);
    let _e62 = a_7;
    let _e64 = b_4;
    if (length(_e62) < length(_e64)) {
        let _e67 = a_7;
        local_3 = _e67;
    } else {
        let _e68 = b_4;
        local_3 = _e68;
    }
    let _e70 = local_3;
    hv = _e70;
    let _e72 = v_3;
    let _e73 = hv;
    id_2 = (_e72 - _e73);
    let _e76 = hv;
    let _e77 = id_2;
    return vec4<f32>(_e76.x, _e76.y, _e77.x, _e77.y);
}

fn hexPolarCoords(v_4: vec2<f32>) -> vec4<f32> {
    var v_5: vec2<f32>;
    var r_6: vec2<f32> = vec2<f32>(1f, 1.7320508f);
    var h_1: vec2<f32>;
    var a_8: vec2<f32>;
    var b_5: vec2<f32>;
    var local_4: vec2<f32>;
    var hv_1: vec2<f32>;
    var x_1: f32;
    var y_1: f32;
    var id_3: vec2<f32>;

    v_5 = v_4;
    let _e11 = r_6;
    h_1 = (_e11 / vec2(2f));
    let _e16 = v_5;
    let _e18 = r_6;
    let _e24 = v_5;
    let _e26 = r_6;
    let _e33 = h_1;
    a_8 = (vec2<f32>((_e16.x - (floor((_e16.x / _e18.x)) * _e18.x)), (_e24.y - (floor((_e24.y / _e26.y)) * _e26.y))) - _e33);
    let _e36 = v_5;
    let _e38 = h_1;
    let _e40 = (_e36.x - _e38.x);
    let _e41 = r_6;
    let _e47 = v_5;
    let _e49 = h_1;
    let _e51 = (_e47.y - _e49.y);
    let _e52 = r_6;
    let _e59 = h_1;
    b_5 = (vec2<f32>((_e40 - (floor((_e40 / _e41.x)) * _e41.x)), (_e51 - (floor((_e51 / _e52.y)) * _e52.y))) - _e59);
    let _e62 = a_8;
    let _e64 = b_5;
    if (length(_e62) < length(_e64)) {
        let _e67 = a_8;
        local_4 = _e67;
    } else {
        let _e68 = b_5;
        local_4 = _e68;
    }
    let _e70 = local_4;
    hv_1 = _e70;
    let _e72 = hv_1;
    let _e74 = hv_1;
    x_1 = atan2(_e72.y, _e74.x);
    let _e78 = hv_1;
    y_1 = length(_e78);
    let _e81 = v_5;
    let _e82 = hv_1;
    id_3 = (_e81 - _e82);
    let _e85 = x_1;
    let _e86 = y_1;
    let _e87 = id_3;
    return vec4<f32>(_e85, _e86, _e87.x, _e87.y);
}

fn rosaces(pos_1: vec2<f32>, outPos: vec2<f32>, color1_2: vec4<f32>, color2_2: vec4<f32>, colorBorder_2: vec4<f32>, radius_2: f32, randomSeed_2: f32, thickness_2: f32, mode_2: i32) -> vec4<f32> {
    var pos_2: vec2<f32>;
    var outPos_1: vec2<f32>;
    var color1_3: vec4<f32>;
    var color2_3: vec4<f32>;
    var colorBorder_3: vec4<f32>;
    var radius_3: f32;
    var randomSeed_3: f32;
    var thickness_3: f32;
    var mode_3: i32;
    var hexCoord: vec4<f32>;
    var gridPos: vec2<f32>;
    var gridIndex: vec2<f32>;
    var inside_4: vec3<f32>;

    pos_2 = pos_1;
    outPos_1 = outPos;
    color1_3 = color1_2;
    color2_3 = color2_2;
    colorBorder_3 = colorBorder_2;
    radius_3 = radius_2;
    randomSeed_3 = randomSeed_2;
    thickness_3 = thickness_2;
    mode_3 = mode_2;
    let _e23 = pos_2;
    let _e24 = hexCoords(_e23);
    hexCoord = _e24;
    let _e26 = hexCoord;
    gridPos = _e26.xy;
    let _e29 = hexCoord;
    gridIndex = floor(((_e29.zw * vec2<f32>(2f, 3.4641016f)) + vec2(0.5f)));
    let _e42 = gridPos;
    let _e43 = radius_3;
    pos_2 = (_e42 / vec2(_e43));
    let _e46 = gridPos;
    let _e47 = gridIndex;
    let _e48 = radius_3;
    let _e49 = randomSeed_3;
    let _e50 = getInsideRosace(_e46, _e47, _e48, _e49);
    inside_4 = _e50;
    let _e52 = radius_3;
    if (_e52 > 0.66f) {
        {
            let _e55 = inside_4;
            let _e56 = gridPos;
            let _e61 = gridIndex;
            let _e66 = radius_3;
            let _e67 = randomSeed_3;
            let _e68 = getInsideRosace((_e56 - vec2<f32>(1f, 0f)), (_e61 + vec2<f32>(2f, 0f)), _e66, _e67);
            let _e69 = combine(_e55, _e68);
            inside_4 = _e69;
            let _e70 = inside_4;
            let _e71 = gridPos;
            let _e76 = gridIndex;
            let _e81 = radius_3;
            let _e82 = randomSeed_3;
            let _e83 = getInsideRosace((_e71 + vec2<f32>(1f, 0f)), (_e76 - vec2<f32>(2f, 0f)), _e81, _e82);
            let _e84 = combine(_e70, _e83);
            inside_4 = _e84;
            let _e85 = inside_4;
            let _e86 = gridPos;
            let _e91 = gridIndex;
            let _e96 = radius_3;
            let _e97 = randomSeed_3;
            let _e98 = getInsideRosace((_e86 - vec2<f32>(0.5f, 0.8660254f)), (_e91 + vec2<f32>(1f, 3f)), _e96, _e97);
            let _e99 = combine(_e85, _e98);
            inside_4 = _e99;
            let _e100 = inside_4;
            let _e101 = gridPos;
            let _e107 = gridIndex;
            let _e113 = radius_3;
            let _e114 = randomSeed_3;
            let _e115 = getInsideRosace((_e101 - vec2<f32>(-0.5f, 0.8660254f)), (_e107 + vec2<f32>(-1f, 3f)), _e113, _e114);
            let _e116 = combine(_e100, _e115);
            inside_4 = _e116;
            let _e117 = inside_4;
            let _e118 = gridPos;
            let _e124 = gridIndex;
            let _e130 = radius_3;
            let _e131 = randomSeed_3;
            let _e132 = getInsideRosace((_e118 - vec2<f32>(0.5f, -0.8660254f)), (_e124 + vec2<f32>(1f, -3f)), _e130, _e131);
            let _e133 = combine(_e117, _e132);
            inside_4 = _e133;
            let _e134 = inside_4;
            let _e135 = gridPos;
            let _e142 = gridIndex;
            let _e149 = radius_3;
            let _e150 = randomSeed_3;
            let _e151 = getInsideRosace((_e135 - vec2<f32>(-0.5f, -0.8660254f)), (_e142 + vec2<f32>(-1f, -3f)), _e149, _e150);
            let _e152 = combine(_e134, _e151);
            inside_4 = _e152;
        }
    }
    let _e153 = inside_4;
    let _e154 = mode_3;
    let _e155 = thickness_3;
    let _e156 = color1_3;
    let _e157 = color2_3;
    let _e158 = colorBorder_3;
    let _e159 = getShapeOverlapColor(_e153, _e154, _e155, _e156, _e157, _e158);
    return _e159;
}

fn main_1() {
    let _e7 = global.U[1];
    let _e8 = _e7.xyz;
    let _e11 = global.U[2];
    let _e12 = _e11.xyz;
    let _e15 = global.U[3];
    let _e16 = _e15.xyz;
    let _e31 = v_uv_1;
    let _e39 = global.U[0];
    let _e43 = (((_e31 - vec2(0.5f)) * 2f) * vec2<f32>(_e39.x, 1f));
    let _e50 = v_uv_1;
    let _e58 = global.U[0];
    let _e65 = global.U[5];
    let _e68 = global.U[6];
    let _e71 = global.U[7];
    let _e74 = global.U[8];
    let _e78 = global.U[9];
    let _e82 = global.U[10];
    let _e86 = global.U[11];
    let _e89 = rosaces((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e8.x, _e8.y, _e8.z), vec3<f32>(_e12.x, _e12.y, _e12.z), vec3<f32>(_e16.x, _e16.y, _e16.z))) * vec3<f32>(_e43.x, _e43.y, 1f)).xy, (((_e50 - vec2(0.5f)) * 2f) * vec2<f32>(_e58.x, 1f)), _e65, _e68, _e71, _e74.x, _e78.x, _e82.x, i32(_e86.x));
    fragColor = _e89;
    return;
}

@fragment 
fn main(@location(0) v_uv: vec2<f32>) -> FragmentOutput {
    v_uv_1 = v_uv;
    main_1();
    let _e11 = fragColor;
    return FragmentOutput(_e11);
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
