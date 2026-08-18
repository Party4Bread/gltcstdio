struct Params {
    U: array<vec4<f32>, 12>,
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

fn sdSegment(u: vec2<f32>, a: vec2<f32>, b: vec2<f32>) -> f32 {
    var u_1: vec2<f32>;
    var a_1: vec2<f32>;
    var b_1: vec2<f32>;
    var ua: vec2<f32>;
    var ba: vec2<f32>;
    var h: f32;

    u_1 = u;
    a_1 = a;
    b_1 = b;
    let _e12 = u_1;
    let _e13 = a_1;
    ua = (_e12 - _e13);
    let _e16 = b_1;
    let _e17 = a_1;
    ba = (_e16 - _e17);
    let _e20 = ua;
    let _e21 = ba;
    let _e23 = ba;
    let _e24 = ba;
    h = clamp((dot(_e20, _e21) / dot(_e23, _e24)), 0f, 1f);
    let _e31 = ua;
    let _e32 = ba;
    let _e33 = h;
    return length((_e31 - (_e32 * _e33)));
}

fn tf(m: mat3x3<f32>, u_2: vec2<f32>) -> vec2<f32> {
    var m_1: mat3x3<f32>;
    var u_3: vec2<f32>;

    m_1 = m;
    u_3 = u_2;
    let _e10 = m_1;
    let _e11 = u_3;
    return (_e10 * vec3<f32>(_e11.x, _e11.y, 1f)).xy;
}

fn segmentCrossCurve(uv: vec2<f32>, outPos: vec2<f32>, mode: i32, count: i32, thickness: f32, color: vec4<f32>, modelTransform: mat3x3<f32>) -> vec4<f32> {
    var uv_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var mode_1: i32;
    var count_1: i32;
    var thickness_1: f32;
    var color_1: vec4<f32>;
    var modelTransform_1: mat3x3<f32>;
    var u_4: vec2<f32>;
    var a_2: vec2<f32> = vec2<f32>(0f, 0f);
    var b_2: vec2<f32>;
    var k: f32 = 0f;
    var th: f32;
    var step: f32;
    var i: i32 = 0i;
    var i_1: i32 = 0i;
    var inCol: vec4<f32>;
    var mergeCol: vec4<f32>;

    uv_1 = uv;
    outPos_1 = outPos;
    mode_1 = mode;
    count_1 = count;
    thickness_1 = thickness;
    color_1 = color;
    modelTransform_1 = modelTransform;
    let _e20 = modelTransform_1;
    let _e22 = uv_1;
    let _e23 = tf(_naga_inverse_3x3_f32(_e20), _e22);
    u_4 = _e23;
    let _e25 = mode_1;
    if (_e25 <= 1i) {
        {
            let _e28 = u_4;
            u_4 = abs(_e28);
            let _e30 = u_4;
            let _e32 = u_4;
            if (_e30.x < _e32.y) {
                let _e35 = u_4;
                let _e37 = u_4;
                let _e38 = _e37.yx;
                u_4.x = _e38.x;
                u_4.y = _e38.y;
            }
        }
    }
    let _e43 = mode_1;
    if (_e43 == 1i) {
        let _e47 = u_4;
        u_4 = (vec2(1f) - _e47);
    }
    let _e54 = a_2;
    b_2 = _e54;
    let _e58 = thickness_1;
    let _e61 = modelTransform_1[0];
    th = (_e58 / length(_e61.xy));
    let _e67 = count_1;
    step = (2f / f32(_e67));
    let _e71 = mode_1;
    if (_e71 <= 1i) {
        {
            loop {
                let _e76 = i;
                let _e77 = count_1;
                if !((_e76 < _e77)) {
                    break;
                }
                {
                    let _e84 = i;
                    let _e86 = step;
                    a_2 = vec2<f32>((1f - (f32(_e84) * _e86)), 0f);
                    let _e93 = a_2;
                    b_2 = vec2<f32>(0f, (1f - _e93.x));
                    let _e97 = k;
                    let _e98 = th;
                    let _e103 = th;
                    let _e106 = u_4;
                    let _e107 = a_2;
                    let _e108 = b_2;
                    let _e109 = sdSegment(_e106, _e107, _e108);
                    k = max(_e97, smoothstep(((_e98 * 0.1f) + 0.0005f), (_e103 * 0.1f), _e109));
                    let _e112 = k;
                    if (_e112 >= 1f) {
                        break;
                    }
                }
                continuing {
                    let _e80 = i;
                    i = (_e80 + 1i);
                }
            }
        }
    } else {
        let _e115 = mode_1;
        if (_e115 == 2i) {
            {
                loop {
                    let _e120 = i_1;
                    let _e121 = count_1;
                    if !((_e120 <= _e121)) {
                        break;
                    }
                    {
                        let _e128 = i_1;
                        let _e130 = step;
                        a_2 = vec2<f32>((1f - (f32(_e128) * _e130)), -1f);
                        let _e138 = a_2;
                        b_2 = vec2<f32>(-1f, -(_e138.x));
                        let _e142 = k;
                        let _e143 = th;
                        let _e148 = th;
                        let _e151 = u_4;
                        let _e152 = a_2;
                        let _e153 = b_2;
                        let _e154 = sdSegment(_e151, _e152, _e153);
                        k = max(_e142, smoothstep(((_e143 * 0.1f) + 0.0005f), (_e148 * 0.1f), _e154));
                        let _e157 = k;
                        if (_e157 >= 1f) {
                            break;
                        }
                        let _e160 = k;
                        let _e161 = th;
                        let _e166 = th;
                        let _e169 = u_4;
                        let _e171 = a_2;
                        let _e172 = b_2;
                        let _e173 = sdSegment(-(_e169), _e171, _e172);
                        k = max(_e160, smoothstep(((_e161 * 0.1f) + 0.0005f), (_e166 * 0.1f), _e173));
                        let _e176 = k;
                        if (_e176 >= 1f) {
                            break;
                        }
                        let _e179 = k;
                        let _e180 = th;
                        let _e185 = th;
                        let _e188 = u_4;
                        let _e190 = u_4;
                        let _e194 = a_2;
                        let _e195 = b_2;
                        let _e196 = sdSegment(vec2<f32>(_e188.x, -(_e190.y)), _e194, _e195);
                        k = max(_e179, smoothstep(((_e180 * 0.1f) + 0.0005f), (_e185 * 0.1f), _e196));
                        let _e199 = k;
                        if (_e199 >= 1f) {
                            break;
                        }
                        let _e202 = k;
                        let _e203 = th;
                        let _e208 = th;
                        let _e211 = u_4;
                        let _e214 = u_4;
                        let _e217 = a_2;
                        let _e218 = b_2;
                        let _e219 = sdSegment(vec2<f32>(-(_e211.x), _e214.y), _e217, _e218);
                        k = max(_e202, smoothstep(((_e203 * 0.1f) + 0.0005f), (_e208 * 0.1f), _e219));
                        let _e222 = k;
                        if (_e222 >= 1f) {
                            break;
                        }
                    }
                    continuing {
                        let _e124 = i_1;
                        i_1 = (_e124 + 1i);
                    }
                }
            }
        }
    }
    let _e225 = uv_1;
    let _e229 = global.U[0];
    let _e232 = uv_1;
    let _e241 = textureSample(t_source, samp, ((vec2<f32>((_e225.x / _e229.x), _e232.y) / vec2(2f)) + vec2(0.5f)));
    inCol = _e241;
    let _e243 = inCol;
    let _e244 = color_1;
    let _e245 = mergeColor(_e243, _e244);
    mergeCol = _e245;
    let _e247 = inCol;
    let _e248 = mergeCol;
    let _e249 = k;
    return mix(_e247, _e248, vec4(_e249));
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
    let _e83 = global.U[9];
    let _e84 = _e83.xyz;
    let _e87 = global.U[10];
    let _e88 = _e87.xyz;
    let _e91 = global.U[11];
    let _e92 = _e91.xyz;
    let _e106 = segmentCrossCurve((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e9.x, _e9.y, _e9.z), vec3<f32>(_e13.x, _e13.y, _e13.z), vec3<f32>(_e17.x, _e17.y, _e17.z))) * vec3<f32>(_e44.x, _e44.y, 1f)).xy, (((_e51 - vec2(0.5f)) * 2f) * vec2<f32>(_e59.x, 1f)), i32(_e66.x), i32(_e71.x), _e76.x, _e80, mat3x3<f32>(vec3<f32>(_e84.x, _e84.y, _e84.z), vec3<f32>(_e88.x, _e88.y, _e88.z), vec3<f32>(_e92.x, _e92.y, _e92.z)));
    fragColor = _e106;
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
