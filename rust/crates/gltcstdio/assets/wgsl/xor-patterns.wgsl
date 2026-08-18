struct Params {
    U: array<vec4<f32>, 11>,
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

fn pr(x: f32, k: f32, process: i32) -> f32 {
    var x_1: f32;
    var k_1: f32;
    var process_1: i32;

    x_1 = x;
    k_1 = k;
    process_1 = process;
    let _e12 = process_1;
    if (_e12 == 1i) {
        let _e15 = x_1;
        return fract(_e15);
    } else {
        let _e17 = process_1;
        if (_e17 == 2i) {
            let _e21 = x_1;
            return (1f - abs(((_e21 - (floor((_e21 / 2f)) * 2f)) - 1f)));
        } else {
            let _e31 = process_1;
            if (_e31 == 3i) {
                let _e34 = x_1;
                return (_e34 - (floor((_e34 / 2f)) * 2f));
            } else {
                let _e40 = process_1;
                if (_e40 == 4i) {
                    let _e43 = x_1;
                    let _e44 = k_1;
                    return (_e43 / _e44);
                } else {
                    let _e46 = x_1;
                    return _e46;
                }
            }
        }
    }
}

fn xorPatterns(uv: vec2<f32>, outPos: vec2<f32>, source_specified: i32, intensity: f32, colorVariability: f32, mode: i32, color1_: vec4<f32>, color2_: vec4<f32>) -> vec4<f32> {
    var uv_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var source_specified_1: i32;
    var intensity_1: f32;
    var colorVariability_1: f32;
    var mode_1: i32;
    var color1_1: vec4<f32>;
    var color2_1: vec4<f32>;
    var process_2: i32;
    var mR: f32;
    var mB: f32;
    var modG: f32;
    var modR: f32;
    var modB: f32;
    var rdx: i32;
    var bdy: i32;
    var x_2: i32;
    var y: i32;
    var r: f32;
    var g: f32;
    var b: f32;
    var a: f32;
    var outColor: vec4<f32>;

    uv_1 = uv;
    outPos_1 = outPos;
    source_specified_1 = source_specified;
    intensity_1 = intensity;
    colorVariability_1 = colorVariability;
    mode_1 = mode;
    color1_1 = color1_;
    color2_1 = color2_;
    let _e22 = mode_1;
    process_2 = (_e22 % 5i);
    let _e26 = mode_1;
    mode_1 = (_e26 / 5i);
    let _e29 = mode_1;
    mR = ((f32((_e29 % 8i)) - 3.5f) * 3f);
    let _e38 = mode_1;
    mode_1 = (_e38 / 8i);
    let _e41 = mode_1;
    mB = ((f32((_e41 % 8i)) - 3.5f) * 3f);
    let _e50 = mode_1;
    mode_1 = (_e50 / 8i);
    let _e53 = intensity_1;
    modG = _e53;
    let _e55 = intensity_1;
    let _e56 = colorVariability_1;
    let _e57 = mR;
    modR = (_e55 + (_e56 * _e57));
    let _e61 = intensity_1;
    let _e62 = colorVariability_1;
    let _e63 = mB;
    modB = (_e61 + (_e62 * _e63));
    let _e67 = mode_1;
    let _e71 = colorVariability_1;
    rdx = i32(round((f32((_e67 % 16i)) * _e71)));
    let _e76 = mode_1;
    mode_1 = (_e76 / 16i);
    let _e79 = mode_1;
    let _e83 = colorVariability_1;
    bdy = i32(round((f32((_e79 % 16i)) * _e83)));
    let _e88 = mode_1;
    mode_1 = (_e88 / 16i);
    let _e91 = uv_1;
    x_2 = i32(_e91.x);
    let _e95 = uv_1;
    y = i32(_e95.y);
    let _e99 = x_2;
    let _e100 = rdx;
    let _e102 = y;
    let _e104 = f32(((_e99 + _e100) ^ _e102));
    let _e105 = modR;
    let _e110 = modR;
    let _e111 = process_2;
    let _e112 = pr((_e104 - (floor((_e104 / _e105)) * _e105)), _e110, _e111);
    r = _e112;
    let _e114 = x_2;
    let _e115 = y;
    let _e117 = f32((_e114 ^ _e115));
    let _e118 = modG;
    let _e123 = modG;
    let _e124 = process_2;
    let _e125 = pr((_e117 - (floor((_e117 / _e118)) * _e118)), _e123, _e124);
    g = _e125;
    let _e127 = x_2;
    let _e128 = y;
    let _e129 = bdy;
    let _e132 = f32((_e127 ^ (_e128 + _e129)));
    let _e133 = modB;
    let _e138 = modB;
    let _e139 = process_2;
    let _e140 = pr((_e132 - (floor((_e132 / _e133)) * _e133)), _e138, _e139);
    b = _e140;
    let _e142 = x_2;
    let _e143 = rdx;
    let _e145 = y;
    let _e146 = bdy;
    let _e149 = f32(((_e142 + _e143) ^ (_e145 + _e146)));
    let _e150 = modG;
    let _e155 = modG;
    let _e156 = process_2;
    let _e157 = pr((_e149 - (floor((_e149 / _e150)) * _e150)), _e155, _e156);
    a = _e157;
    let _e159 = color1_1;
    let _e161 = color2_1;
    let _e163 = r;
    let _e165 = color1_1;
    let _e167 = color2_1;
    let _e169 = g;
    let _e171 = color1_1;
    let _e173 = color2_1;
    let _e175 = b;
    let _e177 = color1_1;
    let _e179 = color2_1;
    let _e181 = a;
    outColor = vec4<f32>(mix(_e159.x, _e161.x, _e163), mix(_e165.y, _e167.y, _e169), mix(_e171.z, _e173.z, _e175), mix(_e177.w, _e179.w, _e181));
    let _e185 = source_specified_1;
    if (_e185 == 1i) {
        let _e188 = outPos_1;
        let _e192 = global.U[0];
        let _e195 = outPos_1;
        let _e204 = textureSample(t_source, samp, ((vec2<f32>((_e188.x / _e192.x), _e195.y) / vec2(2f)) + vec2(0.5f)));
        let _e205 = outColor;
        let _e206 = mergeColor(_e204, _e205);
        return _e206;
    } else {
        let _e207 = outColor;
        return _e207;
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
    let _e66 = global.U[4];
    let _e71 = global.U[6];
    let _e75 = global.U[7];
    let _e79 = global.U[8];
    let _e84 = global.U[9];
    let _e87 = global.U[10];
    let _e88 = xorPatterns((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e9.x, _e9.y, _e9.z), vec3<f32>(_e13.x, _e13.y, _e13.z), vec3<f32>(_e17.x, _e17.y, _e17.z))) * vec3<f32>(_e44.x, _e44.y, 1f)).xy, (((_e51 - vec2(0.5f)) * 2f) * vec2<f32>(_e59.x, 1f)), i32(_e66.x), _e71.x, _e75.x, i32(_e79.x), _e84, _e87);
    fragColor = _e88;
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
