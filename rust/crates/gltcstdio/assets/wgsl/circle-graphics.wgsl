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

fn distToArc(p: vec2<f32>, center: vec2<f32>, radius: f32, angBegin: f32, angEnd: f32) -> f32 {
    var p_1: vec2<f32>;
    var center_1: vec2<f32>;
    var radius_1: f32;
    var angBegin_1: f32;
    var angEnd_1: f32;
    var centerToP: vec2<f32>;
    var angle: f32;
    var a: vec2<f32>;
    var b: vec2<f32>;

    p_1 = p;
    center_1 = center;
    radius_1 = radius;
    angBegin_1 = angBegin;
    angEnd_1 = angEnd;
    let _e16 = p_1;
    let _e17 = center_1;
    centerToP = (_e16 - _e17);
    let _e20 = centerToP;
    let _e22 = centerToP;
    angle = atan2(_e20.y, _e22.x);
    let _e26 = angle;
    let _e27 = angBegin_1;
    let _e29 = angle;
    let _e30 = angEnd_1;
    if ((_e26 >= _e27) && (_e29 <= _e30)) {
        {
            let _e33 = p_1;
            let _e34 = center_1;
            let _e37 = radius_1;
            return abs((length((_e33 - _e34)) - _e37));
        }
    } else {
        {
            let _e40 = center_1;
            let _e41 = radius_1;
            let _e42 = angBegin_1;
            let _e44 = angBegin_1;
            a = (_e40 + (_e41 * vec2<f32>(cos(_e42), sin(_e44))));
            let _e50 = center_1;
            let _e51 = radius_1;
            let _e52 = angEnd_1;
            let _e54 = angEnd_1;
            b = (_e50 + (_e51 * vec2<f32>(cos(_e52), sin(_e54))));
            let _e60 = p_1;
            let _e61 = a;
            let _e64 = p_1;
            let _e65 = b;
            return min(length((_e60 - _e61)), length((_e64 - _e65)));
        }
    }
}

