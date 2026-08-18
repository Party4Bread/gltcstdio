struct Params {
    U: array<vec4<f32>, 13>,
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

fn geomBreak3F1_(u: vec2<f32>, split: vec2<f32>, N: i32) -> vec2<f32> {
    var u_1: vec2<f32>;
    var split_1: vec2<f32>;
    var N_1: i32;
    var i: i32 = 0i;
    var sc: vec2<f32>;
    var center: vec2<f32>;

    u_1 = u;
    split_1 = split;
    N_1 = N;
    loop {
        let _e14 = i;
        let _e15 = N_1;
        if !((_e14 < _e15)) {
            break;
        }
        {
            let _e23 = u_1;
            let _e25 = split_1;
            let _e28 = u_1;
            let _e30 = split_1;
            if ((_e23.x > _e25.x) && (_e28.y > _e30.y)) {
                {
                    let _e36 = split_1;
                    let _e40 = split_1;
                    sc = (vec2(2f) / vec2<f32>((1f - _e36.x), (1f - _e40.y)));
                    let _e47 = split_1;
                    let _e51 = split_1;
                    center = (vec2<f32>((1f + _e47.x), (1f + _e51.y)) / vec2(2f));
                }
            } else {
                let _e58 = u_1;
                let _e60 = split_1;
                let _e63 = u_1;
                let _e65 = split_1;
                if ((_e58.x <= _e60.x) && (_e63.y > _e65.y)) {
                    {
                        let _e71 = split_1;
                        let _e75 = split_1;
                        sc = (vec2(2f) / vec2<f32>((1f + _e71.x), (1f - _e75.y)));
                        let _e83 = split_1;
                        let _e87 = split_1;
                        center = (vec2<f32>((-1f + _e83.x), (1f + _e87.y)) / vec2(2f));
                    }
                } else {
                    let _e94 = u_1;
                    let _e96 = split_1;
                    if (_e94.x > _e96.x) {
                        {
                            let _e101 = split_1;
                            let _e105 = split_1;
                            sc = (vec2(2f) / vec2<f32>((1f - _e101.x), (1f + _e105.y)));
                            let _e112 = split_1;
                            let _e117 = split_1;
                            center = (vec2<f32>((1f + _e112.x), (-1f + _e117.y)) / vec2(2f));
                        }
                    } else {
                        {
                            let _e126 = split_1;
                            let _e130 = split_1;
                            sc = (vec2(2f) / vec2<f32>((1f + _e126.x), (1f + _e130.y)));
                            let _e138 = split_1;
                            let _e143 = split_1;
                            center = (vec2<f32>((-1f + _e138.x), (-1f + _e143.y)) / vec2(2f));
                        }
                    }
                }
            }
            let _e150 = u_1;
            let _e151 = sc;
            let _e153 = center;
            let _e154 = sc;
            u_1 = ((_e150 * _e151) - (_e153 * _e154));
        }
        continuing {
            let _e18 = i;
            i = (_e18 + 1i);
        }
    }
    let _e157 = u_1;
    return _e157;
}

fn geomBreak3GL(pos: vec2<f32>, outPos: vec2<f32>, count: i32, sourceDim: vec2<f32>, modelTransform: mat3x3<f32>) -> vec4<f32> {
    var pos_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var count_1: i32;
    var sourceDim_1: vec2<f32>;
    var modelTransform_1: mat3x3<f32>;
    var u_2: vec2<f32>;
    var split_2: vec2<f32>;
    var ratio: f32;
    var vRatio: vec2<f32>;
    var warped: vec2<f32>;

    pos_1 = pos;
    outPos_1 = outPos;
    count_1 = count;
    sourceDim_1 = sourceDim;
    modelTransform_1 = modelTransform;
    let _e16 = modelTransform_1;
    let _e17 = pos_1;
    u_2 = (_e16 * vec3<f32>(_e17.x, _e17.y, 1f)).xy;
    let _e25 = u_2;
    split_2 = ((fract(_e25) * 2f) - vec2(1f));
    let _e33 = sourceDim_1;
    let _e35 = sourceDim_1;
    ratio = (_e33.x / _e35.y);
    let _e39 = ratio;
    vRatio = vec2<f32>(_e39, 1f);
    let _e43 = pos_1;
    let _e44 = vRatio;
    let _e46 = split_2;
    let _e47 = count_1;
    let _e48 = geomBreak3F1_((_e43 / _e44), _e46, _e47);
    let _e49 = vRatio;
    warped = (_e48 * _e49);
    let _e52 = warped;
    let _e56 = global.U[0];
    let _e59 = warped;
    let _e68 = _mirror_wrap(((vec2<f32>((_e52.x / _e56.x), _e59.y) / vec2(2f)) + vec2(0.5f)));
    let _e69 = textureSample(t_source, samp, _e68);
    return _e69;
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
    let _e66 = global.U[9];
    let _e71 = global.U[4];
    let _e75 = global.U[10];
    let _e76 = _e75.xyz;
    let _e79 = global.U[11];
    let _e80 = _e79.xyz;
    let _e83 = global.U[12];
    let _e84 = _e83.xyz;
    let _e98 = geomBreak3GL((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e9.x, _e9.y, _e9.z), vec3<f32>(_e13.x, _e13.y, _e13.z), vec3<f32>(_e17.x, _e17.y, _e17.z))) * vec3<f32>(_e44.x, _e44.y, 1f)).xy, (((_e51 - vec2(0.5f)) * 2f) * vec2<f32>(_e59.x, 1f)), i32(_e66.x), _e71.xy, mat3x3<f32>(vec3<f32>(_e76.x, _e76.y, _e76.z), vec3<f32>(_e80.x, _e80.y, _e80.z), vec3<f32>(_e84.x, _e84.y, _e84.z)));
    fragColor = _e98;
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
