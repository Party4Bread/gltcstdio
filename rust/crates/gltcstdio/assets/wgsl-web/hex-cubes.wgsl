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

fn hexDist(p: vec2<f32>) -> f32 {
    var p_1: vec2<f32>;

    p_1 = p;
    let _e8 = p_1;
    p_1 = abs(_e8);
    let _e10 = p_1;
    let _e12 = p_1;
    return max(_e10.x, dot(_e12, normalize(vec2<f32>(1f, 1.7320508f))));
}

fn hexPolarBorderCoords(v: vec2<f32>) -> vec4<f32> {
    var v_1: vec2<f32>;
    var r: vec2<f32> = vec2<f32>(1f, 1.7320508f);
    var h: vec2<f32>;
    var a: vec2<f32>;
    var b: vec2<f32>;
    var local: vec2<f32>;
    var hv: vec2<f32>;
    var x: f32;
    var y: f32;
    var id: vec2<f32>;

    v_1 = v;
    let _e12 = r;
    h = (_e12 / vec2(2f));
    let _e17 = v_1;
    let _e19 = r;
    let _e25 = v_1;
    let _e27 = r;
    let _e34 = h;
    a = (vec2<f32>((_e17.x - (floor((_e17.x / _e19.x)) * _e19.x)), (_e25.y - (floor((_e25.y / _e27.y)) * _e27.y))) - _e34);
    let _e37 = v_1;
    let _e39 = h;
    let _e41 = (_e37.x - _e39.x);
    let _e42 = r;
    let _e48 = v_1;
    let _e50 = h;
    let _e52 = (_e48.y - _e50.y);
    let _e53 = r;
    let _e60 = h;
    b = (vec2<f32>((_e41 - (floor((_e41 / _e42.x)) * _e42.x)), (_e52 - (floor((_e52 / _e53.y)) * _e53.y))) - _e60);
    let _e63 = a;
    let _e65 = b;
    if (length(_e63) < length(_e65)) {
        let _e68 = a;
        local = _e68;
    } else {
        let _e69 = b;
        local = _e69;
    }
    let _e71 = local;
    hv = _e71;
    let _e73 = hv;
    let _e75 = hv;
    x = atan2(_e73.y, _e75.x);
    let _e80 = hv;
    let _e81 = hexDist(_e80);
    y = (0.5f - _e81);
    let _e84 = v_1;
    let _e85 = hv;
    id = (_e84 - _e85);
    let _e88 = x;
    let _e89 = y;
    let _e90 = id;
    return vec4<f32>(_e88, _e89, _e90.x, _e90.y);
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

fn reflectFloat(x_1: f32) -> f32 {
    var x_2: f32;

    x_2 = x_1;
    let _e9 = x_2;
    return (1f - abs(((_e9 - (floor((_e9 / 2f)) * 2f)) - 1f)));
}

fn reflectVec4_(u: vec4<f32>) -> vec4<f32> {
    var u_1: vec4<f32>;

    u_1 = u;
    let _e8 = u_1;
    let _e10 = reflectFloat(_e8.x);
    let _e11 = u_1;
    let _e13 = reflectFloat(_e11.y);
    let _e14 = u_1;
    let _e16 = reflectFloat(_e14.z);
    let _e17 = u_1;
    let _e19 = reflectFloat(_e17.w);
    return vec4<f32>(_e10, _e13, _e16, _e19);
}

fn hexCubes(uv: vec2<f32>, outPos: vec2<f32>, source_specified: i32, thickness: f32, borderColor: vec4<f32>, colorShadow: vec4<f32>, colorOffset: vec4<f32>, color1_: vec4<f32>, color2_: vec4<f32>, color3_: vec4<f32>) -> vec4<f32> {
    var uv_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var source_specified_1: i32;
    var thickness_1: f32;
    var borderColor_1: vec4<f32>;
    var colorShadow_1: vec4<f32>;
    var colorOffset_1: vec4<f32>;
    var color1_1: vec4<f32>;
    var color2_1: vec4<f32>;
    var color3_1: vec4<f32>;
    var u_2: vec2<f32>;
    var col: vec4<f32>;
    var hex: vec4<f32>;
    var borderSize: f32;
    var angle: f32;
    var id_1: vec2<f32>;
    var topIndex: f32;
    var rightIndex: f32;
    var leftIndex: f32;
    var gradientStrength: f32;
    var shadowK: f32;
    var sCol: vec4<f32>;

    uv_1 = uv;
    outPos_1 = outPos;
    source_specified_1 = source_specified;
    thickness_1 = thickness;
    borderColor_1 = borderColor;
    colorShadow_1 = colorShadow;
    colorOffset_1 = colorOffset;
    color1_1 = color1_;
    color2_1 = color2_;
    color3_1 = color3_;
    let _e26 = uv_1;
    u_2 = _e26;
    let _e29 = u_2;
    let _e30 = hexPolarBorderCoords(_e29);
    hex = _e30;
    let _e32 = thickness_1;
    borderSize = (_e32 * 0.5f);
    let _e36 = hex;
    let _e38 = borderSize;
    if (_e36.y < _e38) {
        let _e40 = borderColor_1;
        return _e40;
    }
    let _e41 = hex;
    let _e48 = ((_e41.x + 6.2831855f) + 0.5235988f);
    angle = (_e48 - (floor((_e48 / 6.2831855f)) * 6.2831855f));
    let _e55 = hex;
    id_1 = _e55.zw;
    let _e58 = id_1;
    topIndex = _e58.y;
    let _e61 = id_1;
    let _e63 = id_1;
    rightIndex = (_e61.x - (_e63.y * 0.5f));
    let _e69 = id_1;
    let _e71 = id_1;
    leftIndex = (_e69.x + (_e71.y * 0.5f));
    let _e77 = colorOffset_1;
    let _e79 = colorOffset_1;
    gradientStrength = (_e77.w * _e79.w);
    let _e83 = angle;
    if (_e83 < 2.0943952f) {
        let _e86 = color2_1;
        let _e87 = colorOffset_1;
        let _e89 = rightIndex;
        let _e97 = gradientStrength;
        let _e100 = reflectVec4_((_e86 + (vec4<f32>(((_e87.x * _e89) - 0.5f), 0f, 0f, 0f) * _e97)));
        col = _e100;
    } else {
        let _e101 = angle;
        if (_e101 < 4.1887903f) {
            let _e106 = color1_1;
            let _e108 = colorOffset_1;
            let _e110 = leftIndex;
            let _e117 = gradientStrength;
            let _e120 = reflectVec4_((_e106 + (vec4<f32>(0f, ((_e108.y * _e110) - 0.5f), 0f, 0f) * _e117)));
            col = _e120;
        } else {
            let _e121 = color3_1;
            let _e124 = colorOffset_1;
            let _e126 = topIndex;
            let _e132 = gradientStrength;
            let _e135 = reflectVec4_((_e121 + (vec4<f32>(0f, 0f, ((_e124.z * _e126) - 0.5f), 0f) * _e132)));
            col = _e135;
        }
    }
    let _e137 = hex;
    let _e141 = borderSize;
    shadowK = ((0.5f - _e137.y) / (0.5f - _e141));
    let _e145 = colorShadow_1;
    let _e146 = _e145.xyz;
    let _e147 = colorShadow_1;
    let _e149 = shadowK;
    sCol = vec4<f32>(_e146.x, _e146.y, _e146.z, (_e147.w * _e149));
    let _e156 = col;
    let _e157 = sCol;
    let _e158 = mergeColor(_e156, _e157);
    col = _e158;
    let _e159 = source_specified_1;
    if (_e159 == 1i) {
        {
            let _e162 = uv_1;
            let _e166 = global.U[0];
            let _e169 = uv_1;
            let _e179 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e162.x / _e166.x), _e169.y) / vec2(2f)) + vec2(0.5f)), 0f);
            let _e180 = col;
            let _e181 = mergeColor(_e179, _e180);
            col = _e181;
        }
    }
    let _e182 = col;
    return _e182;
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
    let _e71 = global.U[6];
    let _e75 = global.U[7];
    let _e78 = global.U[8];
    let _e81 = global.U[9];
    let _e84 = global.U[10];
    let _e87 = global.U[11];
    let _e90 = global.U[12];
    let _e91 = hexCubes((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e9.x, _e9.y, _e9.z), vec3<f32>(_e13.x, _e13.y, _e13.z), vec3<f32>(_e17.x, _e17.y, _e17.z))) * vec3<f32>(_e44.x, _e44.y, 1f)).xy, (((_e51 - vec2(0.5f)) * 2f) * vec2<f32>(_e59.x, 1f)), i32(_e66.x), _e71.x, _e75, _e78, _e81, _e84, _e87, _e90);
    fragColor = _e91;
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
