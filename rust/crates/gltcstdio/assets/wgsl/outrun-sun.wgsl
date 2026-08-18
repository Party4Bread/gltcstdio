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

fn tf(m: mat3x3<f32>, u: vec2<f32>) -> vec2<f32> {
    var m_1: mat3x3<f32>;
    var u_1: vec2<f32>;

    m_1 = m;
    u_1 = u;
    let _e10 = m_1;
    let _e11 = u_1;
    return (_e10 * vec3<f32>(_e11.x, _e11.y, 1f)).xy;
}

fn outrunSun(uv: vec2<f32>, outPos: vec2<f32>, thickness: f32, color1_: vec4<f32>, color2_: vec4<f32>, glow: f32, modelTransform: mat3x3<f32>) -> vec4<f32> {
    var uv_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var thickness_1: f32;
    var color1_1: vec4<f32>;
    var color2_1: vec4<f32>;
    var glow_1: f32;
    var modelTransform_1: mat3x3<f32>;
    var u_2: vec2<f32>;
    var bkgCol: vec4<f32>;
    var l: f32;
    var color: vec4<f32>;
    var inside: bool = false;
    var i: f32;
    var d: f32;
    var glowColor: vec4<f32>;
    var alpha: f32;

    uv_1 = uv;
    outPos_1 = outPos;
    thickness_1 = thickness;
    color1_1 = color1_;
    color2_1 = color2_;
    glow_1 = glow;
    modelTransform_1 = modelTransform;
    let _e20 = modelTransform_1;
    let _e22 = uv_1;
    let _e23 = tf(_naga_inverse_3x3_f32(_e20), _e22);
    u_2 = _e23;
    let _e25 = uv_1;
    let _e29 = global.U[0];
    let _e32 = uv_1;
    let _e41 = textureSample(t_source, samp, ((vec2<f32>((_e25.x / _e29.x), _e32.y) / vec2(2f)) + vec2(0.5f)));
    bkgCol = _e41;
    let _e43 = u_2;
    l = length(_e43);
    let _e46 = bkgCol;
    color = _e46;
    let _e50 = l;
    if (_e50 < 1f) {
        {
            let _e53 = u_2;
            if (_e53.y > 0f) {
                {
                    let _e58 = u_2;
                    let _e60 = thickness_1;
                    i = (1f + (_e58.y * (_e60 * 4f)));
                    let _e66 = i;
                    let _e67 = i;
                    if (fract((_e66 * _e67)) > 0.5f) {
                        {
                            let _e72 = color1_1;
                            let _e73 = color2_1;
                            let _e75 = u_2;
                            color = mix(_e72, _e73, vec4((0.5f + (_e75.y * 0.5f))));
                            inside = true;
                        }
                    }
                }
            } else {
                let _e83 = u_2;
                if (_e83.y <= 0f) {
                    {
                        let _e87 = color1_1;
                        let _e88 = color2_1;
                        let _e90 = u_2;
                        color = mix(_e87, _e88, vec4((0.5f + (_e90.y * 0.5f))));
                        inside = true;
                    }
                }
            }
        }
    }
    let _e98 = inside;
    let _e100 = glow_1;
    if (!(_e98) && (_e100 > 0f)) {
        {
            let _e105 = l;
            d = (max(0f, (_e105 - 1f)) + 1.1f);
            let _e112 = color1_1;
            let _e113 = color2_1;
            let _e115 = u_2;
            glowColor = mix(_e112, _e113, vec4((0.5f + (_e115.y * 0.5f))));
            let _e123 = d;
            let _e127 = glow_1;
            alpha = (pow(_e123, -2.5f) * _e127);
            let _e130 = color;
            let _e132 = color;
            let _e134 = glowColor;
            let _e136 = alpha;
            let _e138 = mix(_e132.xyz, _e134.xyz, vec3(_e136));
            color.x = _e138.x;
            color.y = _e138.y;
            color.z = _e138.z;
        }
    }
    let _e145 = bkgCol;
    let _e146 = color;
    let _e147 = mergeColor(_e145, _e146);
    return _e147;
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
    let _e73 = global.U[7];
    let _e76 = global.U[8];
    let _e80 = global.U[9];
    let _e81 = _e80.xyz;
    let _e84 = global.U[10];
    let _e85 = _e84.xyz;
    let _e88 = global.U[11];
    let _e89 = _e88.xyz;
    let _e103 = outrunSun((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e9.x, _e9.y, _e9.z), vec3<f32>(_e13.x, _e13.y, _e13.z), vec3<f32>(_e17.x, _e17.y, _e17.z))) * vec3<f32>(_e44.x, _e44.y, 1f)).xy, (((_e51 - vec2(0.5f)) * 2f) * vec2<f32>(_e59.x, 1f)), _e66.x, _e70, _e73, _e76.x, mat3x3<f32>(vec3<f32>(_e81.x, _e81.y, _e81.z), vec3<f32>(_e85.x, _e85.y, _e85.z), vec3<f32>(_e89.x, _e89.y, _e89.z)));
    fragColor = _e103;
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
