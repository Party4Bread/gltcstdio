struct Params {
    U: array<vec4<f32>, 11>,
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

fn _mirror_wrap(c: vec2<f32>) -> vec2<f32> {
    var c_1: vec2<f32>;

    c_1 = c;
    let _e9 = c_1;
    let _e11 = vec2(2f);
    return (vec2(1f) - abs(((_e9 - (floor((_e9 / _e11)) * _e11)) - vec2(1f))));
}

fn iteratedRipplesGL(pos: vec2<f32>, outPos: vec2<f32>, intensity: f32, dampening: f32, count: i32, modelTransform: mat3x3<f32>) -> vec4<f32> {
    var pos_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var intensity_1: f32;
    var dampening_1: f32;
    var count_1: i32;
    var modelTransform_1: mat3x3<f32>;
    var invM: mat3x3<f32>;
    var color: vec4<f32>;
    var u: vec2<f32>;
    var rippleCount: f32;
    var i: i32 = 0i;
    var d: f32;
    var local: f32;
    var dampen: f32;
    var dilation: f32;

    pos_1 = pos;
    outPos_1 = outPos;
    intensity_1 = intensity;
    dampening_1 = dampening;
    count_1 = count;
    modelTransform_1 = modelTransform;
    let _e18 = modelTransform_1;
    invM = _naga_inverse_3x3_f32(_e18);
    let _e21 = pos_1;
    let _e25 = global.U[0];
    let _e28 = pos_1;
    let _e37 = _mirror_wrap(((vec2<f32>((_e21.x / _e25.x), _e28.y) / vec2(2f)) + vec2(0.5f)));
    let _e39 = textureSampleLevel(t_source, samp, _e37, 0f);
    color = _e39;
    let _e41 = invM;
    let _e42 = pos_1;
    u = (_e41 * vec3<f32>(_e42.x, _e42.y, 1f)).xy;
    let _e50 = count_1;
    rippleCount = f32(_e50);
    loop {
        let _e55 = i;
        if !((_e55 < 6i)) {
            break;
        }
        {
            let _e62 = u;
            d = length(_e62);
            let _e65 = d;
            if (_e65 >= 1f) {
                {
                    let _e68 = color;
                    return _e68;
                }
            } else {
                {
                    let _e69 = dampening_1;
                    if (_e69 >= 0f) {
                        let _e73 = d;
                        let _e75 = dampening_1;
                        local = pow((1f - _e73), (_e75 * 2f));
                    } else {
                        let _e79 = d;
                        let _e80 = dampening_1;
                        local = pow(_e79, (-(_e80) * 5f));
                    }
                    let _e86 = local;
                    dampen = _e86;
                    let _e89 = intensity_1;
                    let _e90 = d;
                    let _e91 = rippleCount;
                    let _e97 = dampen;
                    dilation = (1f + ((_e89 * sin(((_e90 * _e91) * 3.1415927f))) * _e97));
                    let _e101 = u;
                    let _e102 = dilation;
                    u = (_e101 * _e102);
                }
            }
        }
        continuing {
            let _e59 = i;
            i = (_e59 + 1i);
        }
    }
    let _e104 = intensity_1;
    if (_e104 < 0f) {
        let _e107 = u;
        u = -(_e107);
    }
    let _e109 = modelTransform_1;
    let _e110 = u;
    u = (_e109 * vec3<f32>(_e110.x, _e110.y, 1f)).xy;
    let _e117 = u;
    let _e121 = global.U[0];
    let _e124 = u;
    let _e133 = _mirror_wrap(((vec2<f32>((_e117.x / _e121.x), _e124.y) / vec2(2f)) + vec2(0.5f)));
    let _e135 = textureSampleLevel(t_source, samp, _e133, 0f);
    return _e135;
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
    let _e70 = global.U[6];
    let _e74 = global.U[7];
    let _e79 = global.U[8];
    let _e80 = _e79.xyz;
    let _e83 = global.U[9];
    let _e84 = _e83.xyz;
    let _e87 = global.U[10];
    let _e88 = _e87.xyz;
    let _e102 = iteratedRipplesGL((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e9.x, _e9.y, _e9.z), vec3<f32>(_e13.x, _e13.y, _e13.z), vec3<f32>(_e17.x, _e17.y, _e17.z))) * vec3<f32>(_e44.x, _e44.y, 1f)).xy, (((_e51 - vec2(0.5f)) * 2f) * vec2<f32>(_e59.x, 1f)), _e66.x, _e70.x, i32(_e74.x), mat3x3<f32>(vec3<f32>(_e80.x, _e80.y, _e80.z), vec3<f32>(_e84.x, _e84.y, _e84.z), vec3<f32>(_e88.x, _e88.y, _e88.z)));
    fragColor = _e102;
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
