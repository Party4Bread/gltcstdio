struct Params {
    U: array<vec4<f32>, 14>,
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

fn hueToRgb(p: f32, q: f32, h: f32) -> f32 {
    var p_1: f32;
    var q_1: f32;
    var h_1: f32;

    p_1 = p;
    q_1 = q;
    h_1 = h;
    let _e11 = h_1;
    if (_e11 < 0f) {
        let _e14 = h_1;
        h_1 = (_e14 + 1f);
    }
    let _e17 = h_1;
    if (_e17 > 1f) {
        let _e20 = h_1;
        h_1 = (_e20 - 1f);
    }
    let _e24 = h_1;
    if ((6f * _e24) < 1f) {
        {
            let _e28 = p_1;
            let _e29 = q_1;
            let _e30 = p_1;
            let _e34 = h_1;
            return (_e28 + (((_e29 - _e30) * 6f) * _e34));
        }
    }
    let _e38 = h_1;
    if ((2f * _e38) < 1f) {
        {
            let _e42 = q_1;
            return _e42;
        }
    }
    let _e44 = h_1;
    if ((3f * _e44) < 2f) {
        {
            let _e48 = p_1;
            let _e49 = q_1;
            let _e50 = p_1;
            let _e57 = h_1;
            return (_e48 + (((_e49 - _e50) * 6f) * (0.6666667f - _e57)));
        }
    }
    let _e61 = p_1;
    return _e61;
}

fn hslToRgb(inc: vec4<f32>) -> vec4<f32> {
    var inc_1: vec4<f32>;
    var h_2: f32;
    var s: f32;
    var l: f32;
    var q_2: f32 = 0f;
    var p_2: f32;
    var r: f32;
    var g: f32;
    var b: f32;
    var outc: vec4<f32>;

    inc_1 = inc;
    let _e7 = inc_1;
    h_2 = (_e7.x - (floor((_e7.x / 360f)) * 360f));
    let _e15 = h_2;
    h_2 = (_e15 / 360f);
    let _e18 = inc_1;
    s = _e18.y;
    let _e21 = inc_1;
    l = _e21.z;
    let _e26 = l;
    if (_e26 < 0.5f) {
        let _e29 = l;
        let _e31 = s;
        q_2 = (_e29 * (1f + _e31));
    } else {
        let _e34 = l;
        let _e35 = s;
        let _e37 = s;
        let _e38 = l;
        q_2 = ((_e34 + _e35) - (_e37 * _e38));
    }
    let _e42 = l;
    let _e44 = q_2;
    p_2 = ((2f * _e42) - _e44);
    let _e48 = p_2;
    let _e49 = q_2;
    let _e50 = h_2;
    let _e55 = hueToRgb(_e48, _e49, (_e50 + 0.33333334f));
    r = max(0f, _e55);
    let _e59 = p_2;
    let _e60 = q_2;
    let _e61 = h_2;
    let _e62 = hueToRgb(_e59, _e60, _e61);
    g = max(0f, _e62);
    let _e66 = p_2;
    let _e67 = q_2;
    let _e68 = h_2;
    let _e73 = hueToRgb(_e66, _e67, (_e68 - 0.33333334f));
    b = max(0f, _e73);
    let _e78 = r;
    outc.x = min(_e78, 1f);
    let _e82 = g;
    outc.y = min(_e82, 1f);
    let _e86 = b;
    outc.z = min(_e86, 1f);
    let _e90 = inc_1;
    outc.w = _e90.w;
    let _e92 = outc;
    return _e92;
}

fn rgbToHcv(RGB: vec4<f32>) -> vec4<f32> {
    var RGB_1: vec4<f32>;
    var local: vec4<f32>;
    var P: vec4<f32>;
    var local_1: vec4<f32>;
    var Q: vec4<f32>;
    var C: f32;
    var H: f32;

    RGB_1 = RGB;
    let _e7 = RGB_1;
    let _e9 = RGB_1;
    if (_e7.y < _e9.z) {
        let _e12 = RGB_1;
        let _e13 = _e12.zy;
        local = vec4<f32>(_e13.x, _e13.y, -1f, 0.6666667f);
    } else {
        let _e22 = RGB_1;
        let _e23 = _e22.yz;
        local = vec4<f32>(_e23.x, _e23.y, 0f, -0.33333334f);
    }
    let _e33 = local;
    P = _e33;
    let _e35 = RGB_1;
    let _e37 = P;
    if (_e35.x < _e37.x) {
        let _e40 = P;
        let _e41 = _e40.xyw;
        let _e42 = RGB_1;
        local_1 = vec4<f32>(_e41.x, _e41.y, _e41.z, _e42.x);
    } else {
        let _e48 = RGB_1;
        let _e50 = P;
        let _e51 = _e50.yzx;
        local_1 = vec4<f32>(_e48.x, _e51.x, _e51.y, _e51.z);
    }
    let _e57 = local_1;
    Q = _e57;
    let _e59 = Q;
    let _e61 = Q;
    let _e63 = Q;
    C = (_e59.x - min(_e61.w, _e63.y));
    let _e68 = Q;
    let _e70 = Q;
    let _e74 = C;
    let _e79 = Q;
    H = abs((((_e68.w - _e70.y) / ((6f * _e74) + 0.0000000001f)) + _e79.z));
    let _e84 = H;
    let _e85 = C;
    let _e86 = Q;
    let _e88 = RGB_1;
    return vec4<f32>(_e84, _e85, _e86.x, _e88.w);
}

fn rgbToHsl(RGB_2: vec4<f32>) -> vec4<f32> {
    var RGB_3: vec4<f32>;
    var HCV: vec4<f32>;
    var L: f32;
    var S: f32;

    RGB_3 = RGB_2;
    let _e7 = RGB_3;
    let _e8 = rgbToHcv(_e7);
    HCV = _e8;
    let _e10 = HCV;
    let _e12 = HCV;
    L = (_e10.z - (_e12.y * 0.5f));
    let _e18 = HCV;
    let _e21 = L;
    S = (_e18.y / ((1f - abs(((_e21 * 2f) - 1f))) + 0.000001f));
    let _e32 = HCV;
    let _e36 = S;
    let _e37 = L;
    let _e38 = RGB_3;
    return vec4<f32>((_e32.x * 360f), _e36, _e37, _e38.w);
}

fn csColorShift(color: vec4<f32>, delta: vec2<f32>, colorVariability: f32) -> vec4<f32> {
    var color_1: vec4<f32>;
    var delta_1: vec2<f32>;
    var colorVariability_1: f32;
    var deltaHue: f32;
    var hsl: vec4<f32>;

    color_1 = color;
    delta_1 = delta;
    colorVariability_1 = colorVariability;
    let _e11 = delta_1;
    let _e13 = colorVariability_1;
    deltaHue = ((_e11.x * _e13) * 2f);
    let _e18 = color_1;
    let _e19 = rgbToHsl(_e18);
    hsl = _e19;
    let _e22 = hsl;
    let _e24 = deltaHue;
    hsl.x = (_e22.x + (_e24 * 180f));
    let _e29 = hsl;
    let _e33 = delta_1;
    hsl.z = (_e29.z * (1f + (0.3f * _e33.y)));
    let _e38 = hsl;
    let _e39 = hslToRgb(_e38);
    return _e39;
}

fn rand2rel(co: vec2<f32>) -> vec2<f32> {
    var co_1: vec2<f32>;
    var x: f32;
    var y: f32;

    co_1 = co;
    let _e7 = co_1;
    x = fract((sin(dot(_e7.xy, vec2<f32>(12.9898f, 78.233f))) * 43758.547f));
    let _e18 = x;
    let _e19 = co_1;
    y = fract((sin(dot(vec2<f32>(_e18, _e19.x), vec2<f32>(12.9898f, 78.233f))) * 43758.547f));
    let _e31 = x;
    let _e32 = y;
    return (vec2<f32>(_e31, _e32) - vec2<f32>(0.5f, 0.5f));
}

fn tf(m: mat3x3<f32>, u: vec2<f32>) -> vec2<f32> {
    var m_1: mat3x3<f32>;
    var u_1: vec2<f32>;

    m_1 = m;
    u_1 = u;
    let _e9 = m_1;
    let _e10 = u_1;
    return (_e9 * vec3<f32>(_e10.x, _e10.y, 1f)).xy;
}

fn circleStreaks(pos: vec2<f32>, outPos: vec2<f32>, color1_: vec4<f32>, color2_: vec4<f32>, regularity: f32, radius: f32, radiusVariability: f32, colorVariability_2: f32, modelTransform: mat3x3<f32>) -> vec4<f32> {
    var pos_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var color1_1: vec4<f32>;
    var color2_1: vec4<f32>;
    var regularity_1: f32;
    var radius_1: f32;
    var radiusVariability_1: f32;
    var colorVariability_3: f32;
    var modelTransform_1: mat3x3<f32>;
    var u_2: vec2<f32>;
    var variability: f32;
    var v: vec2<f32>;
    var j: i32 = -2i;
    var jEnd: i32 = 2i;
    var inCircle: bool = false;
    var shadowed: bool = false;
    var shadowingRnd: vec2<f32> = vec2(0f);
    var shadowingDisplacedPoint: vec2<f32> = vec2<f32>(0f, 100000000000000000000f);
    var minDistance: f32 = 100000f;
    var i: i32;
    var point: vec2<f32>;
    var rnd: vec2<f32>;
    var displace: vec2<f32>;
    var displacedPoint: vec2<f32>;
    var distance: f32;
    var r_1: f32;
    var inRadius: bool;
    var baseColor: vec4<f32>;
    var local_2: vec4<f32>;

    pos_1 = pos;
    outPos_1 = outPos;
    color1_1 = color1_;
    color2_1 = color2_;
    regularity_1 = regularity;
    radius_1 = radius;
    radiusVariability_1 = radiusVariability;
    colorVariability_3 = colorVariability_2;
    modelTransform_1 = modelTransform;
    let _e23 = modelTransform_1;
    let _e25 = pos_1;
    let _e26 = tf(_naga_inverse_3x3_f32(_e23), _e25);
    u_2 = _e26;
    let _e29 = regularity_1;
    variability = (1f - _e29);
    let _e32 = u_2;
    let _e36 = u_2;
    v = floor(vec2<f32>((_e32.x + 0.5f), (_e36.y + 0.5f)));
    loop {
        let _e61 = j;
        let _e62 = jEnd;
        if !((_e61 <= _e62)) {
            break;
        }
        {
            i = -2i;
            loop {
                let _e68 = i;
                if !((_e68 <= 2i)) {
                    break;
                }
                {
                    let _e75 = v;
                    let _e77 = i;
                    let _e80 = v;
                    let _e82 = j;
                    point = vec2<f32>((_e75.x + f32(_e77)), (_e80.y + f32(_e82)));
                    let _e87 = point;
                    let _e88 = rand2rel(_e87);
                    rnd = _e88;
                    let _e90 = rnd;
                    let _e91 = variability;
                    displace = ((_e90 * _e91) * 2f);
                    let _e96 = point;
                    let _e97 = displace;
                    displacedPoint = (_e96 + _e97);
                    let _e100 = shadowingDisplacedPoint;
                    let _e102 = displacedPoint;
                    if (_e100.y > _e102.y) {
                        {
                            let _e105 = displacedPoint;
                            let _e106 = u_2;
                            distance = length((_e105 - _e106));
                            let _e110 = radius_1;
                            let _e112 = displace;
                            let _e114 = radiusVariability_1;
                            r_1 = (_e110 * (1f + (_e112.x * _e114)));
                            let _e119 = distance;
                            let _e120 = r_1;
                            inRadius = (_e119 < _e120);
                            let _e123 = displacedPoint;
                            let _e125 = u_2;
                            let _e129 = r_1;
                            let _e131 = inRadius;
                            let _e132 = displacedPoint;
                            let _e134 = u_2;
                            if ((abs((_e123.x - _e125.x)) < _e129) && (_e131 || (_e132.y > _e134.y))) {
                                {
                                    let _e139 = minDistance;
                                    let _e140 = distance;
                                    minDistance = min(_e139, _e140);
                                    let _e142 = displacedPoint;
                                    shadowingDisplacedPoint = _e142;
                                    let _e143 = rnd;
                                    shadowingRnd = _e143;
                                    shadowed = true;
                                    let _e145 = inRadius;
                                    inCircle = _e145;
                                }
                            }
                        }
                    }
                }
                continuing {
                    let _e72 = i;
                    i = (_e72 + 1i);
                }
            }
            let _e146 = shadowed;
            let _e148 = jEnd;
            if (!(_e146) && (_e148 < 100i)) {
                let _e152 = jEnd;
                jEnd = (_e152 + 1i);
            }
            let _e155 = j;
            j = (_e155 + 1i);
        }
    }
    let _e158 = shadowed;
    if _e158 {
        {
            let _e159 = color1_1;
            let _e160 = shadowingRnd;
            let _e161 = colorVariability_3;
            let _e162 = csColorShift(_e159, _e160, _e161);
            baseColor = _e162;
            let _e164 = inCircle;
            if _e164 {
                let _e165 = baseColor;
                local_2 = _e165;
            } else {
                let _e166 = baseColor;
                let _e173 = color2_1;
                let _e177 = minDistance;
                let _e181 = mix(((_e166.xyz + vec3(0.2f)) * 1.15f), _e173.xyz, vec3(min(1f, (0.5f * _e177))));
                let _e182 = baseColor;
                local_2 = vec4<f32>(_e181.x, _e181.y, _e181.z, _e182.w);
            }
            let _e189 = local_2;
            return _e189;
        }
    }
    let _e190 = color2_1;
    return _e190;
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
    let _e83 = global.U[10];
    let _e87 = global.U[11];
    let _e88 = _e87.xyz;
    let _e91 = global.U[12];
    let _e92 = _e91.xyz;
    let _e95 = global.U[13];
    let _e96 = _e95.xyz;
    let _e110 = circleStreaks((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e8.x, _e8.y, _e8.z), vec3<f32>(_e12.x, _e12.y, _e12.z), vec3<f32>(_e16.x, _e16.y, _e16.z))) * vec3<f32>(_e43.x, _e43.y, 1f)).xy, (((_e50 - vec2(0.5f)) * 2f) * vec2<f32>(_e58.x, 1f)), _e65, _e68, _e71.x, _e75.x, _e79.x, _e83.x, mat3x3<f32>(vec3<f32>(_e88.x, _e88.y, _e88.z), vec3<f32>(_e92.x, _e92.y, _e92.z), vec3<f32>(_e96.x, _e96.y, _e96.z)));
    fragColor = _e110;
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
