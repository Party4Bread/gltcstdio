struct Params {
    U: array<vec4<f32>, 16>,
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

fn combine(a: vec3<f32>, b: vec3<f32>) -> vec3<f32> {
    var a_1: vec3<f32>;
    var b_1: vec3<f32>;

    a_1 = a;
    b_1 = b;
    let _e10 = a_1;
    let _e12 = b_1;
    let _e15 = a_1;
    let _e17 = b_1;
    let _e20 = a_1;
    let _e22 = b_1;
    return vec3<f32>((_e10.x + _e12.x), min(_e15.y, _e17.y), min(_e20.z, _e22.z));
}

fn sdVesica(u: vec2<f32>, r: f32, d: f32) -> f32 {
    var u_1: vec2<f32>;
    var r_1: f32;
    var d_1: f32;
    var b_2: f32;
    var local: f32;

    u_1 = u;
    r_1 = r;
    d_1 = d;
    let _e12 = u_1;
    u_1 = abs(_e12);
    let _e14 = r_1;
    let _e15 = r_1;
    let _e17 = d_1;
    let _e18 = d_1;
    b_2 = sqrt(((_e14 * _e15) - (_e17 * _e18)));
    let _e23 = u_1;
    let _e25 = b_2;
    let _e27 = d_1;
    let _e29 = u_1;
    let _e31 = b_2;
    if (((_e23.y - _e25) * _e27) > (_e29.x * _e31)) {
        let _e34 = u_1;
        let _e36 = b_2;
        local = length((_e34 - vec2<f32>(0f, _e36)));
    } else {
        let _e40 = u_1;
        let _e41 = d_1;
        let _e47 = r_1;
        local = (length((_e40 - vec2<f32>(-(_e41), 0f))) - _e47);
    }
    let _e50 = local;
    return _e50;
}

fn inVesica(r_2: f32, p: vec2<f32>) -> f32 {
    var r_3: f32;
    var p_1: vec2<f32>;

    r_3 = r_2;
    p_1 = p;
    let _e10 = p_1;
    let _e11 = r_3;
    let _e12 = r_3;
    let _e15 = sdVesica(_e10, _e11, (_e12 * 0.4f));
    return _e15;
}

fn inCircle2_(a_2: f32, d_2: f32, r_4: f32, p_2: vec2<f32>) -> f32 {
    var a_3: f32;
    var d_3: f32;
    var r_5: f32;
    var p_3: vec2<f32>;
    var ca: f32;
    var sa: f32;

    a_3 = a_2;
    d_3 = d_2;
    r_5 = r_4;
    p_3 = p_2;
    let _e14 = a_3;
    ca = cos(_e14);
    let _e17 = a_3;
    sa = sin(_e17);
    let _e20 = ca;
    let _e21 = sa;
    let _e22 = sa;
    let _e23 = ca;
    let _e28 = p_3;
    let _e31 = d_3;
    p_3 = ((mat2x2<f32>(vec2<f32>(_e20, _e21), vec2<f32>(_e22, -(_e23))) * _e28) - vec2<f32>(0f, _e31));
    let _e34 = r_5;
    let _e35 = p_3;
    let _e36 = inVesica(_e34, _e35);
    return _e36;
}

fn inRosace(r1_: f32, r2_: f32, N: i32, p_4: vec2<f32>) -> vec3<f32> {
    var r1_1: f32;
    var r2_1: f32;
    var N_1: i32;
    var p_5: vec2<f32>;
    var di: f32;
    var r_6: f32;
    var d_4: f32;
    var inside: vec3<f32> = vec3<f32>(0f, 1000000000f, 1000000000f);
    var i: i32 = 0i;
    var a_4: f32;
    var dist: f32;
    var local_1: f32;

    r1_1 = r1_;
    r2_1 = r2_;
    N_1 = N;
    p_5 = p_4;
    let _e14 = p_5;
    di = length(_e14);
    let _e17 = di;
    let _e18 = r1_1;
    if (_e17 < _e18) {
        let _e21 = r1_1;
        let _e22 = di;
        let _e24 = r1_1;
        let _e25 = di;
        return vec3<f32>(0f, (_e21 - _e22), (_e24 - _e25));
    } else {
        let _e28 = di;
        let _e29 = r2_1;
        if (_e28 > _e29) {
            let _e32 = di;
            let _e33 = r2_1;
            let _e35 = di;
            let _e36 = r2_1;
            return vec3<f32>(0f, (_e32 - _e33), (_e35 - _e36));
        }
    }
    let _e39 = r2_1;
    let _e40 = r1_1;
    r_6 = ((_e39 - _e40) / 2f);
    let _e45 = r2_1;
    let _e46 = r_6;
    d_4 = (_e45 - _e46);
    loop {
        let _e56 = i;
        let _e57 = N_1;
        if !((_e56 < _e57)) {
            break;
        }
        {
            let _e64 = i;
            let _e67 = N_1;
            a_4 = ((6.2831855f * f32(_e64)) / f32(_e67));
            let _e71 = a_4;
            let _e72 = d_4;
            let _e73 = r_6;
            let _e74 = p_5;
            let _e75 = inCircle2_(_e71, _e72, _e73, _e74);
            dist = _e75;
            let _e77 = inside;
            let _e78 = dist;
            if (_e78 < 0f) {
                local_1 = 1f;
            } else {
                local_1 = 0f;
            }
            let _e84 = local_1;
            let _e85 = dist;
            let _e86 = dist;
            let _e89 = combine(_e77, vec3<f32>(_e84, _e85, abs(_e86)));
            inside = _e89;
        }
        continuing {
            let _e60 = i;
            i = (_e60 + 1i);
        }
    }
    let _e90 = inside;
    return _e90;
}

fn makeDivisible(a_5: f32, b_3: f32) -> f32 {
    var a_6: f32;
    var b_4: f32;

    a_6 = a_5;
    b_4 = b_3;
    let _e10 = a_6;
    let _e11 = b_4;
    if (_e10 > _e11) {
        {
            let _e13 = b_4;
            let _e14 = a_6;
            let _e15 = b_4;
            return (_e13 * floor(((_e14 / _e15) + 0.5f)));
        }
    } else {
        {
            let _e21 = a_6;
            let _e22 = b_4;
            let _e23 = a_6;
            return (_e21 * floor(((_e22 / _e23) + 0.5f)));
        }
    }
}

fn rand2_(v: vec2<f32>) -> vec2<f32> {
    var v_1: vec2<f32>;
    var x: f32;
    var y: f32;

    v_1 = v;
    let _e8 = v_1;
    x = fract((sin(dot(_e8.xy, vec2<f32>(12.9898f, 78.233f))) * 43758.547f));
    let _e19 = x;
    let _e20 = v_1;
    y = fract((sin(dot(vec2<f32>(_e19, _e20.x), vec2<f32>(12.9898f, 78.233f))) * 43758.547f));
    let _e32 = x;
    let _e33 = y;
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

fn rand2relSeeded(co: vec2<f32>, seed: f32) -> vec2<f32> {
    var co_1: vec2<f32>;
    var seed_1: f32;

    co_1 = co;
    seed_1 = seed;
    let _e10 = co_1;
    let _e11 = rand2_(_e10);
    let _e12 = seed_1;
    let _e13 = varyVec2NoiseSmoothly(_e11, _e12);
    return (_e13 - vec2(0.5f));
}

fn getInsideRosace(u_2: vec2<f32>, id: vec2<f32>, radius: f32, randomSeed: f32) -> vec3<f32> {
    var u_3: vec2<f32>;
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

    u_3 = u_2;
    id_1 = id;
    radius_1 = radius;
    randomSeed_1 = randomSeed;
    let _e14 = u_3;
    let _e15 = radius_1;
    pos = (_e14 / vec2(_e15));
    let _e19 = pos;
    l = length(_e19);
    let _e22 = l;
    if (_e22 > 0.75f) {
        let _e26 = l;
        let _e29 = l;
        return vec3<f32>(0f, (_e26 - 0.75f), abs((_e29 - 0.75f)));
    }
    let _e39 = id_1;
    let _e40 = randomSeed_1;
    let _e41 = rand2relSeeded(_e39, _e40);
    rnd = (_e41 + vec2<f32>(0.5f, 0.5f));
    let _e48 = rnd;
    levels = i32((1f + floor((_e48.x * 3f))));
    let _e61 = id_1;
    let _e65 = id_1;
    let _e70 = randomSeed_1;
    if (((_e61.x == 0f) && (_e65.y == 0f)) && (_e70 == 0f)) {
        {
            let _e74 = inside_1;
            let _e78 = pos;
            let _e79 = inRosace(0f, 0.25f, 24i, _e78);
            let _e80 = combine(_e74, _e79);
            inside_1 = _e80;
            let _e81 = inside_1;
            let _e85 = pos;
            let _e86 = inRosace(0.25f, 0.35f, 12i, _e85);
            let _e87 = combine(_e81, _e86);
            inside_1 = _e87;
            let _e88 = inside_1;
            let _e92 = pos;
            let _e93 = inRosace(0.35f, 0.75f, 60i, _e92);
            let _e94 = combine(_e88, _e93);
            inside_1 = _e94;
        }
    } else {
        loop {
            let _e97 = j;
            let _e98 = levels;
            if !((_e97 < _e98)) {
                break;
            }
            {
                let _e104 = rnd;
                let _e105 = randomSeed_1;
                let _e106 = rand2relSeeded(_e104, _e105);
                rnd = (_e106 + vec2<f32>(0.5f, 0.5f));
                let _e111 = r1_2;
                r2_2 = _e111;
                let _e112 = r1_2;
                let _e113 = rnd;
                r1_2 = (_e112 * _e113.x);
                let _e116 = r1_2;
                let _e117 = r2_2;
                if ((_e116 / _e117) > 0.9f) {
                    let _e121 = r2_2;
                    r1_2 = (_e121 * 0.9f);
                }
                let _e124 = r1_2;
                if (_e124 < 0.05f) {
                    r1_2 = 0f;
                }
                let _e128 = N_2;
                let _e129 = rnd;
                let _e131 = rnd;
                let _e139 = makeDivisible(_e128, (floor(((_e129.y * _e131.y) * 60f)) + 2f));
                N_2 = _e139;
                let _e140 = inside_1;
                let _e141 = r1_2;
                let _e142 = r2_2;
                let _e143 = N_2;
                let _e145 = pos;
                let _e146 = inRosace(_e141, _e142, i32(_e143), _e145);
                let _e147 = combine(_e140, _e146);
                inside_1 = _e147;
            }
            continuing {
                let _e101 = j;
                j = (_e101 + 1i);
            }
        }
    }
    let _e148 = inside_1;
    return _e148;
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
    var local_2: f32;
    var local_3: f32;
    var color: vec4<f32>;

    inside_3 = inside_2;
    mode_1 = mode;
    thickness_1 = thickness;
    color1_1 = color1_;
    color2_1 = color2_;
    colorBorder_1 = colorBorder;
    let _e18 = inside_3;
    count = _e18.x;
    let _e21 = inside_3;
    dist_1 = _e21.y;
    let _e24 = inside_3;
    borderDist = _e24.z;
    let _e28 = mode_1;
    if (_e28 == 0i) {
        let _e31 = count;
        if ((_e31 - (floor((_e31 / 2f)) * 2f)) < 1f) {
            local_2 = 1f;
        } else {
            local_2 = 0f;
        }
        let _e42 = local_2;
        k_4 = _e42;
    } else {
        let _e43 = mode_1;
        if (_e43 == 1i) {
            let _e47 = count;
            k_4 = pow(0.8f, _e47);
        } else {
            let _e49 = mode_1;
            if (_e49 == 2i) {
                let _e52 = count;
                if ((_e52 - (floor((_e52 / 2f)) * 2f)) < 1f) {
                    let _e61 = count;
                    local_3 = pow(0.8f, _e61);
                } else {
                    let _e65 = count;
                    local_3 = (1f - pow(0.8f, _e65));
                }
                let _e69 = local_3;
                k_4 = _e69;
            } else {
                let _e70 = mode_1;
                if (_e70 == 3i) {
                    let _e73 = dist_1;
                    k_4 = _e73;
                } else {
                    let _e74 = mode_1;
                    if (_e74 == 4i) {
                        let _e79 = dist_1;
                        k_4 = (-2f * _e79);
                    } else {
                        k_4 = 0.5f;
                    }
                }
            }
        }
    }
    let _e82 = color2_1;
    let _e83 = color1_1;
    let _e84 = k_4;
    color = mix(_e82, _e83, vec4(_e84));
    let _e88 = borderDist;
    let _e89 = thickness_1;
    if (_e88 < (_e89 * 0.005f)) {
        let _e93 = colorBorder_1;
        return _e93;
    } else {
        let _e94 = color;
        return _e94;
    }
}

fn hexCoords(v_2: vec2<f32>) -> vec4<f32> {
    var v_3: vec2<f32>;
    var r_7: vec2<f32> = vec2<f32>(1f, 1.7320508f);
    var h: vec2<f32>;
    var a_7: vec2<f32>;
    var b_5: vec2<f32>;
    var local_4: vec2<f32>;
    var hv: vec2<f32>;
    var id_2: vec2<f32>;

    v_3 = v_2;
    let _e12 = r_7;
    h = (_e12 / vec2(2f));
    let _e17 = v_3;
    let _e19 = r_7;
    let _e25 = v_3;
    let _e27 = r_7;
    let _e34 = h;
    a_7 = (vec2<f32>((_e17.x - (floor((_e17.x / _e19.x)) * _e19.x)), (_e25.y - (floor((_e25.y / _e27.y)) * _e27.y))) - _e34);
    let _e37 = v_3;
    let _e39 = h;
    let _e41 = (_e37.x - _e39.x);
    let _e42 = r_7;
    let _e48 = v_3;
    let _e50 = h;
    let _e52 = (_e48.y - _e50.y);
    let _e53 = r_7;
    let _e60 = h;
    b_5 = (vec2<f32>((_e41 - (floor((_e41 / _e42.x)) * _e42.x)), (_e52 - (floor((_e52 / _e53.y)) * _e53.y))) - _e60);
    let _e63 = a_7;
    let _e65 = b_5;
    if (length(_e63) < length(_e65)) {
        let _e68 = a_7;
        local_4 = _e68;
    } else {
        let _e69 = b_5;
        local_4 = _e69;
    }
    let _e71 = local_4;
    hv = _e71;
    let _e73 = v_3;
    let _e74 = hv;
    id_2 = (_e73 - _e74);
    let _e77 = hv;
    let _e78 = id_2;
    return vec4<f32>(_e77.x, _e77.y, _e78.x, _e78.y);
}

fn hexPolarCoords(v_4: vec2<f32>) -> vec4<f32> {
    var v_5: vec2<f32>;
    var r_8: vec2<f32> = vec2<f32>(1f, 1.7320508f);
    var h_1: vec2<f32>;
    var a_8: vec2<f32>;
    var b_6: vec2<f32>;
    var local_5: vec2<f32>;
    var hv_1: vec2<f32>;
    var x_1: f32;
    var y_1: f32;
    var id_3: vec2<f32>;

    v_5 = v_4;
    let _e12 = r_8;
    h_1 = (_e12 / vec2(2f));
    let _e17 = v_5;
    let _e19 = r_8;
    let _e25 = v_5;
    let _e27 = r_8;
    let _e34 = h_1;
    a_8 = (vec2<f32>((_e17.x - (floor((_e17.x / _e19.x)) * _e19.x)), (_e25.y - (floor((_e25.y / _e27.y)) * _e27.y))) - _e34);
    let _e37 = v_5;
    let _e39 = h_1;
    let _e41 = (_e37.x - _e39.x);
    let _e42 = r_8;
    let _e48 = v_5;
    let _e50 = h_1;
    let _e52 = (_e48.y - _e50.y);
    let _e53 = r_8;
    let _e60 = h_1;
    b_6 = (vec2<f32>((_e41 - (floor((_e41 / _e42.x)) * _e42.x)), (_e52 - (floor((_e52 / _e53.y)) * _e53.y))) - _e60);
    let _e63 = a_8;
    let _e65 = b_6;
    if (length(_e63) < length(_e65)) {
        let _e68 = a_8;
        local_5 = _e68;
    } else {
        let _e69 = b_6;
        local_5 = _e69;
    }
    let _e71 = local_5;
    hv_1 = _e71;
    let _e73 = hv_1;
    let _e75 = hv_1;
    x_1 = atan2(_e73.y, _e75.x);
    let _e79 = hv_1;
    y_1 = length(_e79);
    let _e82 = v_5;
    let _e83 = hv_1;
    id_3 = (_e82 - _e83);
    let _e86 = x_1;
    let _e87 = y_1;
    let _e88 = id_3;
    return vec4<f32>(_e86, _e87, _e88.x, _e88.y);
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

fn rosette(uv: vec2<f32>, outPos: vec2<f32>, modelTransform: mat3x3<f32>, color1_2: vec4<f32>, color2_2: vec4<f32>, colorBorder_2: vec4<f32>, radius_2: f32, randomSeed_2: f32, thickness_2: f32, mode_2: i32, source_specified: i32) -> vec4<f32> {
    var uv_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var modelTransform_1: mat3x3<f32>;
    var color1_3: vec4<f32>;
    var color2_3: vec4<f32>;
    var colorBorder_3: vec4<f32>;
    var radius_3: f32;
    var randomSeed_3: f32;
    var thickness_3: f32;
    var mode_3: i32;
    var source_specified_1: i32;
    var pos_1: vec2<f32>;
    var hexCoord: vec4<f32>;
    var gridPos: vec2<f32>;
    var gridIndex: vec2<f32>;
    var inside_4: vec3<f32>;
    var color_1: vec4<f32>;
    var bkg_2: vec4<f32>;

    uv_1 = uv;
    outPos_1 = outPos;
    modelTransform_1 = modelTransform;
    color1_3 = color1_2;
    color2_3 = color2_2;
    colorBorder_3 = colorBorder_2;
    radius_3 = radius_2;
    randomSeed_3 = randomSeed_2;
    thickness_3 = thickness_2;
    mode_3 = mode_2;
    source_specified_1 = source_specified;
    let _e28 = uv_1;
    pos_1 = _e28;
    let _e30 = pos_1;
    let _e31 = hexCoords(_e30);
    hexCoord = _e31;
    let _e33 = hexCoord;
    gridPos = _e33.xy;
    let _e36 = hexCoord;
    gridIndex = floor(((_e36.zw * vec2<f32>(2f, 3.4641016f)) + vec2(0.5f)));
    let _e49 = gridPos;
    let _e50 = radius_3;
    pos_1 = (_e49 / vec2(_e50));
    let _e53 = gridPos;
    let _e54 = gridIndex;
    let _e55 = radius_3;
    let _e56 = randomSeed_3;
    let _e57 = getInsideRosace(_e53, _e54, _e55, _e56);
    inside_4 = _e57;
    let _e59 = radius_3;
    if (_e59 > 0.66f) {
        {
            let _e62 = inside_4;
            let _e63 = gridPos;
            let _e68 = gridIndex;
            let _e73 = radius_3;
            let _e74 = randomSeed_3;
            let _e75 = getInsideRosace((_e63 - vec2<f32>(1f, 0f)), (_e68 + vec2<f32>(2f, 0f)), _e73, _e74);
            let _e76 = combine(_e62, _e75);
            inside_4 = _e76;
            let _e77 = inside_4;
            let _e78 = gridPos;
            let _e83 = gridIndex;
            let _e88 = radius_3;
            let _e89 = randomSeed_3;
            let _e90 = getInsideRosace((_e78 + vec2<f32>(1f, 0f)), (_e83 - vec2<f32>(2f, 0f)), _e88, _e89);
            let _e91 = combine(_e77, _e90);
            inside_4 = _e91;
            let _e92 = inside_4;
            let _e93 = gridPos;
            let _e98 = gridIndex;
            let _e103 = radius_3;
            let _e104 = randomSeed_3;
            let _e105 = getInsideRosace((_e93 - vec2<f32>(0.5f, 0.8660254f)), (_e98 + vec2<f32>(1f, 3f)), _e103, _e104);
            let _e106 = combine(_e92, _e105);
            inside_4 = _e106;
            let _e107 = inside_4;
            let _e108 = gridPos;
            let _e114 = gridIndex;
            let _e120 = radius_3;
            let _e121 = randomSeed_3;
            let _e122 = getInsideRosace((_e108 - vec2<f32>(-0.5f, 0.8660254f)), (_e114 + vec2<f32>(-1f, 3f)), _e120, _e121);
            let _e123 = combine(_e107, _e122);
            inside_4 = _e123;
            let _e124 = inside_4;
            let _e125 = gridPos;
            let _e131 = gridIndex;
            let _e137 = radius_3;
            let _e138 = randomSeed_3;
            let _e139 = getInsideRosace((_e125 - vec2<f32>(0.5f, -0.8660254f)), (_e131 + vec2<f32>(1f, -3f)), _e137, _e138);
            let _e140 = combine(_e124, _e139);
            inside_4 = _e140;
            let _e141 = inside_4;
            let _e142 = gridPos;
            let _e149 = gridIndex;
            let _e156 = radius_3;
            let _e157 = randomSeed_3;
            let _e158 = getInsideRosace((_e142 - vec2<f32>(-0.5f, -0.8660254f)), (_e149 + vec2<f32>(-1f, -3f)), _e156, _e157);
            let _e159 = combine(_e141, _e158);
            inside_4 = _e159;
        }
    }
    let _e160 = inside_4;
    let _e161 = mode_3;
    let _e162 = thickness_3;
    let _e163 = color1_3;
    let _e164 = color2_3;
    let _e165 = colorBorder_3;
    let _e166 = getShapeOverlapColor(_e160, _e161, _e162, _e163, _e164, _e165);
    color_1 = _e166;
    let _e168 = source_specified_1;
    let _e171 = color_1;
    if ((_e168 == 1i) && (_e171.w < 1f)) {
        {
            let _e176 = uv_1;
            let _e180 = global.U[0];
            let _e183 = uv_1;
            let _e192 = textureSample(t_source, samp, ((vec2<f32>((_e176.x / _e180.x), _e183.y) / vec2(2f)) + vec2(0.5f)));
            bkg_2 = _e192;
            let _e194 = bkg_2;
            let _e195 = color_1;
            let _e196 = mergeColor(_e194, _e195);
            return _e196;
        }
    } else {
        {
            let _e197 = color_1;
            return _e197;
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
    let _e67 = _e66.xyz;
    let _e70 = global.U[7];
    let _e71 = _e70.xyz;
    let _e74 = global.U[8];
    let _e75 = _e74.xyz;
    let _e91 = global.U[9];
    let _e94 = global.U[10];
    let _e97 = global.U[11];
    let _e100 = global.U[12];
    let _e104 = global.U[13];
    let _e108 = global.U[14];
    let _e112 = global.U[15];
    let _e117 = global.U[4];
    let _e120 = rosette((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e9.x, _e9.y, _e9.z), vec3<f32>(_e13.x, _e13.y, _e13.z), vec3<f32>(_e17.x, _e17.y, _e17.z))) * vec3<f32>(_e44.x, _e44.y, 1f)).xy, (((_e51 - vec2(0.5f)) * 2f) * vec2<f32>(_e59.x, 1f)), mat3x3<f32>(vec3<f32>(_e67.x, _e67.y, _e67.z), vec3<f32>(_e71.x, _e71.y, _e71.z), vec3<f32>(_e75.x, _e75.y, _e75.z)), _e91, _e94, _e97, _e100.x, _e104.x, _e108.x, i32(_e112.x), i32(_e117.x));
    fragColor = _e120;
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
