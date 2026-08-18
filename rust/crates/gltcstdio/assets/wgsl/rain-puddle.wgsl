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

fn hash12_(x: f32) -> vec2<f32> {
    var x_1: f32;

    x_1 = x;
    let _e8 = x_1;
    let _e15 = x_1;
    return vec2<f32>(fract((sin((_e8 * 776.4577f)) * 45.77f)), fract((sin(((_e15 * 376.4517f) + 1.2524f)) * 88.77f)));
}

fn ripple(center: vec2<f32>, radius: f32, time: f32, fullCycle: f32, u: vec2<f32>) -> f32 {
    var center_1: vec2<f32>;
    var radius_1: f32;
    var time_1: f32;
    var fullCycle_1: f32;
    var u_1: vec2<f32>;
    var d: f32;
    var dim: f32;
    var dampCenter: f32;
    var dampRadius: f32;
    var dampX: f32;
    var local: f32;
    var damp: f32;
    var timeDamp: f32;

    center_1 = center;
    radius_1 = radius;
    time_1 = time;
    fullCycle_1 = fullCycle;
    u_1 = u;
    let _e16 = u_1;
    let _e17 = center_1;
    u_1 = (_e16 - _e17);
    let _e19 = u_1;
    let _e21 = radius_1;
    d = (length(_e19) / _e21);
    let _e24 = radius_1;
    dim = (_e24 * 0.1f);
    let _e29 = time_1;
    dampCenter = (0f + (_e29 * 0.3f));
    let _e34 = dim;
    let _e38 = time_1;
    dampRadius = ((_e34 * 1.5f) * (1f + (_e38 * 0.5f)));
    let _e44 = d;
    let _e45 = dampCenter;
    let _e47 = dampRadius;
    dampX = ((_e44 - _e45) / _e47);
    let _e50 = dampX;
    if (abs(_e50) > 1f) {
        local = 0f;
    } else {
        let _e55 = dampX;
        local = ((cos((_e55 * 3.1415f)) + 1f) * 0.5f);
    }
    let _e64 = local;
    damp = _e64;
    let _e67 = time_1;
    let _e68 = fullCycle_1;
    let _e71 = fullCycle_1;
    let _e72 = fullCycle_1;
    let _e75 = time_1;
    timeDamp = (pow(0.01f, (_e67 / _e68)) * smoothstep(_e71, (_e72 * 0.5f), _e75));
    let _e79 = d;
    let _e80 = dim;
    let _e86 = time_1;
    let _e91 = damp;
    let _e93 = timeDamp;
    return ((cos(((((_e79 / _e80) * 3.1415f) * 2f) - (_e86 * 20f))) * _e91) * _e93);
}

fn ripples(maxDist: f32, count: i32, radiusVariability: f32, time_2: f32, fullCycle_2: f32, u_2: vec2<f32>) -> f32 {
    var maxDist_1: f32;
    var count_1: i32;
    var radiusVariability_1: f32;
    var time_3: f32;
    var fullCycle_3: f32;
    var u_3: vec2<f32>;
    var total: f32 = 0f;
    var timeSlice: f32;
    var i: i32 = 0i;
    var id: f32;
    var h: vec2<f32>;
    var radius_2: f32;
    var center_2: vec2<f32>;
    var localTime: f32;

    maxDist_1 = maxDist;
    count_1 = count;
    radiusVariability_1 = radiusVariability;
    time_3 = time_2;
    fullCycle_3 = fullCycle_2;
    u_3 = u_2;
    let _e20 = time_3;
    let _e21 = fullCycle_3;
    let _e23 = count_1;
    timeSlice = floor(((_e20 / _e21) * f32(_e23)));
    loop {
        let _e30 = i;
        let _e31 = count_1;
        if !((_e30 <= _e31)) {
            break;
        }
        {
            let _e37 = timeSlice;
            let _e38 = i;
            id = (_e37 - f32(_e38));
            let _e42 = id;
            let _e43 = hash12_(_e42);
            h = _e43;
            let _e47 = radiusVariability_1;
            let _e48 = h;
            radius_2 = max(0.1f, (1f + ((_e47 * (fract((_e48.x * 41f)) - 0.5f)) * 2f)));
            let _e61 = h;
            let _e65 = maxDist_1;
            center_2 = (((_e61 - vec2(0.5f)) * _e65) * 2f);
            let _e70 = time_3;
            let _e71 = id;
            let _e73 = count_1;
            let _e76 = fullCycle_3;
            localTime = (_e70 - ((f32(_e71) / f32(_e73)) * _e76));
            let _e80 = total;
            let _e81 = center_2;
            let _e82 = radius_2;
            let _e83 = localTime;
            let _e84 = fullCycle_3;
            let _e85 = u_3;
            let _e86 = ripple(_e81, _e82, _e83, _e84, _e85);
            total = (_e80 + _e86);
        }
        continuing {
            let _e34 = i;
            i = (_e34 + 1i);
        }
    }
    let _e88 = total;
    return _e88;
}

