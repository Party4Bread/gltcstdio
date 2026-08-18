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
var t_source: texture_2d<f32>;

fn getOffsetPos(transform: mat3x3<f32>, pos: vec2<f32>, k: f32, power: f32) -> vec2<f32> {
    var transform_1: mat3x3<f32>;
    var pos_1: vec2<f32>;
    var k_1: f32;
    var power_1: f32;
    var tScaleRot: mat2x2<f32>;
    var u: vec2<f32>;
    var v: vec2<f32>;
    var nu: vec2<f32>;
    var nv: vec2<f32>;
    var t: vec2<f32>;
    var tu: f32;
    var tv: f32;
    var scale: f32;
    var pu: f32;
    var kk: f32;

    transform_1 = transform;
    pos_1 = pos;
    k_1 = k;
    power_1 = power;
    let _e16 = transform_1[0];
    let _e17 = _e16.xy;
    let _e20 = transform_1[1];
    let _e21 = _e20.xy;
    tScaleRot = mat2x2<f32>(vec2<f32>(_e17.x, _e17.y), vec2<f32>(_e21.x, _e21.y));
    let _e30 = tScaleRot;
    u = (_e30 * vec2<f32>(1f, 0f));
    let _e36 = tScaleRot;
    v = (_e36 * vec2<f32>(0f, 1f));
    let _e42 = u;
    nu = normalize(_e42);
    let _e45 = v;
    nv = normalize(_e45);
    let _e52 = transform_1[2][0];
    let _e57 = transform_1[2][1];
    let _e59 = k_1;
    t = (vec2<f32>(_e52, _e57) * _e59);
    let _e62 = nu;
    let _e63 = t;
    tu = dot(_e62, _e63);
    let _e66 = nv;
    let _e67 = t;
    tv = dot(_e66, _e67);
    let _e70 = u;
    scale = length(_e70);
    let _e73 = nu;
    let _e74 = pos_1;
    pu = dot(_e73, _e74);
    let _e77 = pu;
    let _e78 = tu;
    let _e79 = scale;
    let _e82 = pu;
    let _e83 = tu;
    let _e84 = scale;
    if ((_e77 <= (_e78 - _e79)) || (_e82 >= (_e83 + _e84))) {
        let _e88 = pos_1;
        return _e88;
    }
    let _e90 = pu;
    let _e91 = tu;
    let _e93 = scale;
    let _e102 = power_1;
    kk = pow(((1f + cos((((_e90 - _e91) / _e93) * 3.1415927f))) / 2f), pow(1.07f, (-(_e102) * 100f)));
    let _e109 = pos_1;
    let _e110 = nv;
    let _e111 = kk;
    let _e113 = tv;
    return (_e109 - ((_e110 * _e111) * _e113));
}

