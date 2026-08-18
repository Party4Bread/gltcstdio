struct Params {
    U: array<vec4<f32>, 14>,
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

fn truchet(uv: vec2<f32>, outPos: vec2<f32>, source_specified: i32, border: f32, thickness: f32, variability: f32, randomSeed: f32, color1_: vec4<f32>, colorLines: vec4<f32>, colorBorder: vec4<f32>, colorBkg: vec4<f32>) -> vec4<f32> {
    var uv_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var source_specified_1: i32;
    var border_1: f32;
    var thickness_1: f32;
    var variability_1: f32;
    var randomSeed_1: f32;
    var color1_1: vec4<f32>;
    var colorLines_1: vec4<f32>;
    var colorBorder_1: vec4<f32>;
    var colorBkg_1: vec4<f32>;
    var u: vec2<f32>;
    var id: vec2<f32>;
    var rnd: f32;
    var col: vec4<f32>;
    var t: f32;
    var d: f32;

    uv_1 = uv;
    outPos_1 = outPos;
    source_specified_1 = source_specified;
    border_1 = border;
    thickness_1 = thickness;
    variability_1 = variability;
    randomSeed_1 = randomSeed;
    color1_1 = color1_;
    colorLines_1 = colorLines;
    colorBorder_1 = colorBorder;
    colorBkg_1 = colorBkg;
    let _e28 = uv_1;
    u = fract(_e28);
    let _e31 = uv_1;
    id = floor(_e31);
    let _e35 = id;
    let _e36 = randomSeed_1;
    let _e37 = rand2relSeeded(_e35, _e36);
    let _e41 = variability_1;
    rnd = mix(0f, (_e37.x + 0.5f), _e41);
    let _e44 = rnd;
    if (_e44 < 0.25f) {
        let _e47 = u;
        let _e50 = u;
        u = vec2<f32>(_e47.x, (1f - _e50.y));
    } else {
        let _e54 = rnd;
        if (_e54 < 0.5f) {
            let _e58 = u;
            let _e61 = u;
            u = vec2<f32>((1f - _e58.x), _e61.y);
        } else {
            let _e64 = rnd;
            if (_e64 < 0.75f) {
                let _e68 = u;
                let _e72 = u;
                u = vec2<f32>((1f - _e68.x), (1f - _e72.y));
            }
        }
    }
    let _e77 = thickness_1;
    t = _e77;
    let _e79 = u;
    d = (abs((length(_e79) - 0.5f)) * 2f);
    let _e87 = d;
    let _e88 = t;
    if (_e87 > _e88) {
        {
            let _e91 = u;
            u = (vec2(1f) - _e91);
            let _e94 = u;
            d = (abs((length(_e94) - 0.5f)) * 2f);
            let _e101 = d;
            let _e102 = t;
            if (_e101 > _e102) {
                let _e104 = colorBkg_1;
                col = _e104;
            } else {
                let _e105 = d;
                let _e106 = t;
                let _e108 = border_1;
                if (_e105 > (_e106 * (1f - _e108))) {
                    let _e112 = colorBorder_1;
                    col = _e112;
                } else {
                    let _e113 = colorLines_1;
                    col = _e113;
                }
            }
        }
    } else {
        let _e114 = d;
        let _e115 = t;
        let _e117 = border_1;
        if (_e114 > (_e115 * (1f - _e117))) {
            let _e121 = colorBorder_1;
            col = _e121;
        } else {
            let _e122 = colorLines_1;
            col = _e122;
        }
    }
    let _e123 = source_specified_1;
    if (_e123 == 1i) {
        {
            let _e126 = uv_1;
            let _e130 = global.U[0];
            let _e133 = uv_1;
            let _e142 = textureSample(t_source, samp, ((vec2<f32>((_e126.x / _e130.x), _e133.y) / vec2(2f)) + vec2(0.5f)));
            let _e143 = col;
            let _e144 = mergeColor(_e142, _e143);
            col = _e144;
        }
    }
    let _e145 = col;
    return _e145;
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
    let _e83 = global.U[9];
    let _e87 = global.U[10];
    let _e90 = global.U[11];
    let _e93 = global.U[12];
    let _e96 = global.U[13];
    let _e97 = truchet((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e9.x, _e9.y, _e9.z), vec3<f32>(_e13.x, _e13.y, _e13.z), vec3<f32>(_e17.x, _e17.y, _e17.z))) * vec3<f32>(_e44.x, _e44.y, 1f)).xy, (((_e51 - vec2(0.5f)) * 2f) * vec2<f32>(_e59.x, 1f)), i32(_e66.x), _e71.x, _e75.x, _e79.x, _e83.x, _e87, _e90, _e93, _e96);
    fragColor = _e97;
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
