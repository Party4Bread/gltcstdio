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

fn bentRowsIllusion(uv: vec2<f32>, outPos: vec2<f32>, source_specified: i32, count: i32, offset: f32, thickness: f32, color1_: vec4<f32>, color2_: vec4<f32>, color3_: vec4<f32>) -> vec4<f32> {
    var uv_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var source_specified_1: i32;
    var count_1: i32;
    var offset_1: f32;
    var thickness_1: f32;
    var color1_1: vec4<f32>;
    var color2_1: vec4<f32>;
    var color3_1: vec4<f32>;
    var u: vec2<f32>;
    var outColor: vec4<f32>;
    var row: f32;
    var N: f32;
    var rowIndex: f32;
    var local: f32;
    var local_1: f32;
    var offsetMul: f32;
    var k: i32;

    uv_1 = uv;
    outPos_1 = outPos;
    source_specified_1 = source_specified;
    count_1 = count;
    offset_1 = offset;
    thickness_1 = thickness;
    color1_1 = color1_;
    color2_1 = color2_;
    color3_1 = color3_;
    let _e24 = uv_1;
    u = abs((fract((_e24 - vec2(0.5f))) - vec2(0.5f)));
    let _e34 = thickness_1;
    thickness_1 = (_e34 * 0.2f);
    let _e38 = u;
    let _e40 = thickness_1;
    if (_e38.y < _e40) {
        {
            let _e42 = color3_1;
            outColor = _e42;
        }
    } else {
        {
            let _e43 = uv_1;
            row = floor(_e43.y);
            let _e47 = count_1;
            N = f32(_e47);
            let _e50 = row;
            let _e52 = N;
            let _e55 = ((2f * _e52) - 2f);
            rowIndex = (_e50 - (floor((_e50 / _e55)) * _e55));
            let _e61 = count_1;
            if (_e61 == 1i) {
                local_1 = 0f;
            } else {
                let _e65 = rowIndex;
                let _e66 = N;
                if (_e65 >= _e66) {
                    let _e69 = N;
                    let _e73 = rowIndex;
                    local = (((2f * _e69) - 2f) - _e73);
                } else {
                    let _e75 = rowIndex;
                    local = _e75;
                }
                let _e77 = local;
                local_1 = _e77;
            }
            let _e79 = local_1;
            offsetMul = _e79;
            let _e81 = uv_1;
            let _e83 = offset_1;
            let _e84 = offsetMul;
            k = i32(floor((_e81.x + (_e83 * _e84))));
            let _e90 = k;
            if ((_e90 % 2i) == 0i) {
                let _e95 = color1_1;
                outColor = _e95;
            } else {
                let _e96 = color2_1;
                outColor = _e96;
            }
        }
    }
    let _e97 = source_specified_1;
    if (_e97 == 1i) {
        let _e100 = outPos_1;
        let _e104 = global.U[0];
        let _e107 = outPos_1;
        let _e116 = textureSample(t_source, samp, ((vec2<f32>((_e100.x / _e104.x), _e107.y) / vec2(2f)) + vec2(0.5f)));
        let _e117 = outColor;
        let _e118 = mergeColor(_e116, _e117);
        return _e118;
    } else {
        let _e119 = outColor;
        return _e119;
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
    let _e76 = global.U[7];
    let _e80 = global.U[8];
    let _e84 = global.U[9];
    let _e87 = global.U[10];
    let _e90 = global.U[11];
    let _e91 = bentRowsIllusion((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e9.x, _e9.y, _e9.z), vec3<f32>(_e13.x, _e13.y, _e13.z), vec3<f32>(_e17.x, _e17.y, _e17.z))) * vec3<f32>(_e44.x, _e44.y, 1f)).xy, (((_e51 - vec2(0.5f)) * 2f) * vec2<f32>(_e59.x, 1f)), i32(_e66.x), i32(_e71.x), _e76.x, _e80.x, _e84, _e87, _e90);
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
