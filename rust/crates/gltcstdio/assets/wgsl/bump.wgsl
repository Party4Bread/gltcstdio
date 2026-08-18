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

fn _mirror_wrap(c: vec2<f32>) -> vec2<f32> {
    var c_1: vec2<f32>;

    c_1 = c;
    let _e9 = c_1;
    let _e11 = vec2(2f);
    return (vec2(1f) - abs(((_e9 - (floor((_e9 / _e11)) * _e11)) - vec2(1f))));
}

fn measure(v: vec2<f32>, power: f32) -> f32 {
    var v_1: vec2<f32>;
    var power_1: f32;
    var low: f32;
    var high: f32;
    var local: f32;

    v_1 = v;
    power_1 = power;
    let _e10 = v_1;
    let _e13 = v_1;
    low = min(abs(_e10.x), abs(_e13.y));
    let _e18 = v_1;
    let _e21 = v_1;
    high = max(abs(_e18.x), abs(_e21.y));
    let _e26 = high;
    if (_e26 == 0f) {
        local = 0f;
    } else {
        let _e30 = high;
        let _e32 = low;
        let _e33 = high;
        let _e35 = power_1;
        let _e39 = power_1;
        local = (_e30 * pow((1f + pow((_e32 / _e33), _e35)), (1f / _e39)));
    }
    let _e44 = local;
    return _e44;
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

fn bump(uv: vec2<f32>, outPos: vec2<f32>, sourceDim: vec2<f32>, intensity: f32, power_2: f32, dampening: f32, lighting: f32, highFreqColor: vec4<f32>, modelTransform: mat3x3<f32>) -> vec4<f32> {
    var uv_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var sourceDim_1: vec2<f32>;
    var intensity_1: f32;
    var power_3: f32;
    var dampening_1: f32;
    var lighting_1: f32;
    var highFreqColor_1: vec4<f32>;
    var modelTransform_1: mat3x3<f32>;
    var t: mat3x3<f32>;
    var ratio: f32;
    var local_1: vec2<f32>;
    var u_2: vec2<f32>;
    var v_2: vec2<f32>;
    var d: f32;
    var kCol: f32 = 0f;
    var light: f32 = 1f;
    var dilation: f32 = 1f;
    var k: f32;
    var b: f32;
    var pixel: f32;
    var grad: vec2<f32>;
    var local_2: vec2<f32>;
    var outCol: vec4<f32>;

    uv_1 = uv;
    outPos_1 = outPos;
    sourceDim_1 = sourceDim;
    intensity_1 = intensity;
    power_3 = power_2;
    dampening_1 = dampening;
    lighting_1 = lighting;
    highFreqColor_1 = highFreqColor;
    modelTransform_1 = modelTransform;
    let _e24 = modelTransform_1;
    t = _naga_inverse_3x3_f32(_e24);
    let _e27 = sourceDim_1;
    let _e29 = sourceDim_1;
    ratio = (_e27.x / _e29.y);
    let _e33 = ratio;
    if (_e33 < 1f) {
        let _e36 = uv_1;
        let _e37 = ratio;
        local_1 = (_e36 / vec2(_e37));
    } else {
        let _e40 = uv_1;
        local_1 = _e40;
    }
    let _e42 = local_1;
    u_2 = _e42;
    let _e44 = t;
    let _e45 = u_2;
    let _e46 = tf(_e44, _e45);
    v_2 = _e46;
    let _e48 = v_2;
    let _e49 = power_3;
    let _e50 = measure(_e48, _e49);
    d = _e50;
    let _e58 = d;
    let _e61 = d;
    if ((_e58 > 0f) && (_e61 < 1f)) {
        {
            let _e65 = d;
            let _e66 = d;
            k = (_e65 * _e66);
            let _e69 = intensity_1;
            if (_e69 <= 0f) {
                {
                    let _e72 = k;
                    let _e73 = intensity_1;
                    dilation = pow(_e72, (_e73 * 2.5f));
                }
            } else {
                {
                    let _e78 = intensity_1;
                    b = (1f - (_e78 * 2f));
                    let _e83 = b;
                    let _e84 = k;
                    let _e86 = b;
                    dilation = (_e83 + (_e84 * (1f - _e86)));
                }
            }
            let _e90 = dampening_1;
            let _e93 = d;
            let _e95 = dampening_1;
            if ((_e90 > 0f) && (_e93 > (1f - _e95))) {
                {
                    let _e100 = dilation;
                    let _e103 = dampening_1;
                    let _e105 = d;
                    dilation = mix(1f, _e100, smoothstep(1f, (1f - _e103), _e105));
                }
            } else {
                let _e108 = dampening_1;
                if (_e108 < 0f) {
                    {
                        let _e111 = dilation;
                        let _e113 = dampening_1;
                        let _e114 = dampening_1;
                        let _e118 = d;
                        let _e123 = dampening_1;
                        dilation = (_e111 * (1f - (((_e113 * _e114) * 0.25f) * pow((_e118 * 2f), (-4f * _e123)))));
                    }
                }
            }
            let _e131 = dilation;
            let _e133 = highFreqColor_1;
            kCol = smoothstep(0f, 3f, (log(_e131) * _e133.w));
            let _e137 = modelTransform_1;
            let _e138 = dilation;
            let _e139 = v_2;
            let _e141 = tf(_e137, (_e138 * _e139));
            u_2 = _e141.xy;
        }
    }
    let _e143 = lighting_1;
    if (_e143 > 0f) {
        {
            let _e147 = sourceDim_1;
            pixel = (2f / _e147.y);
            let _e151 = dilation;
            let _e152 = dpdx(_e151);
            let _e153 = u_2;
            let _e155 = dpdx(_e153.x);
            let _e157 = dilation;
            let _e158 = dpdy(_e157);
            let _e159 = u_2;
            let _e161 = dpdy(_e159.y);
            grad = (vec2<f32>((_e152 / _e155), (_e158 / _e161)) * 4f);
            let _e168 = lighting_1;
            let _e169 = grad;
            light = (1f + (_e168 * dot(_e169, vec2<f32>(0f, -1f))));
        }
    }
    let _e177 = ratio;
    if (_e177 < 1f) {
        let _e180 = u_2;
        let _e181 = ratio;
        local_2 = (_e180 * _e181);
    } else {
        let _e183 = u_2;
        local_2 = _e183;
    }
    let _e185 = local_2;
    u_2 = _e185;
    let _e186 = u_2;
    let _e190 = global.U[0];
    let _e193 = u_2;
    let _e202 = _mirror_wrap(((vec2<f32>((_e186.x / _e190.x), _e193.y) / vec2(2f)) + vec2(0.5f)));
    let _e203 = textureSample(t_source, samp, _e202);
    outCol = _e203;
    let _e205 = outCol;
    let _e207 = outCol;
    let _e209 = light;
    let _e210 = (_e207.xyz * _e209);
    outCol.x = _e210.x;
    outCol.y = _e210.y;
    outCol.z = _e210.z;
    let _e217 = outCol;
    let _e218 = highFreqColor_1;
    let _e219 = _e218.xyz;
    let _e225 = kCol;
    return mix(_e217, vec4<f32>(_e219.x, _e219.y, _e219.z, 1f), vec4(_e225));
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
    let _e70 = global.U[6];
    let _e74 = global.U[7];
    let _e78 = global.U[8];
    let _e82 = global.U[9];
    let _e86 = global.U[10];
    let _e89 = global.U[11];
    let _e90 = _e89.xyz;
    let _e93 = global.U[12];
    let _e94 = _e93.xyz;
    let _e97 = global.U[13];
    let _e98 = _e97.xyz;
    let _e112 = bump((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e9.x, _e9.y, _e9.z), vec3<f32>(_e13.x, _e13.y, _e13.z), vec3<f32>(_e17.x, _e17.y, _e17.z))) * vec3<f32>(_e44.x, _e44.y, 1f)).xy, (((_e51 - vec2(0.5f)) * 2f) * vec2<f32>(_e59.x, 1f)), _e66.xy, _e70.x, _e74.x, _e78.x, _e82.x, _e86, mat3x3<f32>(vec3<f32>(_e90.x, _e90.y, _e90.z), vec3<f32>(_e94.x, _e94.y, _e94.z), vec3<f32>(_e98.x, _e98.y, _e98.z)));
    fragColor = _e112;
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
