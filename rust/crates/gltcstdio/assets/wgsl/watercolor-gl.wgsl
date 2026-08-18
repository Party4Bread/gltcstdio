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
    let _e34 = textureSample(t_source, samp, ((vec2<f32>((_e18.x / _e22.x), _e25.y) / vec2(2f)) + vec2(0.5f)));
    let _e36 = luma(_e34.xyz);
    lum = _e36;
    let _e39 = balance_1;
    if (abs(_e39) >= 1f) {
        let _e43 = balance_1;
        intensityModifier = _e43;
    } else {
        {
            let _e44 = balance_1;
            if (_e44 >= 0f) {
                local = 0f;
            } else {
                let _e48 = balance_1;
                local = -(_e48);
            }
            let _e51 = local;
            a = _e51;
            let _e53 = balance_1;
            if (_e53 >= 0f) {
                let _e57 = balance_1;
                local_1 = (1f - _e57);
            } else {
                local_1 = 1f;
            }
            let _e61 = local_1;
            b = _e61;
            let _e63 = a;
            let _e64 = b;
            let _e65 = lum;
            intensityModifier = ((smoothstep(_e63, _e64, _e65) * 2f) - 1f);
        }
    }
    let _e71 = intensity_1;
    let _e72 = intensityModifier;
    intensity_1 = (_e71 * _e72);
    let _e74 = intensity_1;
    N = i32((abs(_e74) * 500f));
    let _e81 = intensity_1;
    step = (0.001f * sign(_e81));
    let _e85 = pos_1;
    let _e89 = global.U[0];
    let _e92 = pos_1;
    let _e101 = textureSample(t_source, samp, ((vec2<f32>((_e85.x / _e89.x), _e92.y) / vec2(2f)) + vec2(0.5f)));
    total = _e101;
    let _e103 = delta_1;
    d = (_e103 * 0.1f);
    let _e107 = pos_1;
    let _e109 = d;
    let _e111 = pos_1;
    let _e117 = global.U[0];
    let _e120 = pos_1;
    let _e122 = d;
    let _e124 = pos_1;
    let _e135 = textureSample(t_source, samp, ((vec2<f32>((vec2<f32>((_e107.x - _e109), _e111.y).x / _e117.x), vec2<f32>((_e120.x - _e122), _e124.y).y) / vec2(2f)) + vec2(0.5f)));
    cx0_ = _e135;
    let _e137 = pos_1;
    let _e139 = d;
    let _e141 = pos_1;
    let _e147 = global.U[0];
    let _e150 = pos_1;
    let _e152 = d;
    let _e154 = pos_1;
    let _e165 = textureSample(t_source, samp, ((vec2<f32>((vec2<f32>((_e137.x + _e139), _e141.y).x / _e147.x), vec2<f32>((_e150.x + _e152), _e154.y).y) / vec2(2f)) + vec2(0.5f)));
    cx1_ = _e165;
    let _e167 = pos_1;
    let _e169 = pos_1;
    let _e171 = d;
    let _e177 = global.U[0];
    let _e180 = pos_1;
    let _e182 = pos_1;
    let _e184 = d;
    let _e195 = textureSample(t_source, samp, ((vec2<f32>((vec2<f32>(_e167.x, (_e169.y - _e171)).x / _e177.x), vec2<f32>(_e180.x, (_e182.y - _e184)).y) / vec2(2f)) + vec2(0.5f)));
    cy0_ = _e195;
    let _e197 = pos_1;
    let _e199 = pos_1;
    let _e201 = d;
    let _e207 = global.U[0];
    let _e210 = pos_1;
    let _e212 = pos_1;
    let _e214 = d;
    let _e225 = textureSample(t_source, samp, ((vec2<f32>((vec2<f32>(_e197.x, (_e199.y + _e201)).x / _e207.x), vec2<f32>(_e210.x, (_e212.y + _e214)).y) / vec2(2f)) + vec2(0.5f)));
    cy1_ = _e225;
    let _e227 = cx1_;
    let _e229 = cx0_;
    let _e233 = d;
    let _e236 = cy1_;
    let _e238 = cy0_;
    let _e242 = d;
    grad = vec2<f32>(((length(_e227) - length(_e229)) / (2f * _e233)), ((length(_e236) - length(_e238)) / (2f * _e242)));
    let _e247 = grad;
    let _e251 = grad;
    if ((_e247.x == 0f) && (_e251.y == 0f)) {
        let _e256 = total;
        return _e256;
    }
    let _e257 = grad;
    grad = normalize(_e257);
    loop {
        let _e261 = i;
        let _e262 = N;
        if !((_e261 < _e262)) {
            break;
        }
        {
            let _e268 = pos_1;
            let _e270 = d;
            let _e272 = pos_1;
            let _e278 = global.U[0];
            let _e281 = pos_1;
            let _e283 = d;
            let _e285 = pos_1;
            let _e296 = textureSample(t_source, samp, ((vec2<f32>((vec2<f32>((_e268.x - _e270), _e272.y).x / _e278.x), vec2<f32>((_e281.x - _e283), _e285.y).y) / vec2(2f)) + vec2(0.5f)));
            cx0_1 = _e296;
            let _e298 = pos_1;
            let _e300 = d;
            let _e302 = pos_1;
            let _e308 = global.U[0];
            let _e311 = pos_1;
            let _e313 = d;
            let _e315 = pos_1;
            let _e326 = textureSample(t_source, samp, ((vec2<f32>((vec2<f32>((_e298.x + _e300), _e302.y).x / _e308.x), vec2<f32>((_e311.x + _e313), _e315.y).y) / vec2(2f)) + vec2(0.5f)));
            cx1_1 = _e326;
            let _e328 = pos_1;
            let _e330 = pos_1;
            let _e332 = d;
            let _e338 = global.U[0];
            let _e341 = pos_1;
            let _e343 = pos_1;
            let _e345 = d;
            let _e356 = textureSample(t_source, samp, ((vec2<f32>((vec2<f32>(_e328.x, (_e330.y - _e332)).x / _e338.x), vec2<f32>(_e341.x, (_e343.y - _e345)).y) / vec2(2f)) + vec2(0.5f)));
            cy0_1 = _e356;
            let _e358 = pos_1;
            let _e360 = pos_1;
            let _e362 = d;
            let _e368 = global.U[0];
            let _e371 = pos_1;
            let _e373 = pos_1;
            let _e375 = d;
            let _e386 = textureSample(t_source, samp, ((vec2<f32>((vec2<f32>(_e358.x, (_e360.y + _e362)).x / _e368.x), vec2<f32>(_e371.x, (_e373.y + _e375)).y) / vec2(2f)) + vec2(0.5f)));
            cy1_1 = _e386;
            let _e388 = cx1_1;
            let _e390 = cx0_1;
            let _e394 = d;
            let _e397 = cy1_1;
            let _e399 = cy0_1;
            let _e403 = d;
            g1_ = vec2<f32>(((length(_e388) - length(_e390)) / (2f * _e394)), ((length(_e397) - length(_e399)) / (2f * _e403)));
            let _e408 = g1_;
            let _e412 = g1_;
            if ((_e408.x == 0f) && (_e412.y == 0f)) {
                let _e417 = total;
                let _e418 = i;
                return (_e417 / vec4(f32((_e418 + 1i))));
            }
            let _e424 = grad;
            let _e426 = g1_;
            g2_ = (_e424 + (0.5f * normalize(_e426)));
            let _e431 = g2_;
            let _e435 = g2_;
            if ((_e431.x == 0f) && (_e435.y == 0f)) {
                let _e440 = total;
                let _e441 = i;
                return (_e440 / vec4(f32((_e441 + 1i))));
            }
            let _e447 = g2_;
            grad = normalize(_e447);
            let _e449 = pos_1;
            let _e450 = delta_1;
            let _e452 = step;
            let _e454 = grad;
            pos_1 = (_e449 + ((sign(_e450) * _e452) * _e454));
            let _e457 = pos_1;
            if (length(_e457) > 3f) {
                return vec4<f32>(1f, 0f, 0f, 1f);
            } else {
                let _e466 = pos_1;
                if (length(_e466) < 0.0001f) {
                    return vec4<f32>(0f, 1f, 0f, 1f);
                }
            }
            let _e475 = total;
            let _e476 = pos_1;
            let _e480 = global.U[0];
            let _e483 = pos_1;
            let _e492 = textureSample(t_source, samp, ((vec2<f32>((_e476.x / _e480.x), _e483.y) / vec2(2f)) + vec2(0.5f)));
            total = (_e475 + _e492);
        }
        continuing {
            let _e265 = i;
            i = (_e265 + 1i);
        }
    }
    let _e494 = total;
    let _e495 = N;
    return (_e494 / vec4(f32((_e495 + 1i))));
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
