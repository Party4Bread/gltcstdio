struct Params {
    U: array<vec4<f32>, 19>,
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

fn rand2_(v: vec2<f32>) -> vec2<f32> {
    var v_1: vec2<f32>;
    var x: f32;
    var y: f32;

    v_1 = v;
    let _e9 = v_1;
    x = fract((sin(dot(_e9.xy, vec2<f32>(12.9898f, 78.233f))) * 43758.547f));
    let _e20 = x;
    let _e21 = v_1;
    y = fract((sin(dot(vec2<f32>(_e20, _e21.x), vec2<f32>(12.9898f, 78.233f))) * 43758.547f));
    let _e33 = x;
    let _e34 = y;
    return vec2<f32>(_e33, _e34);
}

fn interpolatedRand2_(v_2: vec2<f32>) -> vec2<f32> {
    var v_3: vec2<f32>;
    var fractY: f32;

    v_3 = v_2;
    let _e9 = v_3;
    fractY = fract(_e9.y);
    let _e13 = v_3;
    let _e15 = rand2_(floor(_e13));
    let _e16 = v_3;
    let _e19 = v_3;
    let _e23 = rand2_(vec2<f32>(floor(_e16.x), ceil(_e19.y)));
    let _e24 = fractY;
    let _e27 = v_3;
    let _e30 = v_3;
    let _e34 = rand2_(vec2<f32>(ceil(_e27.x), floor(_e30.y)));
    let _e35 = v_3;
    let _e37 = rand2_(ceil(_e35));
    let _e38 = fractY;
    let _e41 = v_3;
    return mix(mix(_e15, _e23, vec2(_e24)), mix(_e34, _e37, vec2(_e38)), vec2(fract(_e41.x)));
}

fn fractalValueNoiseDisplace(u: vec2<f32>, v_4: vec2<f32>, count: i32, intensity: f32) -> vec2<f32> {
    var u_1: vec2<f32>;
    var v_5: vec2<f32>;
    var count_1: i32;
    var intensity_1: f32;
    var s: f32 = 1f;
    var maxDisplacement: f32;
    var totalDisp: vec2<f32> = vec2(0f);
    var i: i32 = 0i;
    var disp: vec2<f32>;

    u_1 = u;
    v_5 = v_4;
    count_1 = count;
    intensity_1 = intensity;
    let _e17 = intensity_1;
    maxDisplacement = _e17;
    loop {
        let _e24 = i;
        let _e25 = count_1;
        if !((_e24 < _e25)) {
            break;
        }
        {
            let _e31 = v_5;
            let _e32 = s;
            let _e34 = interpolatedRand2_((_e31 * _e32));
            disp = _e34;
            let _e36 = totalDisp;
            let _e37 = maxDisplacement;
            let _e38 = disp;
            totalDisp = (_e36 + ((_e37 * (_e38 - vec2<f32>(0.5f, 0.5f))) * 2f));
            let _e47 = maxDisplacement;
            maxDisplacement = (_e47 * 0.5f);
            let _e50 = s;
            s = (_e50 * 2.1055472f);
        }
        continuing {
            let _e28 = i;
            i = (_e28 + 1i);
        }
    }
    let _e53 = u_1;
    let _e54 = totalDisp;
    return (_e53 + _e54);
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

fn tf(m: mat3x3<f32>, u_2: vec2<f32>) -> vec2<f32> {
    var m_1: mat3x3<f32>;
    var u_3: vec2<f32>;

    m_1 = m;
    u_3 = u_2;
    let _e11 = m_1;
    let _e12 = u_3;
    return (_e11 * vec3<f32>(_e12.x, _e12.y, 1f)).xy;
}

fn shredCombine(pos: vec2<f32>, outPos: vec2<f32>, shadows: f32, intensity_2: f32, thickness: f32, borderColor: vec4<f32>, colorShadow: vec4<f32>, axisTransform: mat3x3<f32>, viewTransform1_: mat3x3<f32>, viewTransform2_: mat3x3<f32>) -> vec4<f32> {
    var pos_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var shadows_1: f32;
    var intensity_3: f32;
    var thickness_1: f32;
    var borderColor_1: vec4<f32>;
    var colorShadow_1: vec4<f32>;
    var axisTransform_1: mat3x3<f32>;
    var viewTransform1_1: mat3x3<f32>;
    var viewTransform2_1: mat3x3<f32>;
    var inverseAxisTransform: mat3x3<f32>;
    var u_4: vec2<f32>;
    var scale: f32;
    var d: f32;
    var th: f32;
    var outCol: vec4<f32>;
    var dShadow: f32;
    var shadowStrength: f32;
    var shColor: vec4<f32>;

    pos_1 = pos;
    outPos_1 = outPos;
    shadows_1 = shadows;
    intensity_3 = intensity_2;
    thickness_1 = thickness;
    borderColor_1 = borderColor;
    colorShadow_1 = colorShadow;
    axisTransform_1 = axisTransform;
    viewTransform1_1 = viewTransform1_;
    viewTransform2_1 = viewTransform2_;
    let _e27 = axisTransform_1;
    inverseAxisTransform = _naga_inverse_3x3_f32(_e27);
    let _e30 = inverseAxisTransform;
    let _e31 = pos_1;
    let _e32 = tf(_e30, _e31);
    u_4 = _e32;
    let _e36 = axisTransform_1[0];
    scale = length(_e36.xy);
    let _e40 = u_4;
    let _e41 = u_4;
    let _e43 = intensity_3;
    let _e46 = fractalValueNoiseDisplace(_e40, _e41, 12i, (_e43 * 5f));
    u_4 = _e46;
    let _e47 = u_4;
    let _e49 = scale;
    d = (_e47.x * _e49);
    let _e52 = thickness_1;
    th = (_e52 * 0.25f);
    let _e56 = d;
    let _e58 = th;
    if (abs(_e56) < _e58) {
        let _e60 = borderColor_1;
        return _e60;
    }
    let _e62 = d;
    if (_e62 < 0f) {
        let _e65 = viewTransform1_1;
        let _e67 = pos_1;
        let _e68 = tf(_naga_inverse_3x3_f32(_e65), _e67);
        let _e72 = global.U[0];
        let _e75 = viewTransform1_1;
        let _e77 = pos_1;
        let _e78 = tf(_naga_inverse_3x3_f32(_e75), _e77);
        let _e88 = textureSampleLevel(t_source1_, samp, ((vec2<f32>((_e68.x / _e72.x), _e78.y) / vec2(2f)) + vec2(0.5f)), 0f);
        outCol = _e88;
    } else {
        let _e89 = viewTransform2_1;
        let _e91 = pos_1;
        let _e92 = tf(_naga_inverse_3x3_f32(_e89), _e91);
        let _e96 = global.U[0];
        let _e99 = viewTransform2_1;
        let _e101 = pos_1;
        let _e102 = tf(_naga_inverse_3x3_f32(_e99), _e101);
        let _e112 = textureSampleLevel(t_source2_, samp, ((vec2<f32>((_e92.x / _e96.x), _e102.y) / vec2(2f)) + vec2(0.5f)), 0f);
        outCol = _e112;
    }
    let _e113 = shadows_1;
    if (_e113 != 0f) {
        {
            let _e116 = shadows_1;
            let _e118 = d;
            let _e120 = th;
            dShadow = ((sign(_e116) * _e118) - _e120);
            let _e123 = dShadow;
            if (_e123 > 0f) {
                {
                    let _e126 = shadows_1;
                    let _e128 = shadows_1;
                    let _e132 = dShadow;
                    shadowStrength = smoothstep(abs(_e126), (abs(_e128) * 0.25f), _e132);
                    let _e135 = colorShadow_1;
                    let _e136 = _e135.xyz;
                    let _e137 = colorShadow_1;
                    let _e139 = shadowStrength;
                    shColor = vec4<f32>(_e136.x, _e136.y, _e136.z, (_e137.w * _e139));
                    let _e146 = outCol;
                    let _e147 = shColor;
                    let _e148 = mergeColor(_e146, _e147);
                    outCol = _e148;
                }
            }
        }
    }
    let _e149 = outCol;
    return _e149;
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
    let _e75 = global.U[7];
    let _e79 = global.U[8];
    let _e82 = global.U[9];
    let _e85 = global.U[10];
    let _e86 = _e85.xyz;
    let _e89 = global.U[11];
    let _e90 = _e89.xyz;
    let _e93 = global.U[12];
    let _e94 = _e93.xyz;
    let _e110 = global.U[13];
    let _e111 = _e110.xyz;
    let _e114 = global.U[14];
    let _e115 = _e114.xyz;
    let _e118 = global.U[15];
    let _e119 = _e118.xyz;
    let _e135 = global.U[16];
    let _e136 = _e135.xyz;
    let _e139 = global.U[17];
    let _e140 = _e139.xyz;
    let _e143 = global.U[18];
    let _e144 = _e143.xyz;
    let _e158 = shredCombine((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e10.x, _e10.y, _e10.z), vec3<f32>(_e14.x, _e14.y, _e14.z), vec3<f32>(_e18.x, _e18.y, _e18.z))) * vec3<f32>(_e45.x, _e45.y, 1f)).xy, (((_e52 - vec2(0.5f)) * 2f) * vec2<f32>(_e60.x, 1f)), _e67.x, _e71.x, _e75.x, _e79, _e82, mat3x3<f32>(vec3<f32>(_e86.x, _e86.y, _e86.z), vec3<f32>(_e90.x, _e90.y, _e90.z), vec3<f32>(_e94.x, _e94.y, _e94.z)), mat3x3<f32>(vec3<f32>(_e111.x, _e111.y, _e111.z), vec3<f32>(_e115.x, _e115.y, _e115.z), vec3<f32>(_e119.x, _e119.y, _e119.z)), mat3x3<f32>(vec3<f32>(_e136.x, _e136.y, _e136.z), vec3<f32>(_e140.x, _e140.y, _e140.z), vec3<f32>(_e144.x, _e144.y, _e144.z)));
    fragColor = _e158;
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
