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

fn hexCubePixelate(uv: vec2<f32>, outPos: vec2<f32>, pixelation: f32, thickness: f32, color: vec4<f32>, modelTransform: mat3x3<f32>) -> vec4<f32> {
    var uv_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var pixelation_1: f32;
    var thickness_1: f32;
    var color_1: vec4<f32>;
    var modelTransform_1: mat3x3<f32>;
    var u: vec2<f32>;
    var hex: vec4<f32>;
    var v_2: vec2<f32>;
    var col: vec4<f32>;
    var l: f32;
    var pickCoord: vec2<f32>;
    var Y: f32;
    var a_1: f32;
    var a2_: f32;

    uv_1 = uv;
    outPos_1 = outPos;
    pixelation_1 = pixelation;
    thickness_1 = thickness;
    color_1 = color;
    modelTransform_1 = modelTransform;
    let _e18 = modelTransform_1;
    let _e20 = uv_1;
    u = (_naga_inverse_3x3_f32(_e18) * vec3<f32>(_e20.x, _e20.y, 1f)).xy;
    let _e28 = u;
    let _e29 = hexPolarBorderCoords(_e28);
    hex = _e29;
    let _e31 = modelTransform_1;
    let _e32 = hex;
    let _e33 = _e32.zw;
    v_2 = (_e31 * vec3<f32>(_e33.x, _e33.y, 1f)).xy;
    let _e41 = hex;
    let _e43 = thickness_1;
    if (_e41.y < (_e43 * 0.5f)) {
        {
            let _e47 = v_2;
            let _e51 = global.U[0];
            let _e54 = v_2;
            let _e64 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e47.x / _e51.x), _e54.y) / vec2(2f)) + vec2(0.5f)), 0f);
            col = _e64;
            let _e66 = col;
            let _e67 = color_1;
            let _e68 = mergeColor(_e66, _e67);
            return _e68;
        }
    } else {
        {
            let _e71 = modelTransform_1[0];
            l = length(_e71.xy);
            let _e76 = hex;
            let _e79 = pixelation_1;
            Y = mix(_e76.y, 0.5f, _e79);
            let _e82 = hex;
            a_1 = _e82.x;
            let _e85 = a_1;
            a2_ = (_e85 - 0.5235988f);
            let _e91 = a_1;
            let _e99 = a_1;
            if ((_e91 > -2.617994f) && (_e99 < -0.5235988f)) {
                let _e106 = hex;
                let _e108 = Y;
                pickCoord = (_e106.zw + (_e108 * vec2<f32>(0f, -0.5f)));
            } else {
                let _e115 = a_1;
                let _e123 = a_1;
                if ((_e115 <= -2.617994f) || (_e123 > 1.5707964f)) {
                    let _e127 = hex;
                    let _e129 = Y;
                    pickCoord = (_e127.zw + ((_e129 * 0.5f) * vec2<f32>(-0.8660254f, 0.5f)));
                } else {
                    let _e138 = hex;
                    let _e140 = Y;
                    pickCoord = (_e138.zw + ((_e140 * 0.5f) * vec2<f32>(0.8660254f, 0.5f)));
                }
            }
            let _e148 = modelTransform_1;
            let _e149 = pickCoord;
            v_2 = (_e148 * vec3<f32>(_e149.x, _e149.y, 1f)).xy;
            let _e156 = v_2;
            let _e160 = global.U[0];
            let _e163 = v_2;
            let _e173 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e156.x / _e160.x), _e163.y) / vec2(2f)) + vec2(0.5f)), 0f);
            return _e173;
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
    let _e77 = global.U[8];
    let _e78 = _e77.xyz;
    let _e81 = global.U[9];
    let _e82 = _e81.xyz;
    let _e85 = global.U[10];
    let _e86 = _e85.xyz;
    let _e100 = hexCubePixelate((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e9.x, _e9.y, _e9.z), vec3<f32>(_e13.x, _e13.y, _e13.z), vec3<f32>(_e17.x, _e17.y, _e17.z))) * vec3<f32>(_e44.x, _e44.y, 1f)).xy, (((_e51 - vec2(0.5f)) * 2f) * vec2<f32>(_e59.x, 1f)), _e66.x, _e70.x, _e74, mat3x3<f32>(vec3<f32>(_e78.x, _e78.y, _e78.z), vec3<f32>(_e82.x, _e82.y, _e82.z), vec3<f32>(_e86.x, _e86.y, _e86.z)));
    fragColor = _e100;
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