fn rgbSpike(pos_2: vec2<f32>, outPos: vec2<f32>, mode: i32, power_2: f32, modelTransform: mat3x3<f32>, redTransform: mat3x3<f32>, greenTransform: mat3x3<f32>, blueTransform: mat3x3<f32>) -> vec4<f32> {
    var pos_3: vec2<f32>;
    var outPos_1: vec2<f32>;
    var mode_1: i32;
    var power_3: f32;
    var modelTransform_1: mat3x3<f32>;
    var redTransform_1: mat3x3<f32>;
    var greenTransform_1: mat3x3<f32>;
    var blueTransform_1: mat3x3<f32>;
    var col: vec4<f32>;
    var k_2: f32 = 1f;
    var rmt: mat3x3<f32>;
    var gmt: mat3x3<f32>;
    var bmt: mat3x3<f32>;
    var dir: vec2<f32>;
    var itr: vec2<f32>;
    var red: vec4<f32>;
    var green: vec4<f32>;
    var blue: vec4<f32>;
    var outColor: vec4<f32>;

    pos_3 = pos_2;
    outPos_1 = outPos;
    mode_1 = mode;
    power_3 = power_2;
    modelTransform_1 = modelTransform;
    redTransform_1 = redTransform;
    greenTransform_1 = greenTransform;
    blueTransform_1 = blueTransform;
    let _e22 = pos_3;
    let _e26 = global.U[0];
    let _e29 = pos_3;
    let _e38 = textureSample(t_source, samp, ((vec2<f32>((_e22.x / _e26.x), _e29.y) / vec2(2f)) + vec2(0.5f)));
    col = _e38;
    let _e42 = modelTransform_1;
    rmt = _e42;
    let _e44 = modelTransform_1;
    gmt = _e44;
    let _e46 = modelTransform_1;
    bmt = _e46;
    let _e48 = mode_1;
    if (_e48 == 1i) {
        {
            let _e53 = modelTransform_1[1];
            dir = normalize(_e53.xy);
            let _e59 = modelTransform_1[2];
            let _e62 = dir;
            let _e64 = dir;
            let _e67 = modelTransform_1[2];
            itr = (_e59.xy - ((2f * _e62) * dot(_e64, _e67.xy)));
            let _e75 = modelTransform_1[0];
            let _e78 = modelTransform_1[1];
            gmt = mat3x3<f32>(vec3<f32>(_e75.x, _e75.y, _e75.z), vec3<f32>(_e78.x, _e78.y, _e78.z), vec3<f32>(0f, 0f, 1f));
            let _e95 = modelTransform_1[0];
            let _e98 = modelTransform_1[1];
            let _e99 = itr;
            let _e103 = vec3<f32>(_e99.x, _e99.y, 1f);
            rmt = mat3x3<f32>(vec3<f32>(_e95.x, _e95.y, _e95.z), vec3<f32>(_e98.x, _e98.y, _e98.z), vec3<f32>(_e103.x, _e103.y, _e103.z));
        }
    } else {
        let _e117 = mode_1;
        if (_e117 == 2i) {
            {
                let _e122 = modelTransform_1[0];
                let _e125 = modelTransform_1[1];
                gmt = mat3x3<f32>(vec3<f32>(_e122.x, _e122.y, _e122.z), vec3<f32>(_e125.x, _e125.y, _e125.z), vec3<f32>(0f, 0f, 1f));
                let _e142 = modelTransform_1[0];
                let _e145 = modelTransform_1[1];
                let _e148 = modelTransform_1[2];
                let _e150 = -(_e148.xy);
                let _e154 = vec3<f32>(_e150.x, _e150.y, 1f);
                rmt = mat3x3<f32>(vec3<f32>(_e142.x, _e142.y, _e142.z), vec3<f32>(_e145.x, _e145.y, _e145.z), vec3<f32>(_e154.x, _e154.y, _e154.z));
            }
        }
    }
    let _e168 = rmt;
    let _e169 = redTransform_1;
    let _e171 = pos_3;
    let _e172 = k_2;
    let _e173 = power_3;
    let _e174 = getOffsetPos((_e168 * _e169), _e171, _e172, _e173);
    let _e178 = global.U[0];
    let _e181 = rmt;
    let _e182 = redTransform_1;
    let _e184 = pos_3;
    let _e185 = k_2;
    let _e186 = power_3;
    let _e187 = getOffsetPos((_e181 * _e182), _e184, _e185, _e186);
    let _e196 = textureSample(t_source, samp, ((vec2<f32>((_e174.x / _e178.x), _e187.y) / vec2(2f)) + vec2(0.5f)));
    red = _e196;
    let _e198 = gmt;
    let _e199 = greenTransform_1;
    let _e201 = pos_3;
    let _e202 = k_2;
    let _e203 = power_3;
    let _e204 = getOffsetPos((_e198 * _e199), _e201, _e202, _e203);
    let _e208 = global.U[0];
    let _e211 = gmt;
    let _e212 = greenTransform_1;
    let _e214 = pos_3;
    let _e215 = k_2;
    let _e216 = power_3;
    let _e217 = getOffsetPos((_e211 * _e212), _e214, _e215, _e216);
    let _e226 = textureSample(t_source, samp, ((vec2<f32>((_e204.x / _e208.x), _e217.y) / vec2(2f)) + vec2(0.5f)));
    green = _e226;
    let _e228 = bmt;
    let _e229 = blueTransform_1;
    let _e231 = pos_3;
    let _e232 = k_2;
    let _e233 = power_3;
    let _e234 = getOffsetPos((_e228 * _e229), _e231, _e232, _e233);
    let _e238 = global.U[0];
    let _e241 = bmt;
    let _e242 = blueTransform_1;
    let _e244 = pos_3;
    let _e245 = k_2;
    let _e246 = power_3;
    let _e247 = getOffsetPos((_e241 * _e242), _e244, _e245, _e246);
    let _e256 = textureSample(t_source, samp, ((vec2<f32>((_e234.x / _e238.x), _e247.y) / vec2(2f)) + vec2(0.5f)));
    blue = _e256;
    let _e258 = red;
    let _e260 = green;
    let _e262 = blue;
    let _e264 = red;
    let _e266 = green;
    let _e269 = blue;
    outColor = vec4<f32>(_e258.x, _e260.y, _e262.z, (((_e264.w + _e266.w) + _e269.w) / 3f));
    let _e276 = outColor;
    return _e276;
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
    let _e76 = _e75.xyz;
    let _e79 = global.U[8];
    let _e80 = _e79.xyz;
    let _e83 = global.U[9];
    let _e84 = _e83.xyz;
    let _e100 = global.U[10];
    let _e101 = _e100.xyz;
    let _e104 = global.U[11];
    let _e105 = _e104.xyz;
    let _e108 = global.U[12];
    let _e109 = _e108.xyz;
    let _e125 = global.U[13];
    let _e126 = _e125.xyz;
    let _e129 = global.U[14];
    let _e130 = _e129.xyz;
    let _e133 = global.U[15];
    let _e134 = _e133.xyz;
    let _e150 = global.U[16];
    let _e151 = _e150.xyz;
    let _e154 = global.U[17];
    let _e155 = _e154.xyz;
    let _e158 = global.U[18];
    let _e159 = _e158.xyz;
    let _e173 = rgbSpike((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e9.x, _e9.y, _e9.z), vec3<f32>(_e13.x, _e13.y, _e13.z), vec3<f32>(_e17.x, _e17.y, _e17.z))) * vec3<f32>(_e44.x, _e44.y, 1f)).xy, (((_e51 - vec2(0.5f)) * 2f) * vec2<f32>(_e59.x, 1f)), i32(_e66.x), _e71.x, mat3x3<f32>(vec3<f32>(_e76.x, _e76.y, _e76.z), vec3<f32>(_e80.x, _e80.y, _e80.z), vec3<f32>(_e84.x, _e84.y, _e84.z)), mat3x3<f32>(vec3<f32>(_e101.x, _e101.y, _e101.z), vec3<f32>(_e105.x, _e105.y, _e105.z), vec3<f32>(_e109.x, _e109.y, _e109.z)), mat3x3<f32>(vec3<f32>(_e126.x, _e126.y, _e126.z), vec3<f32>(_e130.x, _e130.y, _e130.z), vec3<f32>(_e134.x, _e134.y, _e134.z)), mat3x3<f32>(vec3<f32>(_e151.x, _e151.y, _e151.z), vec3<f32>(_e155.x, _e155.y, _e155.z), vec3<f32>(_e159.x, _e159.y, _e159.z)));
    fragColor = _e173;
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
