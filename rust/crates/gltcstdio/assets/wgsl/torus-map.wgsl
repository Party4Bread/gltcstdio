struct Params {
    U: array<vec4<f32>, 16>,
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

fn getFog(dist: f32, alpha: f32) -> f32 {
    var dist_1: f32;
    var alpha_1: f32;

    dist_1 = dist;
    alpha_1 = alpha;
    let _e10 = dist_1;
    let _e17 = alpha_1;
    return (max(((_e10 - 0.5f) * 4f), 0f) * _e17);
}

fn implicitFn(p: vec3<f32>, radius: f32) -> f32 {
    var p_1: vec3<f32>;
    var radius_1: f32;
    var R: f32 = 0.5f;
    var r: f32;
    var a: f32;

    p_1 = p;
    radius_1 = radius;
    let _e12 = R;
    let _e13 = radius_1;
    r = ((_e12 * _e13) * 2f);
    let _e18 = p_1;
    let _e20 = p_1;
    let _e23 = p_1;
    let _e25 = p_1;
    let _e30 = R;
    a = (sqrt(((_e18.x * _e20.x) + (_e23.y * _e25.y))) - _e30);
    let _e33 = a;
    let _e34 = a;
    let _e36 = p_1;
    let _e38 = p_1;
    let _e43 = r;
    return (sqrt(((_e33 * _e34) + (_e36.z * _e38.z))) - _e43);
}

fn sphereIntersectionSpec(center: vec3<f32>, radius_2: f32, origin: vec3<f32>, dir: vec3<f32>) -> vec2<f32> {
    var center_1: vec3<f32>;
    var radius_3: f32;
    var origin_1: vec3<f32>;
    var dir_1: vec3<f32>;
    var relOrigin: vec3<f32>;
    var a_1: f32;
    var b: f32;
    var c: f32;
    var delta: f32;
    var sqrtDelta: f32;
    var l1_: f32;
    var l2_: f32;
    var local: f32;
    var local_1: f32;
    var l: f32;

    center_1 = center;
    radius_3 = radius_2;
    origin_1 = origin;
    dir_1 = dir;
    let _e14 = origin_1;
    let _e15 = center_1;
    relOrigin = (_e14 - _e15);
    let _e18 = dir_1;
    let _e19 = dir_1;
    a_1 = dot(_e18, _e19);
    let _e23 = dir_1;
    let _e24 = relOrigin;
    b = (2f * dot(_e23, _e24));
    let _e28 = relOrigin;
    let _e29 = relOrigin;
    let _e31 = radius_3;
    let _e32 = radius_3;
    c = (dot(_e28, _e29) - (_e31 * _e32));
    let _e36 = b;
    let _e37 = b;
    let _e40 = a_1;
    let _e42 = c;
    delta = ((_e36 * _e37) - ((4f * _e40) * _e42));
    let _e46 = delta;
    if (_e46 >= 0f) {
        {
            let _e49 = delta;
            sqrtDelta = sqrt(_e49);
            let _e52 = b;
            let _e54 = sqrtDelta;
            let _e57 = a_1;
            l1_ = ((-(_e52) - _e54) / (2f * _e57));
            let _e61 = b;
            let _e63 = sqrtDelta;
            let _e66 = a_1;
            l2_ = ((-(_e61) + _e63) / (2f * _e66));
            let _e70 = l1_;
            if (_e70 > 0f) {
                let _e73 = l1_;
                local_1 = _e73;
            } else {
                let _e74 = l2_;
                if (_e74 > 0f) {
                    let _e77 = l2_;
                    local = _e77;
                } else {
                    local = -1f;
                }
                let _e81 = local;
                local_1 = _e81;
            }
            let _e83 = local_1;
            l = _e83;
            let _e85 = l;
            if (_e85 > 0f) {
                {
                    let _e89 = l1_;
                    let _e91 = l2_;
                    return vec2<f32>(max(0f, _e89), _e91);
                }
            }
        }
    }
    return vec2<f32>(-1f, -1f);
}

fn getIntersectionD(origin_2: vec3<f32>, dir_2: vec3<f32>, radius_4: f32) -> vec3<f32> {
    var origin_3: vec3<f32>;
    var dir_3: vec3<f32>;
    var radius_5: f32;
    var minDist: f32 = 1000000000f;
    var k: f32 = 0f;
    var kBounds: vec2<f32>;
    var kk: f32;
    var de: f32 = 0.0001f;
    var maxIter: i32 = 1256i;
    var iter: i32 = 0i;
    var p_2: vec3<f32>;
    var dist_2: f32;
    var local_2: vec3<f32>;

    origin_3 = origin_2;
    dir_3 = dir_2;
    radius_5 = radius_4;
    let _e22 = radius_5;
    let _e27 = origin_3;
    let _e28 = dir_3;
    let _e29 = sphereIntersectionSpec(vec3<f32>(0f, 0f, 0f), (0.5f * (1f + (_e22 * 2f))), _e27, _e28);
    kBounds = _e29;
    let _e31 = kBounds;
    kk = _e31.x;
    let _e34 = kk;
    if (_e34 < 0f) {
        let _e37 = kk;
        let _e39 = minDist;
        return vec3<f32>(_e37, 0f, _e39);
    }
    let _e47 = origin_3;
    p_2 = _e47;
    let _e49 = p_2;
    let _e50 = radius_5;
    let _e51 = implicitFn(_e49, _e50);
    dist_2 = _e51;
    loop {
        let _e53 = dist_2;
        let _e55 = de;
        let _e57 = iter;
        let _e58 = maxIter;
        if !(((abs(_e53) > _e55) && (_e57 < _e58))) {
            break;
        }
        {
            let _e62 = k;
            let _e63 = dist_2;
            k = (_e62 + (abs(_e63) * 0.5f));
            let _e68 = origin_3;
            let _e69 = k;
            let _e70 = dir_3;
            p_2 = (_e68 + (_e69 * _e70));
            let _e73 = p_2;
            let _e74 = radius_5;
            let _e75 = implicitFn(_e73, _e74);
            dist_2 = _e75;
            let _e76 = minDist;
            let _e77 = dist_2;
            minDist = min(_e76, abs(_e77));
            let _e80 = iter;
            iter = (_e80 + 1i);
        }
    }
    let _e83 = dist_2;
    let _e84 = de;
    if (_e83 < _e84) {
        let _e86 = k;
        let _e87 = iter;
        let _e88 = minDist;
        local_2 = vec3<f32>(_e86, f32(_e87), _e88);
    } else {
        let _e93 = iter;
        let _e94 = minDist;
        local_2 = vec3<f32>(-1f, f32(_e93), _e94);
    }
    let _e98 = local_2;
    return _e98;
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

fn torusMap(pos: vec2<f32>, outPos: vec2<f32>, radius_6: f32, blend: f32, colorFog: vec4<f32>, sourceDim: vec2<f32>, model3DTransform: mat4x4<f32>, texTransform: mat3x3<f32>) -> vec4<f32> {
    var pos_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var radius_7: f32;
    var blend_1: f32;
    var colorFog_1: vec4<f32>;
    var sourceDim_1: vec2<f32>;
    var model3DTransform_1: mat4x4<f32>;
    var texTransform_1: mat3x3<f32>;
    var backgroundColor: vec4<f32> = vec4<f32>(0f, 0f, 0f, 1f);
    var invTt: mat3x3<f32>;
    var D: f32 = 1.6666666f;
    var cameraPos: vec3<f32> = vec3<f32>(0f, 0f, 0f);
    var m_2: mat4x4<f32>;
    var dir_4: vec3<f32>;
    var origin_4: vec3<f32>;
    var inters: vec3<f32>;
    var k_1: f32;
    var ratio: f32;
    var width: f32;
    var height: f32;
    var bWidth: f32;
    var bHeight: f32;
    var intersection: vec3<f32>;
    var R_1: f32 = 0.5f;
    var r_1: f32;
    var x: f32;
    var a_2: f32;
    var y: f32;
    var col: vec4<f32>;
    var u00_: vec2<f32>;
    var u10_: vec2<f32>;
    var u01_: vec2<f32>;
    var u11_: vec2<f32>;
    var dist_3: f32;
    var fog: f32;
    var col_1: vec4<f32> = vec4<f32>(0f, 0f, 0f, 1f);
    var dist_4: f32 = 2f;
    var fog_1: f32;

    pos_1 = pos;
    outPos_1 = outPos;
    radius_7 = radius_6;
    blend_1 = blend;
    colorFog_1 = colorFog;
    sourceDim_1 = sourceDim;
    model3DTransform_1 = model3DTransform;
    texTransform_1 = texTransform;
    let _e28 = texTransform_1;
    invTt = _naga_inverse_3x3_f32(_e28);
    let _e38 = model3DTransform_1;
    m_2 = _naga_inverse_4x4_f32(_e38);
    let _e41 = m_2;
    let _e42 = cameraPos;
    cameraPos = (_e41 * vec4<f32>(_e42.x, _e42.y, _e42.z, 1f)).xyz;
    let _e50 = pos_1;
    let _e52 = D;
    let _e54 = pos_1;
    let _e56 = D;
    dir_4 = normalize(vec3<f32>((_e50.x * _e52), (_e54.y * _e56), -1f));
    let _e63 = m_2;
    let _e73 = dir_4;
    dir_4 = normalize((mat3x3<f32>(_e63[0].xyz, _e63[1].xyz, _e63[2].xyz) * _e73));
    let _e76 = cameraPos;
    origin_4 = _e76;
    let _e78 = origin_4;
    let _e79 = dir_4;
    let _e80 = radius_7;
    let _e81 = getIntersectionD(_e78, _e79, _e80);
    inters = _e81;
    let _e83 = inters;
    k_1 = _e83.x;
    let _e86 = sourceDim_1;
    let _e88 = sourceDim_1;
    ratio = (_e86.x / _e88.y);
    let _e92 = blend_1;
    blend_1 = (_e92 * 0.5f);
    let _e95 = ratio;
    let _e97 = blend_1;
    width = (_e95 * (1f - _e97));
    let _e102 = blend_1;
    height = (1f - _e102);
    let _e105 = width;
    let _e106 = ratio;
    let _e107 = blend_1;
    bWidth = (_e105 - (_e106 * _e107));
    let _e111 = height;
    let _e112 = blend_1;
    bHeight = (_e111 - _e112);
    let _e115 = k_1;
    if (_e115 > 0f) {
        {
            let _e118 = origin_4;
            let _e119 = k_1;
            let _e120 = dir_4;
            intersection = (_e118 + (_e119 * _e120));
            let _e126 = R_1;
            let _e127 = radius_7;
            r_1 = ((_e126 * _e127) * 2f);
            let _e132 = intersection;
            let _e134 = intersection;
            let _e139 = width;
            x = ((atan2(_e132.x, _e134.y) / 3.1415927f) * _e139);
            let _e142 = intersection;
            let _e144 = intersection;
            let _e147 = intersection;
            let _e149 = intersection;
            let _e154 = R_1;
            a_2 = (sqrt(((_e142.x * _e144.x) + (_e147.y * _e149.y))) - _e154);
            let _e157 = a_2;
            let _e158 = intersection;
            let _e164 = height;
            y = ((atan2(_e157, -(_e158.z)) / 3.1415927f) * _e164);
            let _e168 = blend_1;
            if (_e168 == 0f) {
                let _e171 = invTt;
                let _e172 = x;
                let _e173 = y;
                let _e175 = tf(_e171, vec2<f32>(_e172, _e173));
                let _e179 = global.U[0];
                let _e182 = invTt;
                let _e183 = x;
                let _e184 = y;
                let _e186 = tf(_e182, vec2<f32>(_e183, _e184));
                let _e195 = textureSample(t_source, samp, ((vec2<f32>((_e175.x / _e179.x), _e186.y) / vec2(2f)) + vec2(0.5f)));
                col = _e195;
            } else {
                {
                    let _e196 = invTt;
                    let _e197 = x;
                    let _e198 = y;
                    let _e200 = tf(_e196, vec2<f32>(_e197, _e198));
                    u00_ = _e200;
                    let _e202 = invTt;
                    let _e203 = x;
                    let _e204 = x;
                    let _e206 = ratio;
                    let _e207 = bWidth;
                    let _e211 = y;
                    let _e213 = tf(_e202, vec2<f32>((_e203 - (sign(_e204) * (_e206 + _e207))), _e211));
                    u10_ = _e213;
                    let _e215 = invTt;
                    let _e216 = x;
                    let _e217 = y;
                    let _e218 = y;
                    let _e221 = bHeight;
                    let _e226 = tf(_e215, vec2<f32>(_e216, (_e217 - (sign(_e218) * (1f + _e221)))));
                    u01_ = _e226;
                    let _e228 = invTt;
                    let _e229 = x;
                    let _e230 = x;
                    let _e232 = ratio;
                    let _e233 = bWidth;
                    let _e237 = y;
                    let _e238 = y;
                    let _e241 = bHeight;
                    let _e246 = tf(_e228, vec2<f32>((_e229 - (sign(_e230) * (_e232 + _e233))), (_e237 - (sign(_e238) * (1f + _e241)))));
                    u11_ = _e246;
                    let _e248 = u00_;
                    let _e252 = global.U[0];
                    let _e255 = u00_;
                    let _e264 = textureSample(t_source, samp, ((vec2<f32>((_e248.x / _e252.x), _e255.y) / vec2(2f)) + vec2(0.5f)));
                    let _e265 = u10_;
                    let _e269 = global.U[0];
                    let _e272 = u10_;
                    let _e281 = textureSample(t_source, samp, ((vec2<f32>((_e265.x / _e269.x), _e272.y) / vec2(2f)) + vec2(0.5f)));
                    let _e284 = blend_1;
                    let _e286 = ratio;
                    let _e288 = x;
                    let _e290 = bWidth;
                    let _e295 = u01_;
                    let _e299 = global.U[0];
                    let _e302 = u01_;
                    let _e311 = textureSample(t_source, samp, ((vec2<f32>((_e295.x / _e299.x), _e302.y) / vec2(2f)) + vec2(0.5f)));
                    let _e312 = u11_;
                    let _e316 = global.U[0];
                    let _e319 = u11_;
                    let _e328 = textureSample(t_source, samp, ((vec2<f32>((_e312.x / _e316.x), _e319.y) / vec2(2f)) + vec2(0.5f)));
                    let _e331 = blend_1;
                    let _e333 = ratio;
                    let _e335 = x;
                    let _e337 = bWidth;
                    let _e344 = blend_1;
                    let _e346 = y;
                    let _e348 = bHeight;
                    col = mix(mix(_e264, _e281, vec4(smoothstep(0f, ((2f * _e284) * _e286), (abs(_e288) - _e290)))), mix(_e311, _e328, vec4(smoothstep(0f, ((2f * _e331) * _e333), (abs(_e335) - _e337)))), vec4(smoothstep(0f, (2f * _e344), (abs(_e346) - _e348))));
                }
            }
            let _e353 = origin_4;
            let _e354 = intersection;
            dist_3 = length((_e353 - _e354));
            let _e358 = dist_3;
            let _e359 = colorFog_1;
            let _e361 = getFog(_e358, _e359.w);
            fog = _e361;
            let _e363 = col;
            let _e365 = colorFog_1;
            let _e367 = fog;
            let _e369 = mix(_e363.xyz, _e365.xyz, vec3(_e367));
            let _e370 = col;
            return vec4<f32>(_e369.x, _e369.y, _e369.z, _e370.w);
        }
    } else {
        {
            let _e384 = dist_4;
            let _e385 = colorFog_1;
            let _e387 = getFog(_e384, _e385.w);
            fog_1 = clamp(_e387, 0f, 1f);
            let _e392 = col_1;
            let _e394 = colorFog_1;
            let _e396 = fog_1;
            let _e398 = mix(_e392.xyz, _e394.xyz, vec3(_e396));
            let _e399 = col_1;
            return vec4<f32>(_e398.x, _e398.y, _e398.z, _e399.w);
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
    let _e66 = global.U[6];
    let _e70 = global.U[7];
    let _e74 = global.U[8];
    let _e77 = global.U[4];
    let _e81 = global.U[9];
    let _e84 = global.U[10];
    let _e87 = global.U[11];
    let _e90 = global.U[12];
    let _e114 = global.U[13];
    let _e115 = _e114.xyz;
    let _e118 = global.U[14];
    let _e119 = _e118.xyz;
    let _e122 = global.U[15];
    let _e123 = _e122.xyz;
    let _e137 = torusMap((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e9.x, _e9.y, _e9.z), vec3<f32>(_e13.x, _e13.y, _e13.z), vec3<f32>(_e17.x, _e17.y, _e17.z))) * vec3<f32>(_e44.x, _e44.y, 1f)).xy, (((_e51 - vec2(0.5f)) * 2f) * vec2<f32>(_e59.x, 1f)), _e66.x, _e70.x, _e74, _e77.xy, mat4x4<f32>(vec4<f32>(_e81.x, _e81.y, _e81.z, _e81.w), vec4<f32>(_e84.x, _e84.y, _e84.z, _e84.w), vec4<f32>(_e87.x, _e87.y, _e87.z, _e87.w), vec4<f32>(_e90.x, _e90.y, _e90.z, _e90.w)), mat3x3<f32>(vec3<f32>(_e115.x, _e115.y, _e115.z), vec3<f32>(_e119.x, _e119.y, _e119.z), vec3<f32>(_e123.x, _e123.y, _e123.z)));
    fragColor = _e137;
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

fn _naga_inverse_4x4_f32(m: mat4x4<f32>) -> mat4x4<f32> {
   let sub_factor00: f32 = m[2][2] * m[3][3] - m[3][2] * m[2][3];
   let sub_factor01: f32 = m[2][1] * m[3][3] - m[3][1] * m[2][3];
   let sub_factor02: f32 = m[2][1] * m[3][2] - m[3][1] * m[2][2];
   let sub_factor03: f32 = m[2][0] * m[3][3] - m[3][0] * m[2][3];
   let sub_factor04: f32 = m[2][0] * m[3][2] - m[3][0] * m[2][2];
   let sub_factor05: f32 = m[2][0] * m[3][1] - m[3][0] * m[2][1];
   let sub_factor06: f32 = m[1][2] * m[3][3] - m[3][2] * m[1][3];
   let sub_factor07: f32 = m[1][1] * m[3][3] - m[3][1] * m[1][3];
   let sub_factor08: f32 = m[1][1] * m[3][2] - m[3][1] * m[1][2];
   let sub_factor09: f32 = m[1][0] * m[3][3] - m[3][0] * m[1][3];
   let sub_factor10: f32 = m[1][0] * m[3][2] - m[3][0] * m[1][2];
   let sub_factor11: f32 = m[1][1] * m[3][3] - m[3][1] * m[1][3];
   let sub_factor12: f32 = m[1][0] * m[3][1] - m[3][0] * m[1][1];
   let sub_factor13: f32 = m[1][2] * m[2][3] - m[2][2] * m[1][3];
   let sub_factor14: f32 = m[1][1] * m[2][3] - m[2][1] * m[1][3];
   let sub_factor15: f32 = m[1][1] * m[2][2] - m[2][1] * m[1][2];
   let sub_factor16: f32 = m[1][0] * m[2][3] - m[2][0] * m[1][3];
   let sub_factor17: f32 = m[1][0] * m[2][2] - m[2][0] * m[1][2];
   let sub_factor18: f32 = m[1][0] * m[2][1] - m[2][0] * m[1][1];

   var adj: mat4x4<f32>;
   adj[0][0] =   (m[1][1] * sub_factor00 - m[1][2] * sub_factor01 + m[1][3] * sub_factor02);
   adj[1][0] = - (m[1][0] * sub_factor00 - m[1][2] * sub_factor03 + m[1][3] * sub_factor04);
   adj[2][0] =   (m[1][0] * sub_factor01 - m[1][1] * sub_factor03 + m[1][3] * sub_factor05);
   adj[3][0] = - (m[1][0] * sub_factor02 - m[1][1] * sub_factor04 + m[1][2] * sub_factor05);
   adj[0][1] = - (m[0][1] * sub_factor00 - m[0][2] * sub_factor01 + m[0][3] * sub_factor02);
   adj[1][1] =   (m[0][0] * sub_factor00 - m[0][2] * sub_factor03 + m[0][3] * sub_factor04);
   adj[2][1] = - (m[0][0] * sub_factor01 - m[0][1] * sub_factor03 + m[0][3] * sub_factor05);
   adj[3][1] =   (m[0][0] * sub_factor02 - m[0][1] * sub_factor04 + m[0][2] * sub_factor05);
   adj[0][2] =   (m[0][1] * sub_factor06 - m[0][2] * sub_factor07 + m[0][3] * sub_factor08);
   adj[1][2] = - (m[0][0] * sub_factor06 - m[0][2] * sub_factor09 + m[0][3] * sub_factor10);
   adj[2][2] =   (m[0][0] * sub_factor11 - m[0][1] * sub_factor09 + m[0][3] * sub_factor12);
   adj[3][2] = - (m[0][0] * sub_factor08 - m[0][1] * sub_factor10 + m[0][2] * sub_factor12);
   adj[0][3] = - (m[0][1] * sub_factor13 - m[0][2] * sub_factor14 + m[0][3] * sub_factor15);
   adj[1][3] =   (m[0][0] * sub_factor13 - m[0][2] * sub_factor16 + m[0][3] * sub_factor17);
   adj[2][3] = - (m[0][0] * sub_factor14 - m[0][1] * sub_factor16 + m[0][3] * sub_factor18);
   adj[3][3] =   (m[0][0] * sub_factor15 - m[0][1] * sub_factor17 + m[0][2] * sub_factor18);

   let det = (m[0][0] * adj[0][0] + m[0][1] * adj[1][0] + m[0][2] * adj[2][0] + m[0][3] * adj[3][0]);

   return adj * (1 / det);
}
