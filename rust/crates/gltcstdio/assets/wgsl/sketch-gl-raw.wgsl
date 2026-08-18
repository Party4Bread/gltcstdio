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
@group(0) @binding(3) 
var t_source2_: texture_2d<f32>;

fn rand2rel(co: vec2<f32>) -> vec2<f32> {
    var co_1: vec2<f32>;
    var x: f32;
    var y: f32;

    co_1 = co;
    let _e9 = co_1;
    x = fract((sin(dot(_e9.xy, vec2<f32>(12.9898f, 78.233f))) * 43758.547f));
    let _e20 = x;
    let _e21 = co_1;
    y = fract((sin(dot(vec2<f32>(_e20, _e21.x), vec2<f32>(12.9898f, 78.233f))) * 43758.547f));
    let _e33 = x;
    let _e34 = y;
    return (vec2<f32>(_e33, _e34) - vec2<f32>(0.5f, 0.5f));
}

fn sketchFmod(a: f32, b: f32) -> f32 {
    var a_1: f32;
    var b_1: f32;

    a_1 = a;
    b_1 = b;
    let _e11 = a_1;
    let _e12 = b_1;
    let _e13 = a_1;
    let _e14 = b_1;
    return (_e11 - (_e12 * trunc((_e13 / _e14))));
}

