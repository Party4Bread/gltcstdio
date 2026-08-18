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
var t_source: texture_2d<f32>;

fn getBackground(dir: vec3<f32>, color: vec4<f32>) -> vec4<f32> {
    var dir_1: vec3<f32>;
    var color_1: vec4<f32>;

    dir_1 = dir;
    color_1 = color;
    let _e10 = color_1;
    return _e10;
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

fn perspective(pos: vec2<f32>, outPos: vec2<f32>, mode: i32, dual: i32, model3DTransform: mat4x4<f32>, highFreqColor: vec4<f32>, sourceDim: vec2<f32>) -> vec4<f32> {
    var pos_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var mode_1: i32;
    var dual_1: i32;
    var model3DTransform_1: mat4x4<f32>;
    var highFreqColor_1: vec4<f32>;
    var sourceDim_1: vec2<f32>;
    var D: f32 = 1f;
    var cameraPos: vec3<f32> = vec3<f32>(0f, 0f, 0f);
    var m: mat4x4<f32>;
    var dir_2: vec3<f32>;
    var col: vec4<f32>;
    var clip: bool;
    var ratio: f32;
    var z: f32 = 0f;
    var k: f32;
    var uv: vec2<f32>;
    var d: f32;
    var fog: f32;

    pos_1 = pos;
    outPos_1 = outPos;
    mode_1 = mode;
    dual_1 = dual;
    model3DTransform_1 = model3DTransform;
    highFreqColor_1 = highFreqColor;
    sourceDim_1 = sourceDim;
    let _e27 = model3DTransform_1;
    m = _naga_inverse_4x4_f32(_e27);
    let _e30 = m;
    let _e31 = cameraPos;
    cameraPos = (_e30 * vec4<f32>(_e31.x, _e31.y, _e31.z, 1f)).xyz;
    let _e39 = pos_1;
    let _e41 = D;
    let _e43 = pos_1;
    let _e45 = D;
    dir_2 = normalize(vec3<f32>((_e39.x * _e41), (_e43.y * _e45), -1f));
    let _e54 = m[0];
    let _e55 = _e54.xyz;
    let _e58 = m[1];
    let _e59 = _e58.xyz;
    let _e62 = m[2];
    let _e63 = _e62.xyz;
    let _e77 = dir_2;
    dir_2 = (mat3x3<f32>(vec3<f32>(_e55.x, _e55.y, _e55.z), vec3<f32>(_e59.x, _e59.y, _e59.z), vec3<f32>(_e63.x, _e63.y, _e63.z)) * _e77);
    let _e79 = dir_2;
    let _e80 = highFreqColor_1;
    let _e81 = getBackground(_e79, _e80);
    col = _e81;
    let _e83 = dir_2;
    if (_e83.z == 0f) {
        let _e87 = col;
        return _e87;
    }
    let _e88 = mode_1;
    clip = (_e88 == 0i);
    let _e92 = sourceDim_1;
    let _e94 = sourceDim_1;
    ratio = (_e92.x / _e94.y);
    let _e100 = z;
    let _e101 = cameraPos;
    let _e104 = dir_2;
    k = ((_e100 - _e101.z) / _e104.z);
    let _e108 = dual_1;
    let _e111 = k;
    if ((_e108 == 1i) || (_e111 > 0f)) {
        {
            let _e115 = dir_2;
            let _e117 = k;
            let _e119 = cameraPos;
            uv = ((_e115.xy * _e117) + _e119.xy);
            let _e123 = clip;
            let _e125 = uv;
            let _e128 = ratio;
            let _e130 = uv;
            if (!(_e123) || ((abs(_e125.x) < _e128) && (abs(_e130.y) < 1f))) {
                {
                    let _e137 = uv;
                    let _e141 = global.U[0];
                    let _e144 = uv;
                    let _e153 = textureSample(t_source, samp, ((vec2<f32>((_e137.x / _e141.x), _e144.y) / vec2(2f)) + vec2(0.5f)));
                    col = _e153;
                    let _e154 = k;
                    d = abs(_e154);
                    let _e157 = d;
                    let _e160 = highFreqColor_1;
                    if ((_e157 > 1f) && (_e160.w > 0f)) {
                        {
                            let _e165 = d;
                            fog = ((abs(_e165) - 1f) * 0.2f);
                            let _e172 = col;
                            let _e173 = highFreqColor_1;
                            let _e174 = _e173.xyz;
                            let _e176 = highFreqColor_1;
                            let _e178 = fog;
                            let _e185 = mergeColor(_e172, vec4<f32>(_e174.x, _e174.y, _e174.z, min(1f, (_e176.w * _e178))));
                            col = _e185;
                        }
                    }
                }
            }
        }
    }
    let _e186 = col;
    return _e186;
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
    let _e71 = global.U[7];
    let _e76 = global.U[8];
    let _e79 = global.U[9];
    let _e82 = global.U[10];
    let _e85 = global.U[11];
    let _e109 = global.U[12];
    let _e112 = global.U[4];
    let _e114 = perspective((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e9.x, _e9.y, _e9.z), vec3<f32>(_e13.x, _e13.y, _e13.z), vec3<f32>(_e17.x, _e17.y, _e17.z))) * vec3<f32>(_e44.x, _e44.y, 1f)).xy, (((_e51 - vec2(0.5f)) * 2f) * vec2<f32>(_e59.x, 1f)), i32(_e66.x), i32(_e71.x), mat4x4<f32>(vec4<f32>(_e76.x, _e76.y, _e76.z, _e76.w), vec4<f32>(_e79.x, _e79.y, _e79.z, _e79.w), vec4<f32>(_e82.x, _e82.y, _e82.z, _e82.w), vec4<f32>(_e85.x, _e85.y, _e85.z, _e85.w)), _e109, _e112.xy);
    fragColor = _e114;
    return;
}

@fragment 
fn main(@location(0) v_uv: vec2<f32>) -> FragmentOutput {
    v_uv_1 = v_uv;
    main_1();
    let _e13 = fragColor;
    return FragmentOutput(_e13);
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
