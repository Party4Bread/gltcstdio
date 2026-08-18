struct Params {
    U: array<vec4<f32>, 11>,
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

fn tf(m: mat3x3<f32>, u: vec2<f32>) -> vec2<f32> {
    var m_1: mat3x3<f32>;
    var u_1: vec2<f32>;

    m_1 = m;
    u_1 = u;
    let _e10 = m_1;
    let _e11 = u_1;
    return (_e10 * vec3<f32>(_e11.x, _e11.y, 1f)).xy;
}

fn vig(w: f32, vignetting: f32) -> f32 {
    var w_1: f32;
    var vignetting_1: f32;

    w_1 = w;
    vignetting_1 = vignetting;
    let _e10 = w_1;
    let _e13 = vignetting_1;
    return mix(_e10, 1f, (1f - _e13));
}

fn hexDist(p: vec2<f32>) -> f32 {
    var p_1: vec2<f32>;

    p_1 = p;
    let _e8 = p_1;
    p_1 = abs(_e8);
    let _e10 = p_1;
    let _e12 = p_1;
    return max(_e10.x, dot(_e12, normalize(vec2<f32>(1f, 1.7320508f))));
}

fn ww(u_2: vec2<f32>, blend: f32) -> f32 {
    var u_3: vec2<f32>;
    var blend_1: f32;
    var d: f32;

    u_3 = u_2;
    blend_1 = blend;
    let _e11 = u_3;
    let _e12 = hexDist(_e11);
    d = ((0.5f - _e12) * 2f);
    let _e17 = blend_1;
    let _e19 = blend_1;
    let _e20 = d;
    return smoothstep(-(_e17), _e19, _e20);
}

fn smoothKaleidoscope(uv: vec2<f32>, outPos: vec2<f32>, blend_2: f32, offset: f32, vignetting_2: f32, modelTransform: mat3x3<f32>, viewTransform: mat3x3<f32>) -> vec4<f32> {
    var uv_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var blend_3: f32;
    var offset_1: f32;
    var vignetting_3: f32;
    var modelTransform_1: mat3x3<f32>;
    var viewTransform_1: mat3x3<f32>;
    var u_4: vec2<f32>;
    var hex: vec4<f32>;
    var inverseModelTransform: mat3x3<f32>;
    var dv: vec2<f32>;
    var total: vec4<f32> = vec4<f32>(0f, 0f, 0f, 0f);
    var totalWeight: f32 = 0f;
    var black: vec4<f32> = vec4<f32>(0f, 0f, 0f, 1f);
    var hc: vec2<f32>;
    var dv_1: vec2<f32>;
    var wCenter: f32;
    var delta: vec2<f32> = vec2<f32>(1f, 0f);
    var hexRight: vec2<f32>;
    var wRight: f32;
    var hexLeft: vec2<f32>;
    var wLeft: f32;
    var hexTopRight: vec2<f32>;
    var wTopRight: f32;
    var hexTopLeft: vec2<f32>;
    var wTopLeft: f32;
    var hexBottomRight: vec2<f32>;
    var wBottomRight: f32;
    var hexBottomLeft: vec2<f32>;
    var wBottomLeft: f32;

    uv_1 = uv;
    outPos_1 = outPos;
    blend_3 = blend_2;
    offset_1 = offset;
    vignetting_3 = vignetting_2;
    modelTransform_1 = modelTransform;
    viewTransform_1 = viewTransform;
    let _e20 = uv_1;
    u_4 = _e20;
    let _e22 = u_4;
    let _e23 = hexCoords(_e22);
    hex = _e23;
    let _e25 = modelTransform_1;
    inverseModelTransform = _naga_inverse_3x3_f32(_e25);
    let _e28 = blend_3;
    if (_e28 == 0f) {
        {
            let _e31 = offset_1;
            let _e32 = hex;
            dv = (_e31 * _e32.zw);
            let _e36 = inverseModelTransform;
            let _e37 = hex;
            let _e39 = dv;
            let _e41 = tf(_e36, (_e37.xy + _e39));
            let _e45 = global.U[0];
            let _e48 = inverseModelTransform;
            let _e49 = hex;
            let _e51 = dv;
            let _e53 = tf(_e48, (_e49.xy + _e51));
            let _e62 = _mirror_wrap(((vec2<f32>((_e41.x / _e45.x), _e53.y) / vec2(2f)) + vec2(0.5f)));
            let _e63 = textureSample(t_source, samp, _e62);
            return _e63;
        }
    } else {
        {
            let _e78 = hex;
            hc = _e78.xy;
            let _e81 = offset_1;
            let _e82 = hex;
            dv_1 = (_e81 * _e82.zw);
            let _e86 = hc;
            let _e87 = blend_3;
            let _e88 = ww(_e86, _e87);
            wCenter = _e88;
            let _e90 = total;
            let _e91 = wCenter;
            let _e92 = black;
            let _e93 = inverseModelTransform;
            let _e94 = hex;
            let _e96 = dv_1;
            let _e98 = tf(_e93, (_e94.xy + _e96));
            let _e102 = global.U[0];
            let _e105 = inverseModelTransform;
            let _e106 = hex;
            let _e108 = dv_1;
            let _e110 = tf(_e105, (_e106.xy + _e108));
            let _e119 = _mirror_wrap(((vec2<f32>((_e98.x / _e102.x), _e110.y) / vec2(2f)) + vec2(0.5f)));
            let _e120 = textureSample(t_source, samp, _e119);
            let _e121 = wCenter;
            let _e122 = vignetting_3;
            let _e123 = vig(_e121, _e122);
            total = (_e90 + (_e91 * mix(_e92, _e120, vec4(_e123))));
            let _e128 = totalWeight;
            let _e129 = wCenter;
            totalWeight = (_e128 + _e129);
            let _e135 = hc;
            let _e136 = delta;
            hexRight = (_e135 - _e136);
            let _e139 = offset_1;
            let _e140 = hex;
            let _e142 = delta;
            dv_1 = (_e139 * (_e140.zw + _e142));
            let _e145 = hexRight;
            let _e146 = blend_3;
            let _e147 = ww(_e145, _e146);
            wRight = _e147;
            let _e149 = totalWeight;
            let _e150 = wRight;
            totalWeight = (_e149 + _e150);
            let _e152 = total;
            let _e153 = wRight;
            let _e154 = black;
            let _e155 = inverseModelTransform;
            let _e156 = hexRight;
            let _e158 = dv_1;
            let _e160 = tf(_e155, (_e156.xy + _e158));
            let _e164 = global.U[0];
            let _e167 = inverseModelTransform;
            let _e168 = hexRight;
            let _e170 = dv_1;
            let _e172 = tf(_e167, (_e168.xy + _e170));
            let _e181 = _mirror_wrap(((vec2<f32>((_e160.x / _e164.x), _e172.y) / vec2(2f)) + vec2(0.5f)));
            let _e182 = textureSample(t_source, samp, _e181);
            let _e183 = wRight;
            let _e184 = vignetting_3;
            let _e185 = vig(_e183, _e184);
            total = (_e152 + (_e153 * mix(_e154, _e182, vec4(_e185))));
            delta = vec2<f32>(-1f, 0f);
            let _e194 = hc;
            let _e195 = delta;
            hexLeft = (_e194 - _e195);
            let _e198 = offset_1;
            let _e199 = hex;
            let _e201 = delta;
            dv_1 = (_e198 * (_e199.zw + _e201));
            let _e204 = hexLeft;
            let _e205 = blend_3;
            let _e206 = ww(_e204, _e205);
            wLeft = _e206;
            let _e208 = totalWeight;
            let _e209 = wLeft;
            totalWeight = (_e208 + _e209);
            let _e211 = total;
            let _e212 = wLeft;
            let _e213 = black;
            let _e214 = inverseModelTransform;
            let _e215 = hexLeft;
            let _e217 = dv_1;
            let _e219 = tf(_e214, (_e215.xy + _e217));
            let _e223 = global.U[0];
            let _e226 = inverseModelTransform;
            let _e227 = hexLeft;
            let _e229 = dv_1;
            let _e231 = tf(_e226, (_e227.xy + _e229));
            let _e240 = _mirror_wrap(((vec2<f32>((_e219.x / _e223.x), _e231.y) / vec2(2f)) + vec2(0.5f)));
            let _e241 = textureSample(t_source, samp, _e240);
            let _e242 = wLeft;
            let _e243 = vignetting_3;
            let _e244 = vig(_e242, _e243);
            total = (_e211 + (_e212 * mix(_e213, _e241, vec4(_e244))));
            delta = vec2<f32>(0.5f, 0.8660254f);
            let _e252 = hc;
            let _e253 = delta;
            hexTopRight = (_e252 - _e253);
            let _e256 = offset_1;
            let _e257 = hex;
            let _e259 = delta;
            dv_1 = (_e256 * (_e257.zw + _e259));
            let _e262 = hexTopRight;
            let _e263 = blend_3;
            let _e264 = ww(_e262, _e263);
            wTopRight = _e264;
            let _e266 = totalWeight;
            let _e267 = wTopRight;
            totalWeight = (_e266 + _e267);
            let _e269 = total;
            let _e270 = wTopRight;
            let _e271 = black;
            let _e272 = inverseModelTransform;
            let _e273 = hexTopRight;
            let _e275 = dv_1;
            let _e277 = tf(_e272, (_e273.xy + _e275));
            let _e281 = global.U[0];
            let _e284 = inverseModelTransform;
            let _e285 = hexTopRight;
            let _e287 = dv_1;
            let _e289 = tf(_e284, (_e285.xy + _e287));
            let _e298 = _mirror_wrap(((vec2<f32>((_e277.x / _e281.x), _e289.y) / vec2(2f)) + vec2(0.5f)));
            let _e299 = textureSample(t_source, samp, _e298);
            let _e300 = wTopRight;
            let _e301 = vignetting_3;
            let _e302 = vig(_e300, _e301);
            total = (_e269 + (_e270 * mix(_e271, _e299, vec4(_e302))));
            delta = vec2<f32>(-0.5f, 0.8660254f);
            let _e311 = hc;
            let _e312 = delta;
            hexTopLeft = (_e311 - _e312);
            let _e315 = offset_1;
            let _e316 = hex;
            let _e318 = delta;
            dv_1 = (_e315 * (_e316.zw + _e318));
            let _e321 = hexTopLeft;
            let _e322 = blend_3;
            let _e323 = ww(_e321, _e322);
            wTopLeft = _e323;
            let _e325 = totalWeight;
            let _e326 = wTopLeft;
            totalWeight = (_e325 + _e326);
            let _e328 = total;
            let _e329 = wTopLeft;
            let _e330 = black;
            let _e331 = inverseModelTransform;
            let _e332 = hexTopLeft;
            let _e334 = dv_1;
            let _e336 = tf(_e331, (_e332.xy + _e334));
            let _e340 = global.U[0];
            let _e343 = inverseModelTransform;
            let _e344 = hexTopLeft;
            let _e346 = dv_1;
            let _e348 = tf(_e343, (_e344.xy + _e346));
            let _e357 = _mirror_wrap(((vec2<f32>((_e336.x / _e340.x), _e348.y) / vec2(2f)) + vec2(0.5f)));
            let _e358 = textureSample(t_source, samp, _e357);
            let _e359 = wTopLeft;
            let _e360 = vignetting_3;
            let _e361 = vig(_e359, _e360);
            total = (_e328 + (_e329 * mix(_e330, _e358, vec4(_e361))));
            delta = vec2<f32>(0.5f, -0.8660254f);
            let _e370 = hc;
            let _e371 = delta;
            hexBottomRight = (_e370 - _e371);
            let _e374 = offset_1;
            let _e375 = hex;
            let _e377 = delta;
            dv_1 = (_e374 * (_e375.zw + _e377));
            let _e380 = hexBottomRight;
            let _e381 = blend_3;
            let _e382 = ww(_e380, _e381);
            wBottomRight = _e382;
            let _e384 = totalWeight;
            let _e385 = wBottomRight;
            totalWeight = (_e384 + _e385);
            let _e387 = total;
            let _e388 = wBottomRight;
            let _e389 = black;
            let _e390 = inverseModelTransform;
            let _e391 = hexBottomRight;
            let _e393 = dv_1;
            let _e395 = tf(_e390, (_e391.xy + _e393));
            let _e399 = global.U[0];
            let _e402 = inverseModelTransform;
            let _e403 = hexBottomRight;
            let _e405 = dv_1;
            let _e407 = tf(_e402, (_e403.xy + _e405));
            let _e416 = _mirror_wrap(((vec2<f32>((_e395.x / _e399.x), _e407.y) / vec2(2f)) + vec2(0.5f)));
            let _e417 = textureSample(t_source, samp, _e416);
            let _e418 = wBottomRight;
            let _e419 = vignetting_3;
            let _e420 = vig(_e418, _e419);
            total = (_e387 + (_e388 * mix(_e389, _e417, vec4(_e420))));
            delta = vec2<f32>(-0.5f, -0.8660254f);
            let _e430 = hc;
            let _e431 = delta;
            hexBottomLeft = (_e430 - _e431);
            let _e434 = offset_1;
            let _e435 = hex;
            let _e437 = delta;
            dv_1 = (_e434 * (_e435.zw + _e437));
            let _e440 = hexBottomLeft;
            let _e441 = blend_3;
            let _e442 = ww(_e440, _e441);
            wBottomLeft = _e442;
            let _e444 = totalWeight;
            let _e445 = wBottomLeft;
            totalWeight = (_e444 + _e445);
            let _e447 = total;
            let _e448 = wBottomLeft;
            let _e449 = black;
            let _e450 = inverseModelTransform;
            let _e451 = hexBottomLeft;
            let _e453 = dv_1;
            let _e455 = tf(_e450, (_e451.xy + _e453));
            let _e459 = global.U[0];
            let _e462 = inverseModelTransform;
            let _e463 = hexBottomLeft;
            let _e465 = dv_1;
            let _e467 = tf(_e462, (_e463.xy + _e465));
            let _e476 = _mirror_wrap(((vec2<f32>((_e455.x / _e459.x), _e467.y) / vec2(2f)) + vec2(0.5f)));
            let _e477 = textureSample(t_source, samp, _e476);
            let _e478 = wBottomLeft;
            let _e479 = vignetting_3;
            let _e480 = vig(_e478, _e479);
            total = (_e447 + (_e448 * mix(_e449, _e477, vec4(_e480))));
            let _e485 = total;
            let _e486 = totalWeight;
            return (_e485 / vec4(_e486));
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
    let _e79 = _e78.xyz;
    let _e82 = global.U[9];
    let _e83 = _e82.xyz;
    let _e86 = global.U[10];
    let _e87 = _e86.xyz;
    let _e103 = global.U[1];
    let _e104 = _e103.xyz;
    let _e107 = global.U[2];
    let _e108 = _e107.xyz;
    let _e111 = global.U[3];
    let _e112 = _e111.xyz;
    let _e126 = smoothKaleidoscope((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e9.x, _e9.y, _e9.z), vec3<f32>(_e13.x, _e13.y, _e13.z), vec3<f32>(_e17.x, _e17.y, _e17.z))) * vec3<f32>(_e44.x, _e44.y, 1f)).xy, (((_e51 - vec2(0.5f)) * 2f) * vec2<f32>(_e59.x, 1f)), _e66.x, _e70.x, _e74.x, mat3x3<f32>(vec3<f32>(_e79.x, _e79.y, _e79.z), vec3<f32>(_e83.x, _e83.y, _e83.z), vec3<f32>(_e87.x, _e87.y, _e87.z)), mat3x3<f32>(vec3<f32>(_e104.x, _e104.y, _e104.z), vec3<f32>(_e108.x, _e108.y, _e108.z), vec3<f32>(_e112.x, _e112.y, _e112.z)));
    fragColor = _e126;
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
