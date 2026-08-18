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

fn _mirror_wrap(c: vec2<f32>) -> vec2<f32> {
    var c_1: vec2<f32>;

    c_1 = c;
    let _e9 = c_1;
    let _e11 = vec2(2f);
    return (vec2(1f) - abs(((_e9 - (floor((_e9 / _e11)) * _e11)) - vec2(1f))));
}

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

fn hexPolarCoords(v_2: vec2<f32>) -> vec4<f32> {
    var v_3: vec2<f32>;
    var r_1: vec2<f32> = vec2<f32>(1f, 1.7320508f);
    var h_1: vec2<f32>;
    var a_1: vec2<f32>;
    var b_1: vec2<f32>;
    var local_1: vec2<f32>;
    var hv_1: vec2<f32>;
    var x_1: f32;
    var y_1: f32;
    var id_1: vec2<f32>;

    v_3 = v_2;
    let _e12 = r_1;
    h_1 = (_e12 / vec2(2f));
    let _e17 = v_3;
    let _e19 = r_1;
    let _e25 = v_3;
    let _e27 = r_1;
    let _e34 = h_1;
    a_1 = (vec2<f32>((_e17.x - (floor((_e17.x / _e19.x)) * _e19.x)), (_e25.y - (floor((_e25.y / _e27.y)) * _e27.y))) - _e34);
    let _e37 = v_3;
    let _e39 = h_1;
    let _e41 = (_e37.x - _e39.x);
    let _e42 = r_1;
    let _e48 = v_3;
    let _e50 = h_1;
    let _e52 = (_e48.y - _e50.y);
    let _e53 = r_1;
    let _e60 = h_1;
    b_1 = (vec2<f32>((_e41 - (floor((_e41 / _e42.x)) * _e42.x)), (_e52 - (floor((_e52 / _e53.y)) * _e53.y))) - _e60);
    let _e63 = a_1;
    let _e65 = b_1;
    if (length(_e63) < length(_e65)) {
        let _e68 = a_1;
        local_1 = _e68;
    } else {
        let _e69 = b_1;
        local_1 = _e69;
    }
    let _e71 = local_1;
    hv_1 = _e71;
    let _e73 = hv_1;
    let _e75 = hv_1;
    x_1 = atan2(_e73.y, _e75.x);
    let _e79 = hv_1;
    y_1 = length(_e79);
    let _e82 = v_3;
    let _e83 = hv_1;
    id_1 = (_e82 - _e83);
    let _e86 = x_1;
    let _e87 = y_1;
    let _e88 = id_1;
    return vec4<f32>(_e86, _e87, _e88.x, _e88.y);
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

fn tf(m: mat3x3<f32>, u: vec2<f32>) -> vec2<f32> {
    var m_1: mat3x3<f32>;
    var u_1: vec2<f32>;

    m_1 = m;
    u_1 = u;
    let _e10 = m_1;
    let _e11 = u_1;
    return (_e10 * vec3<f32>(_e11.x, _e11.y, 1f)).xy;
}

fn hexPixelate(uv: vec2<f32>, outPos: vec2<f32>, pixelation: f32, thickness: f32, color: vec4<f32>, modelTransform: mat3x3<f32>) -> vec4<f32> {
    var uv_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var pixelation_1: f32;
    var thickness_1: f32;
    var color_1: vec4<f32>;
    var modelTransform_1: mat3x3<f32>;
    var streaking: f32;
    var u_2: vec2<f32>;
    var hex: vec4<f32>;
    var v_4: vec2<f32>;
    var col: vec4<f32>;
    var l: f32;
    var hex2_: vec4<f32>;
    var ang: f32;
    var k: f32;
    var v2_: vec2<f32>;

    uv_1 = uv;
    outPos_1 = outPos;
    pixelation_1 = pixelation;
    thickness_1 = thickness;
    color_1 = color;
    modelTransform_1 = modelTransform;
    let _e18 = pixelation_1;
    streaking = _e18;
    let _e20 = modelTransform_1;
    let _e22 = uv_1;
    u_2 = (_naga_inverse_3x3_f32(_e20) * vec3<f32>(_e22.x, _e22.y, 1f)).xy;
    let _e30 = u_2;
    let _e31 = hexPolarBorderCoords(_e30);
    hex = _e31;
    let _e33 = modelTransform_1;
    let _e34 = hex;
    let _e35 = _e34.zw;
    v_4 = (_e33 * vec3<f32>(_e35.x, _e35.y, 1f)).xy;
    let _e43 = hex;
    let _e45 = thickness_1;
    if (_e43.y < (_e45 * 0.5f)) {
        {
            let _e49 = v_4;
            let _e53 = global.U[0];
            let _e56 = v_4;
            let _e65 = _mirror_wrap(((vec2<f32>((_e49.x / _e53.x), _e56.y) / vec2(2f)) + vec2(0.5f)));
            let _e66 = textureSample(t_source, samp, _e65);
            col = _e66;
            let _e68 = col;
            let _e69 = color_1;
            let _e70 = mergeColor(_e68, _e69);
            return _e70;
        }
    } else {
        {
            let _e71 = streaking;
            if (_e71 >= 0f) {
                {
                    let _e76 = modelTransform_1[0];
                    l = length(_e76.xy);
                    let _e80 = v_4;
                    let _e81 = streaking;
                    let _e82 = l;
                    let _e85 = hex;
                    let _e93 = global.U[0];
                    let _e96 = v_4;
                    let _e97 = streaking;
                    let _e98 = l;
                    let _e101 = hex;
                    let _e114 = _mirror_wrap(((vec2<f32>(((_e80 + ((_e81 * _e82) * vec2<f32>(0f, _e85.y))).x / _e93.x), (_e96 + ((_e97 * _e98) * vec2<f32>(0f, _e101.y))).y) / vec2(2f)) + vec2(0.5f)));
                    let _e115 = textureSample(t_source, samp, _e114);
                    return _e115;
                }
            } else {
                {
                    let _e116 = u_2;
                    let _e117 = hexPolarCoords(_e116);
                    hex2_ = _e117;
                    let _e119 = hex;
                    let _e124 = (_e119.x + 0.5235988f);
                    ang = ((_e124 - (floor((_e124 / 1.0471976f)) * 1.0471976f)) - 0.5235988f);
                    let _e138 = ang;
                    k = (1f / cos(_e138));
                    let _e142 = modelTransform_1;
                    let _e143 = hex;
                    let _e145 = streaking;
                    let _e148 = k;
                    let _e150 = hex;
                    let _e153 = hex;
                    let _e159 = tf(_e142, (_e143.zw - (((_e145 * 0.5f) * _e148) * vec2<f32>(cos(_e150.x), sin(_e153.x)))));
                    v2_ = _e159;
                    let _e161 = v2_;
                    let _e165 = global.U[0];
                    let _e168 = v2_;
                    let _e177 = _mirror_wrap(((vec2<f32>((_e161.x / _e165.x), _e168.y) / vec2(2f)) + vec2(0.5f)));
                    let _e178 = textureSample(t_source, samp, _e177);
                    return _e178;
                }
            }
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
    let _e100 = hexPixelate((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e9.x, _e9.y, _e9.z), vec3<f32>(_e13.x, _e13.y, _e13.z), vec3<f32>(_e17.x, _e17.y, _e17.z))) * vec3<f32>(_e44.x, _e44.y, 1f)).xy, (((_e51 - vec2(0.5f)) * 2f) * vec2<f32>(_e59.x, 1f)), _e66.x, _e70.x, _e74, mat3x3<f32>(vec3<f32>(_e78.x, _e78.y, _e78.z), vec3<f32>(_e82.x, _e82.y, _e82.z), vec3<f32>(_e86.x, _e86.y, _e86.z)));
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
