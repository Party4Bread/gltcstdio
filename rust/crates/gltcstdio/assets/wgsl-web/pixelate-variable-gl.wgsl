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
var t_palette: texture_2d<f32>;
@group(0) @binding(3) 
var t_source: texture_2d<f32>;

fn pvg_dither4x4_(x: i32, y: i32) -> f32 {
    var x_1: i32;
    var y_1: i32;
    var i: i32;

    x_1 = x;
    y_1 = y;
    let _e11 = x_1;
    let _e12 = y_1;
    i = (_e11 + (_e12 * 4i));
    let _e17 = i;
    if (_e17 == 0i) {
        return -0.4117647f;
    }
    let _e24 = i;
    if (_e24 == 1i) {
        return 0.11764706f;
    }
    let _e30 = i;
    if (_e30 == 2i) {
        return -0.29411766f;
    }
    let _e37 = i;
    if (_e37 == 3i) {
        return 0.1764706f;
    }
    let _e43 = i;
    if (_e43 == 4i) {
        return 0.29411766f;
    }
    let _e49 = i;
    if (_e49 == 5i) {
        return -0.1764706f;
    }
    let _e56 = i;
    if (_e56 == 6i) {
        return 0.4117647f;
    }
    let _e62 = i;
    if (_e62 == 7i) {
        return -0.05882353f;
    }
    let _e69 = i;
    if (_e69 == 8i) {
        return -0.23529412f;
    }
    let _e76 = i;
    if (_e76 == 9i) {
        return 0.23529412f;
    }
    let _e82 = i;
    if (_e82 == 10i) {
        return -0.3529412f;
    }
    let _e89 = i;
    if (_e89 == 11i) {
        return 0.11764706f;
    }
    let _e95 = i;
    if (_e95 == 12i) {
        return 0.47058824f;
    }
    let _e101 = i;
    if (_e101 == 13i) {
        return 0f;
    }
    let _e105 = i;
    if (_e105 == 14i) {
        return 0.3529412f;
    }
    return -0.11764706f;
}

