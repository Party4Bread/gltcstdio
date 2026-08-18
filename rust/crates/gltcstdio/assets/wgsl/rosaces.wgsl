struct Params {
    U: array<vec4<f32>, 10>,
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

fn inCircle(c: vec2<f32>, r: f32, p: vec2<f32>) -> f32 {
    var c_1: vec2<f32>;
    var r_1: f32;
    var p_1: vec2<f32>;
    var local: f32;

    c_1 = c;
    r_1 = r;
    p_1 = p;
    let _e11 = c_1;
    let _e12 = p_1;
    let _e15 = r_1;
    if (length((_e11 - _e12)) < _e15) {
        local = 1f;
    } else {
        local = 0f;
    }
    let _e20 = local;
    return _e20;
}

fn inCircle2_(a: f32, d: f32, r_2: f32, p_2: vec2<f32>) -> f32 {
    var a_1: f32;
    var d_1: f32;
    var r_3: f32;
    var p_3: vec2<f32>;

    a_1 = a;
    d_1 = d;
    r_3 = r_2;
    p_3 = p_2;
    let _e13 = d_1;
    let _e14 = a_1;
    let _e17 = a_1;
    let _e21 = r_3;
    let _e22 = p_3;
    let _e23 = inCircle((_e13 * vec2<f32>(-(sin(_e14)), cos(_e17))), _e21, _e22);
    return _e23;
}

fn inRosace(r1_: f32, r2_: f32, N: i32, p_4: vec2<f32>) -> f32 {
    var r1_1: f32;
    var r2_1: f32;
    var N_1: i32;
    var p_5: vec2<f32>;
    var di: f32;
    var r_4: f32;
    var d_2: f32;
    var inside: f32 = 0f;
    var i: i32 = 0i;
    var a_2: f32;

    r1_1 = r1_;
    r2_1 = r2_;
    N_1 = N;
    p_5 = p_4;
    let _e13 = p_5;
    di = length(_e13);
    let _e16 = di;
    let _e17 = r1_1;
    let _e19 = di;
    let _e20 = r2_1;
    if ((_e16 < _e17) || (_e19 > _e20)) {
        return 0f;
    }
    let _e24 = r2_1;
    let _e25 = r1_1;
    r_4 = ((_e24 - _e25) / 2f);
    let _e30 = r2_1;
    let _e31 = r_4;
    d_2 = (_e30 - _e31);
    loop {
        let _e38 = i;
        let _e39 = N_1;
        if !((_e38 < _e39)) {
            break;
        }
        {
            let _e46 = i;
            let _e49 = N_1;
            a_2 = ((6.2831855f * f32(_e46)) / f32(_e49));
            let _e53 = inside;
            let _e54 = a_2;
            let _e55 = d_2;
            let _e56 = r_4;
            let _e57 = p_5;
            let _e58 = inCircle2_(_e54, _e55, _e56, _e57);
            inside = (_e53 + _e58);
        }
        continuing {
            let _e42 = i;
            i = (_e42 + 1i);
        }
    }
    let _e60 = inside;
    return _e60;
}

fn makeDivisible(a_3: f32, b: f32) -> f32 {
    var a_4: f32;
    var b_1: f32;

    a_4 = a_3;
    b_1 = b;
    let _e9 = a_4;
    let _e10 = b_1;
    if (_e9 > _e10) {
        {
            let _e12 = b_1;
            let _e13 = a_4;
            let _e14 = b_1;
            return (_e12 * floor(((_e13 / _e14) + 0.5f)));
        }
    } else {
        {
            let _e20 = a_4;
            let _e21 = b_1;
            let _e22 = a_4;
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

fn getInsideRosace(u: vec2<f32>, id: vec2<f32>, radius: f32, randomSeed: f32) -> f32 {
    var u_1: vec2<f32>;
    var id_1: vec2<f32>;
    var radius_1: f32;
    var randomSeed_1: f32;
    var pos: vec2<f32>;
    var inside_1: f32 = 0f;
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
    if (length(_e18) > 0.75f) {
        return 0f;
    }
    let _e25 = id_1;
    let _e26 = randomSeed_1;
    let _e27 = rand2relSeeded(_e25, _e26);
    rnd = (_e27 + vec2<f32>(0.5f, 0.5f));
    let _e34 = rnd;
    levels = i32((1f + floor((_e34.x * 3f))));
    let _e47 = id_1;
    let _e51 = id_1;
    let _e56 = randomSeed_1;
    if (((_e47.x == 0f) && (_e51.y == 0f)) && (_e56 == 0f)) {
        {
            let _e60 = inside_1;
            let _e64 = pos;
            let _e65 = inRosace(0f, 0.25f, 24i, _e64);
            inside_1 = (_e60 + _e65);
            let _e67 = inside_1;
            let _e71 = pos;
            let _e72 = inRosace(0.25f, 0.35f, 12i, _e71);
            inside_1 = (_e67 + _e72);
            let _e74 = inside_1;
            let _e78 = pos;
            let _e79 = inRosace(0.35f, 0.75f, 60i, _e78);
            inside_1 = (_e74 + _e79);
        }
    } else {
        loop {
            let _e83 = j;
            let _e84 = levels;
            if !((_e83 < _e84)) {
                break;
            }
            {
                let _e90 = rnd;
                let _e91 = randomSeed_1;
                let _e92 = rand2relSeeded(_e90, _e91);
                rnd = (_e92 + vec2<f32>(0.5f, 0.5f));
                let _e97 = r1_2;
                r2_2 = _e97;
                let _e98 = r1_2;
                let _e99 = rnd;
                r1_2 = (_e98 * _e99.x);
                let _e102 = r1_2;
                let _e103 = r2_2;
                if ((_e102 / _e103) > 0.9f) {
                    let _e107 = r2_2;
                    r1_2 = (_e107 * 0.9f);
                }
                let _e110 = r1_2;
                if (_e110 < 0.05f) {
                    r1_2 = 0f;
                }
                let _e114 = N_2;
                let _e115 = rnd;
                let _e117 = rnd;
                let _e125 = makeDivisible(_e114, (floor(((_e115.y * _e117.y) * 60f)) + 2f));
                N_2 = _e125;
                let _e126 = inside_1;
                let _e127 = r1_2;
                let _e128 = r2_2;
                let _e129 = N_2;
                let _e131 = pos;
                let _e132 = inRosace(_e127, _e128, i32(_e129), _e131);
                inside_1 = (_e126 + _e132);
            }
            continuing {
                let _e87 = j;
                j = (_e87 + 1i);
            }
        }
    }
    let _e134 = inside_1;
    return _e134;
}

fn hexCoords(v_2: vec2<f32>) -> vec4<f32> {
    var v_3: vec2<f32>;
    var r_5: vec2<f32> = vec2<f32>(1f, 1.7320508f);
    var h: vec2<f32>;
    var a_5: vec2<f32>;
    var b_2: vec2<f32>;
    var local_1: vec2<f32>;
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
    a_5 = (vec2<f32>((_e16.x - (floor((_e16.x / _e18.x)) * _e18.x)), (_e24.y - (floor((_e24.y / _e26.y)) * _e26.y))) - _e33);
    let _e36 = v_3;
    let _e38 = h;
    let _e40 = (_e36.x - _e38.x);
    let _e41 = r_5;
    let _e47 = v_3;
    let _e49 = h;
    let _e51 = (_e47.y - _e49.y);
    let _e52 = r_5;
    let _e59 = h;
    b_2 = (vec2<f32>((_e40 - (floor((_e40 / _e41.x)) * _e41.x)), (_e51 - (floor((_e51 / _e52.y)) * _e52.y))) - _e59);
    let _e62 = a_5;
    let _e64 = b_2;
    if (length(_e62) < length(_e64)) {
        let _e67 = a_5;
        local_1 = _e67;
    } else {
        let _e68 = b_2;
        local_1 = _e68;
    }
    let _e70 = local_1;
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
    var a_6: vec2<f32>;
    var b_3: vec2<f32>;
    var local_2: vec2<f32>;
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
    a_6 = (vec2<f32>((_e16.x - (floor((_e16.x / _e18.x)) * _e18.x)), (_e24.y - (floor((_e24.y / _e26.y)) * _e26.y))) - _e33);
    let _e36 = v_5;
    let _e38 = h_1;
    let _e40 = (_e36.x - _e38.x);
    let _e41 = r_6;
    let _e47 = v_5;
    let _e49 = h_1;
    let _e51 = (_e47.y - _e49.y);
    let _e52 = r_6;
    let _e59 = h_1;
    b_3 = (vec2<f32>((_e40 - (floor((_e40 / _e41.x)) * _e41.x)), (_e51 - (floor((_e51 / _e52.y)) * _e52.y))) - _e59);
    let _e62 = a_6;
    let _e64 = b_3;
    if (length(_e62) < length(_e64)) {
        let _e67 = a_6;
        local_2 = _e67;
    } else {
        let _e68 = b_3;
        local_2 = _e68;
    }
    let _e70 = local_2;
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

fn rosaces(pos_1: vec2<f32>, outPos: vec2<f32>, color1_: vec4<f32>, color2_: vec4<f32>, radius_2: f32, randomSeed_2: f32, mode: i32) -> vec4<f32> {
    var pos_2: vec2<f32>;
    var outPos_1: vec2<f32>;
    var color1_1: vec4<f32>;
    var color2_1: vec4<f32>;
    var radius_3: f32;
    var randomSeed_3: f32;
    var mode_1: i32;
    var hexCoord: vec4<f32>;
    var gridPos: vec2<f32>;
    var gridIndex: vec2<f32>;
    var inside_2: f32 = 0f;
    var k_4: f32;
    var local_3: f32;
    var local_4: f32;

    pos_2 = pos_1;
    outPos_1 = outPos;
    color1_1 = color1_;
    color2_1 = color2_;
    radius_3 = radius_2;
    randomSeed_3 = randomSeed_2;
    mode_1 = mode;
    let _e19 = pos_2;
    let _e20 = hexCoords(_e19);
    hexCoord = _e20;
    let _e22 = hexCoord;
    gridPos = _e22.xy;
    let _e25 = hexCoord;
    gridIndex = floor(((_e25.zw * vec2<f32>(2f, 3.4641016f)) + vec2(0.5f)));
    let _e38 = gridPos;
    let _e39 = radius_3;
    pos_2 = (_e38 / vec2(_e39));
    let _e44 = inside_2;
    let _e45 = gridPos;
    let _e46 = gridIndex;
    let _e47 = radius_3;
    let _e48 = randomSeed_3;
    let _e49 = getInsideRosace(_e45, _e46, _e47, _e48);
    inside_2 = (_e44 + _e49);
    let _e51 = radius_3;
    if (_e51 > 0.66f) {
        {
            let _e54 = inside_2;
            let _e55 = gridPos;
            let _e60 = gridIndex;
            let _e65 = radius_3;
            let _e66 = randomSeed_3;
            let _e67 = getInsideRosace((_e55 - vec2<f32>(1f, 0f)), (_e60 + vec2<f32>(2f, 0f)), _e65, _e66);
            inside_2 = (_e54 + _e67);
            let _e69 = inside_2;
            let _e70 = gridPos;
            let _e75 = gridIndex;
            let _e80 = radius_3;
            let _e81 = randomSeed_3;
            let _e82 = getInsideRosace((_e70 + vec2<f32>(1f, 0f)), (_e75 - vec2<f32>(2f, 0f)), _e80, _e81);
            inside_2 = (_e69 + _e82);
            let _e84 = inside_2;
            let _e85 = gridPos;
            let _e90 = gridIndex;
            let _e95 = radius_3;
            let _e96 = randomSeed_3;
            let _e97 = getInsideRosace((_e85 - vec2<f32>(0.5f, 0.8660254f)), (_e90 + vec2<f32>(1f, 3f)), _e95, _e96);
            inside_2 = (_e84 + _e97);
            let _e99 = inside_2;
            let _e100 = gridPos;
            let _e106 = gridIndex;
            let _e112 = radius_3;
            let _e113 = randomSeed_3;
            let _e114 = getInsideRosace((_e100 - vec2<f32>(-0.5f, 0.8660254f)), (_e106 + vec2<f32>(-1f, 3f)), _e112, _e113);
            inside_2 = (_e99 + _e114);
            let _e116 = inside_2;
            let _e117 = gridPos;
            let _e123 = gridIndex;
            let _e129 = radius_3;
            let _e130 = randomSeed_3;
            let _e131 = getInsideRosace((_e117 - vec2<f32>(0.5f, -0.8660254f)), (_e123 + vec2<f32>(1f, -3f)), _e129, _e130);
            inside_2 = (_e116 + _e131);
            let _e133 = inside_2;
            let _e134 = gridPos;
            let _e141 = gridIndex;
            let _e148 = radius_3;
            let _e149 = randomSeed_3;
            let _e150 = getInsideRosace((_e134 - vec2<f32>(-0.5f, -0.8660254f)), (_e141 + vec2<f32>(-1f, -3f)), _e148, _e149);
            inside_2 = (_e133 + _e150);
        }
    }
    let _e153 = mode_1;
    if (_e153 == 0i) {
        let _e156 = inside_2;
        if ((_e156 - (floor((_e156 / 2f)) * 2f)) < 1f) {
            local_3 = 1f;
        } else {
            local_3 = 0f;
        }
        let _e167 = local_3;
        k_4 = _e167;
    } else {
        let _e168 = mode_1;
        if (_e168 == 1i) {
            let _e172 = inside_2;
            k_4 = pow(0.8f, _e172);
        } else {
            let _e174 = mode_1;
            if (_e174 == 2i) {
                let _e177 = inside_2;
                if ((_e177 - (floor((_e177 / 2f)) * 2f)) < 1f) {
                    let _e186 = inside_2;
                    local_4 = pow(0.8f, _e186);
                } else {
                    let _e190 = inside_2;
                    local_4 = (1f - pow(0.8f, _e190));
                }
                let _e194 = local_4;
                k_4 = _e194;
            } else {
                k_4 = 0.5f;
            }
        }
    }
    let _e196 = color2_1;
    let _e197 = color1_1;
    let _e198 = k_4;
    return mix(_e196, _e197, vec4(_e198));
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
    let _e75 = global.U[8];
    let _e79 = global.U[9];
    let _e82 = rosaces((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e8.x, _e8.y, _e8.z), vec3<f32>(_e12.x, _e12.y, _e12.z), vec3<f32>(_e16.x, _e16.y, _e16.z))) * vec3<f32>(_e43.x, _e43.y, 1f)).xy, (((_e50 - vec2(0.5f)) * 2f) * vec2<f32>(_e58.x, 1f)), _e65, _e68, _e71.x, _e75.x, i32(_e79.x));
    fragColor = _e82;
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
