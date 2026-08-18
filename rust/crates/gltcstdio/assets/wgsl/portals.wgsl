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

fn portals(pos: vec2<f32>, outPos: vec2<f32>, sourceDim: vec2<f32>, colorFog: vec4<f32>, thickness: f32, count: i32, modelTransform: mat3x3<f32>) -> vec4<f32> {
    var pos_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var sourceDim_1: vec2<f32>;
    var colorFog_1: vec4<f32>;
    var thickness_1: f32;
    var count_1: i32;
    var modelTransform_1: mat3x3<f32>;
    var invModelTransform: mat3x3<f32>;
    var u: vec2<f32>;
    var ratio: f32;
    var intensity: f32;
    var i: i32 = 0i;
    var m: vec2<f32>;
    var color: vec4<f32>;
    var k: f32;
    var alpha: f32;

    pos_1 = pos;
    outPos_1 = outPos;
    sourceDim_1 = sourceDim;
    colorFog_1 = colorFog;
    thickness_1 = thickness;
    count_1 = count;
    modelTransform_1 = modelTransform;
    let _e20 = modelTransform_1;
    invModelTransform = _naga_inverse_3x3_f32(_e20);
    let _e23 = pos_1;
    u = _e23;
    let _e25 = sourceDim_1;
    let _e27 = sourceDim_1;
    ratio = (_e25.x / _e27.y);
    let _e32 = thickness_1;
    intensity = (1f - _e32);
    loop {
        let _e37 = i;
        let _e38 = count_1;
        if !((_e37 < _e38)) {
            break;
        }
        {
            let _e44 = u;
            let _e46 = ratio;
            let _e49 = ((_e44.x / _e46) + 1f);
            let _e55 = u;
            let _e58 = (_e55.y + 1f);
            m = (vec2<f32>((_e49 - (floor((_e49 / 2f)) * 2f)), (_e58 - (floor((_e58 / 2f)) * 2f))) - vec2<f32>(1f, 1f));
            let _e70 = m;
            let _e73 = m;
            let _e77 = intensity;
            if (max(abs(_e70.x), abs(_e73.y)) > _e77) {
                break;
            }
            let _e79 = invModelTransform;
            let _e80 = u;
            u = (_e79 * vec3<f32>(_e80.x, _e80.y, 1f)).xy;
        }
        continuing {
            let _e41 = i;
            i = (_e41 + 1i);
        }
    }
    let _e87 = u;
    let _e91 = global.U[0];
    let _e94 = u;
    let _e103 = _mirror_wrap(((vec2<f32>((_e87.x / _e91.x), _e94.y) / vec2(2f)) + vec2(0.5f)));
    let _e104 = textureSample(t_source, samp, _e103);
    color = _e104;
    let _e106 = colorFog_1;
    if (_e106.w != 0f) {
        {
            let _e110 = i;
            let _e112 = count_1;
            k = (f32(_e110) / f32(_e112));
            let _e116 = k;
            let _e117 = colorFog_1;
            alpha = (_e116 * _e117.w);
            let _e121 = color;
            let _e122 = colorFog_1;
            let _e123 = _e122.xyz;
            let _e124 = alpha;
            let _e129 = mergeColor(_e121, vec4<f32>(_e123.x, _e123.y, _e123.z, _e124));
            color = _e129;
        }
    }
    let _e130 = color;
    return _e130;
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
    let _e73 = global.U[7];
    let _e77 = global.U[8];
    let _e82 = global.U[9];
    let _e83 = _e82.xyz;
    let _e86 = global.U[10];
    let _e87 = _e86.xyz;
    let _e90 = global.U[11];
    let _e91 = _e90.xyz;
    let _e105 = portals((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e9.x, _e9.y, _e9.z), vec3<f32>(_e13.x, _e13.y, _e13.z), vec3<f32>(_e17.x, _e17.y, _e17.z))) * vec3<f32>(_e44.x, _e44.y, 1f)).xy, (((_e51 - vec2(0.5f)) * 2f) * vec2<f32>(_e59.x, 1f)), _e66.xy, _e70, _e73.x, i32(_e77.x), mat3x3<f32>(vec3<f32>(_e83.x, _e83.y, _e83.z), vec3<f32>(_e87.x, _e87.y, _e87.z), vec3<f32>(_e91.x, _e91.y, _e91.z)));
    fragColor = _e105;
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
