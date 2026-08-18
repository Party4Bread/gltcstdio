struct Params {
    U: array<vec4<f32>, 16>,
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

fn measure(v: vec2<f32>, power: f32) -> f32 {
    var v_1: vec2<f32>;
    var power_1: f32;
    var low: f32;
    var high: f32;
    var local: f32;

    v_1 = v;
    power_1 = power;
    let _e10 = v_1;
    let _e13 = v_1;
    low = min(abs(_e10.x), abs(_e13.y));
    let _e18 = v_1;
    let _e21 = v_1;
    high = max(abs(_e18.x), abs(_e21.y));
    let _e26 = high;
    if (_e26 == 0f) {
        local = 0f;
    } else {
        let _e30 = high;
        let _e32 = low;
        let _e33 = high;
        let _e35 = power_1;
        let _e39 = power_1;
        local = (_e30 * pow((1f + pow((_e32 / _e33), _e35)), (1f / _e39)));
    }
    let _e44 = local;
    return _e44;
}

fn tf(m: mat3x3<f32>, u: vec2<f32>) -> vec2<f32> {
    var m_1: mat3x3<f32>;
    var u_1: vec2<f32>;

    m_1 = m;
    u_1 = u;
    let _e10 = m_1;
    let _e11 = u_1;
    return (_e10 * vec3<f32>(_e11.x, _e11.y, 1f)).xy;
}

fn globe(uv: vec2<f32>, outPos: vec2<f32>, intensity: f32, sourceDim: vec2<f32>, power_2: f32, shadows: f32, colorShadow: vec4<f32>, modelTransform: mat3x3<f32>, shadowTransform: mat3x3<f32>) -> vec4<f32> {
    var uv_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var intensity_1: f32;
    var sourceDim_1: vec2<f32>;
    var power_3: f32;
    var shadows_1: f32;
    var colorShadow_1: vec4<f32>;
    var modelTransform_1: mat3x3<f32>;
    var shadowTransform_1: mat3x3<f32>;
    var t: mat3x3<f32>;
    var ratio: f32;
    var local_1: vec2<f32>;
    var u_2: vec2<f32>;
    var v_2: vec2<f32>;
    var d: f32;
    var kShadow: f32 = 0f;
    var hh: f32;
    var h: f32;
    var s: f32;
    var dilation: f32;
    var vs: vec2<f32>;
    var ds: f32;
    var vs_1: vec2<f32>;
    var ds_1: f32;
    var local_2: vec2<f32>;
    var col: vec4<f32>;

    uv_1 = uv;
    outPos_1 = outPos;
    intensity_1 = intensity;
    sourceDim_1 = sourceDim;
    power_3 = power_2;
    shadows_1 = shadows;
    colorShadow_1 = colorShadow;
    modelTransform_1 = modelTransform;
    shadowTransform_1 = shadowTransform;
    let _e24 = modelTransform_1;
    t = _naga_inverse_3x3_f32(_e24);
    let _e27 = sourceDim_1;
    let _e29 = sourceDim_1;
    ratio = (_e27.x / _e29.y);
    let _e33 = ratio;
    if (_e33 < 1f) {
        let _e36 = uv_1;
        let _e37 = ratio;
        local_1 = (_e36 / vec2(_e37));
    } else {
        let _e40 = uv_1;
        local_1 = _e40;
    }
    let _e42 = local_1;
    u_2 = _e42;
    let _e44 = t;
    let _e45 = u_2;
    let _e46 = tf(_e44, _e45);
    v_2 = _e46;
    let _e48 = v_2;
    let _e49 = power_3;
    let _e50 = measure(_e48, _e49);
    d = _e50;
    let _e54 = d;
    if (_e54 < 1f) {
        {
            let _e58 = d;
            let _e59 = d;
            hh = sqrt((1f - (_e58 * _e59)));
            let _e64 = hh;
            if (_e64 != 0f) {
                {
                    let _e68 = hh;
                    h = (1f + _e68);
                    let _e71 = d;
                    let _e73 = intensity_1;
                    let _e75 = hh;
                    s = ((-(_e71) * _e73) / _e75);
                    let _e79 = h;
                    let _e80 = s;
                    let _e82 = d;
                    dilation = (1f + ((_e79 * _e80) / _e82));
                    let _e86 = modelTransform_1;
                    let _e87 = dilation;
                    let _e88 = v_2;
                    let _e90 = tf(_e86, (_e87 * _e88));
                    u_2 = _e90.xy;
                }
            }
            let _e92 = shadows_1;
            if (_e92 < 0f) {
                {
                    let _e95 = shadowTransform_1;
                    let _e97 = v_2;
                    let _e98 = tf(_naga_inverse_3x3_f32(_e95), _e97);
                    vs = _e98;
                    let _e100 = vs;
                    let _e103 = power_3;
                    let _e105 = vs;
                    let _e108 = power_3;
                    let _e112 = power_3;
                    ds = pow((pow(abs(_e100.x), _e103) + pow(abs(_e105.y), _e108)), (1f / _e112));
                    let _e117 = shadows_1;
                    let _e119 = ds;
                    kShadow = (1f * smoothstep(_e117, 0f, (_e119 - 1f)));
                }
            }
        }
    } else {
        let _e124 = shadows_1;
        if (_e124 > 0f) {
            {
                let _e127 = shadowTransform_1;
                let _e129 = v_2;
                let _e130 = tf(_naga_inverse_3x3_f32(_e127), _e129);
                vs_1 = _e130;
                let _e132 = vs_1;
                let _e135 = power_3;
                let _e137 = vs_1;
                let _e140 = power_3;
                let _e144 = power_3;
                ds_1 = pow((pow(abs(_e132.x), _e135) + pow(abs(_e137.y), _e140)), (1f / _e144));
                let _e149 = shadows_1;
                let _e151 = ds_1;
                kShadow = (1f * smoothstep(_e149, 0f, (_e151 - 1f)));
            }
        }
    }
    let _e156 = ratio;
    if (_e156 < 1f) {
        let _e159 = u_2;
        let _e160 = ratio;
        local_2 = (_e159 * _e160);
    } else {
        let _e162 = u_2;
        local_2 = _e162;
    }
    let _e164 = local_2;
    u_2 = _e164;
    let _e165 = u_2;
    let _e169 = global.U[0];
    let _e172 = u_2;
    let _e181 = _mirror_wrap(((vec2<f32>((_e165.x / _e169.x), _e172.y) / vec2(2f)) + vec2(0.5f)));
    let _e182 = textureSample(t_source, samp, _e181);
    col = _e182;
    let _e184 = col;
    let _e185 = colorShadow_1;
    let _e186 = _e185.xyz;
    let _e187 = col;
    let _e193 = kShadow;
    let _e194 = colorShadow_1;
    return mix(_e184, vec4<f32>(_e186.x, _e186.y, _e186.z, _e187.w), vec4((_e193 * _e194.w)));
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
    let _e66 = global.U[6];
    let _e70 = global.U[4];
    let _e74 = global.U[7];
    let _e78 = global.U[8];
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
    let _e133 = globe((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e9.x, _e9.y, _e9.z), vec3<f32>(_e13.x, _e13.y, _e13.z), vec3<f32>(_e17.x, _e17.y, _e17.z))) * vec3<f32>(_e44.x, _e44.y, 1f)).xy, (((_e51 - vec2(0.5f)) * 2f) * vec2<f32>(_e59.x, 1f)), _e66.x, _e70.xy, _e74.x, _e78.x, _e82, mat3x3<f32>(vec3<f32>(_e86.x, _e86.y, _e86.z), vec3<f32>(_e90.x, _e90.y, _e90.z), vec3<f32>(_e94.x, _e94.y, _e94.z)), mat3x3<f32>(vec3<f32>(_e111.x, _e111.y, _e111.z), vec3<f32>(_e115.x, _e115.y, _e115.z), vec3<f32>(_e119.x, _e119.y, _e119.z)));
    fragColor = _e133;
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
