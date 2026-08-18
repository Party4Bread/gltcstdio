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

const SIERPINSKI_SLOPE: f32 = 1.7320508f;

var<private> v_uv_1: vec2<f32>;
var<private> fragColor: vec4<f32>;
@group(0) @binding(0) 
var<uniform> global: Params;
@group(0) @binding(1) 
var samp: sampler;
@group(0) @binding(2) 
var t_source: texture_2d<f32>;

fn inTriangle(p: vec2<f32>, a: vec2<f32>, b: vec2<f32>, c: vec2<f32>) -> bool {
    var p_1: vec2<f32>;
    var a_1: vec2<f32>;
    var b_1: vec2<f32>;
    var c_1: vec2<f32>;
    var e0_: vec2<f32>;
    var e1_: vec2<f32>;
    var e2_: vec2<f32>;
    var v0_: vec2<f32>;
    var v1_: vec2<f32>;
    var v2_: vec2<f32>;
    var s: f32;

    p_1 = p;
    a_1 = a;
    b_1 = b;
    c_1 = c;
    let _e15 = b_1;
    let _e16 = a_1;
    e0_ = (_e15 - _e16);
    let _e19 = c_1;
    let _e20 = b_1;
    e1_ = (_e19 - _e20);
    let _e23 = a_1;
    let _e24 = c_1;
    e2_ = (_e23 - _e24);
    let _e27 = p_1;
    let _e28 = a_1;
    v0_ = (_e27 - _e28);
    let _e31 = p_1;
    let _e32 = b_1;
    v1_ = (_e31 - _e32);
    let _e35 = p_1;
    let _e36 = c_1;
    v2_ = (_e35 - _e36);
    let _e39 = e0_;
    let _e41 = e2_;
    let _e44 = e0_;
    let _e46 = e2_;
    s = sign(((_e39.x * _e41.y) - (_e44.y * _e46.x)));
    let _e52 = s;
    let _e53 = v0_;
    let _e55 = e0_;
    let _e58 = v0_;
    let _e60 = e0_;
    let _e67 = s;
    let _e68 = v1_;
    let _e70 = e1_;
    let _e73 = v1_;
    let _e75 = e1_;
    let _e83 = s;
    let _e84 = v2_;
    let _e86 = e2_;
    let _e89 = v2_;
    let _e91 = e2_;
    return ((((_e52 * ((_e53.x * _e55.y) - (_e58.y * _e60.x))) > 0f) && ((_e67 * ((_e68.x * _e70.y) - (_e73.y * _e75.x))) > 0f)) && ((_e83 * ((_e84.x * _e86.y) - (_e89.y * _e91.x))) > 0f));
}

