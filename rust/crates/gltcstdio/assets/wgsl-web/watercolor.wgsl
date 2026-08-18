struct Params {
    U: array<vec4<f32>, 9>,
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

fn luma(c: vec3<f32>) -> f32 {
    var c_1: vec3<f32>;

    c_1 = c;
    let _e9 = c_1;
    let _e13 = c_1;
    let _e18 = c_1;
    return (((0.2989f * _e9.x) + (0.587f * _e13.y)) + (0.114f * _e18.z));
}

fn watercolor(pos: vec2<f32>, outPos: vec2<f32>, sourceDim: vec2<f32>, intensity: f32, delta: f32, balance: f32) -> vec4<f32> {
    var pos_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var sourceDim_1: vec2<f32>;
    var intensity_1: f32;
    var delta_1: f32;
    var balance_1: f32;
    var lum: f32;
    var intensityModifier: f32;
    var local: f32;
    var a: f32;
    var local_1: f32;
    var b: f32;
    var N: i32;
    var step: f32;
    var total: vec4<f32>;
    var d: f32;
    var cx0_: vec4<f32>;
    var cx1_: vec4<f32>;
    var cy0_: vec4<f32>;
    var cy1_: vec4<f32>;
    var grad: vec2<f32>;
    var i: i32 = 0i;
    var cx0_1: vec4<f32>;
    var cx1_1: vec4<f32>;
    var cy0_1: vec4<f32>;
    var cy1_1: vec4<f32>;
    var g1_: vec2<f32>;
    var g2_: vec2<f32>;

    pos_1 = pos;
    outPos_1 = outPos;
    sourceDim_1 = sourceDim;
    intensity_1 = intensity;
    delta_1 = delta;
    balance_1 = balance;
    let _e18 = pos_1;
    let _e22 = global.U[0];
    let _e25 = pos_1;
    let _e35 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e18.x / _e22.x), _e25.y) / vec2(2f)) + vec2(0.5f)), 0f);
    let _e37 = luma(_e35.xyz);
    lum = _e37;
    let _e40 = balance_1;
    if (abs(_e40) >= 1f) {
        let _e44 = balance_1;
        intensityModifier = _e44;
    } else {
        {
            let _e45 = balance_1;
            if (_e45 >= 0f) {
                local = 0f;
            } else {
                let _e49 = balance_1;
                local = -(_e49);
            }
            let _e52 = local;
            a = _e52;
            let _e54 = balance_1;
            if (_e54 >= 0f) {
                let _e58 = balance_1;
                local_1 = (1f - _e58);
            } else {
                local_1 = 1f;
            }
            let _e62 = local_1;
            b = _e62;
            let _e64 = a;
            let _e65 = b;
            let _e66 = lum;
            intensityModifier = ((smoothstep(_e64, _e65, _e66) * 2f) - 1f);
        }
    }
    let _e72 = intensity_1;
    let _e73 = intensityModifier;
    intensity_1 = (_e72 * _e73);
    let _e75 = intensity_1;
    N = i32((abs(_e75) * 500f));
    let _e82 = intensity_1;
    step = (0.001f * sign(_e82));
    let _e86 = pos_1;
    let _e90 = global.U[0];
    let _e93 = pos_1;
    let _e103 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e86.x / _e90.x), _e93.y) / vec2(2f)) + vec2(0.5f)), 0f);
    total = _e103;
    let _e105 = delta_1;
    d = (_e105 * 0.1f);
    let _e109 = pos_1;
    let _e111 = d;
    let _e113 = pos_1;
    let _e119 = global.U[0];
    let _e122 = pos_1;
    let _e124 = d;
    let _e126 = pos_1;
    let _e138 = textureSampleLevel(t_source, samp, ((vec2<f32>((vec2<f32>((_e109.x - _e111), _e113.y).x / _e119.x), vec2<f32>((_e122.x - _e124), _e126.y).y) / vec2(2f)) + vec2(0.5f)), 0f);
    cx0_ = _e138;
    let _e140 = pos_1;
    let _e142 = d;
    let _e144 = pos_1;
    let _e150 = global.U[0];
    let _e153 = pos_1;
    let _e155 = d;
    let _e157 = pos_1;
    let _e169 = textureSampleLevel(t_source, samp, ((vec2<f32>((vec2<f32>((_e140.x + _e142), _e144.y).x / _e150.x), vec2<f32>((_e153.x + _e155), _e157.y).y) / vec2(2f)) + vec2(0.5f)), 0f);
    cx1_ = _e169;
    let _e171 = pos_1;
    let _e173 = pos_1;
    let _e175 = d;
    let _e181 = global.U[0];
    let _e184 = pos_1;
    let _e186 = pos_1;
    let _e188 = d;
    let _e200 = textureSampleLevel(t_source, samp, ((vec2<f32>((vec2<f32>(_e171.x, (_e173.y - _e175)).x / _e181.x), vec2<f32>(_e184.x, (_e186.y - _e188)).y) / vec2(2f)) + vec2(0.5f)), 0f);
    cy0_ = _e200;
    let _e202 = pos_1;
    let _e204 = pos_1;
    let _e206 = d;
    let _e212 = global.U[0];
    let _e215 = pos_1;
    let _e217 = pos_1;
    let _e219 = d;
    let _e231 = textureSampleLevel(t_source, samp, ((vec2<f32>((vec2<f32>(_e202.x, (_e204.y + _e206)).x / _e212.x), vec2<f32>(_e215.x, (_e217.y + _e219)).y) / vec2(2f)) + vec2(0.5f)), 0f);
    cy1_ = _e231;
    let _e233 = cx1_;
    let _e235 = cx0_;
    let _e239 = d;
    let _e242 = cy1_;
    let _e244 = cy0_;
    let _e248 = d;
    grad = vec2<f32>(((length(_e233) - length(_e235)) / (2f * _e239)), ((length(_e242) - length(_e244)) / (2f * _e248)));
    let _e253 = grad;
    let _e257 = grad;
    if ((_e253.x == 0f) && (_e257.y == 0f)) {
        let _e262 = total;
        return _e262;
    }
    let _e263 = grad;
    grad = normalize(_e263);
    loop {
        let _e267 = i;
        let _e268 = N;
        if !((_e267 < _e268)) {
            break;
        }
        {
            let _e274 = pos_1;
            let _e276 = d;
            let _e278 = pos_1;
            let _e284 = global.U[0];
            let _e287 = pos_1;
            let _e289 = d;
            let _e291 = pos_1;
            let _e303 = textureSampleLevel(t_source, samp, ((vec2<f32>((vec2<f32>((_e274.x - _e276), _e278.y).x / _e284.x), vec2<f32>((_e287.x - _e289), _e291.y).y) / vec2(2f)) + vec2(0.5f)), 0f);
            cx0_1 = _e303;
            let _e305 = pos_1;
            let _e307 = d;
            let _e309 = pos_1;
            let _e315 = global.U[0];
            let _e318 = pos_1;
            let _e320 = d;
            let _e322 = pos_1;
            let _e334 = textureSampleLevel(t_source, samp, ((vec2<f32>((vec2<f32>((_e305.x + _e307), _e309.y).x / _e315.x), vec2<f32>((_e318.x + _e320), _e322.y).y) / vec2(2f)) + vec2(0.5f)), 0f);
            cx1_1 = _e334;
            let _e336 = pos_1;
            let _e338 = pos_1;
            let _e340 = d;
            let _e346 = global.U[0];
            let _e349 = pos_1;
            let _e351 = pos_1;
            let _e353 = d;
            let _e365 = textureSampleLevel(t_source, samp, ((vec2<f32>((vec2<f32>(_e336.x, (_e338.y - _e340)).x / _e346.x), vec2<f32>(_e349.x, (_e351.y - _e353)).y) / vec2(2f)) + vec2(0.5f)), 0f);
            cy0_1 = _e365;
            let _e367 = pos_1;
            let _e369 = pos_1;
            let _e371 = d;
            let _e377 = global.U[0];
            let _e380 = pos_1;
            let _e382 = pos_1;
            let _e384 = d;
            let _e396 = textureSampleLevel(t_source, samp, ((vec2<f32>((vec2<f32>(_e367.x, (_e369.y + _e371)).x / _e377.x), vec2<f32>(_e380.x, (_e382.y + _e384)).y) / vec2(2f)) + vec2(0.5f)), 0f);
            cy1_1 = _e396;
            let _e398 = cx1_1;
            let _e400 = cx0_1;
            let _e404 = d;
            let _e407 = cy1_1;
            let _e409 = cy0_1;
            let _e413 = d;
            g1_ = vec2<f32>(((length(_e398) - length(_e400)) / (2f * _e404)), ((length(_e407) - length(_e409)) / (2f * _e413)));
            let _e418 = g1_;
            let _e422 = g1_;
            if ((_e418.x == 0f) && (_e422.y == 0f)) {
                let _e427 = total;
                let _e428 = i;
                return (_e427 / vec4(f32((_e428 + 1i))));
            }
            let _e434 = grad;
            let _e436 = g1_;
            g2_ = (_e434 + (0.5f * normalize(_e436)));
            let _e441 = g2_;
            let _e445 = g2_;
            if ((_e441.x == 0f) && (_e445.y == 0f)) {
                let _e450 = total;
                let _e451 = i;
                return (_e450 / vec4(f32((_e451 + 1i))));
            }
            let _e457 = g2_;
            grad = normalize(_e457);
            let _e459 = pos_1;
            let _e460 = delta_1;
            let _e462 = step;
            let _e464 = grad;
            pos_1 = (_e459 + ((sign(_e460) * _e462) * _e464));
            let _e467 = pos_1;
            if (length(_e467) > 3f) {
                return vec4<f32>(1f, 0f, 0f, 1f);
            } else {
                let _e476 = pos_1;
                if (length(_e476) < 0.0001f) {
                    return vec4<f32>(0f, 1f, 0f, 1f);
                }
            }
            let _e485 = total;
            let _e486 = pos_1;
            let _e490 = global.U[0];
            let _e493 = pos_1;
            let _e503 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e486.x / _e490.x), _e493.y) / vec2(2f)) + vec2(0.5f)), 0f);
            total = (_e485 + _e503);
        }
        continuing {
            let _e271 = i;
            i = (_e271 + 1i);
        }
    }
    let _e505 = total;
    let _e506 = N;
    return (_e505 / vec4(f32((_e506 + 1i))));
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
    let _e66 = global.U[4];
    let _e70 = global.U[6];
    let _e74 = global.U[7];
    let _e78 = global.U[8];
    let _e80 = watercolor((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e9.x, _e9.y, _e9.z), vec3<f32>(_e13.x, _e13.y, _e13.z), vec3<f32>(_e17.x, _e17.y, _e17.z))) * vec3<f32>(_e44.x, _e44.y, 1f)).xy, (((_e51 - vec2(0.5f)) * 2f) * vec2<f32>(_e59.x, 1f)), _e66.xy, _e70.x, _e74.x, _e78.x);
    fragColor = _e80;
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
