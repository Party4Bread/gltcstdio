struct Params {
    U: array<vec4<f32>, 21>,
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

fn mergeGlow(bkg_2: vec4<f32>, glow: vec4<f32>) -> vec4<f32> {
    var bkg_3: vec4<f32>;
    var glow_1: vec4<f32>;

    bkg_3 = bkg_2;
    glow_1 = glow;
    let _e10 = bkg_3;
    let _e12 = glow_1;
    let _e14 = glow_1;
    let _e17 = (_e10.xyz + (_e12.xyz * _e14.w));
    let _e18 = bkg_3;
    return vec4<f32>(_e17.x, _e17.y, _e17.z, _e18.w);
}

fn sdDisk(u: vec2<f32>, r: f32) -> f32 {
    var u_1: vec2<f32>;
    var r_1: f32;

    u_1 = u;
    r_1 = r;
    let _e10 = u_1;
    let _e12 = r_1;
    return (length(_e10) - _e12);
}

fn sdEquiTriangle(u_2: vec2<f32>) -> f32 {
    var u_3: vec2<f32>;

    u_3 = u_2;
    let _e9 = u_3;
    u_3.x = (abs(_e9.x) - 1f);
    let _e15 = u_3;
    u_3.y = (_e15.y + 0.57735026f);
    let _e21 = u_3;
    let _e24 = u_3;
    if ((_e21.x + (1.7320508f * _e24.y)) > 0f) {
        let _e30 = u_3;
        let _e33 = u_3;
        let _e39 = u_3;
        let _e42 = u_3;
        u_3 = (vec2<f32>((_e30.x - (1.7320508f * _e33.y)), ((-1.7320508f * _e39.x) - _e42.y)) / vec2(2f));
    }
    let _e50 = u_3;
    let _e52 = u_3;
    u_3.x = (_e50.x - clamp(_e52.x, -2f, 0f));
    let _e59 = u_3;
    let _e62 = u_3;
    return (-(length(_e59)) * sign(_e62.y));
}

fn sdRectangle(u_4: vec2<f32>, halfSize: vec2<f32>) -> f32 {
    var u_5: vec2<f32>;
    var halfSize_1: vec2<f32>;
    var local: f32;

    u_5 = u_4;
    halfSize_1 = halfSize;
    let _e10 = u_5;
    let _e12 = halfSize_1;
    u_5 = (abs(_e10) - _e12);
    let _e14 = u_5;
    let _e18 = u_5;
    if ((_e14.x >= 0f) && (_e18.y >= 0f)) {
        let _e23 = u_5;
        local = length(_e23);
    } else {
        let _e25 = u_5;
        let _e27 = u_5;
        local = max(_e25.x, _e27.y);
    }
    let _e31 = local;
    return _e31;
}

fn sdf(u_6: vec2<f32>, count: f32, shape: f32, cellTransform: mat3x3<f32>) -> f32 {
    var u_7: vec2<f32>;
    var count_1: f32;
    var shape_1: f32;
    var cellTransform_1: mat3x3<f32>;

    u_7 = u_6;
    count_1 = count;
    shape_1 = shape;
    cellTransform_1 = cellTransform;
    let _e14 = cellTransform_1;
    let _e15 = u_7;
    let _e16 = u_7;
    let _e18 = count_1;
    let _e20 = count_1;
    let _e26 = ((_e15 - clamp(round(_e16), vec2(-(_e18)), vec2(_e20))) * 2f);
    u_7 = (_e14 * vec3<f32>(_e26.x, _e26.y, 1f)).xy;
    let _e33 = shape_1;
    if (_e33 < 0f) {
        let _e36 = u_7;
        let _e39 = sdRectangle(_e36, vec2(0.5f));
        return _e39;
    } else {
        let _e40 = shape_1;
        if (_e40 <= 1f) {
            let _e43 = u_7;
            let _e46 = sdRectangle(_e43, vec2(0.5f));
            let _e47 = u_7;
            let _e49 = sdDisk(_e47, 0.5f);
            let _e50 = shape_1;
            return mix(_e46, _e49, _e50);
        } else {
            let _e52 = shape_1;
            if (_e52 <= 2f) {
                let _e55 = u_7;
                let _e57 = sdDisk(_e55, 0.5f);
                let _e58 = u_7;
                let _e61 = sdEquiTriangle((_e58 * 1.5f));
                let _e62 = shape_1;
                return mix(_e57, _e61, (_e62 - 1f));
            } else {
                let _e66 = u_7;
                let _e69 = sdEquiTriangle((_e66 * 1.5f));
                return _e69;
            }
        }
    }
}

fn tf(m: mat3x3<f32>, u_8: vec2<f32>) -> vec2<f32> {
    var m_1: mat3x3<f32>;
    var u_9: vec2<f32>;

    m_1 = m;
    u_9 = u_8;
    let _e10 = m_1;
    let _e11 = u_9;
    return (_e10 * vec3<f32>(_e11.x, _e11.y, 1f)).xy;
}

fn gridOfSquares(uv: vec2<f32>, outPos: vec2<f32>, count_2: i32, shape_2: f32, shadows: f32, colorIn: vec4<f32>, colorOut: vec4<f32>, colorShadow: vec4<f32>, colorGlow: vec4<f32>, modelTransform: mat3x3<f32>, insideTransform: mat3x3<f32>, cellTransform_2: mat3x3<f32>) -> vec4<f32> {
    var uv_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var count_3: i32;
    var shape_3: f32;
    var shadows_1: f32;
    var colorIn_1: vec4<f32>;
    var colorOut_1: vec4<f32>;
    var colorShadow_1: vec4<f32>;
    var colorGlow_1: vec4<f32>;
    var modelTransform_1: mat3x3<f32>;
    var insideTransform_1: mat3x3<f32>;
    var cellTransform_3: mat3x3<f32>;
    var u_10: vec2<f32>;
    var d: f32;
    var shadow: f32 = 0f;
    var tint: vec4<f32> = vec4(0f);
    var v: vec2<f32>;
    var color: vec4<f32>;
    var local_1: vec4<f32>;
    var glow_2: vec4<f32>;

    uv_1 = uv;
    outPos_1 = outPos;
    count_3 = count_2;
    shape_3 = shape_2;
    shadows_1 = shadows;
    colorIn_1 = colorIn;
    colorOut_1 = colorOut;
    colorShadow_1 = colorShadow;
    colorGlow_1 = colorGlow;
    modelTransform_1 = modelTransform;
    insideTransform_1 = insideTransform;
    cellTransform_3 = cellTransform_2;
    let _e30 = modelTransform_1;
    let _e32 = uv_1;
    let _e33 = tf(_naga_inverse_3x3_f32(_e30), _e32);
    u_10 = _e33;
    let _e35 = u_10;
    let _e36 = count_3;
    let _e38 = shape_3;
    let _e39 = cellTransform_3;
    let _e41 = sdf(_e35, f32(_e36), _e38, _naga_inverse_3x3_f32(_e39));
    d = _e41;
    let _e48 = uv_1;
    v = _e48;
    let _e50 = d;
    if (_e50 > 0f) {
        {
            let _e53 = shadows_1;
            if (_e53 > 0f) {
                let _e57 = shadows_1;
                let _e59 = d;
                shadow = (0.7f * smoothstep(_e57, 0f, _e59));
            }
            let _e62 = colorOut_1;
            tint = _e62;
        }
    } else {
        {
            let _e63 = shadows_1;
            if (_e63 < 0f) {
                let _e67 = shadows_1;
                let _e69 = d;
                shadow = (0.7f * smoothstep(_e67, 0f, _e69));
            }
            let _e72 = colorIn_1;
            tint = _e72;
            let _e73 = insideTransform_1;
            let _e75 = uv_1;
            let _e76 = tf(_naga_inverse_3x3_f32(_e73), _e75);
            v = _e76;
        }
    }
    let _e77 = v;
    let _e81 = global.U[0];
    let _e84 = v;
    let _e93 = textureSample(t_source, samp, ((vec2<f32>((_e77.x / _e81.x), _e84.y) / vec2(2f)) + vec2(0.5f)));
    color = _e93;
    let _e95 = colorGlow_1;
    if (_e95.w != 0f) {
        let _e99 = colorGlow_1;
        let _e103 = d;
        let _e106 = ((_e99.xyz * 0.01f) / vec3(abs(_e103)));
        let _e108 = colorGlow_1;
        let _e112 = d;
        local_1 = vec4<f32>(_e106.x, _e106.y, _e106.z, min(1f, ((_e108.w * 0.01f) / abs(_e112))));
    } else {
        local_1 = vec4(0f);
    }
    let _e123 = local_1;
    glow_2 = _e123;
    let _e125 = color;
    let _e126 = tint;
    let _e127 = mergeColor(_e125, _e126);
    let _e128 = colorShadow_1;
    let _e129 = _e128.xyz;
    let _e130 = colorShadow_1;
    let _e132 = shadow;
    let _e138 = mergeColor(_e127, vec4<f32>(_e129.x, _e129.y, _e129.z, (_e130.w * _e132)));
    let _e139 = glow_2;
    let _e140 = mergeGlow(_e138, _e139);
    return _e140;
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
    let _e71 = global.U[6];
    let _e75 = global.U[7];
    let _e79 = global.U[8];
    let _e82 = global.U[9];
    let _e85 = global.U[10];
    let _e88 = global.U[11];
    let _e91 = global.U[12];
    let _e92 = _e91.xyz;
    let _e95 = global.U[13];
    let _e96 = _e95.xyz;
    let _e99 = global.U[14];
    let _e100 = _e99.xyz;
    let _e116 = global.U[15];
    let _e117 = _e116.xyz;
    let _e120 = global.U[16];
    let _e121 = _e120.xyz;
    let _e124 = global.U[17];
    let _e125 = _e124.xyz;
    let _e141 = global.U[18];
    let _e142 = _e141.xyz;
    let _e145 = global.U[19];
    let _e146 = _e145.xyz;
    let _e149 = global.U[20];
    let _e150 = _e149.xyz;
    let _e164 = gridOfSquares((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e9.x, _e9.y, _e9.z), vec3<f32>(_e13.x, _e13.y, _e13.z), vec3<f32>(_e17.x, _e17.y, _e17.z))) * vec3<f32>(_e44.x, _e44.y, 1f)).xy, (((_e51 - vec2(0.5f)) * 2f) * vec2<f32>(_e59.x, 1f)), i32(_e66.x), _e71.x, _e75.x, _e79, _e82, _e85, _e88, mat3x3<f32>(vec3<f32>(_e92.x, _e92.y, _e92.z), vec3<f32>(_e96.x, _e96.y, _e96.z), vec3<f32>(_e100.x, _e100.y, _e100.z)), mat3x3<f32>(vec3<f32>(_e117.x, _e117.y, _e117.z), vec3<f32>(_e121.x, _e121.y, _e121.z), vec3<f32>(_e125.x, _e125.y, _e125.z)), mat3x3<f32>(vec3<f32>(_e142.x, _e142.y, _e142.z), vec3<f32>(_e146.x, _e146.y, _e146.z), vec3<f32>(_e150.x, _e150.y, _e150.z)));
    fragColor = _e164;
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
