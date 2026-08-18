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

fn mergeColor(bkg: vec4<f32>, front: vec4<f32>) -> vec4<f32> {
    var bkg_1: vec4<f32>;
    var front_1: vec4<f32>;

    bkg_1 = bkg;
    front_1 = front;
    let _e11 = bkg_1;
    let _e13 = front_1;
    let _e15 = front_1;
    let _e18 = bkg_1;
    let _e22 = front_1;
    let _e28 = mix(_e11.xyz, _e13.xyz, vec3((_e15.w + ((1f - _e18.w) * (1f - _e22.w)))));
    let _e29 = bkg_1;
    let _e31 = front_1;
    return vec4<f32>(_e28.x, _e28.y, _e28.z, max(_e29.w, _e31.w));
}

fn sdRectangle(u: vec2<f32>, halfSize: vec2<f32>) -> f32 {
    var u_1: vec2<f32>;
    var halfSize_1: vec2<f32>;
    var local: f32;

    u_1 = u;
    halfSize_1 = halfSize;
    let _e11 = u_1;
    let _e13 = halfSize_1;
    u_1 = (abs(_e11) - _e13);
    let _e15 = u_1;
    let _e19 = u_1;
    if ((_e15.x >= 0f) && (_e19.y >= 0f)) {
        let _e24 = u_1;
        local = length(_e24);
    } else {
        let _e26 = u_1;
        let _e28 = u_1;
        local = max(_e26.x, _e28.y);
    }
    let _e32 = local;
    return _e32;
}

fn tf(m: mat3x3<f32>, u_2: vec2<f32>) -> vec2<f32> {
    var m_1: mat3x3<f32>;
    var u_3: vec2<f32>;

    m_1 = m;
    u_3 = u_2;
    let _e11 = m_1;
    let _e12 = u_3;
    return (_e11 * vec3<f32>(_e12.x, _e12.y, 1f)).xy;
}

fn overlay(uv: vec2<f32>, outPos: vec2<f32>, blendMode: i32, intensity: f32, thickness: f32, shadows: f32, color: vec4<f32>, source2Dim: vec2<f32>, modelTransform: mat3x3<f32>) -> vec4<f32> {
    var uv_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var blendMode_1: i32;
    var intensity_1: f32;
    var thickness_1: f32;
    var shadows_1: f32;
    var color_1: vec4<f32>;
    var source2Dim_1: vec2<f32>;
    var modelTransform_1: mat3x3<f32>;
    var bkgColor: vec4<f32>;
    var u_4: vec2<f32>;
    var ratio2_: f32;
    var borderDim: vec2<f32>;
    var overColor: vec4<f32>;
    var blended: vec4<f32>;
    var mixed: vec4<f32>;
    var d: f32;
    var s: f32;

    uv_1 = uv;
    outPos_1 = outPos;
    blendMode_1 = blendMode;
    intensity_1 = intensity;
    thickness_1 = thickness;
    shadows_1 = shadows;
    color_1 = color;
    source2Dim_1 = source2Dim;
    modelTransform_1 = modelTransform;
    let _e25 = uv_1;
    let _e29 = global.U[0];
    let _e32 = uv_1;
    let _e41 = textureSample(t_source1_, samp, ((vec2<f32>((_e25.x / _e29.x), _e32.y) / vec2(2f)) + vec2(0.5f)));
    bkgColor = _e41;
    let _e43 = modelTransform_1;
    let _e45 = uv_1;
    let _e46 = tf(_naga_inverse_3x3_f32(_e43), _e45);
    u_4 = _e46;
    let _e48 = source2Dim_1;
    let _e50 = source2Dim_1;
    ratio2_ = (_e48.x / _e50.y);
    let _e54 = ratio2_;
    let _e55 = thickness_1;
    let _e60 = thickness_1;
    borderDim = vec2<f32>((_e54 + (_e55 * 0.3f)), (1f + (_e60 * 0.3f)));
    let _e66 = u_4;
    let _e69 = ratio2_;
    let _e71 = u_4;
    if ((abs(_e66.x) <= _e69) && (abs(_e71.y) <= 1f)) {
        {
            let _e77 = u_4;
            let _e81 = global.U[0];
            let _e84 = u_4;
            let _e93 = textureSample(t_source2_, samp, ((vec2<f32>((_e77.x / _e81.x), _e84.y) / vec2(2f)) + vec2(0.5f)));
            overColor = _e93;
            let _e95 = blendMode_1;
            let _e96 = bkgColor;
            let _e97 = overColor;
            let _e98 = blend(_e95, _e96, _e97);
            blended = _e98;
            let _e100 = bkgColor;
            let _e101 = blended;
            let _e102 = intensity_1;
            mixed = mix(_e100, _e101, vec4(_e102));
            let _e106 = bkgColor;
            let _e107 = mixed;
            let _e108 = mergeColor(_e106, _e107);
            return _e108;
        }
    } else {
        let _e109 = u_4;
        let _e112 = borderDim;
        let _e115 = u_4;
        let _e118 = borderDim;
        if ((abs(_e109.x) <= _e112.x) && (abs(_e115.y) <= _e118.y)) {
            {
                let _e122 = color_1;
                return _e122;
            }
        } else {
            {
                let _e123 = shadows_1;
                if (_e123 == 0f) {
                    let _e126 = bkgColor;
                    return _e126;
                }
                let _e127 = u_4;
                let _e128 = borderDim;
                let _e129 = sdRectangle(_e127, _e128);
                d = _e129;
                let _e131 = shadows_1;
                let _e135 = d;
                s = (smoothstep((_e131 * 0.6f), 0f, _e135) * 0.5f);
                let _e140 = bkgColor;
                let _e144 = s;
                let _e146 = mergeColor(_e140, vec4<f32>(0f, 0f, 0f, _e144));
                return _e146;
            }
        }
    }
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
    let _e67 = global.U[6];
    let _e72 = global.U[7];
    let _e76 = global.U[8];
    let _e80 = global.U[9];
    let _e84 = global.U[10];
    let _e87 = global.U[4];
    let _e91 = global.U[11];
    let _e92 = _e91.xyz;
    let _e95 = global.U[12];
    let _e96 = _e95.xyz;
    let _e99 = global.U[13];
    let _e100 = _e99.xyz;
    let _e114 = overlay((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e10.x, _e10.y, _e10.z), vec3<f32>(_e14.x, _e14.y, _e14.z), vec3<f32>(_e18.x, _e18.y, _e18.z))) * vec3<f32>(_e45.x, _e45.y, 1f)).xy, (((_e52 - vec2(0.5f)) * 2f) * vec2<f32>(_e60.x, 1f)), i32(_e67.x), _e72.x, _e76.x, _e80.x, _e84, _e87.xy, mat3x3<f32>(vec3<f32>(_e92.x, _e92.y, _e92.z), vec3<f32>(_e96.x, _e96.y, _e96.z), vec3<f32>(_e100.x, _e100.y, _e100.z)));
    fragColor = _e114;
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
