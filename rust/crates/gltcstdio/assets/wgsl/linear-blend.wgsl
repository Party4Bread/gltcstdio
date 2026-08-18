struct Params {
    U: array<vec4<f32>, 7>,
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
var t_source1_: texture_2d<f32>;
@group(0) @binding(3) 
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
    let _e13 = a_1;
    aa = _e13.xyz;
    let _e16 = b_1;
    bb = _e16.xyz;
    {
        let _e20 = mode_1;
        _sw_sel = i32(_e20);
        let _e23 = _sw_sel;
        if (_e23 == 1i) {
            {
                let _e27 = aa;
                let _e28 = bb;
                cc = (_e27 + _e28);
            }
        } else {
            let _e30 = _sw_sel;
            if (_e30 == 2i) {
                {
                    let _e34 = aa;
                    let _e35 = bb;
                    cc = (_e34 * _e35);
                }
            } else {
                let _e37 = _sw_sel;
                if (_e37 == 3i) {
                    {
                        let _e41 = aa;
                        let _e42 = bb;
                        cc = (_e41 - _e42);
                    }
                } else {
                    let _e44 = _sw_sel;
                    if (_e44 == 4i) {
                        {
                            let _e48 = aa;
                            let _e49 = bb;
                            cc = abs((_e48 - _e49));
                        }
                    } else {
                        let _e52 = _sw_sel;
                        if (_e52 == 5i) {
                            {
                                let _e56 = aa;
                                let _e57 = bb;
                                cc = (_e56 / _e57);
                            }
                        } else {
                            let _e59 = _sw_sel;
                            if (_e59 == 10i) {
                                {
                                    let _e63 = a_1;
                                    let _e64 = b_1;
                                    return max(_e63, _e64);
                                }
                            } else {
                                let _e66 = _sw_sel;
                                if (_e66 == 11i) {
                                    {
                                        let _e70 = a_1;
                                        let _e71 = b_1;
                                        return min(_e70, _e71);
                                    }
                                } else {
                                    {
                                        let _e73 = b_1;
                                        return _e73;
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    let _e74 = cc;
    let _e75 = a_1;
    let _e77 = b_1;
    return vec4<f32>(_e74.x, _e74.y, _e74.z, mix(_e75.w, _e77.w, 0.5f));
}

fn linearBlend(pos: vec2<f32>, outPos: vec2<f32>, intensity: f32, blendMode: i32) -> vec4<f32> {
    var pos_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var intensity_1: f32;
    var blendMode_1: i32;
    var in1_: vec4<f32>;
    var in2_: vec4<f32>;
    var blended: vec4<f32>;

    pos_1 = pos;
    outPos_1 = outPos;
    intensity_1 = intensity;
    blendMode_1 = blendMode;
    let _e15 = pos_1;
    let _e19 = global.U[0];
    let _e22 = pos_1;
    let _e31 = textureSample(t_source1_, samp, ((vec2<f32>((_e15.x / _e19.x), _e22.y) / vec2(2f)) + vec2(0.5f)));
    in1_ = _e31;
    let _e33 = pos_1;
    let _e37 = global.U[0];
    let _e40 = pos_1;
    let _e49 = textureSample(t_source2_, samp, ((vec2<f32>((_e33.x / _e37.x), _e40.y) / vec2(2f)) + vec2(0.5f)));
    in2_ = _e49;
    let _e51 = blendMode_1;
    let _e52 = in1_;
    let _e53 = in2_;
    let _e54 = blend(_e51, _e52, _e53);
    blended = _e54;
    let _e56 = in1_;
    let _e57 = blended;
    let _e58 = intensity_1;
    return mix(_e56, _e57, vec4(_e58));
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
    let _e71 = global.U[6];
    let _e74 = linearBlend((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e10.x, _e10.y, _e10.z), vec3<f32>(_e14.x, _e14.y, _e14.z), vec3<f32>(_e18.x, _e18.y, _e18.z))) * vec3<f32>(_e45.x, _e45.y, 1f)).xy, (((_e52 - vec2(0.5f)) * 2f) * vec2<f32>(_e60.x, 1f)), _e67.x, i32(_e71.x));
    fragColor = _e74;
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
