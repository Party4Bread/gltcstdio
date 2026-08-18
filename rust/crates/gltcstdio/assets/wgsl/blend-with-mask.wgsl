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
var t_mask: texture_2d<f32>;
@group(0) @binding(3) 
var t_source1_: texture_2d<f32>;
@group(0) @binding(4) 
var t_source2_: texture_2d<f32>;

fn blend(mode: i32, a: vec4<f32>, b: vec4<f32>) -> vec4<f32> {
    var mode_1: i32;
    var a_1: vec4<f32>;
    var b_1: vec4<f32>;
    var aa: vec3<f32>;
    var bb: vec3<f32>;
    var cc: vec3<f32>;
    var _sw_sel: i32;

    mode_1 = mode;
    a_1 = a;
    b_1 = b;
    let _e14 = a_1;
    aa = _e14.xyz;
    let _e17 = b_1;
    bb = _e17.xyz;
    {
        let _e21 = mode_1;
        _sw_sel = i32(_e21);
        let _e24 = _sw_sel;
        if (_e24 == 1i) {
            {
                let _e28 = aa;
                let _e29 = bb;
                cc = (_e28 + _e29);
            }
        } else {
            let _e31 = _sw_sel;
            if (_e31 == 2i) {
                {
                    let _e35 = aa;
                    let _e36 = bb;
                    cc = (_e35 * _e36);
                }
            } else {
                let _e38 = _sw_sel;
                if (_e38 == 3i) {
                    {
                        let _e42 = aa;
                        let _e43 = bb;
                        cc = (_e42 - _e43);
                    }
                } else {
                    let _e45 = _sw_sel;
                    if (_e45 == 4i) {
                        {
                            let _e49 = aa;
                            let _e50 = bb;
                            cc = abs((_e49 - _e50));
                        }
                    } else {
                        let _e53 = _sw_sel;
                        if (_e53 == 5i) {
                            {
                                let _e57 = aa;
                                let _e58 = bb;
                                cc = (_e57 / _e58);
                            }
                        } else {
                            let _e60 = _sw_sel;
                            if (_e60 == 10i) {
                                {
                                    let _e64 = a_1;
                                    let _e65 = b_1;
                                    return max(_e64, _e65);
                                }
                            } else {
                                let _e67 = _sw_sel;
                                if (_e67 == 11i) {
                                    {
                                        let _e71 = a_1;
                                        let _e72 = b_1;
                                        return min(_e71, _e72);
                                    }
                                } else {
                                    {
                                        let _e74 = b_1;
                                        return _e74;
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    let _e75 = cc;
    let _e76 = a_1;
    let _e78 = b_1;
    return vec4<f32>(_e75.x, _e75.y, _e75.z, mix(_e76.w, _e78.w, 0.5f));
}

fn luma(c: vec3<f32>) -> f32 {
    var c_1: vec3<f32>;

    c_1 = c;
    let _e11 = c_1;
    let _e15 = c_1;
    let _e20 = c_1;
    return (((0.2989f * _e11.x) + (0.587f * _e15.y)) + (0.114f * _e20.z));
}

fn tf(m: mat3x3<f32>, u: vec2<f32>) -> vec2<f32> {
    var m_1: mat3x3<f32>;
    var u_1: vec2<f32>;

    m_1 = m;
    u_1 = u;
    let _e12 = m_1;
    let _e13 = u_1;
    return (_e12 * vec3<f32>(_e13.x, _e13.y, 1f)).xy;
}

fn blendImg(pos: vec2<f32>, outPos: vec2<f32>, blendMode: i32, intensity: f32, mask_specified: i32, maskTransform: mat3x3<f32>) -> vec4<f32> {
    var pos_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var blendMode_1: i32;
    var intensity_1: f32;
    var mask_specified_1: i32;
    var maskTransform_1: mat3x3<f32>;
    var in1_: vec4<f32>;
    var in2_: vec4<f32>;
    var local: f32;
    var mask: f32;
    var blended: vec4<f32>;

    pos_1 = pos;
    outPos_1 = outPos;
    blendMode_1 = blendMode;
    intensity_1 = intensity;
    mask_specified_1 = mask_specified;
    maskTransform_1 = maskTransform;
    let _e20 = pos_1;
    let _e24 = global.U[0];
    let _e27 = pos_1;
    let _e36 = textureSample(t_source1_, samp, ((vec2<f32>((_e20.x / _e24.x), _e27.y) / vec2(2f)) + vec2(0.5f)));
    in1_ = _e36;
    let _e38 = pos_1;
    let _e42 = global.U[0];
    let _e45 = pos_1;
    let _e54 = textureSample(t_source2_, samp, ((vec2<f32>((_e38.x / _e42.x), _e45.y) / vec2(2f)) + vec2(0.5f)));
    in2_ = _e54;
    let _e56 = mask_specified_1;
    if (_e56 == 1i) {
        let _e59 = pos_1;
        let _e63 = global.U[0];
        let _e66 = pos_1;
        let _e75 = textureSample(t_mask, samp, ((vec2<f32>((_e59.x / _e63.x), _e66.y) / vec2(2f)) + vec2(0.5f)));
        let _e77 = luma(_e75.xyz);
        local = _e77;
    } else {
        local = 0.5f;
    }
    let _e80 = local;
    mask = _e80;
    let _e82 = blendMode_1;
    let _e83 = in1_;
    let _e84 = in2_;
    let _e85 = blend(_e82, _e83, _e84);
    blended = _e85;
    let _e87 = in1_;
    let _e88 = blended;
    let _e89 = mask;
    let _e90 = intensity_1;
    return mix(_e87, _e88, vec4((_e89 * _e90)));
}

fn main_1() {
    let _e10 = global.U[1];
    let _e11 = _e10.xyz;
    let _e14 = global.U[2];
    let _e15 = _e14.xyz;
    let _e18 = global.U[3];
    let _e19 = _e18.xyz;
    let _e34 = v_uv_1;
    let _e42 = global.U[0];
    let _e46 = (((_e34 - vec2(0.5f)) * 2f) * vec2<f32>(_e42.x, 1f));
    let _e53 = v_uv_1;
    let _e61 = global.U[0];
    let _e68 = global.U[6];
    let _e73 = global.U[7];
    let _e77 = global.U[4];
    let _e82 = global.U[8];
    let _e83 = _e82.xyz;
    let _e86 = global.U[9];
    let _e87 = _e86.xyz;
    let _e90 = global.U[10];
    let _e91 = _e90.xyz;
    let _e105 = blendImg((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e11.x, _e11.y, _e11.z), vec3<f32>(_e15.x, _e15.y, _e15.z), vec3<f32>(_e19.x, _e19.y, _e19.z))) * vec3<f32>(_e46.x, _e46.y, 1f)).xy, (((_e53 - vec2(0.5f)) * 2f) * vec2<f32>(_e61.x, 1f)), i32(_e68.x), _e73.x, i32(_e77.x), mat3x3<f32>(vec3<f32>(_e83.x, _e83.y, _e83.z), vec3<f32>(_e87.x, _e87.y, _e87.z), vec3<f32>(_e91.x, _e91.y, _e91.z)));
    fragColor = _e105;
    return;
}

@fragment 
fn main(@location(0) v_uv: vec2<f32>) -> FragmentOutput {
    v_uv_1 = v_uv;
    main_1();
    let _e17 = fragColor;
    return FragmentOutput(_e17);
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
