struct Params {
    U: array<vec4<f32>, 10>,
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
var t_source1_: texture_2d<f32>;
@group(0) @binding(3) 
var t_source2_: texture_2d<f32>;

fn _mirror_wrap(c: vec2<f32>) -> vec2<f32> {
    var c_1: vec2<f32>;

    c_1 = c;
    let _e10 = c_1;
    let _e12 = vec2(2f);
    return (vec2(1f) - abs(((_e10 - (floor((_e10 / _e12)) * _e12)) - vec2(1f))));
}

fn reduce3_2_(v: vec3<f32>, k: f32) -> vec2<f32> {
    var v_1: vec3<f32>;
    var k_1: f32;
    var a: f32 = 0.33333334f;
    var b: f32 = 0.6666667f;
    var kk: f32;
    var kk_1: f32;
    var kk_2: f32;

    v_1 = v;
    k_1 = k;
    let _e19 = k_1;
    let _e20 = a;
    if (_e19 < _e20) {
        {
            let _e22 = k_1;
            kk = (_e22 * 3f);
            let _e26 = v_1;
            let _e28 = v_1;
            let _e30 = kk;
            let _e32 = v_1;
            let _e34 = v_1;
            let _e36 = kk;
            return vec2<f32>(mix(_e26.x, _e28.y, _e30), mix(_e32.y, _e34.z, _e36));
        }
    } else {
        let _e39 = k_1;
        let _e40 = b;
        if (_e39 < _e40) {
            {
                let _e42 = k_1;
                let _e43 = a;
                kk_1 = ((_e42 - _e43) * 3f);
                let _e48 = v_1;
                let _e50 = v_1;
                let _e52 = kk_1;
                let _e54 = v_1;
                let _e56 = v_1;
                let _e58 = kk_1;
                return vec2<f32>(mix(_e48.y, _e50.z, _e52), mix(_e54.z, _e56.x, _e58));
            }
        } else {
            {
                let _e61 = k_1;
                let _e62 = b;
                kk_2 = ((_e61 - _e62) * 3f);
                let _e67 = v_1;
                let _e69 = v_1;
                let _e71 = kk_2;
                let _e73 = v_1;
                let _e75 = v_1;
                let _e77 = kk_2;
                return vec2<f32>(mix(_e67.z, _e69.x, _e71), mix(_e73.x, _e75.y, _e77));
            }
        }
    }
}

fn tf(m: mat3x3<f32>, u: vec2<f32>) -> vec2<f32> {
    var m_1: mat3x3<f32>;
    var u_1: vec2<f32>;

    m_1 = m;
    u_1 = u;
    let _e11 = m_1;
    let _e12 = u_1;
    return (_e11 * vec3<f32>(_e12.x, _e12.y, 1f)).xy;
}

fn quickcopper(pos: vec2<f32>, outPos: vec2<f32>, balance: f32, source2_specified: i32, modelTransform: mat3x3<f32>) -> vec4<f32> {
    var pos_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var balance_1: f32;
    var source2_specified_1: i32;
    var modelTransform_1: mat3x3<f32>;
    var col: vec4<f32>;
    var uv: vec2<f32>;
    var local: vec4<f32>;

    pos_1 = pos;
    outPos_1 = outPos;
    balance_1 = balance;
    source2_specified_1 = source2_specified;
    modelTransform_1 = modelTransform;
    let _e17 = pos_1;
    let _e21 = global.U[0];
    let _e24 = pos_1;
    let _e33 = _mirror_wrap(((vec2<f32>((_e17.x / _e21.x), _e24.y) / vec2(2f)) + vec2(0.5f)));
    let _e34 = textureSample(t_source1_, samp, _e33);
    col = _e34;
    let _e36 = col;
    let _e38 = balance_1;
    let _e39 = reduce3_2_(_e36.xyz, _e38);
    uv = ((_e39 - vec2(0.5f)) * 2f);
    let _e46 = source2_specified_1;
    if (_e46 == 0i) {
        let _e49 = modelTransform_1;
        let _e51 = uv;
        let _e52 = tf(_naga_inverse_3x3_f32(_e49), _e51);
        let _e56 = global.U[0];
        let _e59 = modelTransform_1;
        let _e61 = uv;
        let _e62 = tf(_naga_inverse_3x3_f32(_e59), _e61);
        let _e71 = _mirror_wrap(((vec2<f32>((_e52.x / _e56.x), _e62.y) / vec2(2f)) + vec2(0.5f)));
        let _e72 = textureSample(t_source1_, samp, _e71);
        local = _e72;
    } else {
        let _e73 = modelTransform_1;
        let _e75 = uv;
        let _e76 = tf(_naga_inverse_3x3_f32(_e73), _e75);
        let _e80 = global.U[0];
        let _e83 = modelTransform_1;
        let _e85 = uv;
        let _e86 = tf(_naga_inverse_3x3_f32(_e83), _e85);
        let _e95 = textureSample(t_source2_, samp, ((vec2<f32>((_e76.x / _e80.x), _e86.y) / vec2(2f)) + vec2(0.5f)));
        local = _e95;
    }
    let _e97 = local;
    return _e97;
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
    let _e71 = global.U[4];
    let _e76 = global.U[7];
    let _e77 = _e76.xyz;
    let _e80 = global.U[8];
    let _e81 = _e80.xyz;
    let _e84 = global.U[9];
    let _e85 = _e84.xyz;
    let _e99 = quickcopper((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e10.x, _e10.y, _e10.z), vec3<f32>(_e14.x, _e14.y, _e14.z), vec3<f32>(_e18.x, _e18.y, _e18.z))) * vec3<f32>(_e45.x, _e45.y, 1f)).xy, (((_e52 - vec2(0.5f)) * 2f) * vec2<f32>(_e60.x, 1f)), _e67.x, i32(_e71.x), mat3x3<f32>(vec3<f32>(_e77.x, _e77.y, _e77.z), vec3<f32>(_e81.x, _e81.y, _e81.z), vec3<f32>(_e85.x, _e85.y, _e85.z)));
    fragColor = _e99;
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