fn ripplesNormal(maxDist_2: f32, count_2: i32, radiusVariability_2: f32, time_4: f32, fullCycle_4: f32, u_4: vec2<f32>) -> vec2<f32> {
    var maxDist_3: f32;
    var count_3: i32;
    var radiusVariability_3: f32;
    var time_5: f32;
    var fullCycle_5: f32;
    var u_5: vec2<f32>;
    var ri: f32;
    var delta: f32 = 0.0001f;
    var riX: f32;
    var riY: f32;

    maxDist_3 = maxDist_2;
    count_3 = count_2;
    radiusVariability_3 = radiusVariability_2;
    time_5 = time_4;
    fullCycle_5 = fullCycle_4;
    u_5 = u_4;
    let _e18 = maxDist_3;
    let _e19 = count_3;
    let _e20 = radiusVariability_3;
    let _e21 = time_5;
    let _e22 = fullCycle_5;
    let _e23 = u_5;
    let _e24 = ripples(_e18, _e19, _e20, _e21, _e22, _e23);
    ri = _e24;
    let _e28 = maxDist_3;
    let _e29 = count_3;
    let _e30 = radiusVariability_3;
    let _e31 = time_5;
    let _e32 = fullCycle_5;
    let _e33 = u_5;
    let _e34 = delta;
    let _e38 = ripples(_e28, _e29, _e30, _e31, _e32, (_e33 + vec2<f32>(_e34, 0f)));
    riX = _e38;
    let _e40 = maxDist_3;
    let _e41 = count_3;
    let _e42 = radiusVariability_3;
    let _e43 = time_5;
    let _e44 = fullCycle_5;
    let _e45 = u_5;
    let _e47 = delta;
    let _e50 = ripples(_e40, _e41, _e42, _e43, _e44, (_e45 + vec2<f32>(0f, _e47)));
    riY = _e50;
    let _e52 = riX;
    let _e53 = ri;
    let _e55 = delta;
    let _e57 = riY;
    let _e58 = ri;
    let _e60 = delta;
    return vec2<f32>(((_e52 - _e53) / _e55), ((_e57 - _e58) / _e60));
}

fn tf(m: mat3x3<f32>, u_6: vec2<f32>) -> vec2<f32> {
    var m_1: mat3x3<f32>;
    var u_7: vec2<f32>;

    m_1 = m;
    u_7 = u_6;
    let _e10 = m_1;
    let _e11 = u_7;
    return (_e10 * vec3<f32>(_e11.x, _e11.y, 1f)).xy;
}

