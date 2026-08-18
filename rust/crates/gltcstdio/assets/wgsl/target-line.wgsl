struct Params {
    U: array<vec4<f32>, 13>,
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

fn distToCrossPartial(p_2: vec2<f32>, center_2: vec2<f32>, r1_: f32, r2_: f32) -> f32 {
    var p_3: vec2<f32>;
    var center_3: vec2<f32>;
    var r1_1: f32;
    var r2_1: f32;

    p_3 = p_2;
    center_3 = center_2;
    r1_1 = r1_;
    r2_1 = r2_;
    let _e14 = p_3;
    p_3 = abs(_e14);
    let _e16 = p_3;
    let _e18 = p_3;
    let _e21 = p_3;
    let _e23 = p_3;
    p_3 = vec2<f32>(max(_e16.x, _e18.y), min(_e21.x, _e23.y));
    let _e27 = p_3;
    let _e28 = center_3;
    let _e30 = r1_1;
    let _e31 = r2_1;
    let _e32 = p_3;
    return length(((_e27 - _e28) - vec2<f32>(clamp(_e30, _e31, _e32.x), 0f)));
}

fn distToSegment(p_4: vec2<f32>, a_1: vec2<f32>, b_1: vec2<f32>) -> f32 {
    var p_5: vec2<f32>;
    var a_2: vec2<f32>;
    var b_2: vec2<f32>;
    var ab: vec2<f32>;
    var abLen: f32;
    var abNorm: vec2<f32>;
    var ap: vec2<f32>;
    var abProj: f32;

    p_5 = p_4;
    a_2 = a_1;
    b_2 = b_1;
    let _e12 = b_2;
    let _e13 = a_2;
    ab = (_e12 - _e13);
    let _e16 = ab;
    abLen = length(_e16);
    let _e19 = abLen;
    if (_e19 == 0f) {
        let _e22 = p_5;
        let _e23 = a_2;
        return length((_e22 - _e23));
    }
    let _e26 = ab;
    let _e27 = abLen;
    abNorm = (_e26 / vec2(_e27));
    let _e31 = p_5;
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
            let _e57 = p_5;
            let _e58 = b_2;
            return min(length(_e55), length((_e57 - _e58)));
        }
    }
}

fn distToRadialTicks2_(p_6: vec2<f32>, center_4: vec2<f32>, n: i32, r1_2: f32, r2_2: f32, angBegin_2: f32, angEnd_2: f32) -> f32 {
    var p_7: vec2<f32>;
    var center_5: vec2<f32>;
    var n_1: i32;
    var r1_3: f32;
    var r2_3: f32;
    var angBegin_3: f32;
    var angEnd_3: f32;
    var d: f32 = 10000000000f;
    var centerToP_1: vec2<f32>;
    var ang: f32;
    var dAng: f32;
    var nd: f32;
    var dir1_: vec2<f32>;
    var dir2_: vec2<f32>;

    p_7 = p_6;
    center_5 = center_4;
    n_1 = n;
    r1_3 = r1_2;
    r2_3 = r2_2;
    angBegin_3 = angBegin_2;
    angEnd_3 = angEnd_2;
    let _e22 = p_7;
    let _e23 = center_5;
    centerToP_1 = (_e22 - _e23);
    let _e26 = centerToP_1;
    let _e28 = centerToP_1;
    ang = atan2(_e26.y, _e28.x);
    let _e32 = angEnd_3;
    let _e33 = angBegin_3;
    let _e35 = n_1;
    dAng = ((_e32 - _e33) / f32(_e35));
    let _e39 = ang;
    let _e40 = dAng;
    nd = floor((_e39 / _e40));
    let _e44 = nd;
    let _e45 = dAng;
    let _e48 = nd;
    let _e49 = dAng;
    dir1_ = vec2<f32>(cos((_e44 * _e45)), sin((_e48 * _e49)));
    let _e54 = nd;
    let _e57 = dAng;
    let _e60 = nd;
    let _e63 = dAng;
    dir2_ = vec2<f32>(cos(((_e54 + 1f) * _e57)), sin(((_e60 + 1f) * _e63)));
    let _e68 = d;
    let _e69 = p_7;
    let _e70 = center_5;
    let _e71 = r1_3;
    let _e72 = dir1_;
    let _e75 = center_5;
    let _e76 = r2_3;
    let _e77 = dir1_;
    let _e80 = distToSegment(_e69, (_e70 + (_e71 * _e72)), (_e75 + (_e76 * _e77)));
    d = min(_e68, _e80);
    let _e82 = d;
    let _e83 = p_7;
    let _e84 = center_5;
    let _e85 = r1_3;
    let _e86 = dir2_;
    let _e89 = center_5;
    let _e90 = r2_3;
    let _e91 = dir2_;
    let _e94 = distToSegment(_e83, (_e84 + (_e85 * _e86)), (_e89 + (_e90 * _e91)));
    d = min(_e82, _e94);
    let _e96 = d;
    return _e96;
}

