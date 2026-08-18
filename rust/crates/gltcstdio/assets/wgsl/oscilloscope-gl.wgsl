struct Params {
    U: array<vec4<f32>, 11>,
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

fn osc_getStart(p: vec2<f32>, dir: vec2<f32>, dim: vec2<f32>) -> vec2<f32> {
    var p_1: vec2<f32>;
    var dir_1: vec2<f32>;
    var dim_1: vec2<f32>;
    var local: f32;
    var kx1_: f32;
    var local_1: f32;
    var kx2_: f32;
    var local_2: f32;
    var ky1_: f32;
    var local_3: f32;
    var ky2_: f32;
    var k: f32;

    p_1 = p;
    dir_1 = dir;
    dim_1 = dim;
    let _e12 = dir_1;
    if (_e12.x == 0f) {
        local = -1f;
    } else {
        let _e18 = dim_1;
        let _e21 = p_1;
        let _e24 = dir_1;
        local = ((-(_e18.x) - _e21.x) / _e24.x);
    }
    let _e28 = local;
    kx1_ = _e28;
    let _e30 = dir_1;
    if (_e30.x == 0f) {
        local_1 = -1f;
    } else {
        let _e36 = dim_1;
        let _e38 = p_1;
        let _e41 = dir_1;
        local_1 = ((_e36.x - _e38.x) / _e41.x);
    }
    let _e45 = local_1;
    kx2_ = _e45;
    let _e47 = dir_1;
    if (_e47.y == 0f) {
        local_2 = -1f;
    } else {
        let _e53 = dim_1;
        let _e56 = p_1;
        let _e59 = dir_1;
        local_2 = ((-(_e53.y) - _e56.y) / _e59.y);
    }
    let _e63 = local_2;
    ky1_ = _e63;
    let _e65 = dir_1;
    if (_e65.y == 0f) {
        local_3 = -1f;
    } else {
        let _e71 = dim_1;
        let _e73 = p_1;
        let _e76 = dir_1;
        local_3 = ((_e71.y - _e73.y) / _e76.y);
    }
    let _e80 = local_3;
    ky2_ = _e80;
    let _e82 = kx1_;
    k = _e82;
    let _e84 = k;
    let _e87 = kx2_;
    let _e90 = kx2_;
    let _e91 = k;
    if ((_e84 < 0f) || ((_e87 >= 0f) && (_e90 < _e91))) {
        let _e95 = kx2_;
        k = _e95;
    }
    let _e96 = k;
    let _e99 = ky2_;
    let _e102 = ky2_;
    let _e103 = k;
    if ((_e96 < 0f) || ((_e99 >= 0f) && (_e102 < _e103))) {
        let _e107 = ky2_;
        k = _e107;
    }
    let _e108 = k;
    let _e111 = ky1_;
    let _e114 = ky1_;
    let _e115 = k;
    if ((_e108 < 0f) || ((_e111 >= 0f) && (_e114 < _e115))) {
        let _e119 = ky1_;
        k = _e119;
    }
    let _e120 = p_1;
    let _e121 = k;
    let _e122 = dir_1;
    return (_e120 + (_e121 * _e122));
}

fn oscilloscope(pos: vec2<f32>, outPos: vec2<f32>, intensity: f32, thickness: f32, angle: f32, color1_: vec4<f32>, color2_: vec4<f32>, sourceDim: vec2<f32>) -> vec4<f32> {
    var pos_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var intensity_1: f32;
    var thickness_1: f32;
    var angle_1: f32;
    var color1_1: vec4<f32>;
    var color2_1: vec4<f32>;
    var sourceDim_1: vec2<f32>;
    var ratio: f32;
    var dir_2: vec2<f32>;
    var pixel: f32;
    var step: f32;
    var dim_2: vec2<f32>;
    var p_2: vec2<f32>;
    var acc: f32 = 0f;
    var radius: f32;
    var weight: f32;
    var N: i32;
    var bestL: f32 = 10000000000f;
    var i: i32 = 0i;
    var c_2: vec4<f32>;
    var val: f32;
    var dd: vec2<f32>;
    var k_1: f32;
    var bkgCol: vec4<f32>;
    var lineColor: vec4<f32>;
    var backColor: vec4<f32>;

    pos_1 = pos;
    outPos_1 = outPos;
    intensity_1 = intensity;
    thickness_1 = thickness;
    angle_1 = angle;
    color1_1 = color1_;
    color2_1 = color2_;
    sourceDim_1 = sourceDim;
    let _e22 = sourceDim_1;
    let _e24 = sourceDim_1;
    ratio = (_e22.x / _e24.y);
    let _e28 = angle_1;
    let _e30 = angle_1;
    dir_2 = vec2<f32>(cos(_e28), sin(_e30));
    let _e35 = sourceDim_1;
    pixel = (2f / _e35.y);
    let _e39 = pixel;
    step = _e39;
    let _e41 = ratio;
    dim_2 = vec2<f32>(_e41, 1f);
    let _e45 = pos_1;
    let _e46 = dir_2;
    let _e48 = dim_2;
    let _e49 = osc_getStart(_e45, -(_e46), _e48);
    p_2 = _e49;
    let _e53 = thickness_1;
    radius = (_e53 * 0.02f);
    let _e57 = step;
    let _e60 = intensity_1;
    weight = ((_e57 * 333.33f) * _e60);
    let _e63 = dim_2;
    let _e65 = dim_2;
    let _e70 = pixel;
    let _e72 = p_2;
    let _e73 = pos_1;
    let _e76 = radius;
    let _e78 = step;
    N = i32(min((((_e63.x + _e65.y) * 2.01f) / _e70), ceil(((length((_e72 - _e73)) + _e76) / _e78))));
    loop {
        let _e88 = i;
        let _e89 = N;
        if !((_e88 < _e89)) {
            break;
        }
        {
            let _e95 = p_2;
            let _e99 = global.U[0];
            let _e102 = p_2;
            let _e111 = _mirror_wrap(((vec2<f32>((_e95.x / _e99.x), _e102.y) / vec2(2f)) + vec2(0.5f)));
            let _e112 = textureSample(t_source, samp, _e111);
            c_2 = _e112;
            let _e114 = c_2;
            let _e116 = c_2;
            let _e119 = c_2;
            val = ((_e114.x + _e116.y) + _e119.z);
            let _e123 = acc;
            let _e124 = weight;
            let _e125 = val;
            acc = (_e123 + (_e124 * _e125));
            let _e128 = acc;
            if (_e128 >= 1f) {
                {
                    let _e131 = p_2;
                    let _e132 = pos_1;
                    dd = (_e131 - _e132);
                    let _e135 = bestL;
                    let _e136 = dd;
                    let _e137 = dd;
                    bestL = min(_e135, dot(_e136, _e137));
                    acc = 0f;
                }
            }
            let _e141 = p_2;
            let _e142 = step;
            let _e143 = dir_2;
            p_2 = (_e141 + (_e142 * _e143));
        }
        continuing {
            let _e92 = i;
            i = (_e92 + 1i);
        }
    }
    let _e146 = radius;
    let _e148 = bestL;
    k_1 = smoothstep(_e146, 0f, sqrt(_e148));
    let _e152 = pos_1;
    let _e156 = global.U[0];
    let _e159 = pos_1;
    let _e168 = _mirror_wrap(((vec2<f32>((_e152.x / _e156.x), _e159.y) / vec2(2f)) + vec2(0.5f)));
    let _e169 = textureSample(t_source, samp, _e168);
    bkgCol = _e169;
    let _e171 = bkgCol;
    let _e173 = color2_1;
    let _e175 = color2_1;
    let _e178 = mix(_e171.xyz, _e173.xyz, vec3(_e175.w));
    let _e179 = bkgCol;
    lineColor = vec4<f32>(_e178.x, _e178.y, _e178.z, _e179.w);
    let _e186 = bkgCol;
    let _e188 = color1_1;
    let _e190 = color1_1;
    let _e193 = mix(_e186.xyz, _e188.xyz, vec3(_e190.w));
    let _e194 = bkgCol;
    backColor = vec4<f32>(_e193.x, _e193.y, _e193.z, _e194.w);
    let _e201 = backColor;
    let _e202 = lineColor;
    let _e203 = k_1;
    return mix(_e201, _e202, vec4(clamp(_e203, 0f, 1f)));
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
    let _e81 = global.U[10];
    let _e84 = global.U[4];
    let _e86 = oscilloscope((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e9.x, _e9.y, _e9.z), vec3<f32>(_e13.x, _e13.y, _e13.z), vec3<f32>(_e17.x, _e17.y, _e17.z))) * vec3<f32>(_e44.x, _e44.y, 1f)).xy, (((_e51 - vec2(0.5f)) * 2f) * vec2<f32>(_e59.x, 1f)), _e66.x, _e70.x, _e74.x, _e78, _e81, _e84.xy);
    fragColor = _e86;
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
