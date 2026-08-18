struct Params {
    U: array<vec4<f32>, 10>,
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

fn mixColors(a: vec4<f32>, b: vec4<f32>, k: f32) -> vec4<f32> {
    var a_1: vec4<f32>;
    var b_1: vec4<f32>;
    var k_1: f32;
    var ka: f32;
    var local: vec4<f32>;

    a_1 = a;
    b_1 = b;
    k_1 = k;
    let _e12 = a_1;
    let _e14 = b_1;
    let _e16 = k_1;
    ka = mix(_e12.w, _e14.w, _e16);
    let _e19 = ka;
    if (_e19 == 0f) {
        let _e22 = a_1;
        let _e23 = b_1;
        let _e24 = k_1;
        local = mix(_e22, _e23, vec4(_e24));
    } else {
        let _e27 = a_1;
        let _e29 = a_1;
        let _e32 = b_1;
        let _e34 = b_1;
        let _e37 = k_1;
        let _e40 = ka;
        let _e42 = (mix((_e27.xyz * _e29.w), (_e32.xyz * _e34.w), vec3(_e37)) / vec3(_e40));
        let _e43 = a_1;
        let _e45 = b_1;
        let _e47 = k_1;
        local = vec4<f32>(_e42.x, _e42.y, _e42.z, mix(_e43.w, _e45.w, _e47));
    }
    let _e54 = local;
    return _e54;
}

fn sampleCol(color: vec4<f32>, count: f32) -> f32 {
    var color_1: vec4<f32>;
    var count_1: f32;

    color_1 = color;
    count_1 = count;
    let _e10 = color_1;
    let _e12 = color_1;
    let _e15 = color_1;
    let _e18 = count_1;
    return floor((((((_e10.x + _e12.y) + _e15.z) * (_e18 - 1f)) / 3f) + 0.5f));
}

fn contour(uv: vec2<f32>, outPos: vec2<f32>, sourceDim: vec2<f32>, count_2: i32, colorBkg: vec4<f32>, colorStroke: vec4<f32>, thickness: f32) -> vec4<f32> {
    var uv_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var sourceDim_1: vec2<f32>;
    var count_3: i32;
    var colorBkg_1: vec4<f32>;
    var colorStroke_1: vec4<f32>;
    var thickness_1: f32;
    var pixel: f32;
    var p: vec2<f32>;
    var sum: f32 = 0f;
    var max: f32 = 0f;
    var fRadius: f32;
    var r2_: f32;
    var radius: i32;
    var fcount: f32;
    var maxCoverage: f32 = 0f;
    var j: i32;
    var i: i32;
    var delta: vec2<f32>;
    var minDelta: vec2<f32>;
    var coverage: f32;
    var pos: vec2<f32>;
    var s0_: f32;
    var s1_: f32;
    var s2_: f32;
    var s3_: f32;
    var s: f32;
    var onContour: bool;
    var color_2: vec4<f32>;
    var bkgColor: vec4<f32>;

    uv_1 = uv;
    outPos_1 = outPos;
    sourceDim_1 = sourceDim;
    count_3 = count_2;
    colorBkg_1 = colorBkg;
    colorStroke_1 = colorStroke;
    thickness_1 = thickness;
    let _e21 = sourceDim_1;
    pixel = (2f / _e21.y);
    let _e25 = pixel;
    p = vec2<f32>(_e25, 0f);
    let _e33 = thickness_1;
    let _e36 = pixel;
    fRadius = ((_e33 * 0.01f) / _e36);
    let _e39 = fRadius;
    let _e40 = fRadius;
    r2_ = (_e39 * _e40);
    let _e44 = fRadius;
    radius = i32(floor((0.5f + _e44)));
    let _e49 = count_3;
    fcount = f32(_e49);
    let _e54 = radius;
    j = -(_e54);
    loop {
        let _e57 = j;
        let _e58 = radius;
        if !((_e57 <= _e58)) {
            break;
        }
        {
            let _e64 = radius;
            i = -(_e64);
            loop {
                let _e67 = i;
                let _e68 = radius;
                if !((_e67 <= _e68)) {
                    break;
                }
                {
                    let _e74 = i;
                    let _e76 = j;
                    delta = vec2<f32>(f32(_e74), f32(_e76));
                    let _e80 = delta;
                    minDelta = (abs(_e80) - vec2(0.25f));
                    let _e86 = i;
                    let _e89 = j;
                    let _e93 = minDelta;
                    let _e94 = minDelta;
                    let _e96 = r2_;
                    if (((_e86 == 0i) && (_e89 == 0i)) || (dot(_e93, _e94) < _e96)) {
                        {
                            let _e99 = fRadius;
                            let _e102 = fRadius;
                            let _e106 = fRadius;
                            let _e109 = fRadius;
                            let _e113 = delta;
                            let _e114 = delta;
                            coverage = smoothstep(((_e99 + 0.75f) * (_e102 + 0.75f)), ((_e106 - 0.75f) * (_e109 - 0.75f)), dot(_e113, _e114));
                            let _e118 = uv_1;
                            let _e119 = delta;
                            let _e120 = pixel;
                            let _e121 = pixel;
                            pos = (_e118 + (_e119 * vec2<f32>(_e120, _e121)));
                            let _e126 = pos;
                            let _e127 = p;
                            let _e133 = global.U[0];
                            let _e136 = pos;
                            let _e137 = p;
                            let _e148 = textureSample(t_source, samp, ((vec2<f32>(((_e126 + _e127.xy).x / _e133.x), (_e136 + _e137.xy).y) / vec2(2f)) + vec2(0.5f)));
                            let _e149 = fcount;
                            let _e150 = sampleCol(_e148, _e149);
                            s0_ = _e150;
                            let _e152 = pos;
                            let _e153 = p;
                            let _e159 = global.U[0];
                            let _e162 = pos;
                            let _e163 = p;
                            let _e174 = textureSample(t_source, samp, ((vec2<f32>(((_e152 - _e153.xy).x / _e159.x), (_e162 - _e163.xy).y) / vec2(2f)) + vec2(0.5f)));
                            let _e175 = fcount;
                            let _e176 = sampleCol(_e174, _e175);
                            s1_ = _e176;
                            let _e178 = pos;
                            let _e179 = p;
                            let _e185 = global.U[0];
                            let _e188 = pos;
                            let _e189 = p;
                            let _e200 = textureSample(t_source, samp, ((vec2<f32>(((_e178 + _e179.yx).x / _e185.x), (_e188 + _e189.yx).y) / vec2(2f)) + vec2(0.5f)));
                            let _e201 = fcount;
                            let _e202 = sampleCol(_e200, _e201);
                            s2_ = _e202;
                            let _e204 = pos;
                            let _e205 = p;
                            let _e211 = global.U[0];
                            let _e214 = pos;
                            let _e215 = p;
                            let _e226 = textureSample(t_source, samp, ((vec2<f32>(((_e204 - _e205.yx).x / _e211.x), (_e214 - _e215.yx).y) / vec2(2f)) + vec2(0.5f)));
                            let _e227 = fcount;
                            let _e228 = sampleCol(_e226, _e227);
                            s3_ = _e228;
                            let _e230 = pos;
                            let _e234 = global.U[0];
                            let _e237 = pos;
                            let _e246 = textureSample(t_source, samp, ((vec2<f32>((_e230.x / _e234.x), _e237.y) / vec2(2f)) + vec2(0.5f)));
                            let _e247 = fcount;
                            let _e248 = sampleCol(_e246, _e247);
                            s = _e248;
                            let _e250 = s;
                            let _e251 = s0_;
                            let _e253 = s;
                            let _e254 = s1_;
                            let _e257 = s;
                            let _e258 = s2_;
                            let _e261 = s;
                            let _e262 = s3_;
                            onContour = ((((_e250 != _e251) || (_e253 != _e254)) || (_e257 != _e258)) || (_e261 != _e262));
                            let _e266 = onContour;
                            let _e267 = maxCoverage;
                            let _e268 = coverage;
                            if (_e266 && (_e267 < _e268)) {
                                let _e271 = coverage;
                                maxCoverage = _e271;
                            }
                        }
                    }
                }
                continuing {
                    let _e71 = i;
                    i = (_e71 + 1i);
                }
            }
        }
        continuing {
            let _e61 = j;
            j = (_e61 + 1i);
        }
    }
    let _e272 = colorBkg_1;
    let _e273 = colorStroke_1;
    let _e274 = maxCoverage;
    let _e275 = mixColors(_e272, _e273, _e274);
    color_2 = _e275;
    let _e277 = uv_1;
    let _e281 = global.U[0];
    let _e284 = uv_1;
    let _e293 = textureSample(t_source, samp, ((vec2<f32>((_e277.x / _e281.x), _e284.y) / vec2(2f)) + vec2(0.5f)));
    bkgColor = _e293;
    let _e295 = bkgColor;
    let _e296 = color_2;
    let _e297 = mergeColor(_e295, _e296);
    return _e297;
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
    let _e75 = global.U[7];
    let _e78 = global.U[8];
    let _e81 = global.U[9];
    let _e83 = contour((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e9.x, _e9.y, _e9.z), vec3<f32>(_e13.x, _e13.y, _e13.z), vec3<f32>(_e17.x, _e17.y, _e17.z))) * vec3<f32>(_e44.x, _e44.y, 1f)).xy, (((_e51 - vec2(0.5f)) * 2f) * vec2<f32>(_e59.x, 1f)), _e66.xy, i32(_e70.x), _e75, _e78, _e81.x);
    fragColor = _e83;
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