fn distToSquare(p_8: vec2<f32>, center_6: vec2<f32>, radius_2: f32) -> f32 {
    var p_9: vec2<f32>;
    var center_7: vec2<f32>;
    var radius_3: f32;

    p_9 = p_8;
    center_7 = center_6;
    radius_3 = radius_2;
    let _e12 = p_9;
    let _e13 = center_7;
    p_9 = abs((_e12 - _e13));
    let _e16 = p_9;
    let _e18 = p_9;
    let _e21 = p_9;
    let _e23 = p_9;
    p_9 = vec2<f32>(max(_e16.x, _e18.y), min(_e21.x, _e23.y));
    let _e27 = p_9;
    let _e28 = radius_3;
    let _e30 = radius_3;
    let _e31 = p_9;
    return length((_e27 - vec2<f32>(_e28, clamp(0f, _e30, _e31.y))));
}

fn distToTarget7_(p_10: vec2<f32>, center_8: vec2<f32>, r: f32, m: f32) -> f32 {
    var p_11: vec2<f32>;
    var center_9: vec2<f32>;
    var r_1: f32;
    var m_1: f32;
    var d_1: f32 = 10000000000f;
    var c: vec2<f32> = vec2<f32>(0f, 0f);

    p_11 = p_10;
    center_9 = center_8;
    r_1 = r;
    m_1 = m;
    let _e20 = p_11;
    let _e21 = center_9;
    p_11 = abs((_e20 - _e21));
    let _e24 = m_1;
    if ((_e24 - (floor((_e24 / 2f)) * 2f)) >= 1f) {
        let _e32 = d_1;
        let _e33 = p_11;
        let _e34 = c;
        let _e35 = r_1;
        let _e38 = r_1;
        let _e39 = distToCrossPartial(_e33, _e34, (_e35 * 0.3f), _e38);
        d_1 = min(_e32, _e39);
    }
    let _e41 = m_1;
    m_1 = (_e41 / 2f);
    let _e44 = m_1;
    if ((_e44 - (floor((_e44 / 2f)) * 2f)) >= 1f) {
        let _e52 = d_1;
        let _e53 = p_11;
        let _e54 = c;
        let _e56 = r_1;
        let _e59 = r_1;
        let _e65 = distToRadialTicks2_(_e53, _e54, 32i, (_e56 * 0.3f), (_e59 * 0.45f), -3.1415927f, 3.1415927f);
        d_1 = min(_e52, _e65);
    }
    let _e67 = m_1;
    m_1 = (_e67 / 2f);
    let _e70 = m_1;
    if ((_e70 - (floor((_e70 / 2f)) * 2f)) >= 1f) {
        let _e78 = d_1;
        let _e79 = p_11;
        let _e80 = c;
        let _e82 = r_1;
        let _e85 = r_1;
        let _e91 = distToRadialTicks2_(_e79, _e80, 8i, (_e82 * 0.3f), (_e85 * 0.6f), -3.1415927f, 3.1415927f);
        d_1 = min(_e78, _e91);
    }
    let _e93 = m_1;
    m_1 = (_e93 / 2f);
    let _e96 = m_1;
    if ((_e96 - (floor((_e96 / 2f)) * 2f)) >= 1f) {
        let _e104 = d_1;
        let _e105 = p_11;
        let _e106 = c;
        let _e107 = r_1;
        let _e110 = distToSquare(_e105, _e106, (_e107 * 0.5f));
        d_1 = min(_e104, _e110);
    }
    let _e112 = m_1;
    m_1 = (_e112 / 2f);
    let _e115 = m_1;
    if ((_e115 - (floor((_e115 / 2f)) * 2f)) >= 1f) {
        let _e123 = d_1;
        let _e124 = p_11;
        let _e125 = c;
        let _e126 = r_1;
        let _e129 = distToSquare(_e124, _e125, (_e126 * 0.3f));
        d_1 = min(_e123, _e129);
    }
    let _e131 = m_1;
    m_1 = (_e131 / 2f);
    let _e134 = m_1;
    if ((_e134 - (floor((_e134 / 2f)) * 2f)) >= 1f) {
        let _e142 = d_1;
        let _e143 = p_11;
        let _e144 = c;
        let _e145 = r_1;
        let _e151 = distToArc(_e143, _e144, (_e145 * 0.5f), -3.1415927f, 3.1415927f);
        d_1 = min(_e142, _e151);
    }
    let _e153 = m_1;
    m_1 = (_e153 / 2f);
    let _e156 = m_1;
    if ((_e156 - (floor((_e156 / 2f)) * 2f)) >= 1f) {
        let _e164 = d_1;
        let _e165 = p_11;
        let _e166 = c;
        let _e167 = r_1;
        let _e173 = distToArc(_e165, _e166, (_e167 * 0.3f), -3.1415927f, 3.1415927f);
        d_1 = min(_e164, _e173);
    }
    let _e175 = m_1;
    m_1 = (_e175 / 2f);
    let _e178 = m_1;
    if ((_e178 - (floor((_e178 / 3f)) * 3f)) >= 2f) {
        let _e186 = d_1;
        let _e187 = p_11;
        let _e188 = r_1;
        let _e191 = r_1;
        let _e195 = r_1;
        let _e198 = distToSquare(_e187, vec2<f32>((_e188 * 0.5f), (_e191 * 0.5f)), (_e195 * 0.1f));
        d_1 = min(_e186, _e198);
    } else {
        let _e200 = m_1;
        if ((_e200 - (floor((_e200 / 3f)) * 3f)) >= 1f) {
            let _e208 = d_1;
            let _e209 = p_11;
            let _e210 = r_1;
            let _e213 = r_1;
            let _e217 = r_1;
            let _e223 = distToArc(_e209, vec2<f32>((_e210 * 0.5f), (_e213 * 0.5f)), (_e217 * 0.1f), -3.1415927f, 3.1415927f);
            d_1 = min(_e208, _e223);
        }
    }
    let _e225 = m_1;
    m_1 = (_e225 / 3f);
    let _e228 = m_1;
    if ((_e228 - (floor((_e228 / 3f)) * 3f)) >= 2f) {
        let _e236 = d_1;
        let _e237 = p_11;
        let _e238 = r_1;
        let _e243 = r_1;
        let _e246 = distToSquare(_e237, vec2<f32>((_e238 * 0.8f), 0f), (_e243 * 0.1f));
        d_1 = min(_e236, _e246);
    } else {
        let _e248 = m_1;
        if ((_e248 - (floor((_e248 / 3f)) * 3f)) >= 1f) {
            let _e256 = d_1;
            let _e257 = p_11;
            let _e258 = r_1;
            let _e263 = r_1;
            let _e269 = distToArc(_e257, vec2<f32>((_e258 * 0.8f), 0f), (_e263 * 0.1f), -3.1415927f, 3.1415927f);
            d_1 = min(_e256, _e269);
        }
    }
    let _e271 = m_1;
    m_1 = (_e271 / 3f);
    let _e274 = d_1;
    return _e274;
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

fn response(d_2: f32, thickness: f32, blur: f32) -> f32 {
    var d_3: f32;
    var thickness_1: f32;
    var blur_1: f32;

    d_3 = d_2;
    thickness_1 = thickness;
    blur_1 = blur;
    let _e12 = thickness_1;
    let _e13 = thickness_1;
    let _e14 = blur_1;
    let _e16 = d_3;
    return pow(smoothstep(_e12, (_e13 + _e14), _e16), 0.3f);
}

fn tf(m_2: mat3x3<f32>, u: vec2<f32>) -> vec2<f32> {
    var m_3: mat3x3<f32>;
    var u_1: vec2<f32>;

    m_3 = m_2;
    u_1 = u;
    let _e10 = m_3;
    let _e11 = u_1;
    return (_e10 * vec3<f32>(_e11.x, _e11.y, 1f)).xy;
}

fn targetLine(uv: vec2<f32>, outPos: vec2<f32>, count: i32, randomSeed: f32, thickness_2: f32, color: vec4<f32>, glow: f32, modelTransform: mat3x3<f32>) -> vec4<f32> {
    var uv_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var count_1: i32;
    var randomSeed_1: f32;
    var thickness_3: f32;
    var color_1: vec4<f32>;
    var glow_1: f32;
    var modelTransform_1: mat3x3<f32>;
    var invModelTransform: mat3x3<f32>;
    var u_2: vec2<f32>;
    var scale: f32;
    var n_2: f32;
    var colH: f32 = 1.65f;
    var ch: f32;
    var r_2: f32;
    var fy: f32;
    var idx: f32;
    var d_4: f32 = 10000000000f;
    var pm: f32 = 1f;
    var dk: i32 = -1i;
    var cidx: f32;
    var rel: vec2<f32>;
    var m_4: f32;
    var parts: f32;
    var b_3: f32;
    var local: f32;
    var local_1: f32;
    var blur_2: f32;
    var k: f32;
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
    randomSeed_1 = randomSeed;
    thickness_3 = thickness_2;
    color_1 = color;
    glow_1 = glow;
    modelTransform_1 = modelTransform;
    let _e22 = modelTransform_1;
    invModelTransform = _naga_inverse_3x3_f32(_e22);
    let _e25 = invModelTransform;
    let _e26 = uv_1;
    let _e27 = tf(_e25, _e26);
    u_2 = _e27;
    let _e31 = invModelTransform[0];
    scale = length(_e31.xy);
    let _e35 = thickness_3;
    let _e40 = scale;
    thickness_3 = ((pow(_e35, 2f) * 0.25f) * _e40);
    let _e42 = count_1;
    n_2 = f32(max(_e42, 1i));
    let _e49 = colH;
    let _e50 = n_2;
    ch = (_e49 / _e50);
    let _e53 = ch;
    r_2 = (_e53 * 0.56f);
    let _e57 = u_2;
    let _e59 = ch;
    let _e61 = n_2;
    fy = ((_e57.y / _e59) + ((_e61 - 1f) * 0.5f));
    let _e68 = fy;
    idx = floor((_e68 + 0.5f));
    loop {
        let _e80 = dk;
        if !((_e80 <= 1i)) {
            break;
        }
        {
            let _e87 = idx;
            let _e88 = dk;
            cidx = (_e87 + f32(_e88));
            let _e92 = cidx;
            let _e95 = cidx;
            let _e96 = n_2;
            if ((_e92 < 0f) || (_e95 > (_e96 - 1f))) {
                continue;
            }
            let _e101 = u_2;
            let _e103 = fy;
            let _e104 = cidx;
            let _e106 = ch;
            rel = vec2<f32>(_e101.x, ((_e103 - _e104) * _e106));
            m_4 = 0f;
            parts = 0f;
            let _e115 = cidx;
            let _e122 = randomSeed_1;
            b_3 = fract((sin((((_e115 * 12.9898f) + 78.233f) + (_e122 * 37.719f))) * 43758.547f));
            let _e130 = b_3;
            let _e132 = pm;
            if (_e130 < (0.55f * _e132)) {
                {
                    let _e135 = m_4;
                    m_4 = (_e135 + 1f);
                    let _e138 = parts;
                    parts = (_e138 + 1f);
                }
            }
            let _e141 = cidx;
            let _e148 = randomSeed_1;
            b_3 = fract((sin((((_e141 * 12.9898f) + 156.466f) + (_e148 * 37.719f))) * 43758.547f));
            let _e156 = b_3;
            let _e158 = pm;
            if (_e156 < (0.15f * _e158)) {
                {
                    let _e161 = m_4;
                    m_4 = (_e161 + 2f);
                    let _e164 = parts;
                    parts = (_e164 + 1f);
                }
            }
            let _e167 = cidx;
            let _e174 = randomSeed_1;
            b_3 = fract((sin((((_e167 * 12.9898f) + 234.699f) + (_e174 * 37.719f))) * 43758.547f));
            let _e182 = b_3;
            let _e184 = pm;
            if (_e182 < (0.2f * _e184)) {
                {
                    let _e187 = m_4;
                    m_4 = (_e187 + 4f);
                    let _e190 = parts;
                    parts = (_e190 + 1f);
                }
            }
            let _e193 = cidx;
            let _e200 = randomSeed_1;
            b_3 = fract((sin((((_e193 * 12.9898f) + 312.932f) + (_e200 * 37.719f))) * 43758.547f));
            let _e208 = b_3;
            let _e210 = pm;
            if (_e208 < (0.22f * _e210)) {
                {
                    let _e213 = m_4;
                    m_4 = (_e213 + 8f);
                    let _e216 = parts;
                    parts = (_e216 + 1f);
                }
            }
            let _e219 = cidx;
            let _e226 = randomSeed_1;
            b_3 = fract((sin((((_e219 * 12.9898f) + 391.165f) + (_e226 * 37.719f))) * 43758.547f));
            let _e234 = b_3;
            let _e236 = pm;
            if (_e234 < (0.22f * _e236)) {
                {
                    let _e239 = m_4;
                    m_4 = (_e239 + 16f);
                    let _e242 = parts;
                    parts = (_e242 + 1f);
                }
            }
            let _e245 = cidx;
            let _e252 = randomSeed_1;
            b_3 = fract((sin((((_e245 * 12.9898f) + 469.398f) + (_e252 * 37.719f))) * 43758.547f));
            let _e260 = b_3;
            let _e262 = pm;
            if (_e260 < (0.35f * _e262)) {
                {
                    let _e265 = m_4;
                    m_4 = (_e265 + 32f);
                    let _e268 = parts;
                    parts = (_e268 + 1f);
                }
            }
            let _e271 = cidx;
            let _e278 = randomSeed_1;
            b_3 = fract((sin((((_e271 * 12.9898f) + 547.631f) + (_e278 * 37.719f))) * 43758.547f));
            let _e286 = b_3;
            let _e288 = pm;
            if (_e286 < (0.35f * _e288)) {
                {
                    let _e291 = m_4;
                    m_4 = (_e291 + 64f);
                    let _e294 = parts;
                    parts = (_e294 + 1f);
                }
            }
            let _e297 = cidx;
            let _e304 = randomSeed_1;
            b_3 = fract((sin((((_e297 * 12.9898f) + 625.864f) + (_e304 * 37.719f))) * 43758.547f));
            let _e312 = b_3;
            let _e314 = pm;
            if (_e312 < (0.3f * _e314)) {
                let _e317 = m_4;
                let _e319 = b_3;
                let _e321 = pm;
                if (_e319 < (0.15f * _e321)) {
                    local = 2f;
                } else {
                    local = 1f;
                }
                let _e327 = local;
                m_4 = (_e317 + (128f * _e327));
            }
            let _e330 = cidx;
            let _e337 = randomSeed_1;
            b_3 = fract((sin((((_e330 * 12.9898f) + 704.09705f) + (_e337 * 37.719f))) * 43758.547f));
            let _e345 = b_3;
            let _e347 = pm;
            if (_e345 < (0.3f * _e347)) {
                let _e350 = m_4;
                let _e352 = b_3;
                let _e354 = pm;
                if (_e352 < (0.15f * _e354)) {
                    local_1 = 2f;
                } else {
                    local_1 = 1f;
                }
                let _e360 = local_1;
                m_4 = (_e350 + (384f * _e360));
            }
            let _e363 = parts;
            if (_e363 < 1f) {
                let _e366 = m_4;
                m_4 = (_e366 + 33f);
            }
            let _e369 = d_4;
            let _e370 = rel;
            let _e374 = r_2;
            let _e375 = m_4;
            let _e376 = distToTarget7_(_e370, vec2<f32>(0f, 0f), _e374, _e375);
            d_4 = min(_e369, _e376);
        }
        continuing {
            let _e84 = dk;
            dk = (_e84 + 1i);
        }
    }
    let _e378 = glow_1;
    blur_2 = _e378;
    let _e380 = d_4;
    let _e381 = thickness_3;
    let _e382 = blur_2;
    let _e385 = scale;
    let _e387 = response(_e380, _e381, ((_e382 * 0.2f) * _e385));
    k = _e387;
    let _e391 = blur_2;
    let _e399 = k;
    gg = ((0.025f * max(0f, ((_e391 * 100f) - 50f))) * pow((1f - _e399), 10f));
    let _e407 = blur_2;
    addK = smoothstep(0.5f, 1f, _e407);
    let _e410 = uv_1;
    let _e414 = global.U[0];
    let _e417 = uv_1;
    let _e426 = textureSample(t_source, samp, ((vec2<f32>((_e410.x / _e414.x), _e417.y) / vec2(2f)) + vec2(0.5f)));
    bkgCol = _e426;
    let _e428 = color_1;
    let _e430 = gg;
    let _e431 = gg;
    let _e432 = gg;
    let _e435 = gg;
    shapeRgb = ((_e428.xyz + vec3<f32>(_e430, _e431, _e432)) * (_e435 + 1f));
    let _e440 = bkgCol;
    let _e441 = shapeRgb;
    let _e442 = color_1;
    let _e445 = k;
    let _e452 = mergeColor(_e440, vec4<f32>(_e441.x, _e441.y, _e441.z, (_e442.w * (1f - _e445))));
    overCol = _e452;
    let _e454 = bkgCol;
    let _e456 = shapeRgb;
    let _e457 = color_1;
    let _e460 = bkgCol;
    let _e464 = color_1;
    addRgb = mix(_e454.xyz, _e456, vec3((_e457.w + ((1f - _e460.w) * (1f - _e464.w)))));
    let _e472 = addRgb;
    let _e474 = k;
    let _e477 = bkgCol;
    let _e479 = bkgCol;
    let _e482 = ((_e472 * (1f - _e474)) + (_e477.xyz * _e479.w));
    let _e484 = bkgCol;
    let _e486 = color_1;
    let _e489 = k;
    addCol = vec4<f32>(_e482.x, _e482.y, _e482.z, min(1f, (_e484.w + (_e486.w * (1f - _e489)))));
    let _e499 = overCol;
    let _e500 = addCol;
    let _e501 = addK;
    outCol = mix(_e499, _e500, vec4(_e501));
    let _e505 = outCol;
    return _e505;
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
    let _e75 = global.U[7];
    let _e79 = global.U[8];
    let _e82 = global.U[9];
    let _e86 = global.U[10];
    let _e87 = _e86.xyz;
    let _e90 = global.U[11];
    let _e91 = _e90.xyz;
    let _e94 = global.U[12];
    let _e95 = _e94.xyz;
    let _e109 = targetLine((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e9.x, _e9.y, _e9.z), vec3<f32>(_e13.x, _e13.y, _e13.z), vec3<f32>(_e17.x, _e17.y, _e17.z))) * vec3<f32>(_e44.x, _e44.y, 1f)).xy, (((_e51 - vec2(0.5f)) * 2f) * vec2<f32>(_e59.x, 1f)), i32(_e66.x), _e71.x, _e75.x, _e79, _e82.x, mat3x3<f32>(vec3<f32>(_e87.x, _e87.y, _e87.z), vec3<f32>(_e91.x, _e91.y, _e91.z), vec3<f32>(_e95.x, _e95.y, _e95.z)));
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