fn rainPuddle(uv: vec2<f32>, outPos: vec2<f32>, mode: i32, spacing: f32, intensity: f32, count_4: i32, radiusVariability_4: f32, time_6: f32, lighting: f32, specular: f32, modelTransform: mat3x3<f32>) -> vec4<f32> {
    var uv_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var mode_1: i32;
    var spacing_1: f32;
    var intensity_1: f32;
    var count_5: i32;
    var radiusVariability_5: f32;
    var time_7: f32;
    var lighting_1: f32;
    var specular_1: f32;
    var modelTransform_1: mat3x3<f32>;
    var t: mat3x3<f32>;
    var u_8: vec2<f32>;
    var col: vec4<f32>;
    var ripplesN: vec2<f32>;
    var n: vec3<f32>;
    var duv: vec2<f32>;
    var lum: f32;
    var spec: f32;

    uv_1 = uv;
    outPos_1 = outPos;
    mode_1 = mode;
    spacing_1 = spacing;
    intensity_1 = intensity;
    count_5 = count_4;
    radiusVariability_5 = radiusVariability_4;
    time_7 = time_6;
    lighting_1 = lighting;
    specular_1 = specular;
    modelTransform_1 = modelTransform;
    let _e28 = modelTransform_1;
    t = _naga_inverse_3x3_f32(_e28);
    let _e31 = t;
    let _e32 = uv_1;
    let _e33 = tf(_e31, _e32);
    u_8 = _e33;
    let _e36 = spacing_1;
    let _e37 = count_5;
    let _e38 = radiusVariability_5;
    let _e39 = time_7;
    let _e43 = u_8;
    let _e44 = ripplesNormal(_e36, _e37, _e38, (_e39 * 1f), 4f, _e43);
    ripplesN = _e44;
    let _e46 = ripplesN;
    n = normalize(vec3<f32>(_e46.x, _e46.y, 1f));
    let _e53 = mode_1;
    if (_e53 == 2i) {
        {
            let _e56 = spacing_1;
            let _e57 = count_5;
            let _e58 = radiusVariability_5;
            let _e59 = time_7;
            let _e63 = u_8;
            let _e64 = ripples(_e56, _e57, _e58, (_e59 * 1f), 4f, _e63);
            let _e69 = vec3(((_e64 + 1f) * 0.5f));
            col = vec4<f32>(_e69.x, _e69.y, _e69.z, 1f);
        }
    } else {
        let _e75 = mode_1;
        if (_e75 == 1i) {
            {
                let _e78 = n;
                let _e80 = n;
                let _e82 = n;
                col = vec4<f32>(_e78.x, _e80.y, _e82.z, 1f);
            }
        } else {
            {
                let _e86 = modelTransform_1;
                let _e87 = u_8;
                let _e88 = ripplesN;
                let _e89 = intensity_1;
                let _e94 = tf(_e86, (_e87 + ((_e88 * _e89) * 0.02f)));
                duv = _e94;
                let _e96 = duv;
                let _e100 = global.U[0];
                let _e103 = duv;
                let _e112 = _mirror_wrap(((vec2<f32>((_e96.x / _e100.x), _e103.y) / vec2(2f)) + vec2(0.5f)));
                let _e113 = textureSample(t_source, samp, _e112);
                col = _e113;
            }
        }
    }
    let _e114 = n;
    let _e121 = lighting_1;
    lum = (dot(_e114, normalize(vec3<f32>(1f, 1f, 0f))) * _e121);
    let _e125 = n;
    let _e126 = u_8;
    let _e128 = u_8;
    let _e139 = specular_1;
    spec = ((pow(max(0f, dot(_e125, normalize(vec3<f32>(_e126.x, _e128.y, 1f)))), 9f) * 2f) * _e139);
    let _e142 = lum;
    let _e143 = spec;
    lum = (_e142 + _e143);
    let _e145 = col;
    let _e146 = lum;
    let _e147 = lum;
    let _e148 = lum;
    col = (_e145 + vec4<f32>(_e146, _e147, _e148, 1f));
    let _e152 = col;
    return _e152;
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
    let _e75 = global.U[7];
    let _e79 = global.U[8];
    let _e84 = global.U[9];
    let _e88 = global.U[10];
    let _e92 = global.U[11];
    let _e96 = global.U[12];
    let _e100 = global.U[13];
    let _e101 = _e100.xyz;
    let _e104 = global.U[14];
    let _e105 = _e104.xyz;
    let _e108 = global.U[15];
    let _e109 = _e108.xyz;
    let _e123 = rainPuddle((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e9.x, _e9.y, _e9.z), vec3<f32>(_e13.x, _e13.y, _e13.z), vec3<f32>(_e17.x, _e17.y, _e17.z))) * vec3<f32>(_e44.x, _e44.y, 1f)).xy, (((_e51 - vec2(0.5f)) * 2f) * vec2<f32>(_e59.x, 1f)), i32(_e66.x), _e71.x, _e75.x, i32(_e79.x), _e84.x, _e88.x, _e92.x, _e96.x, mat3x3<f32>(vec3<f32>(_e101.x, _e101.y, _e101.z), vec3<f32>(_e105.x, _e105.y, _e105.z), vec3<f32>(_e109.x, _e109.y, _e109.z)));
    fragColor = _e123;
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
