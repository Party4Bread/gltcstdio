struct Params {
    U: array<vec4<f32>, 20>,
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

fn rand2_(v: vec2<f32>) -> vec2<f32> {
    var v_1: vec2<f32>;
    var x: f32;
    var y: f32;

    v_1 = v;
    let _e8 = v_1;
    x = fract((sin(dot(_e8.xy, vec2<f32>(12.9898f, 78.233f))) * 43758.547f));
    let _e19 = x;
    let _e20 = v_1;
    y = fract((sin(dot(vec2<f32>(_e19, _e20.x), vec2<f32>(12.9898f, 78.233f))) * 43758.547f));
    let _e32 = x;
    let _e33 = y;
    return vec2<f32>(_e32, _e33);
}

fn varyNoiseSmoothly(noise: f32, k: f32) -> f32 {
    var noise_1: f32;
    var k_1: f32;
    var phase: f32;
    var freq: f32;

    noise_1 = noise;
    k_1 = k;
    let _e11 = noise_1;
    phase = acos(((2f * _e11) - 1f));
    let _e17 = noise_1;
    freq = (fract((_e17 * 16f)) + 0.5f);
    let _e25 = phase;
    let _e26 = freq;
    let _e27 = k_1;
    return ((1f + cos((_e25 + (_e26 * _e27)))) * 0.5f);
}

fn varyVec2NoiseSmoothly(noise_2: vec2<f32>, k_2: f32) -> vec2<f32> {
    var noise_3: vec2<f32>;
    var k_3: f32;

    noise_3 = noise_2;
    k_3 = k_2;
    let _e10 = noise_3;
    let _e12 = k_3;
    let _e13 = varyNoiseSmoothly(_e10.x, _e12);
    let _e14 = noise_3;
    let _e16 = k_3;
    let _e17 = varyNoiseSmoothly(_e14.y, _e16);
    return vec2<f32>(_e13, _e17);
}

fn rand2relSeeded(co: vec2<f32>, seed: f32) -> vec2<f32> {
    var co_1: vec2<f32>;
    var seed_1: f32;

    co_1 = co;
    seed_1 = seed;
    let _e10 = co_1;
    let _e11 = rand2_(_e10);
    let _e12 = seed_1;
    let _e13 = varyVec2NoiseSmoothly(_e11, _e12);
    return (_e13 - vec2(0.5f));
}

fn getPoint(x_1: f32, y_1: f32, variability: f32, seed_2: f32) -> vec2<f32> {
    var x_2: f32;
    var y_2: f32;
    var variability_1: f32;
    var seed_3: f32;
    var u: vec2<f32>;

    x_2 = x_1;
    y_2 = y_1;
    variability_1 = variability;
    seed_3 = seed_2;
    let _e14 = x_2;
    let _e15 = y_2;
    u = vec2<f32>(_e14, _e15);
    let _e18 = u;
    let _e19 = variability_1;
    let _e22 = u;
    let _e23 = seed_3;
    let _e24 = rand2relSeeded(_e22, _e23);
    return (_e18 + ((_e19 * 4f) * _e24));
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

fn sdSegment(u_1: vec2<f32>, a: vec2<f32>, b: vec2<f32>) -> f32 {
    var u_2: vec2<f32>;
    var a_1: vec2<f32>;
    var b_1: vec2<f32>;
    var ua: vec2<f32>;
    var ba: vec2<f32>;
    var h: f32;

    u_2 = u_1;
    a_1 = a;
    b_1 = b;
    let _e12 = u_2;
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

fn tf(m: mat3x3<f32>, u_3: vec2<f32>) -> vec2<f32> {
    var m_1: mat3x3<f32>;
    var u_4: vec2<f32>;

    m_1 = m;
    u_4 = u_3;
    let _e10 = m_1;
    let _e11 = u_4;
    return (_e10 * vec3<f32>(_e11.x, _e11.y, 1f)).xy;
}

fn squareSegments(uv: vec2<f32>, outPos: vec2<f32>, variability_2: f32, randomSeed: f32, count: i32, step: f32, thickness: f32, color: vec4<f32>, modelTransform: mat3x3<f32>, outerTransform: mat3x3<f32>, innerTransform: mat3x3<f32>) -> vec4<f32> {
    var uv_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var variability_3: f32;
    var randomSeed_1: f32;
    var count_1: i32;
    var step_1: f32;
    var thickness_1: f32;
    var color_1: vec4<f32>;
    var modelTransform_1: mat3x3<f32>;
    var outerTransform_1: mat3x3<f32>;
    var innerTransform_1: mat3x3<f32>;
    var u_5: vec2<f32>;
    var a_2: vec2<f32> = vec2<f32>(0f, 0f);
    var b_2: vec2<f32>;
    var k_4: f32 = 0f;
    var th: f32;
    var o11_: vec2<f32>;
    var o21_: vec2<f32>;
    var o12_: vec2<f32>;
    var o22_: vec2<f32>;
    var i11_: vec2<f32>;
    var i21_: vec2<f32>;
    var i12_: vec2<f32>;
    var i22_: vec2<f32>;
    var i: i32 = 0i;
    var l: f32;
    var inCol: vec4<f32>;
    var mergeCol: vec4<f32>;

    uv_1 = uv;
    outPos_1 = outPos;
    variability_3 = variability_2;
    randomSeed_1 = randomSeed;
    count_1 = count;
    step_1 = step;
    thickness_1 = thickness;
    color_1 = color;
    modelTransform_1 = modelTransform;
    outerTransform_1 = outerTransform;
    innerTransform_1 = innerTransform;
    let _e28 = modelTransform_1;
    let _e30 = uv_1;
    let _e31 = tf(_naga_inverse_3x3_f32(_e28), _e30);
    u_5 = _e31;
    let _e37 = a_2;
    b_2 = _e37;
    let _e41 = thickness_1;
    let _e44 = modelTransform_1[0];
    th = (_e41 / length(_e44.xy));
    let _e49 = outerTransform_1;
    let _e54 = variability_3;
    let _e55 = randomSeed_1;
    let _e56 = getPoint(-1f, -1f, _e54, _e55);
    let _e57 = tf(_e49, _e56);
    o11_ = _e57;
    let _e59 = outerTransform_1;
    let _e63 = variability_3;
    let _e64 = randomSeed_1;
    let _e65 = getPoint(1f, -1f, _e63, _e64);
    let _e66 = tf(_e59, _e65);
    o21_ = _e66;
    let _e68 = outerTransform_1;
    let _e72 = variability_3;
    let _e73 = randomSeed_1;
    let _e74 = getPoint(-1f, 1f, _e72, _e73);
    let _e75 = tf(_e68, _e74);
    o12_ = _e75;
    let _e77 = outerTransform_1;
    let _e80 = variability_3;
    let _e81 = randomSeed_1;
    let _e82 = getPoint(1f, 1f, _e80, _e81);
    let _e83 = tf(_e77, _e82);
    o22_ = _e83;
    let _e85 = innerTransform_1;
    let _e90 = variability_3;
    let _e91 = randomSeed_1;
    let _e92 = getPoint(-1f, -1f, _e90, _e91);
    let _e93 = tf(_e85, _e92);
    i11_ = _e93;
    let _e95 = innerTransform_1;
    let _e99 = variability_3;
    let _e100 = randomSeed_1;
    let _e101 = getPoint(1f, -1f, _e99, _e100);
    let _e102 = tf(_e95, _e101);
    i21_ = _e102;
    let _e104 = innerTransform_1;
    let _e108 = variability_3;
    let _e109 = randomSeed_1;
    let _e110 = getPoint(-1f, 1f, _e108, _e109);
    let _e111 = tf(_e104, _e110);
    i12_ = _e111;
    let _e113 = innerTransform_1;
    let _e116 = variability_3;
    let _e117 = randomSeed_1;
    let _e118 = getPoint(1f, 1f, _e116, _e117);
    let _e119 = tf(_e113, _e118);
    i22_ = _e119;
    loop {
        let _e123 = i;
        let _e124 = count_1;
        if !((_e123 < _e124)) {
            break;
        }
        {
            let _e130 = i;
            let _e132 = count_1;
            l = (f32(_e130) / f32(_e132));
            let _e136 = k_4;
            let _e137 = th;
            let _e142 = th;
            let _e145 = u_5;
            let _e146 = o11_;
            let _e147 = o21_;
            let _e148 = l;
            let _e151 = i11_;
            let _e152 = i21_;
            let _e153 = l;
            let _e156 = sdSegment(_e145, mix(_e146, _e147, vec2(_e148)), mix(_e151, _e152, vec2(_e153)));
            k_4 = max(_e136, smoothstep(((_e137 * 0.1f) + 0.0005f), (_e142 * 0.1f), _e156));
            let _e159 = k_4;
            let _e160 = th;
            let _e165 = th;
            let _e168 = u_5;
            let _e169 = o21_;
            let _e170 = o22_;
            let _e171 = l;
            let _e174 = i21_;
            let _e175 = i22_;
            let _e176 = l;
            let _e179 = sdSegment(_e168, mix(_e169, _e170, vec2(_e171)), mix(_e174, _e175, vec2(_e176)));
            k_4 = max(_e159, smoothstep(((_e160 * 0.1f) + 0.0005f), (_e165 * 0.1f), _e179));
            let _e182 = k_4;
            let _e183 = th;
            let _e188 = th;
            let _e191 = u_5;
            let _e192 = o22_;
            let _e193 = o12_;
            let _e194 = l;
            let _e197 = i22_;
            let _e198 = i12_;
            let _e199 = l;
            let _e202 = sdSegment(_e191, mix(_e192, _e193, vec2(_e194)), mix(_e197, _e198, vec2(_e199)));
            k_4 = max(_e182, smoothstep(((_e183 * 0.1f) + 0.0005f), (_e188 * 0.1f), _e202));
            let _e205 = k_4;
            let _e206 = th;
            let _e211 = th;
            let _e214 = u_5;
            let _e215 = o12_;
            let _e216 = o11_;
            let _e217 = l;
            let _e220 = i12_;
            let _e221 = i11_;
            let _e222 = l;
            let _e225 = sdSegment(_e214, mix(_e215, _e216, vec2(_e217)), mix(_e220, _e221, vec2(_e222)));
            k_4 = max(_e205, smoothstep(((_e206 * 0.1f) + 0.0005f), (_e211 * 0.1f), _e225));
            let _e228 = k_4;
            if (_e228 >= 1f) {
                break;
            }
            let _e231 = b_2;
            a_2 = _e231;
        }
        continuing {
            let _e127 = i;
            i = (_e127 + 1i);
        }
    }
    let _e232 = uv_1;
    let _e236 = global.U[0];
    let _e239 = uv_1;
    let _e248 = textureSample(t_source, samp, ((vec2<f32>((_e232.x / _e236.x), _e239.y) / vec2(2f)) + vec2(0.5f)));
    inCol = _e248;
    let _e250 = inCol;
    let _e251 = color_1;
    let _e252 = mergeColor(_e250, _e251);
    mergeCol = _e252;
    let _e254 = inCol;
    let _e255 = mergeCol;
    let _e256 = k_4;
    return mix(_e254, _e255, vec4(_e256));
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
    let _e79 = global.U[8];
    let _e83 = global.U[9];
    let _e87 = global.U[10];
    let _e90 = global.U[11];
    let _e91 = _e90.xyz;
    let _e94 = global.U[12];
    let _e95 = _e94.xyz;
    let _e98 = global.U[13];
    let _e99 = _e98.xyz;
    let _e115 = global.U[14];
    let _e116 = _e115.xyz;
    let _e119 = global.U[15];
    let _e120 = _e119.xyz;
    let _e123 = global.U[16];
    let _e124 = _e123.xyz;
    let _e140 = global.U[17];
    let _e141 = _e140.xyz;
    let _e144 = global.U[18];
    let _e145 = _e144.xyz;
    let _e148 = global.U[19];
    let _e149 = _e148.xyz;
    let _e163 = squareSegments((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e9.x, _e9.y, _e9.z), vec3<f32>(_e13.x, _e13.y, _e13.z), vec3<f32>(_e17.x, _e17.y, _e17.z))) * vec3<f32>(_e44.x, _e44.y, 1f)).xy, (((_e51 - vec2(0.5f)) * 2f) * vec2<f32>(_e59.x, 1f)), _e66.x, _e70.x, i32(_e74.x), _e79.x, _e83.x, _e87, mat3x3<f32>(vec3<f32>(_e91.x, _e91.y, _e91.z), vec3<f32>(_e95.x, _e95.y, _e95.z), vec3<f32>(_e99.x, _e99.y, _e99.z)), mat3x3<f32>(vec3<f32>(_e116.x, _e116.y, _e116.z), vec3<f32>(_e120.x, _e120.y, _e120.z), vec3<f32>(_e124.x, _e124.y, _e124.z)), mat3x3<f32>(vec3<f32>(_e141.x, _e141.y, _e141.z), vec3<f32>(_e145.x, _e145.y, _e145.z), vec3<f32>(_e149.x, _e149.y, _e149.z)));
    fragColor = _e163;
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
