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

fn constants() {
    return;
}

fn complexExp(u: vec2<f32>) -> vec2<f32> {
    var u_1: vec2<f32>;

    u_1 = u;
    let _e7 = u_1;
    let _e10 = u_1;
    let _e13 = u_1;
    return (exp(_e7.x) * vec2<f32>(cos(_e10.y), sin(_e13.y)));
}

fn complexMul(u_2: vec2<f32>, v: vec2<f32>) -> vec2<f32> {
    var u_3: vec2<f32>;
    var v_1: vec2<f32>;

    u_3 = u_2;
    v_1 = v;
    let _e9 = u_3;
    let _e11 = v_1;
    let _e14 = u_3;
    let _e16 = v_1;
    let _e20 = u_3;
    let _e21 = v_1;
    return vec2<f32>(((_e9.x * _e11.x) - (_e14.y * _e16.y)), dot(_e20, _e21.yx));
}

fn gg(z: vec2<f32>, c: vec2<f32>) -> vec2<f32> {
    var z_1: vec2<f32>;
    var c_1: vec2<f32>;

    z_1 = z;
    c_1 = c;
    let _e9 = z_1;
    let _e10 = z_1;
    let _e11 = complexMul(_e9, _e10);
    let _e12 = c_1;
    return (_e11 + _e12);
}

fn orbit(z_2: vec2<f32>, orbitSize: f32) -> f32 {
    var z_3: vec2<f32>;
    var orbitSize_1: f32;

    z_3 = z_2;
    orbitSize_1 = orbitSize;
    let _e9 = z_3;
    let _e11 = orbitSize_1;
    return abs((length(_e9) - _e11));
}

fn mandelbrot(pos: vec2<f32>, outPos: vec2<f32>, modelTransform: mat3x3<f32>, count: i32, orbitSize_2: f32) -> vec4<f32> {
    var pos_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var modelTransform_1: mat3x3<f32>;
    var count_1: i32;
    var orbitSize_3: f32;
    var lookDir: vec3<f32>;
    var uv: vec2<f32>;
    var dist: f32 = 100000000000000000000f;
    var distx: f32 = 100000000000000000000f;
    var disty: f32 = 100000000000000000000f;
    var z_4: vec2<f32> = vec2<f32>(0f, 0f);
    var delta: f32;
    var uvx: vec2<f32>;
    var uvy: vec2<f32>;
    var zx: vec2<f32>;
    var zy: vec2<f32>;
    var i: i32 = 0i;
    var g: f32;
    var normal: vec3<f32>;
    var sourceDir: vec3<f32>;
    var lum: f32;
    var specular: f32;

    pos_1 = pos;
    outPos_1 = outPos;
    modelTransform_1 = modelTransform;
    count_1 = count;
    orbitSize_3 = orbitSize_2;
    constants();
    let _e15 = pos_1;
    lookDir = normalize(vec3<f32>(_e15.x, _e15.y, 1f));
    let _e22 = modelTransform_1;
    let _e24 = pos_1;
    uv = (_naga_inverse_3x3_f32(_e22) * vec3<f32>(_e24.x, _e24.y, 1f)).xy;
    let _e45 = modelTransform_1[0];
    delta = (0.001f / length(_e45.xy));
    let _e50 = uv;
    let _e51 = delta;
    uvx = (_e50 + vec2<f32>(_e51, 0f));
    let _e56 = uv;
    let _e58 = delta;
    uvy = (_e56 + vec2<f32>(0f, _e58));
    let _e62 = z_4;
    zx = _e62;
    let _e64 = z_4;
    zy = _e64;
    loop {
        let _e68 = i;
        let _e69 = count_1;
        if !((_e68 < _e69)) {
            break;
        }
        {
            let _e75 = z_4;
            let _e76 = uv;
            let _e77 = gg(_e75, _e76);
            z_4 = _e77;
            let _e78 = zx;
            let _e79 = uvx;
            let _e80 = gg(_e78, _e79);
            zx = _e80;
            let _e81 = zy;
            let _e82 = uvy;
            let _e83 = gg(_e81, _e82);
            zy = _e83;
            let _e84 = dist;
            let _e85 = z_4;
            let _e86 = orbitSize_3;
            let _e87 = orbit(_e85, _e86);
            dist = min(_e84, _e87);
            let _e89 = distx;
            let _e90 = zx;
            let _e91 = orbitSize_3;
            let _e92 = orbit(_e90, _e91);
            distx = min(_e89, _e92);
            let _e94 = disty;
            let _e95 = zy;
            let _e96 = orbitSize_3;
            let _e97 = orbit(_e95, _e96);
            disty = min(_e94, _e97);
        }
        continuing {
            let _e72 = i;
            i = (_e72 + 1i);
        }
    }
    let _e99 = dist;
    g = _e99;
    let _e101 = distx;
    let _e102 = dist;
    let _e104 = delta;
    let _e106 = disty;
    let _e107 = dist;
    let _e109 = delta;
    normal = normalize(vec3<f32>(((_e101 - _e102) / _e104), ((_e106 - _e107) / _e109), 1f));
    sourceDir = normalize(vec3<f32>(0f, 0.5f, 1f));
    let _e124 = sourceDir;
    let _e125 = normal;
    lum = (smoothstep(-1f, 1f, dot(_e124, _e125)) * 0.7f);
    let _e131 = lookDir;
    let _e132 = sourceDir;
    let _e133 = normal;
    specular = dot(_e131, reflect(_e132, _e133));
    let _e137 = lum;
    let _e141 = specular;
    lum = (_e137 + (0.7f * pow(smoothstep(0.95f, 1f, _e141), 3f)));
    let _e147 = lum;
    let _e148 = vec3(_e147);
    return vec4<f32>(_e148.x, _e148.y, _e148.z, 1f);
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
    let _e66 = _e65.xyz;
    let _e69 = global.U[6];
    let _e70 = _e69.xyz;
    let _e73 = global.U[7];
    let _e74 = _e73.xyz;
    let _e90 = global.U[8];
    let _e95 = global.U[9];
    let _e97 = mandelbrot((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e8.x, _e8.y, _e8.z), vec3<f32>(_e12.x, _e12.y, _e12.z), vec3<f32>(_e16.x, _e16.y, _e16.z))) * vec3<f32>(_e43.x, _e43.y, 1f)).xy, (((_e50 - vec2(0.5f)) * 2f) * vec2<f32>(_e58.x, 1f)), mat3x3<f32>(vec3<f32>(_e66.x, _e66.y, _e66.z), vec3<f32>(_e70.x, _e70.y, _e70.z), vec3<f32>(_e74.x, _e74.y, _e74.z)), i32(_e90.x), _e95.x);
    fragColor = _e97;
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