fn sketchLocusGetBlock(pos: vec2<f32>) -> f32 {
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
    let _e33 = sketchFmod(((_e23.x - (2f * _e26.y)) / 200f), 24f);
    divisor = (floor(_e33) / 2f);
    let _e38 = pos_1;
    let _e41 = pos_1;
    let _e48 = sketchFmod(((_e38.x + (2f * _e41.y)) / 200f), 24f);
    threshold = (_e48 / 6f);
    let _e54 = i2_;
    let _e58 = sketchFmod((_e54 * 8877f), 65536f);
    let _e60 = i2_;
    let _e65 = sketchFmod((55f + (_e60 * 777f)), 65536f);
    let _e66 = i2_;
    let _e70 = sketchFmod((_e66 * 413f), 65536f);
    let _e72 = i2_;
    let _e77 = sketchFmod((4445f + (_e72 * 78f)), 65536f);
    rdmz = vec4<f32>(_e58, _e65, _e70, _e77);
    loop {
        let _e82 = i;
        if !((_e82 < 5i)) {
            break;
        }
        {
            let _e89 = pos_1;
            let _e92 = sketchFmod(_e89.x, 8f);
            let _e93 = pos_1;
            let _e96 = sketchFmod(_e93.y, 8f);
            v = vec2<f32>(_e92, _e96);
            let _e99 = v;
            let _e101 = v;
            index = (_e99.x + (_e101.y * 8f));
            let _e107 = pos_1;
            let _e110 = sketchFmod(_e107.y, 300f);
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
            let _e138 = sketchFmod(floor((_e127 / pow(2f, (_e129 - (_e130 * 16f))))), 2f);
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

fn sketchLocusGetHue(c: vec4<f32>) -> f32 {
    var c_1: vec4<f32>;
    var r: f32;
    var g: f32;
    var b_2: f32;
    var mini: f32;
    var maxi: f32;

    c_1 = c;
    let _e9 = c_1;
    r = _e9.x;
    let _e12 = c_1;
    g = _e12.y;
    let _e15 = c_1;
    b_2 = _e15.z;
    let _e18 = r;
    let _e19 = g;
    let _e20 = b_2;
    mini = min(_e18, min(_e19, _e20));
    let _e24 = r;
    let _e25 = g;
    let _e26 = b_2;
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
            let _e39 = b_2;
            let _e42 = maxi;
            let _e43 = mini;
            let _e49 = sketchFmod((((60f * (_e38 - _e39)) / (_e42 - _e43)) + 360f), 360f);
            return _e49;
        } else {
            let _e50 = maxi;
            let _e51 = g;
            if (_e50 == _e51) {
                let _e54 = b_2;
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

fn sketchGetLocus(pos_2: vec2<f32>, inCol: vec4<f32>, outCol: vec4<f32>, locusMode: i32, locusTransform: mat3x3<f32>) -> f32 {
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
    var y_1: f32;
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
                        let _e73 = sketchLocusGetHue(_e72);
                        hue = _e73;
                        let _e79 = locusTransform_1[2][0];
                        let _e83 = sketchFmod((_e79 * 180f), 360f);
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
                            let _e131 = sketchLocusGetBlock(_e130);
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
                                        y_1 = ((-(_e244) * _e246.x) + (_e249 * _e250.y));
                                        let _e255 = y_1;
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

fn sketchGetStroke(p: vec2<f32>, c_2: vec2<f32>, dir: vec2<f32>, thickness: f32) -> f32 {
    var p_1: vec2<f32>;
    var c_3: vec2<f32>;
    var dir_1: vec2<f32>;
    var thickness_1: f32;
    var d_1: vec2<f32>;
    var len: f32;
    var l: f32;
    var local_5: f32;

    p_1 = p;
    c_3 = c_2;
    dir_1 = dir;
    thickness_1 = thickness;
    let _e15 = dir_1;
    let _e19 = dir_1;
    if ((_e15.x == 0f) && (_e19.y == 0f)) {
        return 0f;
    }
    let _e25 = dir_1;
    d_1 = normalize(_e25);
    let _e28 = d_1;
    let _e30 = d_1;
    let _e33 = vec2<f32>(_e28.x, -(_e30.y));
    let _e34 = d_1;
    let _e35 = _e34.yx;
    let _e43 = p_1;
    let _e44 = c_3;
    p_1 = (mat2x2<f32>(vec2<f32>(_e33.x, _e33.y), vec2<f32>(_e35.x, _e35.y)) * (_e43 - _e44));
    let _e47 = dir_1;
    len = length(_e47);
    let _e51 = p_1;
    let _e54 = len;
    let _e57 = p_1;
    l = length(vec2<f32>(max(0f, (abs(_e51.x) - _e54)), _e57.y));
    let _e62 = l;
    let _e63 = thickness_1;
    if (_e62 < _e63) {
        local_5 = 1f;
    } else {
        local_5 = 0f;
    }
    let _e68 = local_5;
    return _e68;
}

fn sketchResponse(u_1: vec2<f32>, dampeningTh: f32) -> vec2<f32> {
    var u_2: vec2<f32>;
    var dampeningTh_1: f32;
    var len_1: f32;
    var local_6: f32;

    u_2 = u_1;
    dampeningTh_1 = dampeningTh;
    let _e11 = u_2;
    let _e15 = u_2;
    if ((_e11.x == 0f) && (_e15.y == 0f)) {
        let _e20 = u_2;
        return _e20;
    }
    let _e21 = u_2;
    len_1 = length(_e21);
    let _e24 = len_1;
    let _e25 = dampeningTh_1;
    if (_e24 < _e25) {
        local_6 = 0f;
    } else {
        let _e28 = len_1;
        let _e29 = dampeningTh_1;
        let _e32 = dampeningTh_1;
        local_6 = pow(((_e28 - _e29) / (1f - _e32)), 0.1f);
    }
    let _e38 = local_6;
    len_1 = _e38;
    let _e39 = len_1;
    let _e40 = u_2;
    return (_e39 * normalize(_e40));
}

fn sketchGL(pos_4: vec2<f32>, outPos: vec2<f32>, count: i32, dampening: f32, mode: f32, thickness_2: f32, color1_: vec4<f32>, color2_: vec4<f32>, locusMode_2: i32, locusTransform_2: mat3x3<f32>, modelTransform: mat3x3<f32>) -> vec4<f32> {
    var pos_5: vec2<f32>;
    var outPos_1: vec2<f32>;
    var count_1: i32;
    var dampening_1: f32;
    var mode_1: f32;
    var thickness_3: f32;
    var color1_1: vec4<f32>;
    var color2_1: vec4<f32>;
    var locusMode_3: i32;
    var locusTransform_3: mat3x3<f32>;
    var modelTransform_1: mat3x3<f32>;
    var thicknessNorm: f32;
    var dampeningTh_2: f32;
    var style: f32;
    var resolution: f32;
    var sp: vec2<f32>;
    var delta: f32 = 0.005f;
    var step: f32;
    var sum: f32 = 0f;
    var fCount: f32;
    var jj: i32 = 0i;
    var j: f32;
    var ii: i32;
    var i_1: f32;
    var pp: vec2<f32>;
    var grad: vec2<f32>;
    var _o_d: f32;
    var _o_cx0_: vec4<f32>;
    var _o_cx1_: vec4<f32>;
    var _o_cy0_: vec4<f32>;
    var _o_cy1_: vec4<f32>;
    var g_1: vec2<f32>;
    var val: f32;
    var _o_c: vec4<f32>;
    var index_1: vec2<f32>;
    var k: f32;
    var val_1: f32;
    var _o_c_1: vec4<f32>;
    var ratio: f32;
    var index_2: vec2<f32>;
    var vDir: f32;
    var k_1: f32;
    var hDir: vec2<f32>;
    var local_7: f32;
    var k_2: f32;
    var color: vec4<f32>;
    var bkgCol: vec4<f32>;
    var mixCol: vec4<f32>;
    var locus: f32;

    pos_5 = pos_4;
    outPos_1 = outPos;
    count_1 = count;
    dampening_1 = dampening;
    mode_1 = mode;
    thickness_3 = thickness_2;
    color1_1 = color1_;
    color2_1 = color2_;
    locusMode_3 = locusMode_2;
    locusTransform_3 = locusTransform_2;
    modelTransform_1 = modelTransform;
    let _e29 = thickness_3;
    thicknessNorm = (_e29 * 0.02f);
    let _e33 = dampening_1;
    let _e34 = dampening_1;
    dampeningTh_2 = (_e33 * _e34);
    let _e37 = mode_1;
    style = _e37;
    let _e43 = modelTransform_1[0][0];
    let _e48 = modelTransform_1[0][1];
    resolution = length(vec2<f32>(_e43, _e48));
    let _e52 = pos_5;
    let _e53 = resolution;
    let _e59 = resolution;
    sp = (floor(((_e52 * _e53) + vec2(0.5f))) / vec2(_e59));
    let _e66 = resolution;
    step = (1f / _e66);
    let _e71 = count_1;
    fCount = f32(_e71);
    loop {
        let _e76 = jj;
        if !((_e76 <= 200i)) {
            break;
        }
        {
            let _e83 = jj;
            let _e85 = count_1;
            if (_e83 > (2i * _e85)) {
                break;
            }
            let _e88 = jj;
            let _e90 = fCount;
            j = (f32(_e88) - _e90);
            ii = 0i;
            loop {
                let _e95 = ii;
                if !((_e95 <= 200i)) {
                    break;
                }
                {
                    let _e102 = ii;
                    let _e104 = count_1;
                    if (_e102 > (2i * _e104)) {
                        break;
                    }
                    let _e107 = ii;
                    let _e109 = fCount;
                    i_1 = (f32(_e107) - _e109);
                    let _e112 = sp;
                    let _e113 = i_1;
                    let _e114 = j;
                    let _e116 = step;
                    pp = (_e112 + (vec2<f32>(_e113, _e114) * _e116));
                    {
                        let _e121 = delta;
                        _o_d = _e121;
                        let _e123 = pp;
                        let _e124 = _o_d;
                        let _e131 = global.U[0];
                        let _e134 = pp;
                        let _e135 = _o_d;
                        let _e147 = textureSample(t_source2_, samp, ((vec2<f32>(((_e123 + vec2<f32>(_e124, 0f)).x / _e131.x), (_e134 + vec2<f32>(_e135, 0f)).y) / vec2(2f)) + vec2(0.5f)));
                        _o_cx0_ = _e147;
                        let _e149 = pp;
                        let _e150 = _o_d;
                        let _e157 = global.U[0];
                        let _e160 = pp;
                        let _e161 = _o_d;
                        let _e173 = textureSample(t_source2_, samp, ((vec2<f32>(((_e149 - vec2<f32>(_e150, 0f)).x / _e157.x), (_e160 - vec2<f32>(_e161, 0f)).y) / vec2(2f)) + vec2(0.5f)));
                        _o_cx1_ = _e173;
                        let _e175 = pp;
                        let _e177 = _o_d;
                        let _e183 = global.U[0];
                        let _e186 = pp;
                        let _e188 = _o_d;
                        let _e199 = textureSample(t_source2_, samp, ((vec2<f32>(((_e175 + vec2<f32>(0f, _e177)).x / _e183.x), (_e186 + vec2<f32>(0f, _e188)).y) / vec2(2f)) + vec2(0.5f)));
                        _o_cy0_ = _e199;
                        let _e201 = pp;
                        let _e203 = _o_d;
                        let _e209 = global.U[0];
                        let _e212 = pp;
                        let _e214 = _o_d;
                        let _e225 = textureSample(t_source2_, samp, ((vec2<f32>(((_e201 - vec2<f32>(0f, _e203)).x / _e209.x), (_e212 - vec2<f32>(0f, _e214)).y) / vec2(2f)) + vec2(0.5f)));
                        _o_cy1_ = _e225;
                        let _e227 = _o_cx0_;
                        let _e229 = _o_cx0_;
                        let _e232 = _o_cx0_;
                        let _e235 = _o_cx1_;
                        let _e237 = _o_cx1_;
                        let _e240 = _o_cx1_;
                        let _e246 = _o_d;
                        let _e250 = _o_cy0_;
                        let _e252 = _o_cy0_;
                        let _e255 = _o_cy0_;
                        let _e258 = _o_cy1_;
                        let _e260 = _o_cy1_;
                        let _e263 = _o_cy1_;
                        let _e269 = _o_d;
                        grad = vec2<f32>((((((_e227.x + _e229.y) + _e232.z) - ((_e235.x + _e237.y) + _e240.z)) / 3f) / (_e246 * 2f)), (((((_e250.x + _e252.y) + _e255.z) - ((_e258.x + _e260.y) + _e263.z)) / 3f) / (_e269 * 2f)));
                    }
                    let _e274 = grad;
                    let _e275 = delta;
                    grad = ((_e274 * _e275) / vec2(2f));
                    let _e280 = grad;
                    let _e281 = dampeningTh_2;
                    let _e282 = sketchResponse(_e280, _e281);
                    let _e283 = resolution;
                    let _e289 = fCount;
                    g_1 = (((_e282 / vec2(_e283)) / vec2(2f)) * _e289);
                    let _e292 = sum;
                    let _e293 = pos_5;
                    let _e294 = pp;
                    let _e295 = g_1;
                    let _e297 = g_1;
                    let _e301 = thicknessNorm;
                    let _e302 = sketchGetStroke(_e293, _e294, vec2<f32>(_e295.y, -(_e297.x)), _e301);
                    sum = (_e292 + _e302);
                    let _e304 = style;
                    if (_e304 <= 0.5f) {
                        {
                            {
                                let _e308 = pos_5;
                                let _e312 = global.U[0];
                                let _e315 = pos_5;
                                let _e324 = textureSample(t_source2_, samp, ((vec2<f32>((_e308.x / _e312.x), _e315.y) / vec2(2f)) + vec2(0.5f)));
                                _o_c = _e324;
                                let _e326 = _o_c;
                                let _e328 = _o_c;
                                let _e331 = _o_c;
                                val = (((_e326.x + _e328.y) + _e331.z) / 3f);
                            }
                            let _e336 = pp;
                            let _e337 = resolution;
                            index_1 = floor((_e336 * _e337));
                            let _e341 = index_1;
                            let _e343 = index_1;
                            k = (_e341.x + _e343.y);
                            let _e347 = k;
                            let _e353 = val;
                            if ((_e347 - (floor((_e347 / 4f)) * 4f)) >= (_e353 * 4f)) {
                                {
                                    let _e357 = sum;
                                    let _e358 = pos_5;
                                    let _e359 = pp;
                                    let _e360 = grad;
                                    let _e362 = resolution;
                                    let _e368 = fCount;
                                    let _e370 = thicknessNorm;
                                    let _e373 = style;
                                    let _e376 = sketchGetStroke(_e358, _e359, (((normalize(_e360) / vec2(_e362)) / vec2(2f)) * _e368), (_e370 * smoothstep(0f, 0.5f, _e373)));
                                    sum = (_e357 + _e376);
                                }
                            }
                        }
                    } else {
                        {
                            {
                                let _e379 = pp;
                                let _e383 = global.U[0];
                                let _e386 = pp;
                                let _e395 = textureSample(t_source2_, samp, ((vec2<f32>((_e379.x / _e383.x), _e386.y) / vec2(2f)) + vec2(0.5f)));
                                _o_c_1 = _e395;
                                let _e397 = _o_c_1;
                                let _e399 = _o_c_1;
                                let _e402 = _o_c_1;
                                val_1 = (((_e397.x + _e399.y) + _e402.z) / 3f);
                            }
                            let _e407 = val_1;
                            ratio = floor(((_e407 * 5f) + 0.5f));
                            let _e414 = ratio;
                            if (_e414 < 5f) {
                                {
                                    let _e417 = pp;
                                    let _e421 = resolution;
                                    index_2 = floor(((_e417 + vec2(20f)) * _e421));
                                    vDir = 1f;
                                    let _e427 = index_2;
                                    let _e429 = vDir;
                                    let _e430 = index_2;
                                    k_1 = (_e427.x - (_e429 * _e430.y));
                                    let _e435 = ratio;
                                    let _e438 = k_1;
                                    let _e439 = ratio;
                                    if ((_e435 == 0f) || ((_e438 - (floor((_e438 / _e439)) * _e439)) == 0f)) {
                                        {
                                            let _e447 = index_2;
                                            let _e448 = rand2rel(_e447);
                                            let _e451 = ratio;
                                            let _e452 = vDir;
                                            let _e458 = resolution;
                                            let _e464 = fCount;
                                            hDir = (((normalize(((_e448 * 1f) + vec2<f32>((_e451 + _e452), 1f))) / vec2(_e458)) / vec2(2f)) * _e464);
                                            let _e467 = sum;
                                            let _e468 = pos_5;
                                            let _e469 = pp;
                                            let _e470 = hDir;
                                            let _e471 = thicknessNorm;
                                            let _e474 = style;
                                            let _e477 = sketchGetStroke(_e468, _e469, _e470, (_e471 * smoothstep(0.5f, 1f, _e474)));
                                            sum = (_e467 + _e477);
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                continuing {
                    let _e99 = ii;
                    ii = (_e99 + 1i);
                }
            }
        }
        continuing {
            let _e80 = jj;
            jj = (_e80 + 1i);
        }
    }
    let _e479 = sum;
    if (_e479 > 0f) {
        local_7 = 1f;
    } else {
        local_7 = 0f;
    }
    let _e485 = local_7;
    k_2 = _e485;
    let _e487 = color1_1;
    let _e488 = color2_1;
    let _e489 = k_2;
    color = mix(_e487, _e488, vec4(_e489));
    let _e493 = pos_5;
    let _e497 = global.U[0];
    let _e500 = pos_5;
    let _e509 = textureSample(t_source, samp, ((vec2<f32>((_e493.x / _e497.x), _e500.y) / vec2(2f)) + vec2(0.5f)));
    bkgCol = _e509;
    let _e511 = bkgCol;
    let _e513 = color;
    let _e515 = color;
    let _e518 = mix(_e511.xyz, _e513.xyz, vec3(_e515.w));
    let _e519 = bkgCol;
    mixCol = vec4<f32>(_e518.x, _e518.y, _e518.z, _e519.w);
    let _e526 = pos_5;
    let _e527 = bkgCol;
    let _e528 = mixCol;
    let _e529 = locusMode_3;
    let _e530 = locusTransform_3;
    let _e531 = sketchGetLocus(_e526, _e527, _e528, _e529, _e530);
    locus = _e531;
    let _e533 = bkgCol;
    let _e534 = mixCol;
    let _e535 = locus;
    return mix(_e533, _e534, vec4(_e535));
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
    let _e76 = global.U[7];
    let _e80 = global.U[8];
    let _e84 = global.U[9];
    let _e87 = global.U[10];
    let _e90 = global.U[11];
    let _e95 = global.U[12];
    let _e96 = _e95.xyz;
    let _e99 = global.U[13];
    let _e100 = _e99.xyz;
    let _e103 = global.U[14];
    let _e104 = _e103.xyz;
    let _e120 = global.U[15];
    let _e121 = _e120.xyz;
    let _e124 = global.U[16];
    let _e125 = _e124.xyz;
    let _e128 = global.U[17];
    let _e129 = _e128.xyz;
    let _e143 = sketchGL((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e10.x, _e10.y, _e10.z), vec3<f32>(_e14.x, _e14.y, _e14.z), vec3<f32>(_e18.x, _e18.y, _e18.z))) * vec3<f32>(_e45.x, _e45.y, 1f)).xy, (((_e52 - vec2(0.5f)) * 2f) * vec2<f32>(_e60.x, 1f)), i32(_e67.x), _e72.x, _e76.x, _e80.x, _e84, _e87, i32(_e90.x), mat3x3<f32>(vec3<f32>(_e96.x, _e96.y, _e96.z), vec3<f32>(_e100.x, _e100.y, _e100.z), vec3<f32>(_e104.x, _e104.y, _e104.z)), mat3x3<f32>(vec3<f32>(_e121.x, _e121.y, _e121.z), vec3<f32>(_e125.x, _e125.y, _e125.z), vec3<f32>(_e129.x, _e129.y, _e129.z)));
    fragColor = _e143;
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
