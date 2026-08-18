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
    let _e42 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e25.x / _e29.x), _e32.y) / vec2(2f)) + vec2(0.5f)), 0f);
    inCol = _e42;
    let _e44 = intensity_1;
    STEP = (_e44 * 2f);
    let _e50 = modelTransform_1[0];
    scaleM = length(_e50.xy);
    let _e56 = objectTransform_1[0];
    cellLen = length(_e56.xy);
    let _e61 = cellLen;
    marchCell = (max(0f, (_e61 - 1f)) * 0.02f);
    let _e70 = objectTransform_1[2];
    marchBias = _e70.xy;
    let _e74 = STEP;
    stepLen = (0.001f * _e74);
    let _e77 = frag;
    let _e78 = center;
    dir = -(normalize((_e77 - _e78)));
    let _e83 = dir;
    origdir = _e83;
    let _e85 = center;
    let _e86 = frag;
    dist = length((_e85 - _e86));
    let _e90 = frag;
    p = _e90;
    let _e92 = p;
    q = _e92;
    loop {
        let _e110 = i;
        if !((_e110 < 400i)) {
            break;
        }
        {
            let _e117 = d;
            let _e118 = dist;
            if (_e117 >= _e118) {
                break;
            }
            let _e120 = q;
            let _e121 = dir;
            let _e122 = marchBias;
            let _e124 = stepLen;
            q = (_e120 + ((_e121 + _e122) * _e124));
            let _e127 = marchCell;
            if (_e127 > 0.000001f) {
                {
                    let _e130 = q;
                    let _e131 = marchCell;
                    cell = floor((_e130 / vec2(_e131)));
                    let _e136 = cell;
                    let _e140 = marchCell;
                    let _e142 = cell;
                    let _e143 = mashHash2_(_e142);
                    let _e147 = marchCell;
                    p = (((_e136 + vec2(0.5f)) * _e140) + (((_e143 - vec2(0.5f)) * _e147) * 6f));
                }
            } else {
                {
                    let _e152 = q;
                    p = _e152;
                }
            }
            let _e153 = p;
            let _e157 = global.U[0];
            let _e160 = p;
            let _e170 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e153.x / _e157.x), _e160.y) / vec2(2f)) + vec2(0.5f)), 0f);
            col = _e170.xyz;
            let _e173 = col;
            let _e175 = col;
            let _e178 = col;
            vv = (((_e173.x + _e175.y) + _e178.z) / 3f);
            let _e184 = sumV;
            let _e185 = vv;
            sumV = (_e184 + _e185);
            let _e187 = maxC;
            let _e188 = col;
            maxC = max(_e187, _e188);
            let _e190 = minC;
            let _e191 = col;
            minC = min(_e190, _e191);
            let _e193 = k;
            let _e195 = vv;
            k = (_e193 + (0.001f * _e195));
            let _e198 = vv;
            let _e199 = maxV;
            if (_e198 > _e199) {
                let _e201 = vv;
                maxV = _e201;
            }
            let _e202 = maxV;
            let _e204 = (_e202 * 50f);
            if ((_e204 - (floor((_e204 / 2f)) * 2f)) < 1f) {
                let _e212 = origdir;
                local = normalize(vec2<f32>(_e212.x, 0f));
            } else {
                let _e218 = origdir;
                local = normalize(vec2<f32>(0f, _e218.y));
            }
            let _e223 = local;
            dir = _e223;
            let _e224 = d;
            let _e225 = stepLen;
            d = (_e224 + _e225);
        }
        continuing {
            let _e114 = i;
            i = (_e114 + 1i);
        }
    }
    let _e227 = k;
    let _e228 = STEP;
    let _e230 = scaleM;
    insidness = ((_e227 * _e228) / _e230);
    let _e234 = insidness;
    if (_e234 < 1f) {
        {
            let _e237 = minC;
            let _e238 = maxC;
            let _e241 = k;
            let _e245 = mix(_e237, _e238, vec3((1f - (3f * _e241))));
            iCol = vec4<f32>(_e245.x, _e245.y, _e245.z, 1f);
            let _e252 = balance_1;
            if (_e252 >= 0f) {
                {
                    let _e255 = iCol;
                    let _e256 = inCol;
                    let _e257 = balance_1;
                    outCol = mix(_e255, _e256, vec4(_e257));
                }
            } else {
                {
                    let _e260 = iCol;
                    let _e261 = inCol;
                    let _e264 = balance_1;
                    let _e270 = iCol;
                    let _e272 = balance_1;
                    let _e278 = (((_e260 * _e261) * min(1f, (-(_e264) * 2f))) + (_e270 * (1f + (_e272 * 0.6f)))).xyz;
                    let _e279 = inCol;
                    outCol = vec4<f32>(_e278.x, _e278.y, _e278.z, _e279.w);
                }
            }
        }
    } else {
        {
            let _e285 = frag;
            let _e289 = global.U[0];
            let _e292 = frag;
            let _e302 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e285.x / _e289.x), _e292.y) / vec2(2f)) + vec2(0.5f)), 0f);
            outCol = _e302;
        }
    }
    let _e304 = inCol;
    outCol.w = _e304.w;
    let _e306 = outCol;
    let _e308 = outCol;
    let _e314 = clamp(_e308.xyz, vec3(0f), vec3(1f));
    outCol.x = _e314.x;
    outCol.y = _e314.y;
    outCol.z = _e314.z;
    let _e321 = outCol;
    return _e321;
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