fn inTriangle_1(pos: vec2<f32>, root: vec2<f32>, side: f32, up: bool) -> bool {
    var pos_1: vec2<f32>;
    var root_1: vec2<f32>;
    var side_1: f32;
    var up_1: bool;
    var halfSide: f32;

    pos_1 = pos;
    root_1 = root;
    side_1 = side;
    up_1 = up;
    let _e15 = side_1;
    halfSide = (_e15 * 0.5f);
    let _e19 = pos_1;
    let _e21 = root_1;
    let _e23 = halfSide;
    let _e26 = pos_1;
    let _e28 = root_1;
    let _e30 = halfSide;
    let _e34 = pos_1;
    let _e36 = root_1;
    let _e40 = pos_1;
    let _e42 = root_1;
    let _e44 = halfSide;
    if ((((_e19.x > (_e21.x + _e23)) || (_e26.x < (_e28.x - _e30))) || (_e34.y < _e36.y)) || (_e40.y > (_e42.y + (_e44 * SIERPINSKI_SLOPE)))) {
        {
            return false;
        }
    }
    let _e50 = up_1;
    if _e50 {
        {
            let _e51 = pos_1;
            let _e53 = root_1;
            if (_e51.x < _e53.x) {
                {
                    let _e56 = pos_1;
                    let _e58 = root_1;
                    let _e61 = halfSide;
                    let _e64 = pos_1;
                    let _e66 = root_1;
                    return ((((_e56.x - _e58.x) + _e61) * SIERPINSKI_SLOPE) > (_e64.y - _e66.y));
                }
            } else {
                {
                    let _e70 = root_1;
                    let _e72 = halfSide;
                    let _e74 = pos_1;
                    let _e78 = pos_1;
                    let _e80 = root_1;
                    return ((((_e70.x + _e72) - _e74.x) * SIERPINSKI_SLOPE) > (_e78.y - _e80.y));
                }
            }
        }
    } else {
        {
            let _e84 = pos_1;
            let _e86 = root_1;
            if (_e84.x < _e86.x) {
                {
                    let _e89 = halfSide;
                    let _e90 = pos_1;
                    let _e92 = root_1;
                    let _e95 = halfSide;
                    let _e99 = pos_1;
                    let _e101 = root_1;
                    return (((_e89 - ((_e90.x - _e92.x) + _e95)) * SIERPINSKI_SLOPE) < (_e99.y - _e101.y));
                }
            } else {
                {
                    let _e105 = halfSide;
                    let _e106 = root_1;
                    let _e108 = halfSide;
                    let _e110 = pos_1;
                    let _e115 = pos_1;
                    let _e117 = root_1;
                    return (((_e105 - ((_e106.x + _e108) - _e110.x)) * SIERPINSKI_SLOPE) < (_e115.y - _e117.y));
                }
            }
        }
    }
}

fn tf(m: mat3x3<f32>, u: vec2<f32>) -> vec2<f32> {
    var m_1: mat3x3<f32>;
    var u_1: vec2<f32>;

    m_1 = m;
    u_1 = u;
    let _e11 = m_1;
    let _e12 = u_1;
    return (_e11 * vec3<f32>(_e12.x, _e12.y, 1f)).xy;
}