fn pixelateVariable(pos: vec2<f32>, outPos: vec2<f32>, modelTransform: mat3x3<f32>, balance: f32, regularity: f32, dithering: f32, paletteDim: vec2<f32>) -> vec4<f32> {
    var pos_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var modelTransform_1: mat3x3<f32>;
    var balance_1: f32;
    var regularity_1: f32;
    var dithering_1: f32;
    var paletteDim_1: vec2<f32>;
    var resolution: f32;
    var sampledColor: vec4<f32>;
    var uu: vec2<f32> = vec2(0f);
    var scale: f32;
    var threshold: f32;
    var regularityScaled: f32;
    var i_1: i32 = 0i;
    var u: vec2<f32>;
    var local: f32;
    var scale2_: f32;
    var total: f32;
    var base: vec2<f32>;
    var j: i32;
    var k: i32;
    var other: vec4<f32>;
    var dist: f32;
    var colorCount: i32;
    var offset: vec2<f32>;
    var k_1: f32;
    var outCol: vec4<f32>;
    var n: i32;
    var minDist: f32 = 1000000000f;
    var i_2: i32 = 0i;
    var target_: vec4<f32>;
    var dist_1: f32;

    pos_1 = pos;
    outPos_1 = outPos;
    modelTransform_1 = modelTransform;
    balance_1 = balance;
    regularity_1 = regularity;
    dithering_1 = dithering;
    paletteDim_1 = paletteDim;
    let _e25 = modelTransform_1[0][0];
    let _e30 = modelTransform_1[0][1];
    resolution = length(vec2<f32>(_e25, _e30));
    let _e39 = resolution;
    scale = (1f / _e39);
    let _e43 = balance_1;
    threshold = ((0.5f + (_e43 * 0.5f)) * 1.717f);
    let _e50 = regularity_1;
    regularityScaled = (_e50 * 2f);
    loop {
        let _e56 = i_1;
        if !((_e56 < 5i)) {
            break;
        }
        {
            let _e63 = scale;
            scale = (_e63 * 2f);
            let _e66 = pos_1;
            let _e67 = scale;
            uu = floor(((_e66 / vec2(_e67)) + vec2(0.5f)));
            let _e74 = uu;
            let _e75 = scale;
            u = (_e74 * _e75);
            let _e78 = u;
            let _e82 = global.U[0];
            let _e85 = u;
            let _e95 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e78.x / _e82.x), _e85.y) / vec2(2f)) + vec2(0.5f)), 0f);
            sampledColor = _e95;
            let _e96 = regularityScaled;
            if (_e96 == 0f) {
                local = 0.0000001f;
            } else {
                let _e100 = regularityScaled;
                let _e101 = scale;
                local = (_e100 * _e101);
            }
            let _e104 = local;
            scale2_ = _e104;
            total = 0f;
            let _e108 = pos_1;
            let _e109 = scale2_;
            let _e116 = scale2_;
            base = (floor(((_e108 / vec2(_e109)) + vec2(0.5f))) * _e116);
            j = -1i;
            loop {
                let _e122 = j;
                if !((_e122 <= 1i)) {
                    break;
                }
                {
                    k = -1i;
                    loop {
                        let _e132 = k;
                        if !((_e132 <= 1i)) {
                            break;
                        }
                        {
                            let _e139 = base;
                            let _e140 = scale;
                            let _e143 = k;
                            let _e145 = j;
                            let _e153 = global.U[0];
                            let _e156 = base;
                            let _e157 = scale;
                            let _e160 = k;
                            let _e162 = j;
                            let _e176 = textureSampleLevel(t_source, samp, ((vec2<f32>(((_e139 + ((_e140 * 0.5f) * vec2<f32>(f32(_e143), f32(_e145)))).x / _e153.x), (_e156 + ((_e157 * 0.5f) * vec2<f32>(f32(_e160), f32(_e162)))).y) / vec2(2f)) + vec2(0.5f)), 0f);
                            other = _e176;
                            let _e178 = total;
                            let _e179 = sampledColor;
                            let _e181 = other;
                            total = (_e178 + length((_e179.xyz - _e181.xyz)));
                        }
                        continuing {
                            let _e136 = k;
                            k = (_e136 + 1i);
                        }
                    }
                }
                continuing {
                    let _e126 = j;
                    j = (_e126 + 1i);
                }
            }
            let _e186 = total;
            dist = (_e186 / 8f);
            let _e190 = dist;
            let _e191 = threshold;
            if (_e190 >= _e191) {
                break;
            }
        }
        continuing {
            let _e60 = i_1;
            i_1 = (_e60 + 1i);
        }
    }
    let _e193 = paletteDim_1;
    colorCount = max(i32(_e193.x), 1i);
    let _e199 = dithering_1;
    if (_e199 != 0f) {
        {
            let _e202 = uu;
            let _e209 = uu;
            offset = vec2<f32>((_e202.x - (floor((_e202.x / 4f)) * 4f)), (_e209.y - (floor((_e209.y / 4f)) * 4f)));
            let _e218 = offset;
            let _e221 = (_e218 + vec2(4f));
            let _e223 = vec2(4f);
            offset = (_e221 - (floor((_e221 / _e223)) * _e223));
            let _e228 = offset;
            let _e231 = offset;
            let _e234 = pvg_dither4x4_(i32(_e228.x), i32(_e231.y));
            let _e235 = dithering_1;
            let _e241 = colorCount;
            k_1 = ((((_e234 * _e235) * 3f) * 1.4f) / pow(f32(_e241), 0.5f));
            let _e247 = sampledColor;
            let _e249 = sampledColor;
            let _e252 = k_1;
            let _e254 = (_e249.xyz * (1f + _e252));
            sampledColor.x = _e254.x;
            sampledColor.y = _e254.y;
            sampledColor.z = _e254.z;
        }
    }
    let _e261 = sampledColor;
    outCol = _e261;
    let _e263 = paletteDim_1;
    n = i32(_e263.x);
    let _e267 = n;
    if (_e267 > 1i) {
        {
            loop {
                let _e274 = i_2;
                let _e275 = n;
                if !((_e274 < _e275)) {
                    break;
                }
                {
                    let _e281 = i_2;
                    let _e285 = textureLoad(t_palette, vec2<i32>(_e281, 0i), 0i);
                    target_ = _e285;
                    let _e287 = sampledColor;
                    let _e288 = target_;
                    dist_1 = length((_e287 - _e288));
                    let _e292 = dist_1;
                    let _e293 = minDist;
                    if (_e292 < _e293) {
                        {
                            let _e295 = dist_1;
                            minDist = _e295;
                            let _e296 = target_;
                            outCol = _e296;
                        }
                    }
                }
                continuing {
                    let _e278 = i_2;
                    i_2 = (_e278 + 1i);
                }
            }
        }
    }
    let _e297 = outCol;
    return _e297;
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
    let _e68 = _e67.xyz;
    let _e71 = global.U[7];
    let _e72 = _e71.xyz;
    let _e75 = global.U[8];
    let _e76 = _e75.xyz;
    let _e92 = global.U[9];
    let _e96 = global.U[10];
    let _e100 = global.U[11];
    let _e104 = global.U[4];
    let _e106 = pixelateVariable((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e10.x, _e10.y, _e10.z), vec3<f32>(_e14.x, _e14.y, _e14.z), vec3<f32>(_e18.x, _e18.y, _e18.z))) * vec3<f32>(_e45.x, _e45.y, 1f)).xy, (((_e52 - vec2(0.5f)) * 2f) * vec2<f32>(_e60.x, 1f)), mat3x3<f32>(vec3<f32>(_e68.x, _e68.y, _e68.z), vec3<f32>(_e72.x, _e72.y, _e72.z), vec3<f32>(_e76.x, _e76.y, _e76.z)), _e92.x, _e96.x, _e100.x, _e104.xy);
    fragColor = _e106;
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
