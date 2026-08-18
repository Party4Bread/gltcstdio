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
var t_effect: texture_2d<f32>;
@group(0) @binding(3) 
var t_source: texture_2d<f32>;

fn blend(mode: i32, a: vec4<f32>, b: vec4<f32>) -> vec4<f32> {
    var mode_1: i32;
    var a_1: vec4<f32>;
    var b_1: vec4<f32>;
    var aa: vec3<f32>;
    var bb: vec3<f32>;
    var cc: vec3<f32>;
    var _sw_sel: i32;

    mode_1 = mode;
    a_1 = a;
    b_1 = b;
    let _e13 = a_1;
    aa = _e13.xyz;
    let _e16 = b_1;
    bb = _e16.xyz;
    {
        let _e20 = mode_1;
        _sw_sel = i32(_e20);
        let _e23 = _sw_sel;
        if (_e23 == 1i) {
            {
                let _e27 = aa;
                let _e28 = bb;
                cc = (_e27 + _e28);
            }
        } else {
            let _e30 = _sw_sel;
            if (_e30 == 2i) {
                {
                    let _e34 = aa;
                    let _e35 = bb;
                    cc = (_e34 * _e35);
                }
            } else {
                let _e37 = _sw_sel;
                if (_e37 == 3i) {
                    {
                        let _e41 = aa;
                        let _e42 = bb;
                        cc = (_e41 - _e42);
                    }
                } else {
                    let _e44 = _sw_sel;
                    if (_e44 == 4i) {
                        {
                            let _e48 = aa;
                            let _e49 = bb;
                            cc = abs((_e48 - _e49));
                        }
                    } else {
                        let _e52 = _sw_sel;
                        if (_e52 == 5i) {
                            {
                                let _e56 = aa;
                                let _e57 = bb;
                                cc = (_e56 / _e57);
                            }
                        } else {
                            let _e59 = _sw_sel;
                            if (_e59 == 10i) {
                                {
                                    let _e63 = a_1;
                                    let _e64 = b_1;
                                    return max(_e63, _e64);
                                }
                            } else {
                                let _e66 = _sw_sel;
                                if (_e66 == 11i) {
                                    {
                                        let _e70 = a_1;
                                        let _e71 = b_1;
                                        return min(_e70, _e71);
                                    }
                                } else {
                                    {
                                        let _e73 = b_1;
                                        return _e73;
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    let _e74 = cc;
    let _e75 = a_1;
    let _e77 = b_1;
    return vec4<f32>(_e74.x, _e74.y, _e74.z, mix(_e75.w, _e77.w, 0.5f));
}

fn locusFmod(a_2: f32, b_2: f32) -> f32 {
    var a_3: f32;
    var b_3: f32;

    a_3 = a_2;
    b_3 = b_2;
    let _e11 = a_3;
    let _e12 = b_3;
    let _e13 = a_3;
    let _e14 = b_3;
    return (_e11 - (_e12 * trunc((_e13 / _e14))));
}

fn locusGetBlock(pos: vec2<f32>) -> f32 {
    var pos_1: vec2<f32>;
    var inside: f32 = 0f;
    var i2_: f32;
    var divisor: f32;
    var threshold: f32;
    var total: f32 = 0f;
    var rdmz: vec4<f32>;
    var i: i32 = 0i;
    var v: vec2<f32>;
    var index: f32;
    var local: f32;
    var idx: f32;
    var ins: f32;
    var local_1: f32;

    pos_1 = pos;
    let _e11 = pos_1;
    let _e16 = pos_1;
    i2_ = (floor((_e11.x / 10f)) + floor((_e16.y / 10f)));
    let _e23 = pos_1;
    let _e26 = pos_1;
    let _e33 = locusFmod(((_e23.x - (2f * _e26.y)) / 200f), 24f);
    divisor = (floor(_e33) / 2f);
    let _e38 = pos_1;
    let _e41 = pos_1;
    let _e48 = locusFmod(((_e38.x + (2f * _e41.y)) / 200f), 24f);
    threshold = (_e48 / 6f);
    let _e54 = i2_;
    let _e58 = locusFmod((_e54 * 8877f), 65536f);
    let _e60 = i2_;
    let _e65 = locusFmod((55f + (_e60 * 777f)), 65536f);
    let _e66 = i2_;
    let _e70 = locusFmod((_e66 * 413f), 65536f);
    let _e72 = i2_;
    let _e77 = locusFmod((4445f + (_e72 * 78f)), 65536f);
    rdmz = vec4<f32>(_e58, _e65, _e70, _e77);
    loop {
        let _e82 = i;
        if !((_e82 < 5i)) {
            break;
        }
        {
            let _e89 = pos_1;
            let _e92 = locusFmod(_e89.x, 8f);
            let _e93 = pos_1;
            let _e96 = locusFmod(_e93.y, 8f);
            v = vec2<f32>(_e92, _e96);
            let _e99 = v;
            let _e101 = v;
            index = (_e99.x + (_e101.y * 8f));
            let _e107 = pos_1;
            let _e110 = locusFmod(_e107.y, 300f);
            if (_e110 > 150f) {
                local = 3f;
            } else {
                let _e114 = index;
                local = clamp(floor((_e114 / 16f)), 0f, 3f);
            }
            let _e122 = local;
            idx = _e122;
            let _e124 = idx;
            let _e127 = rdmz[i32(_e124)];
            let _e129 = index;
            let _e130 = idx;
            let _e138 = locusFmod(floor((_e127 / pow(2f, (_e129 - (_e130 * 16f))))), 2f);
            ins = _e138;
            let _e140 = total;
            let _e141 = ins;
            total = (_e140 + _e141);
            let _e143 = pos_1;
            let _e144 = divisor;
            pos_1 = floor((_e143 / vec2(_e144)));
        }
        continuing {
            let _e86 = i;
            i = (_e86 + 1i);
        }
    }
    let _e148 = total;
    let _e149 = threshold;
    if (_e148 >= _e149) {
        local_1 = 1f;
    } else {
        local_1 = 0f;
    }
    let _e154 = local_1;
    inside = _e154;
    let _e155 = inside;
    return _e155;
}

fn locusGetHue(c: vec4<f32>) -> f32 {
    var c_1: vec4<f32>;
    var r: f32;
    var g: f32;
    var b_4: f32;
    var mini: f32;
    var maxi: f32;

    c_1 = c;
    let _e9 = c_1;
    r = _e9.x;
    let _e12 = c_1;
    g = _e12.y;
    let _e15 = c_1;
    b_4 = _e15.z;
    let _e18 = r;
    let _e19 = g;
    let _e20 = b_4;
    mini = min(_e18, min(_e19, _e20));
    let _e24 = r;
    let _e25 = g;
    let _e26 = b_4;
    maxi = max(_e24, max(_e25, _e26));
    let _e30 = maxi;
    let _e31 = mini;
    if (_e30 == _e31) {
        return 0f;
    } else {
        let _e34 = maxi;
        let _e35 = r;
        if (_e34 == _e35) {
            let _e38 = g;
            let _e39 = b_4;
            let _e42 = maxi;
            let _e43 = mini;
            let _e49 = locusFmod((((60f * (_e38 - _e39)) / (_e42 - _e43)) + 360f), 360f);
            return _e49;
        } else {
            let _e50 = maxi;
            let _e51 = g;
            if (_e50 == _e51) {
                let _e54 = b_4;
                let _e55 = r;
                let _e58 = maxi;
                let _e59 = mini;
                return (((60f * (_e54 - _e55)) / (_e58 - _e59)) + 120f);
            } else {
                let _e65 = r;
                let _e66 = g;
                let _e69 = maxi;
                let _e70 = mini;
                return (((60f * (_e65 - _e66)) / (_e69 - _e70)) + 240f);
            }
        }
    }
}

fn getLocus(pos_2: vec2<f32>, inCol: vec4<f32>, outCol: vec4<f32>, locusMode: i32, locusTransform: mat3x3<f32>) -> f32 {
    var pos_3: vec2<f32>;
    var inCol_1: vec4<f32>;
    var outCol_1: vec4<f32>;
    var locusMode_1: i32;
    var locusTransform_1: mat3x3<f32>;
    var m: mat3x3<f32>;
    var u: vec2<f32>;
    var local_2: f32;
    var hue: f32;
    var targetHue: f32;
    var d: f32;
    var maxD: f32;
    var v_1: vec2<f32>;
    var colDist: f32;
    var scale: f32;
    var local_3: f32;
    var maxDist: f32;
    var scale_1: f32;
    var angle: f32;
    var intensity: f32;
    var ca: f32;
    var sa: f32;
    var y: f32;
    var h: f32;
    var local_4: f32;

    pos_3 = pos_2;
    inCol_1 = inCol;
    outCol_1 = outCol;
    locusMode_1 = locusMode;
    locusTransform_1 = locusTransform;
    let _e17 = locusMode_1;
    if (_e17 == 0i) {
        return 1f;
    }
    let _e21 = locusTransform_1;
    m = _e21;
    let _e23 = locusMode_1;
    if (_e23 <= 3i) {
        let _e26 = locusTransform_1;
        m = _naga_inverse_3x3_f32(_e26);
    }
    let _e28 = m;
    let _e29 = pos_3;
    u = (_e28 * vec3<f32>(_e29.x, _e29.y, 1f)).xy;
    let _e37 = locusMode_1;
    if (_e37 == 1i) {
        {
            let _e40 = u;
            let _e43 = u;
            if (max(abs(_e40.x), abs(_e43.y)) > 1f) {
                local_2 = 0f;
            } else {
                local_2 = 1f;
            }
            let _e52 = local_2;
            return _e52;
        }
    } else {
        let _e53 = locusMode_1;
        if (_e53 == 2i) {
            {
                let _e58 = u;
                return smoothstep(0.5f, 1f, length(_e58));
            }
        } else {
            let _e61 = locusMode_1;
            if (_e61 == 3i) {
                {
                    let _e66 = u;
                    return smoothstep(1f, 0.5f, length(_e66));
                }
            } else {
                let _e69 = locusMode_1;
                if (_e69 == 4i) {
                    {
                        let _e72 = inCol_1;
                        let _e73 = locusGetHue(_e72);
                        hue = _e73;
                        let _e79 = locusTransform_1[2][0];
                        let _e83 = locusFmod((_e79 * 180f), 360f);
                        targetHue = _e83;
                        let _e85 = hue;
                        let _e86 = targetHue;
                        d = (_e85 - _e86);
                        let _e89 = d;
                        if (_e89 < 0f) {
                            let _e92 = d;
                            d = -(_e92);
                        }
                        let _e94 = d;
                        if (_e94 > 180f) {
                            let _e98 = d;
                            d = (360f - _e98);
                        }
                        let _e105 = locusTransform_1[0][0];
                        let _e110 = locusTransform_1[0][1];
                        maxD = (360f / length(vec2<f32>(_e105, _e110)));
                        let _e115 = d;
                        let _e116 = maxD;
                        d = (_e115 / _e116);
                        let _e120 = d;
                        return smoothstep(1f, 0.75f, _e120);
                    }
                } else {
                    let _e122 = locusMode_1;
                    if (_e122 == 5i) {
                        {
                            let _e125 = u;
                            v_1 = floor((_e125 * 40f));
                            let _e130 = v_1;
                            let _e131 = locusGetBlock(_e130);
                            return _e131;
                        }
                    } else {
                        let _e132 = locusMode_1;
                        if (_e132 == 6i) {
                            {
                                let _e135 = inCol_1;
                                let _e137 = outCol_1;
                                colDist = length((_e135.xyz - _e137.xyz));
                                let _e146 = locusTransform_1[0][0];
                                let _e151 = locusTransform_1[0][1];
                                scale = length(vec2<f32>(_e146, _e151));
                                let _e155 = scale;
                                if (_e155 < 1f) {
                                    let _e159 = scale;
                                    local_3 = (1.732f * _e159);
                                } else {
                                    let _e162 = scale;
                                    local_3 = (1.732f / _e162);
                                }
                                let _e165 = local_3;
                                maxDist = _e165;
                                let _e167 = scale;
                                if (_e167 < 1f) {
                                    let _e171 = colDist;
                                    colDist = (1.732f - _e171);
                                }
                                let _e173 = colDist;
                                let _e174 = maxDist;
                                colDist = (_e173 / _e174);
                                let _e178 = colDist;
                                return smoothstep(1f, 0.75f, _e178);
                            }
                        } else {
                            let _e180 = locusMode_1;
                            if (_e180 == 7i) {
                                {
                                    let _e187 = locusTransform_1[2][0];
                                    let _e193 = locusTransform_1[2][1];
                                    return clamp((-(_e187) + _e193), 0f, 1f);
                                }
                            } else {
                                let _e198 = locusMode_1;
                                if (_e198 == 8i) {
                                    {
                                        let _e205 = locusTransform_1[0][0];
                                        let _e210 = locusTransform_1[0][1];
                                        scale_1 = length(vec2<f32>(_e205, _e210));
                                        let _e218 = locusTransform_1[2][0];
                                        angle = ((floor(((_e218 * 3f) + 0.5f)) / 12f) * 3.1415927f);
                                        let _e233 = locusTransform_1[2][1];
                                        intensity = clamp(_e233, 0f, 1f);
                                        let _e238 = angle;
                                        ca = cos(_e238);
                                        let _e241 = angle;
                                        sa = sin(_e241);
                                        let _e244 = sa;
                                        let _e246 = pos_3;
                                        let _e249 = ca;
                                        let _e250 = pos_3;
                                        y = ((-(_e244) * _e246.x) + (_e249 * _e250.y));
                                        let _e255 = y;
                                        let _e256 = scale_1;
                                        h = cos((((_e255 * _e256) * 3.1415927f) * 100f));
                                        let _e264 = intensity;
                                        if (_e264 < 0.5f) {
                                            let _e267 = intensity;
                                            let _e268 = h;
                                            local_4 = (_e267 * (_e268 + 1f));
                                        } else {
                                            let _e274 = intensity;
                                            let _e276 = h;
                                            local_4 = (1f + ((1f - _e274) * (_e276 - 1f)));
                                        }
                                        let _e282 = local_4;
                                        return _e282;
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    return 1f;
}

fn locusBlend(pos_4: vec2<f32>, outPos: vec2<f32>, locusMode_2: i32, locusTransform_2: mat3x3<f32>) -> vec4<f32> {
    var pos_5: vec2<f32>;
    var outPos_1: vec2<f32>;
    var locusMode_3: i32;
    var locusTransform_3: mat3x3<f32>;
    var inc: vec4<f32>;
    var outc: vec4<f32>;

    pos_5 = pos_4;
    outPos_1 = outPos;
    locusMode_3 = locusMode_2;
    locusTransform_3 = locusTransform_2;
    let _e15 = pos_5;
    let _e19 = global.U[0];
    let _e22 = pos_5;
    let _e31 = textureSample(t_source, samp, ((vec2<f32>((_e15.x / _e19.x), _e22.y) / vec2(2f)) + vec2(0.5f)));
    inc = _e31;
    let _e33 = pos_5;
    let _e37 = global.U[0];
    let _e40 = pos_5;
    let _e49 = textureSample(t_effect, samp, ((vec2<f32>((_e33.x / _e37.x), _e40.y) / vec2(2f)) + vec2(0.5f)));
    outc = _e49;
    let _e51 = inc;
    let _e52 = outc;
    let _e53 = pos_5;
    let _e54 = inc;
    let _e55 = outc;
    let _e56 = locusMode_3;
    let _e57 = locusTransform_3;
    let _e58 = getLocus(_e53, _e54, _e55, _e56, _e57);
    return mix(_e51, _e52, vec4(_e58));
}

fn main_1() {
    let _e9 = global.U[1];
    let _e10 = _e9.xyz;
    let _e13 = global.U[2];
    let _e14 = _e13.xyz;
    let _e17 = global.U[3];
    let _e18 = _e17.xyz;
    let _e33 = v_uv_1;
    let _e41 = global.U[0];
    let _e45 = (((_e33 - vec2(0.5f)) * 2f) * vec2<f32>(_e41.x, 1f));
    let _e52 = v_uv_1;
    let _e60 = global.U[0];
    let _e67 = global.U[5];
    let _e72 = global.U[6];
    let _e73 = _e72.xyz;
    let _e76 = global.U[7];
    let _e77 = _e76.xyz;
    let _e80 = global.U[8];
    let _e81 = _e80.xyz;
    let _e95 = locusBlend((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e10.x, _e10.y, _e10.z), vec3<f32>(_e14.x, _e14.y, _e14.z), vec3<f32>(_e18.x, _e18.y, _e18.z))) * vec3<f32>(_e45.x, _e45.y, 1f)).xy, (((_e52 - vec2(0.5f)) * 2f) * vec2<f32>(_e60.x, 1f)), i32(_e67.x), mat3x3<f32>(vec3<f32>(_e73.x, _e73.y, _e73.z), vec3<f32>(_e77.x, _e77.y, _e77.z), vec3<f32>(_e81.x, _e81.y, _e81.z)));
    fragColor = _e95;
    return;
}

@fragment 
fn main(@location(0) v_uv: vec2<f32>) -> FragmentOutput {
    v_uv_1 = v_uv;
    main_1();
    let _e15 = fragColor;
    return FragmentOutput(_e15);
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
