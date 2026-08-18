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

fn mashHash2_(c: vec2<f32>) -> vec2<f32> {
    var c_1: vec2<f32>;

    c_1 = c;
    let _e8 = c_1;
    let _e13 = c_1;
    return fract((sin(vec2<f32>(dot(_e8, vec2<f32>(127.1f, 311.7f)), dot(_e13, vec2<f32>(269.5f, 183.3f)))) * 43758.547f));
}

fn mashGL(pos: vec2<f32>, outPos: vec2<f32>, intensity: f32, balance: f32, modelTransform: mat3x3<f32>, objectTransform: mat3x3<f32>) -> vec4<f32> {
    var pos_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var intensity_1: f32;
    var balance_1: f32;
    var modelTransform_1: mat3x3<f32>;
    var objectTransform_1: mat3x3<f32>;
    var frag: vec2<f32>;
    var center: vec2<f32>;
    var inCol: vec4<f32>;
    var STEP: f32;
    var scaleM: f32;
    var cellLen: f32;
    var marchCell: f32;
    var marchBias: vec2<f32>;
    var stepLen: f32;
    var dir: vec2<f32>;
    var origdir: vec2<f32>;
    var dist: f32;
    var p: vec2<f32>;
    var q: vec2<f32>;
    var maxC: vec3<f32> = vec3(0f);
    var minC: vec3<f32> = vec3(1f);
    var sumV: f32 = 0f;
    var maxV: f32 = 0f;
    var k: f32 = 0f;
    var d: f32 = 0f;
    var i: i32 = 0i;
    var cell: vec2<f32>;
    var col: vec3<f32>;
    var vv: f32;
    var local: vec2<f32>;
    var insidness: f32;
    var outCol: vec4<f32>;
    var iCol: vec4<f32>;

    pos_1 = pos;
    outPos_1 = outPos;
    intensity_1 = intensity;
    balance_1 = balance;
    modelTransform_1 = modelTransform;
    objectTransform_1 = objectTransform;
    let _e18 = pos_1;
    frag = _e18;
    let _e22 = modelTransform_1[2];
    center = _e22.xy;
    let _e25 = frag;
    let _e29 = global.U[0];
    let _e32 = frag;
    let _e41 = textureSample(t_source, samp, ((vec2<f32>((_e25.x / _e29.x), _e32.y) / vec2(2f)) + vec2(0.5f)));
    inCol = _e41;
    let _e43 = intensity_1;
    STEP = (_e43 * 2f);
    let _e49 = modelTransform_1[0];
    scaleM = length(_e49.xy);
    let _e55 = objectTransform_1[0];
    cellLen = length(_e55.xy);
    let _e60 = cellLen;
    marchCell = (max(0f, (_e60 - 1f)) * 0.02f);
    let _e69 = objectTransform_1[2];
    marchBias = _e69.xy;
    let _e73 = STEP;
    stepLen = (0.001f * _e73);
    let _e76 = frag;
    let _e77 = center;
    dir = -(normalize((_e76 - _e77)));
    let _e82 = dir;
    origdir = _e82;
    let _e84 = center;
    let _e85 = frag;
    dist = length((_e84 - _e85));
    let _e89 = frag;
    p = _e89;
    let _e91 = p;
    q = _e91;
    loop {
        let _e109 = i;
        if !((_e109 < 400i)) {
            break;
        }
        {
            let _e116 = d;
            let _e117 = dist;
            if (_e116 >= _e117) {
                break;
            }
            let _e119 = q;
            let _e120 = dir;
            let _e121 = marchBias;
            let _e123 = stepLen;
            q = (_e119 + ((_e120 + _e121) * _e123));
            let _e126 = marchCell;
            if (_e126 > 0.000001f) {
                {
                    let _e129 = q;
                    let _e130 = marchCell;
                    cell = floor((_e129 / vec2(_e130)));
                    let _e135 = cell;
                    let _e139 = marchCell;
                    let _e141 = cell;
                    let _e142 = mashHash2_(_e141);
                    let _e146 = marchCell;
                    p = (((_e135 + vec2(0.5f)) * _e139) + (((_e142 - vec2(0.5f)) * _e146) * 6f));
                }
            } else {
                {
                    let _e151 = q;
                    p = _e151;
                }
            }
            let _e152 = p;
            let _e156 = global.U[0];
            let _e159 = p;
            let _e168 = textureSample(t_source, samp, ((vec2<f32>((_e152.x / _e156.x), _e159.y) / vec2(2f)) + vec2(0.5f)));
            col = _e168.xyz;
            let _e171 = col;
            let _e173 = col;
            let _e176 = col;
            vv = (((_e171.x + _e173.y) + _e176.z) / 3f);
            let _e182 = sumV;
            let _e183 = vv;
            sumV = (_e182 + _e183);
            let _e185 = maxC;
            let _e186 = col;
            maxC = max(_e185, _e186);
            let _e188 = minC;
            let _e189 = col;
            minC = min(_e188, _e189);
            let _e191 = k;
            let _e193 = vv;
            k = (_e191 + (0.001f * _e193));
            let _e196 = vv;
            let _e197 = maxV;
            if (_e196 > _e197) {
                let _e199 = vv;
                maxV = _e199;
            }
            let _e200 = maxV;
            let _e202 = (_e200 * 50f);
            if ((_e202 - (floor((_e202 / 2f)) * 2f)) < 1f) {
                let _e210 = origdir;
                local = normalize(vec2<f32>(_e210.x, 0f));
            } else {
                let _e216 = origdir;
                local = normalize(vec2<f32>(0f, _e216.y));
            }
            let _e221 = local;
            dir = _e221;
            let _e222 = d;
            let _e223 = stepLen;
            d = (_e222 + _e223);
        }
        continuing {
            let _e113 = i;
            i = (_e113 + 1i);
        }
    }
    let _e225 = k;
    let _e226 = STEP;
    let _e228 = scaleM;
    insidness = ((_e225 * _e226) / _e228);
    let _e232 = insidness;
    if (_e232 < 1f) {
        {
            let _e235 = minC;
            let _e236 = maxC;
            let _e239 = k;
            let _e243 = mix(_e235, _e236, vec3((1f - (3f * _e239))));
            iCol = vec4<f32>(_e243.x, _e243.y, _e243.z, 1f);
            let _e250 = balance_1;
            if (_e250 >= 0f) {
                {
                    let _e253 = iCol;
                    let _e254 = inCol;
                    let _e255 = balance_1;
                    outCol = mix(_e253, _e254, vec4(_e255));
                }
            } else {
                {
                    let _e258 = iCol;
                    let _e259 = inCol;
                    let _e262 = balance_1;
                    let _e268 = iCol;
                    let _e270 = balance_1;
                    let _e276 = (((_e258 * _e259) * min(1f, (-(_e262) * 2f))) + (_e268 * (1f + (_e270 * 0.6f)))).xyz;
                    let _e277 = inCol;
                    outCol = vec4<f32>(_e276.x, _e276.y, _e276.z, _e277.w);
                }
            }
        }
    } else {
        {
            let _e283 = frag;
            let _e287 = global.U[0];
            let _e290 = frag;
            let _e299 = textureSample(t_source, samp, ((vec2<f32>((_e283.x / _e287.x), _e290.y) / vec2(2f)) + vec2(0.5f)));
            outCol = _e299;
        }
    }
    let _e301 = inCol;
    outCol.w = _e301.w;
    let _e303 = outCol;
    let _e305 = outCol;
    let _e311 = clamp(_e305.xyz, vec3(0f), vec3(1f));
    outCol.x = _e311.x;
    outCol.y = _e311.y;
    outCol.z = _e311.z;
    let _e318 = outCol;
    return _e318;
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
    let _e66 = global.U[8];
    let _e70 = global.U[9];
    let _e74 = global.U[10];
    let _e75 = _e74.xyz;
    let _e78 = global.U[11];
    let _e79 = _e78.xyz;
    let _e82 = global.U[12];
    let _e83 = _e82.xyz;
    let _e99 = global.U[13];
    let _e100 = _e99.xyz;
    let _e103 = global.U[14];
    let _e104 = _e103.xyz;
    let _e107 = global.U[15];
    let _e108 = _e107.xyz;
    let _e122 = mashGL((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e9.x, _e9.y, _e9.z), vec3<f32>(_e13.x, _e13.y, _e13.z), vec3<f32>(_e17.x, _e17.y, _e17.z))) * vec3<f32>(_e44.x, _e44.y, 1f)).xy, (((_e51 - vec2(0.5f)) * 2f) * vec2<f32>(_e59.x, 1f)), _e66.x, _e70.x, mat3x3<f32>(vec3<f32>(_e75.x, _e75.y, _e75.z), vec3<f32>(_e79.x, _e79.y, _e79.z), vec3<f32>(_e83.x, _e83.y, _e83.z)), mat3x3<f32>(vec3<f32>(_e100.x, _e100.y, _e100.z), vec3<f32>(_e104.x, _e104.y, _e104.z), vec3<f32>(_e108.x, _e108.y, _e108.z)));
    fragColor = _e122;
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
