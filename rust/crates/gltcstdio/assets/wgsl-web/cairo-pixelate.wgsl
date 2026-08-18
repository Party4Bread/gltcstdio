struct Params {
    U: array<vec4<f32>, 12>,
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

fn cairoTile(uv: vec2<f32>, k: f32) -> CairoTile {
    var uv_1: vec2<f32>;
    var k_1: f32;
    var id: vec2<f32>;
    var alt: f32;
    var p: vec2<f32>;
    var ang: f32;
    var n: vec2<f32>;
    var d: f32;

    uv_1 = uv;
    k_1 = k;
    let _e10 = uv_1;
    id = floor(_e10);
    let _e13 = id;
    let _e15 = id;
    let _e17 = (_e13.x + _e15.y);
    alt = (_e17 - (floor((_e17 / 2f)) * 2f));
    let _e24 = uv_1;
    uv_1 = (fract(_e24) - vec2(0.5f));
    let _e29 = uv_1;
    p = abs(_e29);
    let _e32 = alt;
    if (_e32 == 1f) {
        let _e35 = p;
        p = _e35.yx;
    }
    let _e37 = k_1;
    ang = (((_e37 * 0.5f) + 0.5f) * 3.1415927f);
    let _e45 = ang;
    let _e47 = ang;
    n = vec2<f32>(sin(_e45), cos(_e47));
    let _e51 = p;
    let _e55 = n;
    d = dot((_e51 - vec2(0.5f)), _e55);
    let _e58 = d;
    let _e59 = alt;
    if ((_e58 * (_e59 - 0.5f)) < 0f) {
        let _e66 = id;
        let _e68 = uv_1;
        id.x = (_e66.x + (sign(_e68.x) * 0.5f));
    } else {
        let _e75 = id;
        let _e77 = uv_1;
        id.y = (_e75.y + (sign(_e77.y) * 0.5f));
    }
    let _e83 = d;
    let _e84 = p;
    d = min(_e83, _e84.x);
    let _e87 = d;
    let _e88 = p;
    d = max(_e87, -(_e88.y));
    let _e92 = d;
    d = abs(_e92);
    let _e94 = d;
    let _e95 = p;
    let _e99 = n;
    let _e101 = n;
    d = min(_e94, dot((_e95 - vec2(0.5f)), vec2<f32>(_e99.y, -(_e101.x))));
    let _e107 = id;
    let _e111 = d;
    return CairoTile((_e107 + vec2(0.5f)), _e111);
}

fn mergeColor(bkg: vec4<f32>, front: vec4<f32>) -> vec4<f32> {
    var bkg_1: vec4<f32>;
    var front_1: vec4<f32>;

    bkg_1 = bkg;
    front_1 = front;
    let _e10 = bkg_1;
    let _e12 = front_1;
    let _e14 = front_1;
    let _e17 = bkg_1;
    let _e21 = front_1;
    let _e27 = mix(_e10.xyz, _e12.xyz, vec3((_e14.w + ((1f - _e17.w) * (1f - _e21.w)))));
    let _e28 = bkg_1;
    let _e30 = front_1;
    return vec4<f32>(_e27.x, _e27.y, _e27.z, max(_e28.w, _e30.w));
}

fn cairoPixelate(uv_2: vec2<f32>, outPos: vec2<f32>, pixelation: f32, shape: f32, thickness: f32, color: vec4<f32>, modelTransform: mat3x3<f32>) -> vec4<f32> {
    var uv_3: vec2<f32>;
    var outPos_1: vec2<f32>;
    var pixelation_1: f32;
    var shape_1: f32;
    var thickness_1: f32;
    var color_1: vec4<f32>;
    var modelTransform_1: mat3x3<f32>;
    var u: vec2<f32>;
    var cairo: CairoTile;
    var v: vec2<f32>;
    var col: vec4<f32>;
    var l: f32;

    uv_3 = uv_2;
    outPos_1 = outPos;
    pixelation_1 = pixelation;
    shape_1 = shape;
    thickness_1 = thickness;
    color_1 = color;
    modelTransform_1 = modelTransform;
    let _e20 = modelTransform_1;
    let _e22 = uv_3;
    u = (_naga_inverse_3x3_f32(_e20) * vec3<f32>(_e22.x, _e22.y, 1f)).xy;
    let _e30 = u;
    let _e31 = shape_1;
    let _e32 = cairoTile(_e30, _e31);
    cairo = _e32;
    let _e34 = modelTransform_1;
    let _e35 = cairo;
    v = (_e34 * vec3<f32>(_e35.center.x, _e35.center.y, 1f)).xy;
    let _e44 = cairo;
    let _e46 = thickness_1;
    if (_e44.borderDist < (_e46 * 0.5f)) {
        {
            let _e50 = v;
            let _e54 = global.U[0];
            let _e57 = v;
            let _e66 = _mirror_wrap(((vec2<f32>((_e50.x / _e54.x), _e57.y) / vec2(2f)) + vec2(0.5f)));
            let _e68 = textureSampleLevel(t_source, samp, _e66, 0f);
            col = _e68;
            let _e70 = col;
            let _e71 = color_1;
            let _e72 = mergeColor(_e70, _e71);
            return _e72;
        }
    } else {
        {
            let _e75 = modelTransform_1[0];
            l = length(_e75.xy);
            let _e79 = v;
            let _e80 = pixelation_1;
            let _e81 = l;
            let _e84 = cairo;
            let _e92 = global.U[0];
            let _e95 = v;
            let _e96 = pixelation_1;
            let _e97 = l;
            let _e100 = cairo;
            let _e113 = _mirror_wrap(((vec2<f32>(((_e79 + ((_e80 * _e81) * vec2<f32>(0f, _e84.borderDist))).x / _e92.x), (_e95 + ((_e96 * _e97) * vec2<f32>(0f, _e100.borderDist))).y) / vec2(2f)) + vec2(0.5f)));
            let _e115 = textureSampleLevel(t_source, samp, _e113, 0f);
            return _e115;
        }
    }
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
    let _e74 = global.U[7];
    let _e78 = global.U[8];
    let _e81 = global.U[9];
    let _e82 = _e81.xyz;
    let _e85 = global.U[10];
    let _e86 = _e85.xyz;
    let _e89 = global.U[11];
    let _e90 = _e89.xyz;
    let _e104 = cairoPixelate((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e9.x, _e9.y, _e9.z), vec3<f32>(_e13.x, _e13.y, _e13.z), vec3<f32>(_e17.x, _e17.y, _e17.z))) * vec3<f32>(_e44.x, _e44.y, 1f)).xy, (((_e51 - vec2(0.5f)) * 2f) * vec2<f32>(_e59.x, 1f)), _e66.x, _e70.x, _e74.x, _e78, mat3x3<f32>(vec3<f32>(_e82.x, _e82.y, _e82.z), vec3<f32>(_e86.x, _e86.y, _e86.z), vec3<f32>(_e90.x, _e90.y, _e90.z)));
    fragColor = _e104;
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
