struct Params {
    U: array<vec4<f32>, 9>,
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

fn sdSegment(u: vec2<f32>, a: vec2<f32>, b: vec2<f32>) -> f32 {
    var u_1: vec2<f32>;
    var a_1: vec2<f32>;
    var b_1: vec2<f32>;
    var ua: vec2<f32>;
    var ba: vec2<f32>;
    var h: f32;

    u_1 = u;
    a_1 = a;
    b_1 = b;
    let _e12 = u_1;
    let _e13 = a_1;
    ua = (_e12 - _e13);
    let _e16 = b_1;
    let _e17 = a_1;
    ba = (_e16 - _e17);
    let _e20 = ua;
    let _e21 = ba;
    let _e23 = ba;
    let _e24 = ba;
    h = clamp((dot(_e20, _e21) / dot(_e23, _e24)), 0f, 1f);
    let _e31 = ua;
    let _e32 = ba;
    let _e33 = h;
    return length((_e31 - (_e32 * _e33)));
}

fn tf(m: mat3x3<f32>, u_2: vec2<f32>) -> vec2<f32> {
    var m_1: mat3x3<f32>;
    var u_3: vec2<f32>;

    m_1 = m;
    u_3 = u_2;
    let _e10 = m_1;
    let _e11 = u_3;
    return (_e10 * vec3<f32>(_e11.x, _e11.y, 1f)).xy;
}

fn rotateSmart(uv: vec2<f32>, outPos: vec2<f32>, rotateMode: i32, sourceDim: vec2<f32>, includedRect: vec2<f32>, colorOut: vec4<f32>, viewTransform: mat3x3<f32>) -> vec4<f32> {
    var uv_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var rotateMode_1: i32;
    var sourceDim_1: vec2<f32>;
    var includedRect_1: vec2<f32>;
    var colorOut_1: vec4<f32>;
    var viewTransform_1: mat3x3<f32>;
    var ratio: f32;
    var boundA: vec2<f32>;
    var boundB: vec2<f32>;
    var bounds: vec2<f32>;
    var u_4: vec2<f32>;
    var inside: bool;
    var local: vec4<f32>;
    var bounds2_: vec2<f32>;
    var v: vec2<f32>;
    var delta: vec2<f32>;
    var u_5: vec2<f32>;
    var u_6: vec2<f32>;
    var inside_1: bool;
    var local_1: vec4<f32>;

    uv_1 = uv;
    outPos_1 = outPos;
    rotateMode_1 = rotateMode;
    sourceDim_1 = sourceDim;
    includedRect_1 = includedRect;
    colorOut_1 = colorOut;
    viewTransform_1 = viewTransform;
    let _e20 = sourceDim_1;
    let _e22 = sourceDim_1;
    ratio = (_e20.x / _e22.y);
    let _e26 = viewTransform_1;
    let _e27 = ratio;
    let _e30 = tf(_e26, vec2<f32>(_e27, 1f));
    boundA = abs(_e30);
    let _e33 = viewTransform_1;
    let _e34 = ratio;
    let _e38 = tf(_e33, vec2<f32>(_e34, -1f));
    boundB = abs(_e38);
    let _e41 = boundA;
    let _e43 = boundB;
    let _e46 = boundA;
    let _e48 = boundB;
    bounds = vec2<f32>(max(_e41.x, _e43.x), max(_e46.y, _e48.y));
    let _e53 = rotateMode_1;
    if (_e53 <= 1i) {
        {
            let _e56 = uv_1;
            u_4 = _e56;
            let _e58 = u_4;
            let _e61 = ratio;
            let _e63 = u_4;
            inside = ((abs(_e58.x) <= _e61) && (abs(_e63.y) <= 1f));
            let _e70 = inside;
            let _e71 = rotateMode_1;
            if (_e70 || (_e71 == 1i)) {
                let _e75 = uv_1;
                let _e79 = global.U[0];
                let _e82 = uv_1;
                let _e91 = _mirror_wrap(((vec2<f32>((_e75.x / _e79.x), _e82.y) / vec2(2f)) + vec2(0.5f)));
                let _e93 = textureSampleLevel(t_source, samp, _e91, 0f);
                local = _e93;
            } else {
                let _e94 = uv_1;
                let _e98 = global.U[0];
                let _e101 = uv_1;
                let _e110 = _mirror_wrap(((vec2<f32>((_e94.x / _e98.x), _e101.y) / vec2(2f)) + vec2(0.5f)));
                let _e112 = textureSampleLevel(t_source, samp, _e110, 0f);
                let _e113 = colorOut_1;
                let _e114 = mergeColor(_e112, _e113);
                local = _e114;
            }
            let _e116 = local;
            return _e116;
        }
    }
    let _e117 = rotateMode_1;
    if (_e117 == 3i) {
        {
            let _e120 = viewTransform_1;
            let _e121 = includedRect_1;
            let _e122 = tf(_e120, _e121);
            bounds2_ = abs(_e122);
            let _e125 = viewTransform_1;
            let _e126 = uv_1;
            let _e127 = tf(_e125, _e126);
            let _e128 = bounds;
            v = (_e127 * _e128.y);
            let _e132 = v;
            let _e134 = bounds2_;
            delta = abs((abs(_e132) - _e134));
            let _e138 = uv_1;
            let _e139 = bounds2_;
            u_5 = (_e138 * abs(_e139.y));
            let _e144 = u_5;
            let _e148 = global.U[0];
            let _e151 = u_5;
            let _e160 = _mirror_wrap(((vec2<f32>((_e144.x / _e148.x), _e151.y) / vec2(2f)) + vec2(0.5f)));
            let _e162 = textureSampleLevel(t_source, samp, _e160, 0f);
            return _e162;
        }
    }
    let _e163 = uv_1;
    let _e164 = bounds;
    u_6 = (_e163 * _e164.y);
    let _e168 = u_6;
    let _e171 = ratio;
    let _e173 = u_6;
    inside_1 = ((abs(_e168.x) <= _e171) && (abs(_e173.y) <= 1f));
    let _e180 = inside_1;
    if _e180 {
        let _e181 = uv_1;
        let _e185 = global.U[0];
        let _e188 = uv_1;
        let _e197 = _mirror_wrap(((vec2<f32>((_e181.x / _e185.x), _e188.y) / vec2(2f)) + vec2(0.5f)));
        let _e199 = textureSampleLevel(t_source, samp, _e197, 0f);
        local_1 = _e199;
    } else {
        let _e200 = uv_1;
        let _e204 = global.U[0];
        let _e207 = uv_1;
        let _e216 = _mirror_wrap(((vec2<f32>((_e200.x / _e204.x), _e207.y) / vec2(2f)) + vec2(0.5f)));
        let _e218 = textureSampleLevel(t_source, samp, _e216, 0f);
        let _e219 = colorOut_1;
        let _e220 = mergeColor(_e218, _e219);
        local_1 = _e220;
    }
    let _e222 = local_1;
    return _e222;
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
    let _e66 = global.U[6];
    let _e71 = global.U[4];
    let _e75 = global.U[7];
    let _e79 = global.U[8];
    let _e82 = global.U[1];
    let _e83 = _e82.xyz;
    let _e86 = global.U[2];
    let _e87 = _e86.xyz;
    let _e90 = global.U[3];
    let _e91 = _e90.xyz;
    let _e105 = rotateSmart((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e9.x, _e9.y, _e9.z), vec3<f32>(_e13.x, _e13.y, _e13.z), vec3<f32>(_e17.x, _e17.y, _e17.z))) * vec3<f32>(_e44.x, _e44.y, 1f)).xy, (((_e51 - vec2(0.5f)) * 2f) * vec2<f32>(_e59.x, 1f)), i32(_e66.x), _e71.xy, _e75.xy, _e79, mat3x3<f32>(vec3<f32>(_e83.x, _e83.y, _e83.z), vec3<f32>(_e87.x, _e87.y, _e87.z), vec3<f32>(_e91.x, _e91.y, _e91.z)));
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
