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
@group(0) @binding(2) 
var t_source: texture_2d<f32>;

fn rand2rel(co: vec2<f32>) -> vec2<f32> {
    var co_1: vec2<f32>;
    var x: f32;
    var y: f32;

    co_1 = co;
    let _e8 = co_1;
    x = fract((sin(dot(_e8.xy, vec2<f32>(12.9898f, 78.233f))) * 43758.547f));
    let _e19 = x;
    let _e20 = co_1;
    y = fract((sin(dot(vec2<f32>(_e19, _e20.x), vec2<f32>(12.9898f, 78.233f))) * 43758.547f));
    let _e32 = x;
    let _e33 = y;
    return (vec2<f32>(_e32, _e33) - vec2<f32>(0.5f, 0.5f));
}

fn geomBreak1F1_(u: vec2<f32>, split: vec2<f32>, s: vec2<f32>, N: i32, intensity: f32) -> vec2<f32> {
    var u_1: vec2<f32>;
    var split_1: vec2<f32>;
    var s_1: vec2<f32>;
    var N_1: i32;
    var intensity_1: f32;
    var rnd: vec2<f32>;
    var i: i32 = 0i;
    var ox: f32;

    u_1 = u;
    split_1 = split;
    s_1 = s;
    N_1 = N;
    intensity_1 = intensity;
    let _e16 = s_1;
    let _e17 = rand2rel(_e16);
    rnd = _e17;
    loop {
        let _e21 = i;
        let _e22 = N_1;
        if !((_e21 < _e22)) {
            break;
        }
        {
            let _e28 = u_1;
            let _e30 = split_1;
            let _e33 = u_1;
            let _e35 = split_1;
            if ((_e28.x > _e30.x) && (_e33.y > _e35.y)) {
                {
                    let _e39 = u_1;
                    let _e41 = rnd;
                    u_1 = (_e39 * (1f + _e41.x));
                }
            } else {
                let _e45 = u_1;
                let _e47 = split_1;
                let _e50 = u_1;
                let _e52 = split_1;
                if ((_e45.x <= _e47.x) && (_e50.y > _e52.y)) {
                    {
                        let _e56 = u_1;
                        ox = _e56.x;
                        let _e60 = rnd;
                        let _e63 = u_1;
                        u_1.x = (sign(_e60.x) * _e63.y);
                        let _e67 = rnd;
                        let _e70 = ox;
                        u_1.y = (sign(_e67.y) * _e70);
                    }
                } else {
                    let _e72 = u_1;
                    let _e74 = split_1;
                    if (_e72.x > _e74.x) {
                        {
                            let _e78 = u_1;
                            let _e80 = rnd;
                            u_1.x = (_e78.x + (_e80.y * 2f));
                        }
                    } else {
                        {
                            let _e86 = u_1;
                            let _e89 = u_1;
                            let _e92 = rnd;
                            let _e95 = (sign(_e86.x) * pow(abs(_e89.x), _e92.y));
                            u_1.x = (_e95 - (floor((_e95 / 1f)) * 1f));
                            let _e102 = u_1;
                            let _e105 = u_1;
                            let _e108 = rnd;
                            let _e111 = (sign(_e102.y) * pow(abs(_e105.y), _e108.x));
                            u_1.y = (_e111 - (floor((_e111 / 1f)) * 1f));
                        }
                    }
                }
            }
            let _e117 = u_1;
            let _e120 = u_1;
            if (max(abs(_e117.x), abs(_e120.y)) > 1.5f) {
                {
                    let _e126 = u_1;
                    let _e128 = intensity_1;
                    u_1 = (_e126 * pow(2f, _e128));
                }
            }
        }
        continuing {
            let _e25 = i;
            i = (_e25 + 1i);
        }
    }
    let _e131 = u_1;
    return _e131;
}

fn geomBreak1GL(pos: vec2<f32>, outPos: vec2<f32>, intensity_2: f32, count: i32, sourceDim: vec2<f32>, modelTransform: mat3x3<f32>) -> vec4<f32> {
    var pos_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var intensity_3: f32;
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
    intensity_3 = intensity_2;
    count_1 = count;
    sourceDim_1 = sourceDim;
    modelTransform_1 = modelTransform;
    let _e18 = modelTransform_1;
    let _e20 = pos_1;
    u_2 = (_naga_inverse_3x3_f32(_e18) * vec3<f32>(_e20.x, _e20.y, 1f)).xy;
    let _e28 = u_2;
    split_2 = ((fract(_e28) * 4f) - vec2(2f));
    let _e36 = sourceDim_1;
    let _e38 = sourceDim_1;
    ratio = (_e36.x / _e38.y);
    let _e42 = ratio;
    vRatio = vec2<f32>(_e42, 1f);
    let _e46 = pos_1;
    let _e47 = vRatio;
    let _e49 = split_2;
    let _e50 = u_2;
    let _e52 = count_1;
    let _e53 = intensity_3;
    let _e54 = geomBreak1F1_((_e46 / _e47), _e49, floor(_e50), _e52, _e53);
    let _e55 = vRatio;
    warped = (_e54 * _e55);
    let _e58 = warped;
    let _e62 = global.U[0];
    let _e65 = warped;
    let _e74 = textureSample(t_source, samp, ((vec2<f32>((_e58.x / _e62.x), _e65.y) / vec2(2f)) + vec2(0.5f)));
    return _e74;
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
    let _e70 = global.U[10];
    let _e75 = global.U[4];
    let _e79 = global.U[11];
    let _e80 = _e79.xyz;
    let _e83 = global.U[12];
    let _e84 = _e83.xyz;
    let _e87 = global.U[13];
    let _e88 = _e87.xyz;
    let _e102 = geomBreak1GL((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e9.x, _e9.y, _e9.z), vec3<f32>(_e13.x, _e13.y, _e13.z), vec3<f32>(_e17.x, _e17.y, _e17.z))) * vec3<f32>(_e44.x, _e44.y, 1f)).xy, (((_e51 - vec2(0.5f)) * 2f) * vec2<f32>(_e59.x, 1f)), _e66.x, i32(_e70.x), _e75.xy, mat3x3<f32>(vec3<f32>(_e80.x, _e80.y, _e80.z), vec3<f32>(_e84.x, _e84.y, _e84.z), vec3<f32>(_e88.x, _e88.y, _e88.z)));
    fragColor = _e102;
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
