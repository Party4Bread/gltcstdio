struct Params {
    U: array<vec4<f32>, 13>,
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
var t_gradientMap: texture_2d<f32>;
@group(0) @binding(3) 
var t_source: texture_2d<f32>;

fn _mirror_wrap(c: vec2<f32>) -> vec2<f32> {
    var c_1: vec2<f32>;

    c_1 = c;
    let _e10 = c_1;
    let _e12 = vec2(2f);
    return (vec2(1f) - abs(((_e10 - (floor((_e10 / _e12)) * _e12)) - vec2(1f))));
}

fn luma(c_2: vec3<f32>) -> f32 {
    var c_3: vec3<f32>;

    c_3 = c_2;
    let _e10 = c_3;
    let _e14 = c_3;
    let _e19 = c_3;
    return (((0.2989f * _e10.x) + (0.587f * _e14.y)) + (0.114f * _e19.z));
}

fn mergeColor(bkg: vec4<f32>, front: vec4<f32>) -> vec4<f32> {
    var bkg_1: vec4<f32>;
    var front_1: vec4<f32>;

    bkg_1 = bkg;
    front_1 = front;
    let _e11 = bkg_1;
    let _e13 = front_1;
    let _e15 = front_1;
    let _e18 = bkg_1;
    let _e22 = front_1;
    let _e28 = mix(_e11.xyz, _e13.xyz, vec3((_e15.w + ((1f - _e18.w) * (1f - _e22.w)))));
    let _e29 = bkg_1;
    let _e31 = front_1;
    return vec4<f32>(_e28.x, _e28.y, _e28.z, max(_e29.w, _e31.w));
}

fn response(u: vec2<f32>) -> vec2<f32> {
    var u_1: vec2<f32>;
    var len: f32;
    var n: vec2<f32>;

    u_1 = u;
    let _e9 = u_1;
    let _e13 = u_1;
    if ((_e9.x == 0f) && (_e13.y == 0f)) {
        let _e18 = u_1;
        return _e18;
    }
    let _e19 = u_1;
    len = length(_e19);
    len = 1f;
    let _e23 = u_1;
    n = normalize(_e23);
    let _e26 = len;
    let _e27 = n;
    return (_e26 * _e27);
}

fn rotation2_(angle: f32) -> mat2x2<f32> {
    var angle_1: f32;
    var ca: f32;
    var sa: f32;

    angle_1 = angle;
    let _e9 = angle_1;
    ca = cos(_e9);
    let _e12 = angle_1;
    sa = sin(_e12);
    let _e15 = ca;
    let _e16 = sa;
    let _e17 = sa;
    let _e19 = ca;
    return mat2x2<f32>(vec2<f32>(_e15, _e16), vec2<f32>(-(_e17), _e19));
}

fn gradientStrokes(pos: vec2<f32>, outPos: vec2<f32>, angle_2: f32, thickness: f32, color1_: vec4<f32>, color2_: vec4<f32>, gradientMap_specified: i32, modelTransform: mat3x3<f32>) -> vec4<f32> {
    var pos_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var angle_3: f32;
    var thickness_1: f32;
    var color1_1: vec4<f32>;
    var color2_1: vec4<f32>;
    var gradientMap_specified_1: i32;
    var modelTransform_1: mat3x3<f32>;
    var strokeIntensity: f32 = 0f;
    var inverseModelTransform: mat3x3<f32>;
    var resolution: f32;
    var sp: vec2<f32>;
    var delta: f32 = 0.02f;
    var curColor: vec4<f32> = vec4<f32>(0f, 0f, 0f, 1f);
    var n_1: f32 = 0f;
    var ang: f32;
    var rot: mat2x2<f32>;
    var N: f32 = 1f;
    var pp: vec2<f32>;
    var d: vec2<f32>;
    var local: vec4<f32>;
    var sample00_: f32;
    var local_1: vec4<f32>;
    var sample01_: f32;
    var local_2: vec4<f32>;
    var sample10_: f32;
    var local_3: vec4<f32>;
    var sample11_: f32;
    var grad: vec2<f32>;
    var g: vec2<f32>;
    var dp: f32;
    var k: f32;
    var outCol: vec4<f32>;

    pos_1 = pos;
    outPos_1 = outPos;
    angle_3 = angle_2;
    thickness_1 = thickness;
    color1_1 = color1_;
    color2_1 = color2_;
    gradientMap_specified_1 = gradientMap_specified;
    modelTransform_1 = modelTransform;
    let _e25 = modelTransform_1;
    inverseModelTransform = _naga_inverse_3x3_f32(_e25);
    let _e30 = inverseModelTransform[0];
    resolution = length(_e30.xy);
    let _e34 = pos_1;
    let _e35 = resolution;
    let _e41 = resolution;
    let _e46 = inverseModelTransform[2];
    let _e49 = resolution;
    sp = ((floor(((_e34 * _e35) + vec2(0.5f))) / vec2(_e41)) - (fract(_e46.xy) / vec2(_e49)));
    let _e64 = angle_3;
    ang = _e64;
    let _e66 = ang;
    let _e67 = rotation2_(_e66);
    rot = _e67;
    let _e71 = sp;
    pp = _e71;
    let _e73 = delta;
    d = vec2<f32>(_e73, 0f);
    let _e77 = gradientMap_specified_1;
    if (_e77 == 0i) {
        let _e80 = pp;
        let _e81 = d;
        let _e87 = global.U[0];
        let _e90 = pp;
        let _e91 = d;
        let _e102 = _mirror_wrap(((vec2<f32>(((_e80 + _e81.xy).x / _e87.x), (_e90 + _e91.xy).y) / vec2(2f)) + vec2(0.5f)));
        let _e103 = textureSample(t_source, samp, _e102);
        local = _e103;
    } else {
        let _e104 = pp;
        let _e105 = d;
        let _e111 = global.U[0];
        let _e114 = pp;
        let _e115 = d;
        let _e126 = _mirror_wrap(((vec2<f32>(((_e104 + _e105.xy).x / _e111.x), (_e114 + _e115.xy).y) / vec2(2f)) + vec2(0.5f)));
        let _e127 = textureSample(t_gradientMap, samp, _e126);
        local = _e127;
    }
    let _e129 = local;
    let _e131 = luma(_e129.xyz);
    sample00_ = _e131;
    let _e133 = gradientMap_specified_1;
    if (_e133 == 0i) {
        let _e136 = pp;
        let _e137 = d;
        let _e143 = global.U[0];
        let _e146 = pp;
        let _e147 = d;
        let _e158 = _mirror_wrap(((vec2<f32>(((_e136 - _e137.xy).x / _e143.x), (_e146 - _e147.xy).y) / vec2(2f)) + vec2(0.5f)));
        let _e159 = textureSample(t_source, samp, _e158);
        local_1 = _e159;
    } else {
        let _e160 = pp;
        let _e161 = d;
        let _e167 = global.U[0];
        let _e170 = pp;
        let _e171 = d;
        let _e182 = _mirror_wrap(((vec2<f32>(((_e160 - _e161.xy).x / _e167.x), (_e170 - _e171.xy).y) / vec2(2f)) + vec2(0.5f)));
        let _e183 = textureSample(t_gradientMap, samp, _e182);
        local_1 = _e183;
    }
    let _e185 = local_1;
    let _e187 = luma(_e185.xyz);
    sample01_ = _e187;
    let _e189 = gradientMap_specified_1;
    if (_e189 == 0i) {
        let _e192 = pp;
        let _e193 = d;
        let _e199 = global.U[0];
        let _e202 = pp;
        let _e203 = d;
        let _e214 = _mirror_wrap(((vec2<f32>(((_e192 + _e193.yx).x / _e199.x), (_e202 + _e203.yx).y) / vec2(2f)) + vec2(0.5f)));
        let _e215 = textureSample(t_source, samp, _e214);
        local_2 = _e215;
    } else {
        let _e216 = pp;
        let _e217 = d;
        let _e223 = global.U[0];
        let _e226 = pp;
        let _e227 = d;
        let _e238 = _mirror_wrap(((vec2<f32>(((_e216 + _e217.yx).x / _e223.x), (_e226 + _e227.yx).y) / vec2(2f)) + vec2(0.5f)));
        let _e239 = textureSample(t_gradientMap, samp, _e238);
        local_2 = _e239;
    }
    let _e241 = local_2;
    let _e243 = luma(_e241.xyz);
    sample10_ = _e243;
    let _e245 = gradientMap_specified_1;
    if (_e245 == 0i) {
        let _e248 = pp;
        let _e249 = d;
        let _e255 = global.U[0];
        let _e258 = pp;
        let _e259 = d;
        let _e270 = _mirror_wrap(((vec2<f32>(((_e248 - _e249.yx).x / _e255.x), (_e258 - _e259.yx).y) / vec2(2f)) + vec2(0.5f)));
        let _e271 = textureSample(t_source, samp, _e270);
        local_3 = _e271;
    } else {
        let _e272 = pp;
        let _e273 = d;
        let _e279 = global.U[0];
        let _e282 = pp;
        let _e283 = d;
        let _e294 = _mirror_wrap(((vec2<f32>(((_e272 - _e273.yx).x / _e279.x), (_e282 - _e283.yx).y) / vec2(2f)) + vec2(0.5f)));
        let _e295 = textureSample(t_gradientMap, samp, _e294);
        local_3 = _e295;
    }
    let _e297 = local_3;
    let _e299 = luma(_e297.xyz);
    sample11_ = _e299;
    let _e301 = sample00_;
    let _e302 = sample01_;
    let _e304 = delta;
    let _e308 = sample10_;
    let _e309 = sample11_;
    let _e311 = delta;
    let _e316 = delta;
    grad = ((vec2<f32>(((_e301 - _e302) / (_e304 * 2f)), ((_e308 - _e309) / (_e311 * 2f))) * _e316) / vec2(2f));
    let _e322 = rot;
    let _e323 = grad;
    let _e324 = response(_e323);
    let _e325 = resolution;
    let _e331 = N;
    g = (_e322 * (((_e324 / vec2(_e325)) / vec2(2f)) * _e331));
    let _e335 = pos_1;
    let _e336 = sp;
    let _e338 = g;
    dp = dot((_e335 - _e336), normalize(_e338));
    let _e342 = thickness_1;
    let _e344 = resolution;
    let _e346 = thickness_1;
    let _e347 = resolution;
    let _e349 = dp;
    k = smoothstep((-(_e342) / _e344), (_e346 / _e347), _e349);
    let _e352 = color1_1;
    let _e353 = color2_1;
    let _e354 = k;
    outCol = mix(_e352, _e353, vec4(_e354));
    let _e358 = pos_1;
    let _e362 = global.U[0];
    let _e365 = pos_1;
    let _e374 = _mirror_wrap(((vec2<f32>((_e358.x / _e362.x), _e365.y) / vec2(2f)) + vec2(0.5f)));
    let _e375 = textureSample(t_source, samp, _e374);
    let _e376 = outCol;
    let _e377 = mergeColor(_e375, _e376);
    return _e377;
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
    let _e67 = global.U[6];
    let _e71 = global.U[7];
    let _e75 = global.U[8];
    let _e78 = global.U[9];
    let _e81 = global.U[4];
    let _e86 = global.U[10];
    let _e87 = _e86.xyz;
    let _e90 = global.U[11];
    let _e91 = _e90.xyz;
    let _e94 = global.U[12];
    let _e95 = _e94.xyz;
    let _e109 = gradientStrokes((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e10.x, _e10.y, _e10.z), vec3<f32>(_e14.x, _e14.y, _e14.z), vec3<f32>(_e18.x, _e18.y, _e18.z))) * vec3<f32>(_e45.x, _e45.y, 1f)).xy, (((_e52 - vec2(0.5f)) * 2f) * vec2<f32>(_e60.x, 1f)), _e67.x, _e71.x, _e75, _e78, i32(_e81.x), mat3x3<f32>(vec3<f32>(_e87.x, _e87.y, _e87.z), vec3<f32>(_e91.x, _e91.y, _e91.z), vec3<f32>(_e95.x, _e95.y, _e95.z)));
    fragColor = _e109;
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
