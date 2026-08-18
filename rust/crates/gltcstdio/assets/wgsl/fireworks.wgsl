struct Params {
    U: array<vec4<f32>, 19>,
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

fn hash12_(x: f32) -> vec2<f32> {
    var x_1: f32;

    x_1 = x;
    let _e8 = x_1;
    let _e15 = x_1;
    return vec2<f32>(fract((sin((_e8 * 776.4577f)) * 45.77f)), fract((sin(((_e15 * 376.4517f) + 1.2524f)) * 88.77f)));
}

fn sparc(u: vec2<f32>, power: f32) -> f32 {
    var u_1: vec2<f32>;
    var power_1: f32;
    var len: f32;

    u_1 = u;
    power_1 = power;
    let _e10 = u_1;
    len = length(_e10);
    let _e14 = len;
    let _e15 = power_1;
    return (1f / pow(_e14, _e15));
}

fn explosion(u_2: vec2<f32>, n: i32, id: f32, time: f32, blend: f32, power_2: f32) -> f32 {
    var u_3: vec2<f32>;
    var n_1: i32;
    var id_1: f32;
    var time_1: f32;
    var blend_1: f32;
    var power_3: f32;
    var total: f32 = 0f;
    var i: i32 = 0i;
    var rnd: vec2<f32>;
    var angle: f32;
    var speed: f32;
    var pos: vec2<f32>;
    var decay: f32;
    var lum: f32;

    u_3 = u_2;
    n_1 = n;
    id_1 = id;
    time_1 = time;
    blend_1 = blend;
    power_3 = power_2;
    loop {
        let _e22 = i;
        let _e23 = n_1;
        if !((_e22 < _e23)) {
            break;
        }
        {
            let _e30 = id_1;
            let _e32 = i;
            let _e35 = hash12_(((1f + _e30) + f32(_e32)));
            rnd = _e35;
            let _e37 = rnd;
            angle = (_e37.x * 6.2831855f);
            let _e42 = rnd;
            speed = pow(_e42.y, 0.35f);
            let _e47 = speed;
            let _e48 = time_1;
            let _e50 = angle;
            let _e52 = angle;
            pos = ((_e47 * _e48) * vec2<f32>(cos(_e50), sin(_e52)));
            let _e59 = time_1;
            decay = smoothstep(15f, 5f, _e59);
            let _e62 = u_3;
            let _e63 = pos;
            let _e65 = power_3;
            let _e66 = sparc((_e62 - _e63), _e65);
            let _e67 = decay;
            lum = (_e66 * _e67);
            let _e70 = total;
            let _e71 = blend_1;
            let _e73 = lum;
            let _e74 = blend_1;
            let _e78 = blend_1;
            total = pow((pow(_e70, _e71) + pow(_e73, _e74)), (1f / _e78));
        }
        continuing {
            let _e26 = i;
            i = (_e26 + 1i);
        }
    }
    let _e81 = total;
    return _e81;
}

fn sdUnevenCapsule(p: vec2<f32>, r1_: f32, r2_: f32, h: f32) -> f32 {
    var p_1: vec2<f32>;
    var r1_1: f32;
    var r2_1: f32;
    var h_1: f32;
    var b: f32;
    var a: f32;
    var k: f32;

    p_1 = p;
    r1_1 = r1_;
    r2_1 = r2_;
    h_1 = h;
    let _e15 = p_1;
    p_1.x = abs(_e15.x);
    let _e18 = r1_1;
    let _e19 = r2_1;
    let _e21 = h_1;
    b = ((_e18 - _e19) / _e21);
    let _e25 = b;
    let _e26 = b;
    a = sqrt((1f - (_e25 * _e26)));
    let _e31 = p_1;
    let _e32 = b;
    let _e34 = a;
    k = dot(_e31, vec2<f32>(-(_e32), _e34));
    let _e38 = k;
    if (_e38 < 0f) {
        let _e41 = p_1;
        let _e43 = r1_1;
        return (length(_e41) - _e43);
    }
    let _e45 = k;
    let _e46 = a;
    let _e47 = h_1;
    if (_e45 > (_e46 * _e47)) {
        let _e50 = p_1;
        let _e52 = h_1;
        let _e56 = r2_1;
        return (length((_e50 - vec2<f32>(0f, _e52))) - _e56);
    }
    let _e58 = p_1;
    let _e59 = a;
    let _e60 = b;
    let _e63 = r1_1;
    return (dot(_e58, vec2<f32>(_e59, _e60)) - _e63);
}

fn trail(p_2: vec2<f32>, a_1: vec2<f32>, b_1: vec2<f32>, power_4: f32) -> f32 {
    var p_3: vec2<f32>;
    var a_2: vec2<f32>;
    var b_2: vec2<f32>;
    var power_5: f32;
    var ba: vec2<f32>;
    var h_2: f32;
    var cosa: f32;
    var sina: f32;
    var u_4: vec2<f32>;
    var bigR: f32 = 0.05f;
    var smallR: f32 = 0.01f;
    var local: f32;
    var len_1: f32;

    p_3 = p_2;
    a_2 = a_1;
    b_2 = b_1;
    power_5 = power_4;
    let _e14 = b_2;
    let _e15 = a_2;
    ba = (_e14 - _e15);
    let _e18 = ba;
    h_2 = length(_e18);
    let _e21 = ba;
    let _e23 = h_2;
    cosa = (_e21.x / _e23);
    let _e26 = ba;
    let _e28 = h_2;
    sina = (_e26.y / _e28);
    let _e31 = sina;
    let _e32 = cosa;
    let _e33 = cosa;
    let _e35 = sina;
    let _e39 = p_3;
    let _e40 = a_2;
    u_4 = (mat2x2<f32>(vec2<f32>(_e31, _e32), vec2<f32>(-(_e33), _e35)) * (_e39 - _e40));
    let _e48 = h_2;
    if (_e48 == 0f) {
        let _e51 = p_3;
        let _e52 = b_2;
        local = length((_e51 - _e52));
    } else {
        let _e55 = u_4;
        let _e58 = h_2;
        let _e59 = sdUnevenCapsule(_e55, 0.01f, 0.05f, _e58);
        let _e60 = bigR;
        local = (_e59 + _e60);
    }
    let _e63 = local;
    len_1 = _e63;
    let _e66 = len_1;
    let _e67 = power_5;
    return (1f / pow(_e66, _e67));
}

fn explosionT(u_5: vec2<f32>, n_2: i32, id_2: f32, time_2: f32, deltaT: f32, blend_2: f32, power_6: f32) -> f32 {
    var u_6: vec2<f32>;
    var n_3: i32;
    var id_3: f32;
    var time_3: f32;
    var deltaT_1: f32;
    var blend_3: f32;
    var power_7: f32;
    var total_1: f32 = 0f;
    var i_1: i32 = 0i;
    var rnd_1: vec2<f32>;
    var angle_1: f32;
    var speed_1: vec2<f32>;
    var posA: vec2<f32>;
    var posB: vec2<f32>;
    var decay_1: f32;
    var lum_1: f32;

    u_6 = u_5;
    n_3 = n_2;
    id_3 = id_2;
    time_3 = time_2;
    deltaT_1 = deltaT;
    blend_3 = blend_2;
    power_7 = power_6;
    loop {
        let _e24 = i_1;
        let _e25 = n_3;
        if !((_e24 < _e25)) {
            break;
        }
        {
            let _e32 = id_3;
            let _e34 = i_1;
            let _e37 = hash12_(((1f + _e32) + f32(_e34)));
            rnd_1 = _e37;
            let _e39 = rnd_1;
            angle_1 = (_e39.x * 6.2831855f);
            let _e44 = rnd_1;
            let _e48 = angle_1;
            let _e50 = angle_1;
            speed_1 = (pow(_e44.y, 0.35f) * vec2<f32>(cos(_e48), sin(_e50)));
            let _e55 = speed_1;
            let _e57 = time_3;
            let _e58 = deltaT_1;
            posA = (_e55 * max(0f, (_e57 - _e58)));
            let _e63 = speed_1;
            let _e64 = time_3;
            posB = (_e63 * _e64);
            let _e69 = time_3;
            decay_1 = smoothstep(20f, 5f, _e69);
            let _e73 = u_6;
            let _e74 = posA;
            let _e75 = posB;
            let _e76 = power_7;
            let _e77 = trail(_e73, _e74, _e75, _e76);
            let _e78 = decay_1;
            lum_1 = max(0f, (_e77 * _e78));
            let _e82 = total_1;
            let _e83 = blend_3;
            let _e85 = lum_1;
            let _e86 = blend_3;
            let _e90 = blend_3;
            total_1 = pow((pow(_e82, _e83) + pow(_e85, _e86)), (1f / _e90));
        }
        continuing {
            let _e28 = i_1;
            i_1 = (_e28 + 1i);
        }
    }
    let _e93 = total_1;
    return _e93;
}

fn hash13_(x_2: f32) -> vec3<f32> {
    var x_3: f32;

    x_3 = x_2;
    let _e8 = x_3;
    let _e14 = x_3;
    let _e20 = x_3;
    return fract(vec3<f32>((sin((_e8 * 776.4577f)) * 45.771f), (cos((_e14 * 442.8831f)) * 65.111f), (sin(((_e20 * 376.4517f) + 1.2524f)) * 88.771f)));
}

fn luma(c: vec3<f32>) -> f32 {
    var c_1: vec3<f32>;

    c_1 = c;
    let _e9 = c_1;
    let _e13 = c_1;
    let _e18 = c_1;
    return (((0.2989f * _e9.x) + (0.587f * _e13.y)) + (0.114f * _e18.z));
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

fn spilloverChannels(c_2: vec4<f32>) -> vec4<f32> {
    var c_3: vec4<f32>;
    var overflow: f32;

    c_3 = c_2;
    let _e8 = c_3;
    let _e14 = c_3;
    let _e21 = c_3;
    overflow = (((max((_e8.x - 1f), 0f) + max((_e14.y - 1f), 0f)) + max((_e21.z - 1f), 0f)) / 3f);
    let _e32 = c_3;
    let _e34 = overflow;
    c_3.x = (_e32.x + _e34);
    let _e37 = c_3;
    let _e39 = overflow;
    c_3.y = (_e37.y + _e39);
    let _e42 = c_3;
    let _e44 = overflow;
    c_3.z = (_e42.z + _e44);
    let _e46 = c_3;
    return _e46;
}

fn tf(m: mat3x3<f32>, u_7: vec2<f32>) -> vec2<f32> {
    var m_1: mat3x3<f32>;
    var u_8: vec2<f32>;

    m_1 = m;
    u_8 = u_7;
    let _e10 = m_1;
    let _e11 = u_8;
    return (_e10 * vec3<f32>(_e11.x, _e11.y, 1f)).xy;
}

fn fireworks(uv: vec2<f32>, outPos: vec2<f32>, sourceDim: vec2<f32>, mode: i32, explosions: i32, particles: i32, intensity: f32, power_8: f32, spread: f32, blend_4: f32, randomSeed: f32, color: vec4<f32>, colorVariability: f32, modelTransform: mat3x3<f32>) -> vec4<f32> {
    var uv_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var sourceDim_1: vec2<f32>;
    var mode_1: i32;
    var explosions_1: i32;
    var particles_1: i32;
    var intensity_1: f32;
    var power_9: f32;
    var spread_1: f32;
    var blend_5: f32;
    var randomSeed_1: f32;
    var color_1: vec4<f32>;
    var colorVariability_1: f32;
    var modelTransform_1: mat3x3<f32>;
    var inc: vec4<f32>;
    var u_9: vec2<f32>;
    var time_4: f32;
    var CYCLE: f32 = 20f;
    var outCol: vec3<f32> = vec3(0f);
    var sliceDuration: f32;
    var timeSlice: f32;
    var e: i32 = 0i;
    var explosionId: f32;
    var startTime: f32;
    var eTime: f32;
    var center: vec2<f32>;
    var g: f32;
    var col: vec3<f32>;

    uv_1 = uv;
    outPos_1 = outPos;
    sourceDim_1 = sourceDim;
    mode_1 = mode;
    explosions_1 = explosions;
    particles_1 = particles;
    intensity_1 = intensity;
    power_9 = power_8;
    spread_1 = spread;
    blend_5 = blend_4;
    randomSeed_1 = randomSeed;
    color_1 = color;
    colorVariability_1 = colorVariability;
    modelTransform_1 = modelTransform;
    let _e34 = uv_1;
    let _e38 = global.U[0];
    let _e41 = uv_1;
    let _e50 = textureSample(t_source, samp, ((vec2<f32>((_e34.x / _e38.x), _e41.y) / vec2(2f)) + vec2(0.5f)));
    inc = _e50;
    let _e52 = modelTransform_1;
    let _e54 = uv_1;
    let _e55 = tf(_naga_inverse_3x3_f32(_e52), _e54);
    u_9 = _e55;
    let _e57 = randomSeed_1;
    time_4 = _e57;
    let _e64 = CYCLE;
    let _e65 = explosions_1;
    sliceDuration = (_e64 / f32(_e65));
    let _e69 = time_4;
    let _e70 = sliceDuration;
    timeSlice = floor((_e69 / _e70));
    loop {
        let _e76 = e;
        let _e77 = explosions_1;
        if !((_e76 < _e77)) {
            break;
        }
        {
            let _e83 = timeSlice;
            let _e84 = e;
            explosionId = (_e83 - f32(_e84));
            let _e88 = explosionId;
            let _e89 = sliceDuration;
            startTime = (_e88 * _e89);
            let _e92 = time_4;
            let _e93 = startTime;
            eTime = (_e92 - _e93);
            let _e96 = explosionId;
            let _e97 = hash12_(_e96);
            let _e103 = spread_1;
            center = (((_e97 - vec2(0.5f)) * 20f) * _e103);
            let _e107 = mode_1;
            if (_e107 == 0i) {
                let _e110 = u_9;
                let _e111 = center;
                let _e113 = particles_1;
                let _e114 = particles_1;
                let _e116 = explosionId;
                let _e118 = eTime;
                let _e119 = blend_5;
                let _e120 = power_9;
                let _e121 = explosion((_e110 - _e111), _e113, (f32(_e114) * _e116), _e118, _e119, _e120);
                g = _e121;
            } else {
                let _e122 = mode_1;
                if (_e122 == 1i) {
                    let _e125 = u_9;
                    let _e126 = center;
                    let _e128 = particles_1;
                    let _e129 = particles_1;
                    let _e131 = explosionId;
                    let _e133 = eTime;
                    let _e135 = blend_5;
                    let _e136 = power_9;
                    let _e137 = explosionT((_e125 - _e126), _e128, (f32(_e129) * _e131), _e133, 0.5f, _e135, _e136);
                    g = _e137;
                } else {
                    let _e138 = mode_1;
                    if (_e138 == 2i) {
                        let _e141 = u_9;
                        let _e142 = center;
                        let _e144 = particles_1;
                        let _e145 = particles_1;
                        let _e147 = explosionId;
                        let _e149 = eTime;
                        let _e151 = blend_5;
                        let _e152 = power_9;
                        let _e153 = explosionT((_e141 - _e142), _e144, (f32(_e145) * _e147), _e149, 1.3f, _e151, _e152);
                        g = _e153;
                    } else {
                        let _e154 = mode_1;
                        if (_e154 == 3i) {
                            let _e157 = u_9;
                            let _e158 = center;
                            let _e160 = particles_1;
                            let _e161 = particles_1;
                            let _e163 = explosionId;
                            let _e165 = eTime;
                            let _e167 = blend_5;
                            let _e168 = power_9;
                            let _e169 = explosionT((_e157 - _e158), _e160, (f32(_e161) * _e163), _e165, 3f, _e167, _e168);
                            g = _e169;
                        }
                    }
                }
            }
            let _e170 = color_1;
            let _e172 = explosionId;
            let _e175 = hash13_((_e172 * 10f));
            let _e179 = colorVariability_1;
            col = (_e170.xyz + ((_e175 - vec3(0.5f)) * _e179));
            let _e183 = outCol;
            let _e184 = intensity_1;
            let _e185 = g;
            let _e187 = col;
            outCol = (_e183 + ((_e184 * _e185) * _e187));
        }
        continuing {
            let _e80 = e;
            e = (_e80 + 1i);
        }
    }
    let _e190 = inc;
    let _e191 = outCol;
    let _e193 = outCol;
    let _e194 = luma(_e193);
    let _e200 = mergeColor(_e190, vec4<f32>(_e191.x, _e191.y, _e191.z, min(1f, _e194)));
    let _e201 = spilloverChannels(_e200);
    return _e201;
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
    let _e80 = global.U[8];
    let _e85 = global.U[9];
    let _e89 = global.U[10];
    let _e93 = global.U[11];
    let _e97 = global.U[12];
    let _e101 = global.U[13];
    let _e105 = global.U[14];
    let _e108 = global.U[15];
    let _e112 = global.U[16];
    let _e113 = _e112.xyz;
    let _e116 = global.U[17];
    let _e117 = _e116.xyz;
    let _e120 = global.U[18];
    let _e121 = _e120.xyz;
    let _e135 = fireworks((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e9.x, _e9.y, _e9.z), vec3<f32>(_e13.x, _e13.y, _e13.z), vec3<f32>(_e17.x, _e17.y, _e17.z))) * vec3<f32>(_e44.x, _e44.y, 1f)).xy, (((_e51 - vec2(0.5f)) * 2f) * vec2<f32>(_e59.x, 1f)), _e66.xy, i32(_e70.x), i32(_e75.x), i32(_e80.x), _e85.x, _e89.x, _e93.x, _e97.x, _e101.x, _e105, _e108.x, mat3x3<f32>(vec3<f32>(_e113.x, _e113.y, _e113.z), vec3<f32>(_e117.x, _e117.y, _e117.z), vec3<f32>(_e121.x, _e121.y, _e121.z)));
    fragColor = _e135;
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
