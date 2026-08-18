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

fn getOffsetPos(transform: mat3x3<f32>, pos: vec2<f32>, vignetting: f32) -> vec2<f32> {
    var transform_1: mat3x3<f32>;
    var pos_1: vec2<f32>;
    var vignetting_1: f32;
    var tPos: vec2<f32>;
    var dist: f32;

    transform_1 = transform;
    pos_1 = pos;
    vignetting_1 = vignetting;
    let _e12 = transform_1;
    let _e14 = pos_1;
    tPos = (_naga_inverse_3x3_f32(_e12) * vec3<f32>(_e14.x, _e14.y, 1f)).xy;
    let _e22 = pos_1;
    dist = length(_e22);
    let _e25 = dist;
    if (_e25 < 1f) {
        {
            let _e28 = pos_1;
            let _e29 = tPos;
            let _e31 = vignetting_1;
            let _e33 = dist;
            let _e34 = dist;
            tPos = mix(_e28, _e29, vec2((1f - (_e31 * (1f - (_e33 * _e34))))));
        }
    }
    let _e41 = tPos;
    return _e41;
}

fn colorOffsetGL(pos_2: vec2<f32>, outPos: vec2<f32>, vignetting_2: f32, blur: f32, color1_: vec4<f32>, color2_: vec4<f32>, modelTransform: mat3x3<f32>, modelTransform2_: mat3x3<f32>) -> vec4<f32> {
    var pos_3: vec2<f32>;
    var outPos_1: vec2<f32>;
    var vignetting_3: f32;
    var blur_1: f32;
    var color1_1: vec4<f32>;
    var color2_1: vec4<f32>;
    var modelTransform_1: mat3x3<f32>;
    var modelTransform2_1: mat3x3<f32>;
    var p1_: vec2<f32>;
    var p2_: vec2<f32>;
    var total: vec4<f32> = vec4<f32>(0f, 0f, 0f, 0f);
    var totalWeight: f32 = 0f;
    var N: f32 = 100f;
    var blurExp: f32;
    var i: f32 = 0f;
    var k: f32;
    var c1tone: vec4<f32>;
    var c2tone: vec4<f32>;
    var q1_: vec2<f32>;
    var q2_: vec2<f32>;
    var weight: f32;
    var s1_: vec4<f32>;
    var s2_: vec4<f32>;
    var c1_: vec4<f32>;
    var c2_: vec4<f32>;

    pos_3 = pos_2;
    outPos_1 = outPos;
    vignetting_3 = vignetting_2;
    blur_1 = blur;
    color1_1 = color1_;
    color2_1 = color2_;
    modelTransform_1 = modelTransform;
    modelTransform2_1 = modelTransform2_;
    let _e22 = blur_1;
    if (_e22 != 0f) {
        {
            let _e25 = modelTransform_1;
            let _e26 = pos_3;
            let _e27 = vignetting_3;
            let _e28 = getOffsetPos(_e25, _e26, _e27);
            p1_ = _e28;
            let _e30 = modelTransform2_1;
            let _e31 = pos_3;
            let _e32 = vignetting_3;
            let _e33 = getOffsetPos(_e30, _e31, _e32);
            p2_ = _e33;
            let _e45 = blur_1;
            blurExp = pow((_e45 * 2f), -4f);
            loop {
                let _e54 = i;
                let _e55 = N;
                if !((_e54 <= _e55)) {
                    break;
                }
                {
                    let _e61 = i;
                    let _e62 = N;
                    k = (_e61 / _e62);
                    let _e70 = color1_1;
                    let _e71 = k;
                    c1tone = mix(vec4<f32>(1f, 1f, 1f, 1f), _e70, vec4(_e71));
                    let _e80 = color2_1;
                    let _e81 = k;
                    c2tone = mix(vec4<f32>(1f, 1f, 1f, 1f), _e80, vec4(_e81));
                    let _e85 = pos_3;
                    let _e86 = p1_;
                    let _e87 = k;
                    q1_ = mix(_e85, _e86, vec2(_e87));
                    let _e91 = pos_3;
                    let _e92 = p2_;
                    let _e93 = k;
                    q2_ = mix(_e91, _e92, vec2(_e93));
                    let _e97 = k;
                    let _e98 = blurExp;
                    weight = pow(_e97, _e98);
                    let _e101 = totalWeight;
                    let _e102 = weight;
                    totalWeight = (_e101 + _e102);
                    let _e104 = q1_;
                    let _e108 = global.U[0];
                    let _e111 = q1_;
                    let _e120 = textureSample(t_source, samp, ((vec2<f32>((_e104.x / _e108.x), _e111.y) / vec2(2f)) + vec2(0.5f)));
                    s1_ = _e120;
                    let _e122 = total;
                    let _e124 = total;
                    let _e126 = c1tone;
                    let _e128 = s1_;
                    let _e131 = weight;
                    let _e133 = (_e124.xyz + ((_e126.xyz * _e128.xyz) * _e131));
                    total.x = _e133.x;
                    total.y = _e133.y;
                    total.z = _e133.z;
                    let _e141 = total;
                    let _e143 = s1_;
                    let _e145 = weight;
                    total.w = (_e141.w + (_e143.w * _e145));
                    let _e148 = q2_;
                    let _e152 = global.U[0];
                    let _e155 = q2_;
                    let _e164 = textureSample(t_source, samp, ((vec2<f32>((_e148.x / _e152.x), _e155.y) / vec2(2f)) + vec2(0.5f)));
                    s2_ = _e164;
                    let _e166 = total;
                    let _e168 = total;
                    let _e170 = c2tone;
                    let _e172 = s2_;
                    let _e175 = weight;
                    let _e177 = (_e168.xyz + ((_e170.xyz * _e172.xyz) * _e175));
                    total.x = _e177.x;
                    total.y = _e177.y;
                    total.z = _e177.z;
                    let _e185 = total;
                    let _e187 = s2_;
                    let _e189 = weight;
                    total.w = (_e185.w + (_e187.w * _e189));
                }
                continuing {
                    let _e58 = i;
                    i = (_e58 + 1f);
                }
            }
            let _e192 = total;
            let _e193 = totalWeight;
            let _e196 = blur_1;
            return (_e192 / vec4((_e193 * mix(1f, 1.5f, _e196))));
        }
    } else {
        {
            let _e201 = modelTransform_1;
            let _e202 = pos_3;
            let _e203 = vignetting_3;
            let _e204 = getOffsetPos(_e201, _e202, _e203);
            let _e208 = global.U[0];
            let _e211 = modelTransform_1;
            let _e212 = pos_3;
            let _e213 = vignetting_3;
            let _e214 = getOffsetPos(_e211, _e212, _e213);
            let _e223 = textureSample(t_source, samp, ((vec2<f32>((_e204.x / _e208.x), _e214.y) / vec2(2f)) + vec2(0.5f)));
            c1_ = _e223;
            let _e225 = modelTransform2_1;
            let _e226 = pos_3;
            let _e227 = vignetting_3;
            let _e228 = getOffsetPos(_e225, _e226, _e227);
            let _e232 = global.U[0];
            let _e235 = modelTransform2_1;
            let _e236 = pos_3;
            let _e237 = vignetting_3;
            let _e238 = getOffsetPos(_e235, _e236, _e237);
            let _e247 = textureSample(t_source, samp, ((vec2<f32>((_e228.x / _e232.x), _e238.y) / vec2(2f)) + vec2(0.5f)));
            c2_ = _e247;
            let _e249 = c1_;
            let _e250 = color1_1;
            let _e252 = c2_;
            let _e253 = color2_1;
            let _e256 = ((_e249 * _e250) + (_e252 * _e253)).xyz;
            let _e257 = c1_;
            let _e259 = c2_;
            return vec4<f32>(_e256.x, _e256.y, _e256.z, ((_e257.w + _e259.w) * 0.5f));
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
    let _e70 = global.U[6];
    let _e74 = global.U[7];
    let _e77 = global.U[8];
    let _e80 = global.U[9];
    let _e81 = _e80.xyz;
    let _e84 = global.U[10];
    let _e85 = _e84.xyz;
    let _e88 = global.U[11];
    let _e89 = _e88.xyz;
    let _e105 = global.U[12];
    let _e106 = _e105.xyz;
    let _e109 = global.U[13];
    let _e110 = _e109.xyz;
    let _e113 = global.U[14];
    let _e114 = _e113.xyz;
    let _e128 = colorOffsetGL((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e9.x, _e9.y, _e9.z), vec3<f32>(_e13.x, _e13.y, _e13.z), vec3<f32>(_e17.x, _e17.y, _e17.z))) * vec3<f32>(_e44.x, _e44.y, 1f)).xy, (((_e51 - vec2(0.5f)) * 2f) * vec2<f32>(_e59.x, 1f)), _e66.x, _e70.x, _e74, _e77, mat3x3<f32>(vec3<f32>(_e81.x, _e81.y, _e81.z), vec3<f32>(_e85.x, _e85.y, _e85.z), vec3<f32>(_e89.x, _e89.y, _e89.z)), mat3x3<f32>(vec3<f32>(_e106.x, _e106.y, _e106.z), vec3<f32>(_e110.x, _e110.y, _e110.z), vec3<f32>(_e114.x, _e114.y, _e114.z)));
    fragColor = _e128;
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
