struct Params {
    U: array<vec4<f32>, 7>,
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

fn perspectiveFit(u: vec2<f32>, persp: f32) -> vec2<f32> {
    var u_1: vec2<f32>;
    var persp_1: f32;
    var Z: f32 = 4f;
    var z: f32;
    var maxZ: f32;
    var minZ: f32;
    var maxX: f32;
    var minY: f32;
    var maxY: f32;
    var dy: f32;
    var dx: f32;

    u_1 = u;
    persp_1 = persp;
    let _e10 = persp_1;
    if (_e10 < 10000f) {
        {
            let _e15 = Z;
            let _e16 = u_1;
            let _e19 = Z;
            let _e21 = persp_1;
            let _e23 = u_1;
            z = ((_e15 * _e16.y) / ((-(_e19) * _e21) - _e23.y));
            let _e28 = Z;
            let _e30 = Z;
            let _e31 = persp_1;
            maxZ = (-(_e28) / ((_e30 * -(_e31)) + 1f));
            let _e38 = Z;
            let _e39 = Z;
            let _e40 = persp_1;
            minZ = (_e38 / ((_e39 * -(_e40)) - 1f));
            let _e47 = maxZ;
            let _e48 = Z;
            let _e50 = Z;
            maxX = ((_e47 + _e48) / _e50);
            let _e53 = maxZ;
            let _e54 = persp_1;
            minY = (_e53 * -(_e54));
            let _e58 = minZ;
            let _e59 = persp_1;
            maxY = (_e58 * -(_e59));
            let _e63 = z;
            let _e64 = persp_1;
            dy = (_e63 * -(_e64));
            let _e68 = dy;
            let _e69 = minY;
            let _e71 = maxY;
            let _e72 = minY;
            dy = ((((_e68 - _e69) / (_e71 - _e72)) * 2f) - 1f);
            let _e79 = u_1;
            let _e81 = z;
            let _e82 = Z;
            let _e85 = Z;
            dx = ((_e79.x * (_e81 + _e82)) / _e85);
            let _e88 = dx;
            let _e89 = maxX;
            dx = (_e88 / _e89);
            let _e91 = dx;
            let _e92 = dy;
            return vec2<f32>(_e91, _e92);
        }
    }
    let _e94 = u_1;
    return _e94;
}

fn perspectiveFloorGl(pos: vec2<f32>, outPos: vec2<f32>, perspective: f32, viewAngle: f32) -> vec4<f32> {
    var pos_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var perspective_1: f32;
    var viewAngle_1: f32;
    var q: vec2<f32>;
    var c_2: f32;
    var s: f32;
    var r: vec2<f32>;

    pos_1 = pos;
    outPos_1 = outPos;
    perspective_1 = perspective;
    viewAngle_1 = viewAngle;
    let _e14 = pos_1;
    let _e15 = perspective_1;
    let _e16 = perspectiveFit(_e14, _e15);
    q = _e16;
    let _e18 = viewAngle_1;
    c_2 = cos(_e18);
    let _e21 = viewAngle_1;
    s = sin(_e21);
    let _e24 = c_2;
    let _e25 = q;
    let _e28 = s;
    let _e29 = q;
    let _e33 = s;
    let _e34 = q;
    let _e37 = c_2;
    let _e38 = q;
    r = vec2<f32>(((_e24 * _e25.x) - (_e28 * _e29.y)), ((_e33 * _e34.x) + (_e37 * _e38.y)));
    let _e44 = r;
    let _e48 = global.U[0];
    let _e51 = r;
    let _e60 = _mirror_wrap(((vec2<f32>((_e44.x / _e48.x), _e51.y) / vec2(2f)) + vec2(0.5f)));
    let _e61 = textureSample(t_source, samp, _e60);
    return _e61;
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
    let _e66 = global.U[5];
    let _e70 = global.U[6];
    let _e72 = perspectiveFloorGl((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e9.x, _e9.y, _e9.z), vec3<f32>(_e13.x, _e13.y, _e13.z), vec3<f32>(_e17.x, _e17.y, _e17.z))) * vec3<f32>(_e44.x, _e44.y, 1f)).xy, (((_e51 - vec2(0.5f)) * 2f) * vec2<f32>(_e59.x, 1f)), _e66.x, _e70.x);
    fragColor = _e72;
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