fn distToSegment(p_2: vec2<f32>, a_1: vec2<f32>, b_1: vec2<f32>) -> f32 {
    var p_3: vec2<f32>;
    var a_2: vec2<f32>;
    var b_2: vec2<f32>;
    var ab: vec2<f32>;
    var abLen: f32;
    var abNorm: vec2<f32>;
    var ap: vec2<f32>;
    var abProj: f32;

    p_3 = p_2;
    a_2 = a_1;
    b_2 = b_1;
    let _e12 = b_2;
    let _e13 = a_2;
    ab = (_e12 - _e13);
    let _e16 = ab;
    abLen = length(_e16);
    let _e19 = abLen;
    if (_e19 == 0f) {
        let _e22 = p_3;
        let _e23 = a_2;
        return length((_e22 - _e23));
    }
    let _e26 = ab;
    let _e27 = abLen;
    abNorm = (_e26 / vec2(_e27));
    let _e31 = p_3;
    let _e32 = a_2;
    ap = (_e31 - _e32);
    let _e35 = ap;
    let _e36 = abNorm;
    abProj = dot(_e35, _e36);
    let _e39 = abProj;
    let _e42 = abProj;
    let _e43 = abLen;
    if ((_e39 >= 0f) && (_e42 <= _e43)) {
        {
            let _e46 = ap;
            let _e47 = abNorm;
            let _e49 = abNorm;
            return abs(dot(_e46, vec2<f32>(_e47.y, -(_e49.x))));
        }
    } else {
        {
            let _e55 = ap;
            let _e57 = p_3;
            let _e58 = b_2;
            return min(length(_e55), length((_e57 - _e58)));
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

fn distToDisjointPiePieces(p_4: vec2<f32>, center_2: vec2<f32>, n: i32, r1_: f32, r2_: f32, angBegin_2: f32, angEnd_2: f32, varia: f32, randomSeed: f32) -> f32 {
    var p_5: vec2<f32>;
    var center_3: vec2<f32>;
    var n_1: i32;
    var r1_1: f32;
    var r2_1: f32;
    var angBegin_3: f32;
    var angEnd_3: f32;
    var varia_1: f32;
    var randomSeed_1: f32;
    var d: f32 = 10000000000f;
    var centerToP_1: vec2<f32>;
    var ang: f32;
    var dAng: f32;
    var eAng: f32;
    var nd: f32;
    var a1_: f32;
    var dir1_: vec2<f32>;
    var a2_: f32;
    var dir2_: vec2<f32>;
    var dr: f32;

    p_5 = p_4;
    center_3 = center_2;
    n_1 = n;
    r1_1 = r1_;
    r2_1 = r2_;
    angBegin_3 = angBegin_2;
    angEnd_3 = angEnd_2;
    varia_1 = varia;
    randomSeed_1 = randomSeed;
    let _e26 = p_5;
    let _e27 = center_3;
    centerToP_1 = (_e26 - _e27);
    let _e30 = centerToP_1;
    let _e32 = centerToP_1;
    ang = atan2(_e30.y, _e32.x);
    let _e36 = angEnd_3;
    let _e37 = angBegin_3;
    let _e39 = n_1;
    dAng = ((_e36 - _e37) / f32(_e39));
    let _e43 = dAng;
    eAng = (_e43 * 0.1f);
    let _e47 = ang;
    let _e48 = dAng;
    nd = floor((_e47 / _e48));
    let _e52 = nd;
    let _e53 = dAng;
    let _e55 = eAng;
    a1_ = ((_e52 * _e53) + _e55);
    let _e58 = a1_;
    let _e60 = a1_;
    dir1_ = vec2<f32>(cos(_e58), sin(_e60));
    let _e64 = nd;
    let _e65 = dAng;
    let _e67 = dAng;
    let _e69 = eAng;
    a2_ = (((_e64 * _e65) + _e67) - _e69);
    let _e72 = a2_;
    let _e74 = a2_;
    dir2_ = vec2<f32>(cos(_e72), sin(_e74));
    let _e78 = varia_1;
    if (_e78 != 0f) {
        {
            let _e81 = ang;
            let _e84 = dAng;
            let _e89 = n_1;
            let _e90 = f32(_e89);
            if ((_e81 < (-3.1415927f + (_e84 / 2f))) && ((_e90 - (floor((_e90 / 2f)) * 2f)) == 1f)) {
                let _e99 = ang;
                let _e104 = dAng;
                nd = floor(((_e99 + 6.2831855f) / _e104));
            }
            let _e107 = varia_1;
            let _e108 = nd;
            let _e110 = nd;
            let _e113 = randomSeed_1;
            let _e114 = rand2relSeeded(vec2<f32>(f32(_e108), f32(_e110)), _e113);
            dr = (_e107 * _e114.x);
            let _e118 = varia_1;
            if (_e118 > 0f) {
                let _e121 = r1_1;
                let _e122 = r2_1;
                let _e123 = dr;
                r2_1 = max(_e121, (_e122 + _e123));
            } else {
                let _e127 = r2_1;
                let _e128 = r1_1;
                let _e129 = dr;
                r1_1 = max(0f, min(_e127, (_e128 + _e129)));
            }
        }
    }
    let _e133 = d;
    let _e134 = p_5;
    let _e135 = center_3;
    let _e136 = r1_1;
    let _e137 = dir1_;
    let _e140 = center_3;
    let _e141 = r2_1;
    let _e142 = dir1_;
    let _e145 = distToSegment(_e134, (_e135 + (_e136 * _e137)), (_e140 + (_e141 * _e142)));
    d = min(_e133, _e145);
    let _e147 = d;
    let _e148 = p_5;
    let _e149 = center_3;
    let _e150 = r1_1;
    let _e151 = dir2_;
    let _e154 = center_3;
    let _e155 = r2_1;
    let _e156 = dir2_;
    let _e159 = distToSegment(_e148, (_e149 + (_e150 * _e151)), (_e154 + (_e155 * _e156)));
    d = min(_e147, _e159);
    let _e161 = d;
    let _e162 = p_5;
    let _e163 = center_3;
    let _e164 = r1_1;
    let _e165 = a1_;
    let _e166 = a2_;
    let _e167 = distToArc(_e162, _e163, _e164, _e165, _e166);
    d = min(_e161, _e167);
    let _e169 = d;
    let _e170 = p_5;
    let _e171 = center_3;
    let _e172 = r2_1;
    let _e173 = a1_;
    let _e174 = a2_;
    let _e175 = distToArc(_e170, _e171, _e172, _e173, _e174);
    d = min(_e169, _e175);
    let _e177 = d;
    return _e177;
}

fn distToPiePiece(p_6: vec2<f32>, center_4: vec2<f32>, n_2: i32, r1_2: f32, r2_2: f32, angBegin_4: f32, angEnd_4: f32) -> f32 {
    var p_7: vec2<f32>;
    var center_5: vec2<f32>;
    var n_3: i32;
    var r1_3: f32;
    var r2_3: f32;
    var angBegin_5: f32;
    var angEnd_5: f32;
    var d_1: f32;
    var centerToP_2: vec2<f32>;
    var ang_1: f32;
    var dAng_1: f32;
    var nd_1: f32;
    var dir: vec2<f32>;

    p_7 = p_6;
    center_5 = center_4;
    n_3 = n_2;
    r1_3 = r1_2;
    r2_3 = r2_2;
    angBegin_5 = angBegin_4;
    angEnd_5 = angEnd_4;
    let _e20 = p_7;
    let _e21 = center_5;
    let _e22 = r1_3;
    let _e23 = angBegin_5;
    let _e24 = angEnd_5;
    let _e25 = distToArc(_e20, _e21, _e22, _e23, _e24);
    let _e26 = p_7;
    let _e27 = center_5;
    let _e28 = r2_3;
    let _e29 = angBegin_5;
    let _e30 = angEnd_5;
    let _e31 = distToArc(_e26, _e27, _e28, _e29, _e30);
    d_1 = min(_e25, _e31);
    let _e34 = p_7;
    let _e35 = center_5;
    centerToP_2 = (_e34 - _e35);
    let _e38 = centerToP_2;
    let _e40 = centerToP_2;
    ang_1 = atan2(_e38.y, _e40.x);
    let _e44 = angEnd_5;
    let _e45 = angBegin_5;
    let _e47 = n_3;
    dAng_1 = ((_e44 - _e45) / f32(_e47));
    let _e51 = ang_1;
    let _e52 = dAng_1;
    nd_1 = floor((_e51 / _e52));
    let _e56 = nd_1;
    let _e59 = dAng_1;
    let _e62 = nd_1;
    let _e65 = dAng_1;
    dir = vec2<f32>(cos(((_e56 + 0.5f) * _e59)), sin(((_e62 + 0.5f) * _e65)));
    let _e70 = d_1;
    let _e71 = p_7;
    let _e72 = center_5;
    let _e73 = r1_3;
    let _e74 = dir;
    let _e77 = center_5;
    let _e78 = r2_3;
    let _e79 = dir;
    let _e82 = distToSegment(_e71, (_e72 + (_e73 * _e74)), (_e77 + (_e78 * _e79)));
    d_1 = min(_e70, _e82);
    let _e84 = d_1;
    return _e84;
}

fn distToPolyPiece(p_8: vec2<f32>, center_6: vec2<f32>, n_4: i32, r1_4: f32, r2_4: f32, angBegin_6: f32, angEnd_6: f32) -> f32 {
    var p_9: vec2<f32>;
    var center_7: vec2<f32>;
    var n_5: i32;
    var r1_5: f32;
    var r2_5: f32;
    var angBegin_7: f32;
    var angEnd_7: f32;
    var d_2: f32 = 10000000000f;
    var centerToP_3: vec2<f32>;
    var ang_2: f32;
    var dAng_2: f32;
    var nd_2: f32;
    var a1_1: f32;
    var dir1_1: vec2<f32>;
    var a2_1: f32;
    var dir2_1: vec2<f32>;

    p_9 = p_8;
    center_7 = center_6;
    n_5 = n_4;
    r1_5 = r1_4;
    r2_5 = r2_4;
    angBegin_7 = angBegin_6;
    angEnd_7 = angEnd_6;
    let _e22 = p_9;
    let _e23 = center_7;
    centerToP_3 = (_e22 - _e23);
    let _e26 = centerToP_3;
    let _e28 = centerToP_3;
    ang_2 = atan2(_e26.y, _e28.x);
    let _e32 = angEnd_7;
    let _e33 = angBegin_7;
    let _e35 = n_5;
    dAng_2 = ((_e32 - _e33) / f32(_e35));
    let _e39 = ang_2;
    let _e40 = dAng_2;
    nd_2 = floor((_e39 / _e40));
    let _e44 = nd_2;
    let _e45 = dAng_2;
    a1_1 = (_e44 * _e45);
    let _e48 = a1_1;
    let _e50 = a1_1;
    dir1_1 = vec2<f32>(cos(_e48), sin(_e50));
    let _e54 = nd_2;
    let _e55 = dAng_2;
    let _e57 = dAng_2;
    a2_1 = ((_e54 * _e55) + _e57);
    let _e60 = a2_1;
    let _e62 = a2_1;
    dir2_1 = vec2<f32>(cos(_e60), sin(_e62));
    let _e66 = d_2;
    let _e67 = p_9;
    let _e68 = center_7;
    let _e69 = r1_5;
    let _e70 = dir1_1;
    let _e73 = center_7;
    let _e74 = r2_5;
    let _e75 = dir1_1;
    let _e78 = distToSegment(_e67, (_e68 + (_e69 * _e70)), (_e73 + (_e74 * _e75)));
    d_2 = min(_e66, _e78);
    let _e80 = d_2;
    let _e81 = p_9;
    let _e82 = center_7;
    let _e83 = r1_5;
    let _e84 = dir2_1;
    let _e87 = center_7;
    let _e88 = r2_5;
    let _e89 = dir2_1;
    let _e92 = distToSegment(_e81, (_e82 + (_e83 * _e84)), (_e87 + (_e88 * _e89)));
    d_2 = min(_e80, _e92);
    let _e94 = d_2;
    let _e95 = p_9;
    let _e96 = center_7;
    let _e97 = r2_5;
    let _e98 = dir1_1;
    let _e101 = center_7;
    let _e102 = r2_5;
    let _e103 = dir2_1;
    let _e106 = distToSegment(_e95, (_e96 + (_e97 * _e98)), (_e101 + (_e102 * _e103)));
    d_2 = min(_e94, _e106);
    let _e108 = d_2;
    let _e109 = p_9;
    let _e110 = center_7;
    let _e111 = r1_5;
    let _e112 = dir1_1;
    let _e115 = center_7;
    let _e116 = r1_5;
    let _e117 = dir2_1;
    let _e120 = distToSegment(_e109, (_e110 + (_e111 * _e112)), (_e115 + (_e116 * _e117)));
    d_2 = min(_e108, _e120);
    let _e122 = d_2;
    return _e122;
}

fn distToRadialTicks(p_10: vec2<f32>, center_8: vec2<f32>, n_6: i32, r1_6: f32, r2_6: f32, angBegin_8: f32, angEnd_8: f32, varia_2: f32, randomSeed_2: f32) -> f32 {
    var p_11: vec2<f32>;
    var center_9: vec2<f32>;
    var n_7: i32;
    var r1_7: f32;
    var r2_7: f32;
    var angBegin_9: f32;
    var angEnd_9: f32;
    var varia_3: f32;
    var randomSeed_3: f32;
    var d_3: f32 = 10000000000f;
    var centerToP_4: vec2<f32>;
    var ang_3: f32;
    var dAng_3: f32;
    var nd_3: f32;
    var dr_1: f32;
    var dir_1: vec2<f32>;

    p_11 = p_10;
    center_9 = center_8;
    n_7 = n_6;
    r1_7 = r1_6;
    r2_7 = r2_6;
    angBegin_9 = angBegin_8;
    angEnd_9 = angEnd_8;
    varia_3 = varia_2;
    randomSeed_3 = randomSeed_2;
    let _e26 = p_11;
    let _e27 = center_9;
    centerToP_4 = (_e26 - _e27);
    let _e30 = centerToP_4;
    let _e32 = centerToP_4;
    ang_3 = atan2(_e30.y, _e32.x);
    let _e36 = angEnd_9;
    let _e37 = angBegin_9;
    let _e39 = n_7;
    dAng_3 = ((_e36 - _e37) / f32(_e39));
    let _e43 = ang_3;
    let _e44 = dAng_3;
    nd_3 = floor((_e43 / _e44));
    let _e48 = varia_3;
    if (_e48 != 0f) {
        {
            let _e51 = ang_3;
            let _e54 = dAng_3;
            let _e59 = n_7;
            let _e60 = f32(_e59);
            if ((_e51 < (-3.1415927f + (_e54 / 2f))) && ((_e60 - (floor((_e60 / 2f)) * 2f)) == 1f)) {
                let _e69 = ang_3;
                let _e74 = dAng_3;
                nd_3 = floor(((_e69 + 6.2831855f) / _e74));
            }
            let _e77 = varia_3;
            let _e78 = nd_3;
            let _e80 = nd_3;
            let _e83 = randomSeed_3;
            let _e84 = rand2relSeeded(vec2<f32>(f32(_e78), f32(_e80)), _e83);
            dr_1 = (_e77 * _e84.x);
            let _e88 = r1_7;
            let _e89 = r2_7;
            let _e90 = dr_1;
            r2_7 = max(_e88, (_e89 + _e90));
        }
    }
    let _e93 = nd_3;
    let _e96 = dAng_3;
    let _e99 = nd_3;
    let _e102 = dAng_3;
    dir_1 = vec2<f32>(cos(((_e93 + 0.5f) * _e96)), sin(((_e99 + 0.5f) * _e102)));
    let _e107 = d_3;
    let _e108 = p_11;
    let _e109 = center_9;
    let _e110 = r1_7;
    let _e111 = dir_1;
    let _e114 = center_9;
    let _e115 = r2_7;
    let _e116 = dir_1;
    let _e119 = distToSegment(_e108, (_e109 + (_e110 * _e111)), (_e114 + (_e115 * _e116)));
    d_3 = min(_e107, _e119);
    let _e121 = d_3;
    return _e121;
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

fn response(d_4: f32, thickness: f32, blur: f32) -> f32 {
    var d_5: f32;
    var thickness_1: f32;
    var blur_1: f32;

    d_5 = d_4;
    thickness_1 = thickness;
    blur_1 = blur;
    let _e12 = thickness_1;
    let _e13 = thickness_1;
    let _e14 = blur_1;
    let _e16 = d_5;
    return pow(smoothstep(_e12, (_e13 + _e14), _e16), 0.3f);
}

fn tf(m: mat3x3<f32>, u: vec2<f32>) -> vec2<f32> {
    var m_1: mat3x3<f32>;
    var u_1: vec2<f32>;

    m_1 = m;
    u_1 = u;
    let _e10 = m_1;
    let _e11 = u_1;
    return (_e10 * vec3<f32>(_e11.x, _e11.y, 1f)).xy;
}

fn circleGraphics(uv: vec2<f32>, outPos: vec2<f32>, count: i32, mode: i32, randomSeed_4: f32, thickness_2: f32, color: vec4<f32>, radius_2: f32, glow: f32, variability: f32, modelTransform: mat3x3<f32>) -> vec4<f32> {
    var uv_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var count_1: i32;
    var mode_1: i32;
    var randomSeed_5: f32;
    var thickness_3: f32;
    var color_1: vec4<f32>;
    var radius_3: f32;
    var glow_1: f32;
    var variability_1: f32;
    var modelTransform_1: mat3x3<f32>;
    var invModelTransform: mat3x3<f32>;
    var u_2: vec2<f32>;
    var scale: f32;
    var varia_4: f32;
    var m_2: i32;
    var d_6: f32 = 10000000000f;
    var r2_8: f32 = 0.5f;
    var r1_8: f32;
    var N: i32;
    var rnd: vec2<f32>;
    var i: i32 = 0i;
    var kv: f32;
    var scale_1: f32;
    var blur_2: f32;
    var k_4: f32;
    var gg: f32;
    var addK: f32;
    var bkgCol: vec4<f32>;
    var shapeRgb: vec3<f32>;
    var overCol: vec4<f32>;
    var addRgb: vec3<f32>;
    var addCol: vec4<f32>;
    var outCol: vec4<f32>;

    uv_1 = uv;
    outPos_1 = outPos;
    count_1 = count;
    mode_1 = mode;
    randomSeed_5 = randomSeed_4;
    thickness_3 = thickness_2;
    color_1 = color;
    radius_3 = radius_2;
    glow_1 = glow;
    variability_1 = variability;
    modelTransform_1 = modelTransform;
    let _e28 = modelTransform_1;
    invModelTransform = _naga_inverse_3x3_f32(_e28);
    let _e31 = invModelTransform;
    let _e32 = uv_1;
    let _e33 = tf(_e31, _e32);
    u_2 = _e33;
    let _e37 = invModelTransform[0];
    scale = length(_e37.xy);
    let _e41 = thickness_3;
    let _e46 = scale;
    thickness_3 = ((pow(_e41, 2f) * 0.25f) * _e46);
    let _e48 = variability_1;
    varia_4 = _e48;
    let _e50 = mode_1;
    m_2 = _e50;
    let _e56 = r2_8;
    let _e57 = radius_3;
    r1_8 = (_e56 * _e57);
    let _e60 = m_2;
    if (_e60 == 0i) {
        let _e63 = u_2;
        let _e67 = count_1;
        let _e69 = r1_8;
        let _e70 = r2_8;
        let _e74 = distToPiePiece(_e63, vec2<f32>(0f, 0f), i32(_e67), _e69, _e70, -3.1415927f, 3.1415927f);
        d_6 = _e74;
    } else {
        let _e75 = m_2;
        if (_e75 == 1i) {
            let _e78 = u_2;
            let _e82 = count_1;
            let _e84 = r1_8;
            let _e85 = r2_8;
            let _e89 = distToPolyPiece(_e78, vec2<f32>(0f, 0f), i32(_e82), _e84, _e85, -3.1415927f, 3.1415927f);
            d_6 = _e89;
        } else {
            let _e90 = m_2;
            if (_e90 == 2i) {
                let _e93 = u_2;
                let _e97 = count_1;
                let _e99 = r1_8;
                let _e100 = r2_8;
                let _e104 = varia_4;
                let _e105 = randomSeed_5;
                let _e106 = distToDisjointPiePieces(_e93, vec2<f32>(0f, 0f), i32(_e97), _e99, _e100, -3.1415927f, 3.1415927f, _e104, _e105);
                d_6 = _e106;
            } else {
                let _e107 = m_2;
                if (_e107 == 3i) {
                    let _e110 = u_2;
                    let _e114 = count_1;
                    let _e116 = r1_8;
                    let _e117 = r2_8;
                    let _e121 = varia_4;
                    let _e122 = randomSeed_5;
                    let _e123 = distToRadialTicks(_e110, vec2<f32>(0f, 0f), i32(_e114), _e116, _e117, -3.1415927f, 3.1415927f, _e121, _e122);
                    d_6 = _e123;
                } else {
                    {
                        let _e124 = mode_1;
                        let _e125 = f32(_e124);
                        N = i32(((_e125 - (floor((_e125 / 5f)) * 5f)) + 2f));
                        let _e135 = mode_1;
                        let _e136 = mode_1;
                        let _e141 = rand2relSeeded(vec2<f32>(f32(_e135), f32(_e136)), 0f);
                        rnd = _e141;
                        loop {
                            let _e145 = i;
                            let _e146 = N;
                            if !((_e145 < _e146)) {
                                break;
                            }
                            {
                                let _e153 = rnd;
                                let _e157 = (4f * (_e153.y + 0.5f));
                                m_2 = i32((_e157 - (floor((_e157 / 4f)) * 4f)));
                                let _e164 = rnd;
                                kv = (floor(((_e164.y * 2f) + 0.5f)) - 0.5f);
                                let _e174 = m_2;
                                if (_e174 == 0i) {
                                    let _e177 = d_6;
                                    let _e178 = u_2;
                                    let _e182 = count_1;
                                    let _e184 = r1_8;
                                    let _e185 = r2_8;
                                    let _e189 = distToPiePiece(_e178, vec2<f32>(0f, 0f), i32(_e182), _e184, _e185, -3.1415927f, 3.1415927f);
                                    d_6 = min(_e177, _e189);
                                } else {
                                    let _e191 = m_2;
                                    if (_e191 == 1i) {
                                        let _e194 = d_6;
                                        let _e195 = u_2;
                                        let _e199 = count_1;
                                        let _e201 = r1_8;
                                        let _e202 = r2_8;
                                        let _e206 = distToPolyPiece(_e195, vec2<f32>(0f, 0f), i32(_e199), _e201, _e202, -3.1415927f, 3.1415927f);
                                        d_6 = min(_e194, _e206);
                                    } else {
                                        let _e208 = m_2;
                                        if (_e208 == 2i) {
                                            let _e211 = d_6;
                                            let _e212 = u_2;
                                            let _e216 = count_1;
                                            let _e218 = r1_8;
                                            let _e219 = r2_8;
                                            let _e223 = varia_4;
                                            let _e224 = kv;
                                            let _e226 = randomSeed_5;
                                            let _e227 = distToDisjointPiePieces(_e212, vec2<f32>(0f, 0f), i32(_e216), _e218, _e219, -3.1415927f, 3.1415927f, (_e223 * _e224), _e226);
                                            d_6 = min(_e211, _e227);
                                        } else {
                                            let _e229 = d_6;
                                            let _e230 = u_2;
                                            let _e234 = count_1;
                                            let _e236 = r1_8;
                                            let _e237 = r2_8;
                                            let _e241 = varia_4;
                                            let _e242 = kv;
                                            let _e244 = randomSeed_5;
                                            let _e245 = distToRadialTicks(_e230, vec2<f32>(0f, 0f), i32(_e234), _e236, _e237, -3.1415927f, 3.1415927f, (_e241 * _e242), _e244);
                                            d_6 = min(_e229, _e245);
                                        }
                                    }
                                }
                                let _e249 = rnd;
                                scale_1 = (0.5f + (0.9f * _e249.x));
                                let _e254 = scale_1;
                                if (_e254 < 0.05f) {
                                    break;
                                }
                                let _e257 = r1_8;
                                let _e258 = scale_1;
                                r1_8 = (_e257 * _e258);
                                let _e260 = r2_8;
                                let _e261 = scale_1;
                                r2_8 = (_e260 * _e261);
                                let _e263 = rnd;
                                let _e265 = rand2relSeeded(_e263, 0f);
                                rnd = _e265;
                            }
                            continuing {
                                let _e149 = i;
                                i = (_e149 + 1i);
                            }
                        }
                    }
                }
            }
        }
    }
    let _e266 = glow_1;
    blur_2 = _e266;
    let _e268 = d_6;
    let _e269 = thickness_3;
    let _e270 = blur_2;
    let _e273 = scale;
    let _e275 = response(_e268, _e269, ((_e270 * 0.2f) * _e273));
    k_4 = _e275;
    let _e279 = blur_2;
    let _e287 = k_4;
    gg = ((0.025f * max(0f, ((_e279 * 100f) - 50f))) * pow((1f - _e287), 10f));
    let _e295 = blur_2;
    addK = smoothstep(0.5f, 1f, _e295);
    let _e298 = uv_1;
    let _e302 = global.U[0];
    let _e305 = uv_1;
    let _e314 = textureSample(t_source, samp, ((vec2<f32>((_e298.x / _e302.x), _e305.y) / vec2(2f)) + vec2(0.5f)));
    bkgCol = _e314;
    let _e316 = color_1;
    let _e318 = gg;
    let _e319 = gg;
    let _e320 = gg;
    let _e323 = gg;
    shapeRgb = ((_e316.xyz + vec3<f32>(_e318, _e319, _e320)) * (_e323 + 1f));
    let _e328 = bkgCol;
    let _e329 = shapeRgb;
    let _e330 = color_1;
    let _e333 = k_4;
    let _e340 = mergeColor(_e328, vec4<f32>(_e329.x, _e329.y, _e329.z, (_e330.w * (1f - _e333))));
    overCol = _e340;
    let _e342 = bkgCol;
    let _e344 = shapeRgb;
    let _e345 = color_1;
    let _e348 = bkgCol;
    let _e352 = color_1;
    addRgb = mix(_e342.xyz, _e344, vec3((_e345.w + ((1f - _e348.w) * (1f - _e352.w)))));
    let _e360 = addRgb;
    let _e362 = k_4;
    let _e365 = bkgCol;
    let _e367 = bkgCol;
    let _e370 = ((_e360 * (1f - _e362)) + (_e365.xyz * _e367.w));
    let _e372 = bkgCol;
    let _e374 = color_1;
    let _e377 = k_4;
    addCol = vec4<f32>(_e370.x, _e370.y, _e370.z, min(1f, (_e372.w + (_e374.w * (1f - _e377)))));
    let _e387 = overCol;
    let _e388 = addCol;
    let _e389 = addK;
    outCol = mix(_e387, _e388, vec4(_e389));
    let _e393 = outCol;
    return _e393;
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
    let _e66 = global.U[5];
    let _e71 = global.U[6];
    let _e76 = global.U[7];
    let _e80 = global.U[8];
    let _e84 = global.U[9];
    let _e87 = global.U[10];
    let _e91 = global.U[11];
    let _e95 = global.U[12];
    let _e99 = global.U[13];
    let _e100 = _e99.xyz;
    let _e103 = global.U[14];
    let _e104 = _e103.xyz;
    let _e107 = global.U[15];
    let _e108 = _e107.xyz;
    let _e122 = circleGraphics((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e9.x, _e9.y, _e9.z), vec3<f32>(_e13.x, _e13.y, _e13.z), vec3<f32>(_e17.x, _e17.y, _e17.z))) * vec3<f32>(_e44.x, _e44.y, 1f)).xy, (((_e51 - vec2(0.5f)) * 2f) * vec2<f32>(_e59.x, 1f)), i32(_e66.x), i32(_e71.x), _e76.x, _e80.x, _e84, _e87.x, _e91.x, _e95.x, mat3x3<f32>(vec3<f32>(_e100.x, _e100.y, _e100.z), vec3<f32>(_e104.x, _e104.y, _e104.z), vec3<f32>(_e108.x, _e108.y, _e108.z)));
    fragColor = _e122;
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
