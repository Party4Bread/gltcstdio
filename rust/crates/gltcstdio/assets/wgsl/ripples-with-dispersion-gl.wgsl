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

fn _mirror_wrap(c: vec2<f32>) -> vec2<f32> {
    var c_1: vec2<f32>;

    c_1 = c;
    let _e9 = c_1;
    let _e11 = vec2(2f);
    return (vec2(1f) - abs(((_e9 - (floor((_e9 / _e11)) * _e11)) - vec2(1f))));
}

fn rwdGetRGBWeights(w: f32) -> vec4<f32> {
    var w_1: f32;

    w_1 = w;
    let _e9 = w_1;
    let _e14 = w_1;
    let _e19 = w_1;
    return vec4<f32>(max(0f, -(_e9)), max(0f, (1f - abs(_e14))), max(0f, _e19), 1f);
}

fn ripplesWithDispersionGL(pos: vec2<f32>, outPos: vec2<f32>, intensity: f32, dispersion: f32, dampening: f32, count: i32, modelTransform: mat3x3<f32>) -> vec4<f32> {
    var pos_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var intensity_1: f32;
    var dispersion_1: f32;
    var dampening_1: f32;
    var count_1: i32;
    var modelTransform_1: mat3x3<f32>;
    var invM: mat3x3<f32>;
    var u: vec2<f32>;
    var d: f32;
    var rippleCount: f32;
    var local: f32;
    var dampen: f32;
    var dilation: f32;
    var coord: vec2<f32>;
    var wStep: f32 = 0.05f;
    var totalColor: vec4<f32> = vec4<f32>(0f, 0f, 0f, 0f);
    var totalWeight: vec4<f32> = vec4<f32>(0f, 0f, 0f, 0f);
    var disp: f32;
    var w_2: f32 = -1f;
    var dilation_1: f32;
    var coord_1: vec2<f32>;
    var weight: vec4<f32>;

    pos_1 = pos;
    outPos_1 = outPos;
    intensity_1 = intensity;
    dispersion_1 = dispersion;
    dampening_1 = dampening;
    count_1 = count;
    modelTransform_1 = modelTransform;
    let _e20 = modelTransform_1;
    invM = _naga_inverse_3x3_f32(_e20);
    let _e23 = invM;
    let _e24 = pos_1;
    u = (_e23 * vec3<f32>(_e24.x, _e24.y, 1f)).xy;
    let _e32 = u;
    d = length(_e32);
    let _e35 = count_1;
    rippleCount = f32(_e35);
    let _e38 = d;
    if (_e38 >= 1f) {
        {
            let _e41 = pos_1;
            let _e45 = global.U[0];
            let _e48 = pos_1;
            let _e57 = _mirror_wrap(((vec2<f32>((_e41.x / _e45.x), _e48.y) / vec2(2f)) + vec2(0.5f)));
            let _e58 = textureSample(t_source, samp, _e57);
            return _e58;
        }
    } else {
        {
            let _e59 = dampening_1;
            if (_e59 >= 0f) {
                let _e63 = d;
                let _e65 = dampening_1;
                local = pow((1f - _e63), (_e65 * 2f));
            } else {
                let _e69 = d;
                let _e70 = dampening_1;
                local = pow(_e69, (-(_e70) * 5f));
            }
            let _e76 = local;
            dampen = _e76;
            let _e78 = dispersion_1;
            if (_e78 == 0f) {
                {
                    let _e82 = intensity_1;
                    let _e83 = d;
                    let _e84 = rippleCount;
                    let _e90 = dampen;
                    dilation = (1f + ((_e82 * sin(((_e83 * _e84) * 3.1415927f))) * _e90));
                    let _e94 = modelTransform_1;
                    let _e95 = dilation;
                    let _e96 = u;
                    let _e97 = (_e95 * _e96);
                    coord = (_e94 * vec3<f32>(_e97.x, _e97.y, 1f)).xy;
                    let _e105 = coord;
                    let _e109 = global.U[0];
                    let _e112 = coord;
                    let _e121 = _mirror_wrap(((vec2<f32>((_e105.x / _e109.x), _e112.y) / vec2(2f)) + vec2(0.5f)));
                    let _e122 = textureSample(t_source, samp, _e121);
                    return _e122;
                }
            } else {
                {
                    let _e137 = dispersion_1;
                    disp = (_e137 * 10f);
                    loop {
                        let _e144 = w_2;
                        if !((_e144 <= 1f)) {
                            break;
                        }
                        {
                            let _e152 = intensity_1;
                            let _e154 = w_2;
                            let _e155 = disp;
                            let _e159 = d;
                            let _e160 = rippleCount;
                            let _e166 = dampen;
                            dilation_1 = (1f + (((_e152 * (1f + (_e154 * _e155))) * sin(((_e159 * _e160) * 3.1415927f))) * _e166));
                            let _e170 = modelTransform_1;
                            let _e171 = dilation_1;
                            let _e172 = u;
                            let _e173 = (_e171 * _e172);
                            coord_1 = (_e170 * vec3<f32>(_e173.x, _e173.y, 1f)).xy;
                            let _e181 = w_2;
                            let _e182 = rwdGetRGBWeights(_e181);
                            weight = _e182;
                            let _e184 = totalColor;
                            let _e185 = weight;
                            let _e186 = coord_1;
                            let _e190 = global.U[0];
                            let _e193 = coord_1;
                            let _e202 = _mirror_wrap(((vec2<f32>((_e186.x / _e190.x), _e193.y) / vec2(2f)) + vec2(0.5f)));
                            let _e203 = textureSample(t_source, samp, _e202);
                            totalColor = (_e184 + (_e185 * _e203));
                            let _e206 = totalWeight;
                            let _e207 = weight;
                            totalWeight = (_e206 + _e207);
                        }
                        continuing {
                            let _e148 = w_2;
                            let _e149 = wStep;
                            w_2 = (_e148 + _e149);
                        }
                    }
                    let _e209 = totalColor;
                    let _e210 = totalWeight;
                    return (_e209 / _e210);
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
    let _e78 = global.U[8];
    let _e83 = global.U[9];
    let _e84 = _e83.xyz;
    let _e87 = global.U[10];
    let _e88 = _e87.xyz;
    let _e91 = global.U[11];
    let _e92 = _e91.xyz;
    let _e106 = ripplesWithDispersionGL((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e9.x, _e9.y, _e9.z), vec3<f32>(_e13.x, _e13.y, _e13.z), vec3<f32>(_e17.x, _e17.y, _e17.z))) * vec3<f32>(_e44.x, _e44.y, 1f)).xy, (((_e51 - vec2(0.5f)) * 2f) * vec2<f32>(_e59.x, 1f)), _e66.x, _e70.x, _e74.x, i32(_e78.x), mat3x3<f32>(vec3<f32>(_e84.x, _e84.y, _e84.z), vec3<f32>(_e88.x, _e88.y, _e88.z), vec3<f32>(_e92.x, _e92.y, _e92.z)));
    fragColor = _e106;
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