fn sierpinski(pos_2: vec2<f32>, outPos: vec2<f32>, iterations: i32, dampening: f32, modelTransform: mat3x3<f32>, viewTransform: mat3x3<f32>) -> vec4<f32> {
    var pos_3: vec2<f32>;
    var outPos_1: vec2<f32>;
    var iterations_1: i32;
    var dampening_1: f32;
    var modelTransform_1: mat3x3<f32>;
    var viewTransform_1: mat3x3<f32>;
    var shapePos: vec2<f32>;
    var size: f32 = 1f;
    var halfSide_1: f32;
    var root_2: vec2<f32>;
    var inside: f32 = 0f;
    var i: i32 = 0i;
    var quarterSide: f32;
    var dx: vec2<f32>;
    var d: f32 = 1f;
    var u_2: vec2<f32>;

    pos_3 = pos_2;
    outPos_1 = outPos;
    iterations_1 = iterations;
    dampening_1 = dampening;
    modelTransform_1 = modelTransform;
    viewTransform_1 = viewTransform;
    let _e19 = modelTransform_1;
    let _e21 = pos_3;
    let _e22 = tf(_naga_inverse_3x3_f32(_e19), _e21);
    shapePos = _e22;
    let _e26 = size;
    halfSide_1 = (_e26 * 0.5f);
    let _e33 = size;
    root_2 = vec2<f32>(0f, (-0.4330127f * _e33));
    let _e39 = shapePos;
    let _e40 = root_2;
    let _e41 = size;
    let _e43 = inTriangle_1(_e39, _e40, _e41, true);
    if _e43 {
        {
            inside = 1f;
            loop {
                let _e47 = i;
                let _e48 = iterations_1;
                if !((_e47 < _e48)) {
                    break;
                }
                {
                    let _e54 = shapePos;
                    let _e55 = root_2;
                    let _e56 = size;
                    let _e60 = inTriangle_1(_e54, _e55, (_e56 * 0.5f), false);
                    if _e60 {
                        {
                            inside = 0f;
                            break;
                        }
                    }
                    let _e62 = halfSide_1;
                    quarterSide = (_e62 * 0.5f);
                    let _e66 = quarterSide;
                    dx = vec2<f32>(_e66, 0f);
                    let _e70 = shapePos;
                    let _e71 = root_2;
                    let _e72 = dx;
                    let _e74 = halfSide_1;
                    let _e76 = inTriangle_1(_e70, (_e71 - _e72), _e74, true);
                    if _e76 {
                        {
                            let _e77 = root_2;
                            let _e78 = dx;
                            root_2 = (_e77 - _e78);
                        }
                    } else {
                        let _e80 = shapePos;
                        let _e81 = root_2;
                        let _e82 = dx;
                        let _e84 = halfSide_1;
                        let _e86 = inTriangle_1(_e80, (_e81 + _e82), _e84, true);
                        if _e86 {
                            {
                                let _e87 = root_2;
                                let _e88 = dx;
                                root_2 = (_e87 + _e88);
                            }
                        } else {
                            {
                                let _e90 = root_2;
                                let _e92 = quarterSide;
                                root_2 = (_e90 + vec2<f32>(0f, (_e92 * SIERPINSKI_SLOPE)));
                            }
                        }
                    }
                    let _e96 = halfSide_1;
                    size = _e96;
                    let _e97 = quarterSide;
                    halfSide_1 = _e97;
                }
                continuing {
                    let _e51 = i;
                    i = (_e51 + 1i);
                }
            }
        }
    }
    let _e100 = dampening_1;
    if (_e100 < 0f) {
        let _e104 = dampening_1;
        let _e106 = pos_3;
        d = (1f + (_e104 * min(1f, length(_e106))));
    } else {
        let _e111 = dampening_1;
        if (_e111 > 0f) {
            let _e115 = dampening_1;
            let _e118 = pos_3;
            d = (1f - (_e115 * (1f - min(1f, length(_e118)))));
        }
    }
    let _e124 = pos_3;
    let _e125 = viewTransform_1;
    let _e126 = pos_3;
    let _e127 = tf(_e125, _e126);
    let _e128 = inside;
    let _e129 = d;
    u_2 = mix(_e124, _e127, vec2((_e128 * _e129)));
    let _e134 = u_2;
    let _e138 = global.U[0];
    let _e141 = u_2;
    let _e150 = textureSample(t_source, samp, ((vec2<f32>((_e134.x / _e138.x), _e141.y) / vec2(2f)) + vec2(0.5f)));
    return _e150;
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
    let _e67 = global.U[5];
    let _e72 = global.U[6];
    let _e76 = global.U[7];
    let _e77 = _e76.xyz;
    let _e80 = global.U[8];
    let _e81 = _e80.xyz;
    let _e84 = global.U[9];
    let _e85 = _e84.xyz;
    let _e101 = global.U[1];
    let _e102 = _e101.xyz;
    let _e105 = global.U[2];
    let _e106 = _e105.xyz;
    let _e109 = global.U[3];
    let _e110 = _e109.xyz;
    let _e124 = sierpinski((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e10.x, _e10.y, _e10.z), vec3<f32>(_e14.x, _e14.y, _e14.z), vec3<f32>(_e18.x, _e18.y, _e18.z))) * vec3<f32>(_e45.x, _e45.y, 1f)).xy, (((_e52 - vec2(0.5f)) * 2f) * vec2<f32>(_e60.x, 1f)), i32(_e67.x), _e72.x, mat3x3<f32>(vec3<f32>(_e77.x, _e77.y, _e77.z), vec3<f32>(_e81.x, _e81.y, _e81.z), vec3<f32>(_e85.x, _e85.y, _e85.z)), mat3x3<f32>(vec3<f32>(_e102.x, _e102.y, _e102.z), vec3<f32>(_e106.x, _e106.y, _e106.z), vec3<f32>(_e110.x, _e110.y, _e110.z)));
    fragColor = _e124;
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
