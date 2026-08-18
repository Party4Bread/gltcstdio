struct Params {
    U: array<vec4<f32>, 8>,
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

fn smoothen(pos: vec2<f32>, outPos: vec2<f32>, sourceDim: vec2<f32>, dampening: f32, radius: f32) -> vec4<f32> {
    var pos_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var sourceDim_1: vec2<f32>;
    var dampening_1: f32;
    var radius_1: f32;
    var pixel: f32;
    var n: i32 = 50i;
    var m: i32 = 10i;
    var c: vec4<f32>;
    var div: f32 = 0f;
    var N: f32 = 1f;
    var total: vec4<f32>;
    var delta: vec2<f32>;
    var i: i32 = 0i;
    var prnd: vec2<f32>;
    var col: vec4<f32>;

    pos_1 = pos;
    outPos_1 = outPos;
    sourceDim_1 = sourceDim;
    dampening_1 = dampening;
    radius_1 = radius;
    let _e17 = sourceDim_1;
    pixel = (2f / _e17.y);
    let _e21 = radius_1;
    radius_1 = (_e21 * 0.05f);
    let _e28 = pos_1;
    let _e32 = global.U[0];
    let _e35 = pos_1;
    let _e44 = textureSample(t_source, samp, ((vec2<f32>((_e28.x / _e32.x), _e35.y) / vec2(2f)) + vec2(0.5f)));
    c = _e44;
    let _e50 = c;
    total = _e50;
    let _e52 = pos_1;
    let _e53 = rand2rel(_e52);
    delta = _e53;
    loop {
        let _e57 = i;
        let _e58 = n;
        if !((_e57 < _e58)) {
            break;
        }
        {
            let _e64 = pos_1;
            let _e66 = radius_1;
            let _e68 = delta;
            prnd = (_e64 + ((2f * _e66) * _e68));
            let _e72 = prnd;
            let _e76 = global.U[0];
            let _e79 = prnd;
            let _e88 = textureSample(t_source, samp, ((vec2<f32>((_e72.x / _e76.x), _e79.y) / vec2(2f)) + vec2(0.5f)));
            col = _e88;
            let _e90 = col;
            let _e91 = c;
            let _e94 = dampening_1;
            if (length((_e90 - _e91)) <= _e94) {
                {
                    let _e96 = total;
                    let _e97 = col;
                    total = (_e96 + _e97);
                    let _e99 = N;
                    N = (_e99 + 1f);
                }
            }
            let _e102 = i;
            let _e103 = f32(_e102);
            if ((_e103 - (floor((_e103 / 4f)) * 4f)) == 3f) {
                {
                    let _e111 = delta;
                    let _e113 = delta;
                    delta = vec2<f32>(_e111.y, -(_e113.x));
                }
            } else {
                {
                    let _e117 = delta;
                    let _e118 = rand2rel(_e117);
                    delta = _e118;
                }
            }
            let _e119 = N;
            let _e121 = m;
            if (i32(_e119) >= _e121) {
                break;
            }
        }
        continuing {
            let _e61 = i;
            i = (_e61 + 1i);
        }
    }
    let _e123 = total;
    let _e124 = N;
    return (_e123 / vec4(_e124));
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
    let _e76 = smoothen((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e9.x, _e9.y, _e9.z), vec3<f32>(_e13.x, _e13.y, _e13.z), vec3<f32>(_e17.x, _e17.y, _e17.z))) * vec3<f32>(_e44.x, _e44.y, 1f)).xy, (((_e51 - vec2(0.5f)) * 2f) * vec2<f32>(_e59.x, 1f)), _e66.xy, _e70.x, _e74.x);
    fragColor = _e76;
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
