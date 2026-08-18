struct Params {
    U: array<vec4<f32>, 21>,
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

fn ripples_to_globe(uv: vec2<f32>, outPos: vec2<f32>, time: f32, spacing: f32, ripplesIntensity: f32, count: i32, dampening: f32, intensity: f32, sourceDim: vec2<f32>, power_2: f32, shadows: f32, colorShadow: vec4<f32>, modelTransform: mat3x3<f32>, shadowTransform: mat3x3<f32>) -> vec4<f32> {
    var uv_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var time_1: f32;
    var spacing_1: f32;
    var ripplesIntensity_1: f32;
    var count_1: i32;
    var dampening_1: f32;
    var intensity_1: f32;
    var sourceDim_1: vec2<f32>;
    var power_3: f32;
    var shadows_1: f32;
    var colorShadow_1: vec4<f32>;
    var modelTransform_1: mat3x3<f32>;
    var shadowTransform_1: mat3x3<f32>;
    var t: mat3x3<f32>;
    var ratio: f32;
    var local_1: f32;
    var ratioScale: f32;
    var u_2: vec2<f32>;
    var v_2: vec2<f32>;
    var dCircle: f32;
    var dShape: f32;
    var d: f32;
    var kShadow: f32 = 0f;
    var local_2: f32;
    var dampen: f32;
    var local_3: f32;
    var dd: f32;
    var ripplesDilation: f32;
    var hh: f32;
    var globeDilation: f32 = 1f;
    var h: f32;
    var s: f32;
    var dilation: f32;
    var vs: vec2<f32>;
    var ds: f32;
    var vs_1: vec2<f32>;
    var ds_1: f32;
    var col: vec4<f32>;

    uv_1 = uv;
    outPos_1 = outPos;
    time_1 = time;
    spacing_1 = spacing;
    ripplesIntensity_1 = ripplesIntensity;
    count_1 = count;
    dampening_1 = dampening;
    intensity_1 = intensity;
    sourceDim_1 = sourceDim;
    power_3 = power_2;
    shadows_1 = shadows;
    colorShadow_1 = colorShadow;
    modelTransform_1 = modelTransform;
    shadowTransform_1 = shadowTransform;
    let _e34 = modelTransform_1;
    t = _naga_inverse_3x3_f32(_e34);
    let _e37 = sourceDim_1;
    let _e39 = sourceDim_1;
    ratio = (_e37.x / _e39.y);
    let _e43 = ratio;
    if (_e43 < 1f) {
        let _e48 = ratio;
        let _e50 = time_1;
        local_1 = mix(1f, (1f / _e48), _e50);
    } else {
        local_1 = 1f;
    }
    let _e54 = local_1;
    ratioScale = _e54;
    let _e56 = uv_1;
    let _e57 = ratioScale;
    u_2 = (_e56 * _e57);
    let _e60 = t;
    let _e61 = u_2;
    let _e62 = tf(_e60, _e61);
    v_2 = _e62;
    let _e64 = v_2;
    dCircle = length(_e64);
    let _e67 = v_2;
    let _e68 = power_3;
    let _e69 = measure(_e67, _e68);
    dShape = _e69;
    let _e71 = dCircle;
    let _e72 = dShape;
    let _e73 = time_1;
    d = mix(_e71, _e72, _e73);
    let _e78 = d;
    if (_e78 < 1f) {
        {
            let _e81 = dampening_1;
            if (_e81 >= 0f) {
                let _e85 = d;
                let _e87 = dampening_1;
                local_2 = pow((1f - _e85), (_e87 * 2f));
            } else {
                let _e91 = d;
                let _e92 = dampening_1;
                local_2 = pow(_e91, (-(_e92) * 5f));
            }
            let _e98 = local_2;
            dampen = _e98;
            let _e100 = spacing_1;
            if (_e100 <= 0f) {
                let _e103 = d;
                local_3 = (_e103 - 1f);
            } else {
                let _e106 = d;
                let _e109 = spacing_1;
                let _e114 = spacing_1;
                local_3 = (log((((_e106 - 1f) * _e109) + 1f)) / _e114);
            }
            let _e117 = local_3;
            dd = _e117;
            let _e120 = ripplesIntensity_1;
            let _e121 = dd;
            let _e122 = count_1;
            let _e129 = dampen;
            ripplesDilation = (1f + ((_e120 * sin(((_e121 * f32(_e122)) * 3.1415927f))) * _e129));
            let _e134 = d;
            let _e135 = d;
            hh = sqrt((1f - (_e134 * _e135)));
            let _e142 = hh;
            if (_e142 != 0f) {
                {
                    let _e146 = hh;
                    h = (1f + _e146);
                    let _e149 = d;
                    let _e151 = intensity_1;
                    let _e153 = hh;
                    s = ((-(_e149) * _e151) / _e153);
                    let _e157 = h;
                    let _e158 = s;
                    let _e160 = d;
                    globeDilation = (1f + ((_e157 * _e158) / _e160));
                }
            }
            let _e163 = ripplesDilation;
            let _e164 = globeDilation;
            let _e165 = time_1;
            dilation = mix(_e163, _e164, _e165);
            let _e168 = modelTransform_1;
            let _e169 = dilation;
            let _e170 = v_2;
            let _e172 = tf(_e168, (_e169 * _e170));
            u_2 = _e172;
            let _e173 = shadows_1;
            if (_e173 < 0f) {
                {
                    let _e176 = shadowTransform_1;
                    let _e178 = v_2;
                    let _e179 = tf(_naga_inverse_3x3_f32(_e176), _e178);
                    vs = _e179;
                    let _e181 = vs;
                    let _e182 = power_3;
                    let _e183 = measure(_e181, _e182);
                    ds = _e183;
                    let _e185 = time_1;
                    let _e186 = shadows_1;
                    let _e188 = ds;
                    kShadow = (_e185 * smoothstep(_e186, 0f, (_e188 - 1f)));
                }
            }
        }
    } else {
        {
            let _e193 = shadows_1;
            if (_e193 > 0f) {
                {
                    let _e196 = shadowTransform_1;
                    let _e198 = v_2;
                    let _e199 = tf(_naga_inverse_3x3_f32(_e196), _e198);
                    vs_1 = _e199;
                    let _e201 = vs_1;
                    let _e202 = power_3;
                    let _e203 = measure(_e201, _e202);
                    ds_1 = _e203;
                    let _e205 = time_1;
                    let _e206 = shadows_1;
                    let _e208 = ds_1;
                    kShadow = (_e205 * smoothstep(_e206, 0f, (_e208 - 1f)));
                }
            }
        }
    }
    let _e213 = u_2;
    let _e214 = ratioScale;
    u_2 = (_e213 / vec2(_e214));
    let _e217 = u_2;
    let _e221 = global.U[0];
    let _e224 = u_2;
    let _e233 = _mirror_wrap(((vec2<f32>((_e217.x / _e221.x), _e224.y) / vec2(2f)) + vec2(0.5f)));
    let _e234 = textureSample(t_source, samp, _e233);
    col = _e234;
    let _e236 = col;
    let _e237 = colorShadow_1;
    let _e238 = _e237.xyz;
    let _e239 = col;
    let _e245 = kShadow;
    let _e246 = colorShadow_1;
    return mix(_e236, vec4<f32>(_e238.x, _e238.y, _e238.z, _e239.w), vec4((_e245 * _e246.w)));
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
    let _e70 = global.U[7];
    let _e74 = global.U[8];
    let _e78 = global.U[9];
    let _e83 = global.U[10];
    let _e87 = global.U[11];
    let _e91 = global.U[4];
    let _e95 = global.U[12];
    let _e99 = global.U[13];
    let _e103 = global.U[14];
    let _e106 = global.U[15];
    let _e107 = _e106.xyz;
    let _e110 = global.U[16];
    let _e111 = _e110.xyz;
    let _e114 = global.U[17];
    let _e115 = _e114.xyz;
    let _e131 = global.U[18];
    let _e132 = _e131.xyz;
    let _e135 = global.U[19];
    let _e136 = _e135.xyz;
    let _e139 = global.U[20];
    let _e140 = _e139.xyz;
    let _e154 = ripples_to_globe((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e9.x, _e9.y, _e9.z), vec3<f32>(_e13.x, _e13.y, _e13.z), vec3<f32>(_e17.x, _e17.y, _e17.z))) * vec3<f32>(_e44.x, _e44.y, 1f)).xy, (((_e51 - vec2(0.5f)) * 2f) * vec2<f32>(_e59.x, 1f)), _e66.x, _e70.x, _e74.x, i32(_e78.x), _e83.x, _e87.x, _e91.xy, _e95.x, _e99.x, _e103, mat3x3<f32>(vec3<f32>(_e107.x, _e107.y, _e107.z), vec3<f32>(_e111.x, _e111.y, _e111.z), vec3<f32>(_e115.x, _e115.y, _e115.z)), mat3x3<f32>(vec3<f32>(_e132.x, _e132.y, _e132.z), vec3<f32>(_e136.x, _e136.y, _e136.z), vec3<f32>(_e140.x, _e140.y, _e140.z)));
    fragColor = _e154;
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
