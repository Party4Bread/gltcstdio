struct Params {
    U: array<vec4<f32>, 15>,
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

fn getCenter(o: vec2<f32>, u: vec2<f32>) -> vec2<f32> {
    var o_1: vec2<f32>;
    var u_1: vec2<f32>;
    var a: f32;
    var b: f32;
    var c_2: f32;
    var delta: f32;
    var sqrtDelta: f32;
    var l1_: f32;
    var l2_: f32;

    o_1 = o;
    u_1 = u;
    let _e10 = o_1;
    let _e11 = o_1;
    a = (dot(_e10, _e11) - 1f);
    let _e18 = o_1;
    let _e19 = u_1;
    b = ((-2f * dot(_e18, _e19)) + 2f);
    let _e25 = u_1;
    let _e26 = u_1;
    c_2 = (dot(_e25, _e26) - 1f);
    let _e31 = b;
    let _e32 = b;
    let _e35 = a;
    let _e37 = c_2;
    delta = ((_e31 * _e32) - ((4f * _e35) * _e37));
    let _e41 = delta;
    if (_e41 >= 0f) {
        {
            let _e44 = delta;
            sqrtDelta = sqrt(_e44);
            let _e47 = b;
            let _e49 = sqrtDelta;
            let _e52 = a;
            l1_ = ((-(_e47) - _e49) / (2f * _e52));
            let _e56 = b;
            let _e58 = sqrtDelta;
            let _e61 = a;
            l2_ = ((-(_e56) + _e58) / (2f * _e61));
            let _e65 = l1_;
            let _e68 = l1_;
            if ((_e65 >= 0f) && (_e68 <= 1f)) {
                let _e72 = l1_;
                let _e73 = o_1;
                return (_e72 * _e73);
            } else {
                let _e75 = l2_;
                let _e78 = l2_;
                if ((_e75 >= 0f) && (_e78 <= 1f)) {
                    let _e82 = l2_;
                    let _e83 = o_1;
                    return (_e82 * _e83);
                }
            }
        }
    }
    return vec2<f32>(100000000000000000000f, 100000000000000000000f);
}

fn swirl(pos: vec2<f32>, outPos: vec2<f32>, modelTransform: mat3x3<f32>, centerTransform: mat3x3<f32>, intensity: f32, power: f32, dampening: f32, highFreqColor: vec4<f32>) -> vec4<f32> {
    var pos_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var modelTransform_1: mat3x3<f32>;
    var centerTransform_1: mat3x3<f32>;
    var intensity_1: f32;
    var power_1: f32;
    var dampening_1: f32;
    var highFreqColor_1: vec4<f32>;
    var u_2: vec2<f32>;
    var d: f32;
    var centerMax: vec2<f32>;
    var center: vec2<f32>;
    var d2_: f32;
    var dangle: f32;
    var ca: f32;
    var sa: f32;
    var rotated: vec2<f32>;
    var darken: f32 = 0f;
    var coord: vec2<f32>;
    var col: vec4<f32>;

    pos_1 = pos;
    outPos_1 = outPos;
    modelTransform_1 = modelTransform;
    centerTransform_1 = centerTransform;
    intensity_1 = intensity;
    power_1 = power;
    dampening_1 = dampening;
    highFreqColor_1 = highFreqColor;
    let _e22 = modelTransform_1;
    let _e24 = pos_1;
    u_2 = (_naga_inverse_3x3_f32(_e22) * vec3<f32>(_e24.x, _e24.y, 1f)).xy;
    let _e32 = u_2;
    d = length(_e32);
    let _e35 = d;
    if (_e35 >= 1f) {
        {
            let _e38 = pos_1;
            let _e42 = global.U[0];
            let _e45 = pos_1;
            let _e54 = _mirror_wrap(((vec2<f32>((_e38.x / _e42.x), _e45.y) / vec2(2f)) + vec2(0.5f)));
            let _e56 = textureSampleLevel(t_source, samp, _e54, 0f);
            return _e56;
        }
    } else {
        {
            let _e57 = centerTransform_1;
            centerMax = (_e57 * vec3<f32>(0f, 0f, 1f)).xy;
            let _e65 = centerMax;
            let _e66 = u_2;
            let _e67 = getCenter(_e65, _e66);
            center = _e67;
            let _e69 = center;
            if (_e69.x == 100000000000000000000f) {
                let _e73 = pos_1;
                let _e77 = global.U[0];
                let _e80 = pos_1;
                let _e89 = _mirror_wrap(((vec2<f32>((_e73.x / _e77.x), _e80.y) / vec2(2f)) + vec2(0.5f)));
                let _e91 = textureSampleLevel(t_source, samp, _e89, 0f);
                return _e91;
            }
            let _e92 = u_2;
            let _e93 = center;
            d2_ = length((_e92 - _e93));
            let _e101 = dampening_1;
            let _e103 = d2_;
            let _e105 = intensity_1;
            let _e107 = d2_;
            let _e108 = power_1;
            dangle = ((smoothstep(1f, mix(0.9f, -4f, _e101), _e103) * _e105) * pow(_e107, -(_e108)));
            let _e113 = dangle;
            ca = cos(_e113);
            let _e116 = dangle;
            sa = sin(_e116);
            let _e119 = u_2;
            let _e120 = center;
            u_2 = (_e119 - _e120);
            let _e122 = ca;
            let _e123 = u_2;
            let _e126 = sa;
            let _e127 = u_2;
            let _e131 = ca;
            let _e132 = u_2;
            let _e135 = sa;
            let _e136 = u_2;
            let _e141 = center;
            rotated = (vec2<f32>(((_e122 * _e123.x) - (_e126 * _e127.y)), ((_e131 * _e132.y) + (_e135 * _e136.x))) + _e141);
            let _e146 = highFreqColor_1;
            if (_e146.w != 0f) {
                {
                    let _e151 = highFreqColor_1;
                    let _e155 = d2_;
                    darken = smoothstep((0.75f * _e151.w), 0f, _e155);
                }
            }
            let _e157 = modelTransform_1;
            let _e158 = rotated;
            coord = (_e157 * vec3<f32>(_e158.x, _e158.y, 1f)).xy;
            let _e166 = coord;
            let _e170 = global.U[0];
            let _e173 = coord;
            let _e182 = _mirror_wrap(((vec2<f32>((_e166.x / _e170.x), _e173.y) / vec2(2f)) + vec2(0.5f)));
            let _e184 = textureSampleLevel(t_source, samp, _e182, 0f);
            col = _e184;
            let _e186 = col;
            let _e187 = highFreqColor_1;
            let _e188 = _e187.xyz;
            let _e189 = col;
            let _e195 = darken;
            return mix(_e186, vec4<f32>(_e188.x, _e188.y, _e188.z, _e189.w), vec4(_e195));
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
    let _e66 = global.U[5];
    let _e67 = _e66.xyz;
    let _e70 = global.U[6];
    let _e71 = _e70.xyz;
    let _e74 = global.U[7];
    let _e75 = _e74.xyz;
    let _e91 = global.U[8];
    let _e92 = _e91.xyz;
    let _e95 = global.U[9];
    let _e96 = _e95.xyz;
    let _e99 = global.U[10];
    let _e100 = _e99.xyz;
    let _e116 = global.U[11];
    let _e120 = global.U[12];
    let _e124 = global.U[13];
    let _e128 = global.U[14];
    let _e129 = swirl((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e9.x, _e9.y, _e9.z), vec3<f32>(_e13.x, _e13.y, _e13.z), vec3<f32>(_e17.x, _e17.y, _e17.z))) * vec3<f32>(_e44.x, _e44.y, 1f)).xy, (((_e51 - vec2(0.5f)) * 2f) * vec2<f32>(_e59.x, 1f)), mat3x3<f32>(vec3<f32>(_e67.x, _e67.y, _e67.z), vec3<f32>(_e71.x, _e71.y, _e71.z), vec3<f32>(_e75.x, _e75.y, _e75.z)), mat3x3<f32>(vec3<f32>(_e92.x, _e92.y, _e92.z), vec3<f32>(_e96.x, _e96.y, _e96.z), vec3<f32>(_e100.x, _e100.y, _e100.z)), _e116.x, _e120.x, _e124.x, _e128);
    fragColor = _e129;
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
