struct Params {
    U: array<vec4<f32>, 14>,
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

fn checkerboardLooper(uv: vec2<f32>, outPos: vec2<f32>, time: f32, mode: i32, dampening: f32, roundness: f32, color1_: vec4<f32>, color2_: vec4<f32>, border: f32, color3_: vec4<f32>, color4_: vec4<f32>) -> vec4<f32> {
    var uv_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var time_1: f32;
    var mode_1: i32;
    var dampening_1: f32;
    var roundness_1: f32;
    var color1_1: vec4<f32>;
    var color2_1: vec4<f32>;
    var border_1: f32;
    var color3_1: vec4<f32>;
    var color4_1: vec4<f32>;
    var t: f32;
    var phase: f32;
    var progress: f32;
    var bgInner: vec4<f32>;
    var fgInner: vec4<f32>;
    var bgBorder: vec4<f32>;
    var fgBorder: vec4<f32>;
    var cell: vec2<f32>;
    var parity: f32;
    var f: vec2<f32>;
    var local: f32;
    var local_1: f32;
    var ci: i32;
    var cj: i32;
    var flip: i32 = 0i;
    var e: f32;
    var rAnim: f32;
    var r: f32;
    var local_2: f32;
    var dir: f32;
    var angle: f32;
    var d: vec2<f32>;
    var ca: f32;
    var sa: f32;
    var rd: vec2<f32>;
    var q: vec2<f32>;
    var sdf: f32;
    var ri: f32;
    var qi: vec2<f32>;
    var sdfInner: f32;
    var bgCell: vec2<f32>;
    var bgPar: f32;
    var bd: vec2<f32>;

    uv_1 = uv;
    outPos_1 = outPos;
    time_1 = time;
    mode_1 = mode;
    dampening_1 = dampening;
    roundness_1 = roundness;
    color1_1 = color1_;
    color2_1 = color2_;
    border_1 = border;
    color3_1 = color3_;
    color4_1 = color4_;
    let _e27 = time_1;
    t = fract((_e27 * 0.5f));
    let _e33 = t;
    phase = step(0.5f, _e33);
    let _e36 = t;
    progress = fract((_e36 * 2f));
    let _e41 = color2_1;
    let _e42 = color1_1;
    let _e43 = phase;
    bgInner = mix(_e41, _e42, vec4(_e43));
    let _e47 = color1_1;
    let _e48 = color2_1;
    let _e49 = phase;
    fgInner = mix(_e47, _e48, vec4(_e49));
    let _e53 = color4_1;
    let _e54 = color3_1;
    let _e55 = phase;
    bgBorder = mix(_e53, _e54, vec4(_e55));
    let _e59 = color3_1;
    let _e60 = color4_1;
    let _e61 = phase;
    fgBorder = mix(_e59, _e60, vec4(_e61));
    let _e65 = uv_1;
    cell = floor(_e65);
    let _e68 = cell;
    let _e70 = cell;
    let _e72 = (_e68.x + _e70.y);
    parity = (_e72 - (floor((_e72 / 2f)) * 2f));
    let _e79 = parity;
    let _e80 = phase;
    if (abs((_e79 - _e80)) > 0.5f) {
        {
            let _e85 = uv_1;
            f = fract(_e85);
            let _e88 = f;
            let _e91 = f;
            let _e95 = f;
            let _e98 = f;
            if (min(_e88.x, (1f - _e91.x)) < min(_e95.y, (1f - _e98.y))) {
                let _e104 = cell;
                let _e106 = f;
                if (_e106.x < 0.5f) {
                    local = -1f;
                } else {
                    local = 1f;
                }
                let _e114 = local;
                cell.x = (_e104.x + _e114);
            } else {
                let _e117 = cell;
                let _e119 = f;
                if (_e119.y < 0.5f) {
                    local_1 = -1f;
                } else {
                    local_1 = 1f;
                }
                let _e127 = local_1;
                cell.y = (_e117.y + _e127);
            }
        }
    }
    let _e129 = cell;
    ci = i32(_e129.x);
    let _e133 = cell;
    cj = i32(_e133.y);
    let _e139 = mode_1;
    if ((_e139 & 1i) != 0i) {
        let _e144 = flip;
        let _e145 = phase;
        flip = (_e144 ^ i32(_e145));
    }
    let _e148 = mode_1;
    if ((_e148 & 2i) != 0i) {
        let _e153 = flip;
        let _e154 = ci;
        flip = (_e153 ^ (_e154 & 1i));
    }
    let _e158 = mode_1;
    if ((_e158 & 4i) != 0i) {
        let _e163 = flip;
        let _e164 = cj;
        flip = (_e163 ^ (_e164 & 1i));
    }
    let _e168 = mode_1;
    if ((_e168 & 8i) != 0i) {
        let _e173 = flip;
        let _e174 = cell;
        let _e179 = cell;
        let _e184 = (floor((_e174.x * 0.5f)) + floor((_e179.y * 0.5f)));
        flip = (_e173 ^ i32((_e184 - (floor((_e184 / 2f)) * 2f))));
    }
    let _e193 = dampening_1;
    e = (1f + (_e193 * 4f));
    let _e200 = progress;
    let _e202 = e;
    progress = (1f - pow((1f - _e200), _e202));
    let _e207 = progress;
    let _e212 = progress;
    rAnim = (smoothstep(0f, 0.1f, _e207) * (1f - smoothstep(0.9f, 1f, _e212)));
    let _e217 = roundness_1;
    let _e218 = rAnim;
    r = (_e217 * _e218);
    let _e221 = flip;
    if (_e221 != 0i) {
        local_2 = -1f;
    } else {
        local_2 = 1f;
    }
    let _e228 = local_2;
    dir = _e228;
    let _e230 = progress;
    let _e233 = dir;
    angle = ((_e230 * 1.5707963f) * _e233);
    let _e236 = uv_1;
    let _e237 = cell;
    d = (_e236 - (_e237 + vec2(0.5f)));
    let _e243 = angle;
    ca = cos(_e243);
    let _e246 = angle;
    sa = sin(_e246);
    let _e249 = ca;
    let _e250 = d;
    let _e253 = sa;
    let _e254 = d;
    let _e258 = sa;
    let _e260 = d;
    let _e263 = ca;
    let _e264 = d;
    rd = vec2<f32>(((_e249 * _e250.x) + (_e253 * _e254.y)), ((-(_e258) * _e260.x) + (_e263 * _e264.y)));
    let _e270 = rd;
    let _e275 = r;
    q = ((abs(_e270) - vec2(0.5f)) + vec2(_e275));
    let _e279 = q;
    let _e281 = q;
    let _e286 = q;
    let _e292 = r;
    sdf = ((min(max(_e279.x, _e281.y), 0f) + length(max(_e286, vec2(0f)))) - _e292);
    let _e295 = sdf;
    if (_e295 < 0f) {
        {
            let _e298 = border_1;
            if (_e298 > 0f) {
                {
                    let _e301 = r;
                    let _e303 = border_1;
                    ri = (_e301 * max((1f - (_e303 / 0.5f)), 0f));
                    let _e311 = rd;
                    let _e314 = border_1;
                    let _e318 = ri;
                    qi = ((abs(_e311) - vec2((0.5f - _e314))) + vec2(_e318));
                    let _e322 = qi;
                    let _e324 = qi;
                    let _e329 = qi;
                    let _e335 = ri;
                    sdfInner = ((min(max(_e322.x, _e324.y), 0f) + length(max(_e329, vec2(0f)))) - _e335);
                    let _e338 = sdfInner;
                    if (_e338 < 0f) {
                        let _e341 = fgInner;
                        return _e341;
                    }
                    let _e342 = fgBorder;
                    return _e342;
                }
            }
            let _e343 = fgInner;
            return _e343;
        }
    }
    let _e344 = uv_1;
    bgCell = floor(_e344);
    let _e347 = bgCell;
    let _e349 = bgCell;
    let _e351 = (_e347.x + _e349.y);
    bgPar = (_e351 - (floor((_e351 / 2f)) * 2f));
    let _e358 = bgPar;
    let _e359 = phase;
    if (abs((_e358 - _e359)) > 0.5f) {
        {
            let _e364 = uv_1;
            bd = (fract(_e364) - vec2(0.5f));
            let _e370 = border_1;
            let _e373 = bd;
            let _e377 = border_1;
            let _e380 = bd;
            let _e384 = border_1;
            if ((_e370 > 0f) && ((abs(_e373.x) > (0.5f - _e377)) || (abs(_e380.y) > (0.5f - _e384)))) {
                let _e389 = bgBorder;
                return _e389;
            }
            let _e390 = bgInner;
            return _e390;
        }
    }
    let _e391 = bgInner;
    return _e391;
}

fn main_1() {
    let _e7 = global.U[1];
    let _e8 = _e7.xyz;
    let _e11 = global.U[2];
    let _e12 = _e11.xyz;
    let _e15 = global.U[3];
    let _e16 = _e15.xyz;
    let _e31 = v_uv_1;
    let _e39 = global.U[0];
    let _e43 = (((_e31 - vec2(0.5f)) * 2f) * vec2<f32>(_e39.x, 1f));
    let _e50 = v_uv_1;
    let _e58 = global.U[0];
    let _e65 = global.U[5];
    let _e69 = global.U[6];
    let _e74 = global.U[7];
    let _e78 = global.U[8];
    let _e82 = global.U[9];
    let _e85 = global.U[10];
    let _e88 = global.U[11];
    let _e92 = global.U[12];
    let _e95 = global.U[13];
    let _e96 = checkerboardLooper((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e8.x, _e8.y, _e8.z), vec3<f32>(_e12.x, _e12.y, _e12.z), vec3<f32>(_e16.x, _e16.y, _e16.z))) * vec3<f32>(_e43.x, _e43.y, 1f)).xy, (((_e50 - vec2(0.5f)) * 2f) * vec2<f32>(_e58.x, 1f)), _e65.x, i32(_e69.x), _e74.x, _e78.x, _e82, _e85, _e88.x, _e92, _e95);
    fragColor = _e96;
    return;
}

@fragment 
fn main(@location(0) v_uv: vec2<f32>) -> FragmentOutput {
    v_uv_1 = v_uv;
    main_1();
    let _e11 = fragColor;
    return FragmentOutput(_e11);
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
