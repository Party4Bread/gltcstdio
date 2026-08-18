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

fn copyMachineF1_(u: vec2<f32>, split: vec2<f32>, N: i32) -> vec2<f32> {
    var u_1: vec2<f32>;
    var split_1: vec2<f32>;
    var N_1: i32;
    var i: i32 = 0i;
    var type_34: f32;
    var ox: f32;
    var ox_1: f32;

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
            let _e22 = u_1;
            let _e24 = split_1;
            let _e27 = u_1;
            let _e29 = split_1;
            if ((_e22.x > _e24.x) && (_e27.y > _e29.y)) {
                {
                    type_34 = 0f;
                }
            } else {
                let _e34 = u_1;
                let _e36 = split_1;
                let _e39 = u_1;
                let _e41 = split_1;
                if ((_e34.x <= _e36.x) && (_e39.y > _e41.y)) {
                    {
                        type_34 = 1f;
                    }
                } else {
                    let _e46 = u_1;
                    let _e48 = split_1;
                    if (_e46.x > _e48.x) {
                        {
                            type_34 = 2f;
                        }
                    } else {
                        {
                            type_34 = 3f;
                        }
                    }
                }
            }
            let _e53 = type_34;
            let _e54 = i;
            let _e56 = (_e53 + f32(_e54));
            type_34 = (_e56 - (floor((_e56 / 4f)) * 4f));
            let _e62 = type_34;
            if (_e62 == 0f) {
                {
                    let _e65 = u_1;
                    u_1 = (_e65 * 2f);
                }
            } else {
                let _e68 = type_34;
                if (_e68 == 1f) {
                    {
                        let _e71 = u_1;
                        ox = _e71.x;
                        let _e75 = u_1;
                        u_1.x = -(_e75.y);
                        let _e79 = ox;
                        u_1.y = _e79;
                    }
                } else {
                    let _e80 = type_34;
                    if (_e80 == 2f) {
                        {
                            let _e83 = u_1;
                            ox_1 = _e83.x;
                            let _e87 = u_1;
                            u_1.x = _e87.y;
                            let _e90 = ox_1;
                            u_1.y = -(_e90);
                        }
                    } else {
                        {
                            let _e92 = u_1;
                            u_1 = (_e92 / vec2(2f));
                        }
                    }
                }
            }
        }
        continuing {
            let _e18 = i;
            i = (_e18 + 1i);
        }
    }
    let _e96 = u_1;
    return _e96;
}

fn copyMachineGL(pos: vec2<f32>, outPos: vec2<f32>, count: i32, sourceDim: vec2<f32>, modelTransform: mat3x3<f32>) -> vec4<f32> {
    var pos_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var count_1: i32;
    var sourceDim_1: vec2<f32>;
    var modelTransform_1: mat3x3<f32>;
    var gridTransform: mat3x3<f32>;
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
    gridTransform = _naga_inverse_3x3_f32(_e16);
    let _e19 = gridTransform;
    let _e20 = pos_1;
    u_2 = (_e19 * vec3<f32>(_e20.x, _e20.y, 1f)).xy;
    let _e28 = u_2;
    split_2 = ((fract(_e28) * 2f) - vec2(1f));
    let _e36 = sourceDim_1;
    let _e38 = sourceDim_1;
    ratio = (_e36.x / _e38.y);
    let _e42 = ratio;
    vRatio = vec2<f32>(_e42, 1f);
    let _e46 = pos_1;
    let _e47 = vRatio;
    let _e49 = split_2;
    let _e50 = count_1;
    let _e51 = copyMachineF1_((_e46 / _e47), _e49, _e50);
    let _e52 = vRatio;
    warped = (_e51 * _e52);
    let _e55 = warped;
    let _e59 = global.U[0];
    let _e62 = warped;
    let _e71 = textureSample(t_source, samp, ((vec2<f32>((_e55.x / _e59.x), _e62.y) / vec2(2f)) + vec2(0.5f)));
    return _e71;
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
    let _e98 = copyMachineGL((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e9.x, _e9.y, _e9.z), vec3<f32>(_e13.x, _e13.y, _e13.z), vec3<f32>(_e17.x, _e17.y, _e17.z))) * vec3<f32>(_e44.x, _e44.y, 1f)).xy, (((_e51 - vec2(0.5f)) * 2f) * vec2<f32>(_e59.x, 1f)), i32(_e66.x), _e71.xy, mat3x3<f32>(vec3<f32>(_e76.x, _e76.y, _e76.z), vec3<f32>(_e80.x, _e80.y, _e80.z), vec3<f32>(_e84.x, _e84.y, _e84.z)));
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
