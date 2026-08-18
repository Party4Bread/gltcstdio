struct Params {
    U: array<vec4<f32>, 18>,
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

fn hexCoords(v: vec2<f32>) -> vec4<f32> {
    var v_1: vec2<f32>;
    var r: vec2<f32> = vec2<f32>(1f, 1.7320508f);
    var h: vec2<f32>;
    var a: vec2<f32>;
    var b: vec2<f32>;
    var local: vec2<f32>;
    var hv: vec2<f32>;
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
    let _e73 = v_1;
    let _e74 = hv;
    id = (_e73 - _e74);
    let _e77 = hv;
    let _e78 = id;
    return vec4<f32>(_e77.x, _e77.y, _e78.x, _e78.y);
}

fn measure(v_2: vec2<f32>, power: f32) -> f32 {
    var v_3: vec2<f32>;
    var power_1: f32;
    var low: f32;
    var high: f32;
    var local_1: f32;

    v_3 = v_2;
    power_1 = power;
    let _e10 = v_3;
    let _e13 = v_3;
    low = min(abs(_e10.x), abs(_e13.y));
    let _e18 = v_3;
    let _e21 = v_3;
    high = max(abs(_e18.x), abs(_e21.y));
    let _e26 = high;
    if (_e26 == 0f) {
        local_1 = 0f;
    } else {
        let _e30 = high;
        let _e32 = low;
        let _e33 = high;
        let _e35 = power_1;
        let _e39 = power_1;
        local_1 = (_e30 * pow((1f + pow((_e32 / _e33), _e35)), (1f / _e39)));
    }
    let _e44 = local_1;
    return _e44;
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

fn circleRippleIllusion(uv: vec2<f32>, outPos: vec2<f32>, source_specified: i32, power_2: f32, mode: i32, count: i32, modCount: i32, color1_: vec4<f32>, color2_: vec4<f32>, modelTransform: mat3x3<f32>, modelTransform2_: mat3x3<f32>) -> vec4<f32> {
    var uv_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var source_specified_1: i32;
    var power_3: f32;
    var mode_1: i32;
    var count_1: i32;
    var modCount_1: i32;
    var color1_1: vec4<f32>;
    var color2_1: vec4<f32>;
    var modelTransform_1: mat3x3<f32>;
    var modelTransform2_1: mat3x3<f32>;
    var g: f32 = 1f;
    var inverseTransform: mat3x3<f32>;
    var inverseTransform2_: mat3x3<f32>;
    var origUv: vec2<f32>;
    var origUv_1: vec2<f32>;
    var i: f32 = 0f;
    var d: f32;
    var col: vec4<f32>;

    uv_1 = uv;
    outPos_1 = outPos;
    source_specified_1 = source_specified;
    power_3 = power_2;
    mode_1 = mode;
    count_1 = count;
    modCount_1 = modCount;
    color1_1 = color1_;
    color2_1 = color2_;
    modelTransform_1 = modelTransform;
    modelTransform2_1 = modelTransform2_;
    let _e30 = modelTransform_1;
    inverseTransform = _naga_inverse_3x3_f32(_e30);
    let _e33 = modelTransform2_1;
    inverseTransform2_ = _naga_inverse_3x3_f32(_e33);
    let _e36 = mode_1;
    if (_e36 == 1i) {
        {
            let _e39 = uv_1;
            let _e42 = (_e39 + vec2(1f));
            let _e44 = vec2(2f);
            uv_1 = ((_e42 - (floor((_e42 / _e44)) * _e44)) - vec2(1f));
        }
    } else {
        let _e52 = mode_1;
        if (_e52 == 2i) {
            {
                let _e55 = uv_1;
                let _e58 = hexCoords((_e55 * 0.5f));
                uv_1 = (_e58.xy * 2f);
            }
        } else {
            let _e62 = mode_1;
            if (_e62 == 3i) {
                {
                    let _e65 = uv_1;
                    origUv = _e65;
                    let _e67 = uv_1;
                    let _e70 = (_e67 + vec2(1f));
                    let _e72 = vec2(2f);
                    uv_1 = ((_e70 - (floor((_e70 / _e72)) * _e72)) - vec2(1f));
                    let _e80 = uv_1;
                    let _e81 = power_3;
                    let _e82 = measure(_e80, _e81);
                    if (_e82 > 1f) {
                        let _e85 = origUv;
                        let _e87 = vec2(2f);
                        let _e98 = power_3;
                        uv_1 = (((_e85 - (floor((_e85 / _e87)) * _e87)) - vec2(1f)) / vec2(((1f / pow(0.5f, (1f / _e98))) - 1f)));
                    }
                }
            } else {
                let _e106 = mode_1;
                if (_e106 == 4i) {
                    {
                        let _e109 = uv_1;
                        origUv_1 = _e109;
                        let _e111 = uv_1;
                        let _e114 = hexCoords((_e111 * 0.5f));
                        uv_1 = (_e114.xy * 2f);
                        let _e118 = uv_1;
                        let _e119 = power_3;
                        let _e120 = measure(_e118, _e119);
                        if (_e120 > 1f) {
                            {
                                let _e123 = origUv_1;
                                let _e132 = hexCoords(((_e123 * 0.5f) - vec2<f32>(0f, 0.57735026f)));
                                uv_1 = (_e132.xy * 2f);
                                let _e136 = uv_1;
                                uv_1 = (_e136 * 6.464102f);
                                let _e139 = uv_1;
                                let _e140 = power_3;
                                let _e141 = measure(_e139, _e140);
                                if (_e141 > 1f) {
                                    {
                                        let _e144 = origUv_1;
                                        let _e153 = hexCoords(((_e144 * 0.5f) + vec2<f32>(0f, 0.57735026f)));
                                        uv_1 = (_e153.xy * 2f);
                                        let _e157 = uv_1;
                                        uv_1 = (_e157 * 6.464102f);
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    loop {
        let _e162 = i;
        let _e163 = count_1;
        if !((_e162 < f32(_e163))) {
            break;
        }
        {
            let _e170 = uv_1;
            let _e171 = power_3;
            let _e172 = measure(_e170, _e171);
            d = _e172;
            let _e174 = d;
            if (_e174 > 1f) {
                {
                    break;
                }
            }
            let _e177 = inverseTransform;
            let _e178 = uv_1;
            let _e179 = tf(_e177, _e178);
            uv_1 = _e179;
            let _e180 = i;
            let _e182 = (_e180 + 1f);
            let _e183 = modCount_1;
            let _e184 = f32(_e183);
            if ((_e182 - (floor((_e182 / _e184)) * _e184)) == 0f) {
                let _e191 = inverseTransform2_;
                let _e192 = uv_1;
                let _e193 = tf(_e191, _e192);
                uv_1 = _e193;
            }
            let _e195 = g;
            g = (1f - _e195);
        }
        continuing {
            let _e167 = i;
            i = (_e167 + 1f);
        }
    }
    let _e197 = color1_1;
    let _e198 = color2_1;
    let _e199 = g;
    col = mix(_e197, _e198, vec4(_e199));
    let _e203 = source_specified_1;
    if (_e203 == 1i) {
        {
            let _e206 = uv_1;
            let _e210 = global.U[0];
            let _e213 = uv_1;
            let _e222 = textureSample(t_source, samp, ((vec2<f32>((_e206.x / _e210.x), _e213.y) / vec2(2f)) + vec2(0.5f)));
            let _e223 = col;
            let _e224 = mergeColor(_e222, _e223);
            col = _e224;
        }
    }
    let _e225 = col;
    return _e225;
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
    let _e80 = global.U[8];
    let _e85 = global.U[9];
    let _e90 = global.U[10];
    let _e93 = global.U[11];
    let _e96 = global.U[12];
    let _e97 = _e96.xyz;
    let _e100 = global.U[13];
    let _e101 = _e100.xyz;
    let _e104 = global.U[14];
    let _e105 = _e104.xyz;
    let _e121 = global.U[15];
    let _e122 = _e121.xyz;
    let _e125 = global.U[16];
    let _e126 = _e125.xyz;
    let _e129 = global.U[17];
    let _e130 = _e129.xyz;
    let _e144 = circleRippleIllusion((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e9.x, _e9.y, _e9.z), vec3<f32>(_e13.x, _e13.y, _e13.z), vec3<f32>(_e17.x, _e17.y, _e17.z))) * vec3<f32>(_e44.x, _e44.y, 1f)).xy, (((_e51 - vec2(0.5f)) * 2f) * vec2<f32>(_e59.x, 1f)), i32(_e66.x), _e71.x, i32(_e75.x), i32(_e80.x), i32(_e85.x), _e90, _e93, mat3x3<f32>(vec3<f32>(_e97.x, _e97.y, _e97.z), vec3<f32>(_e101.x, _e101.y, _e101.z), vec3<f32>(_e105.x, _e105.y, _e105.z)), mat3x3<f32>(vec3<f32>(_e122.x, _e122.y, _e122.z), vec3<f32>(_e126.x, _e126.y, _e126.z), vec3<f32>(_e130.x, _e130.y, _e130.z)));
    fragColor = _e144;
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
