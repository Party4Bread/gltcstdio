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
var t_ditheringPattern: texture_2d<f32>;
@group(0) @binding(3) 
var t_palette: texture_2d<f32>;
@group(0) @binding(4) 
var t_source: texture_2d<f32>;

fn _mirror_wrap(c: vec2<f32>) -> vec2<f32> {
    var c_1: vec2<f32>;

    c_1 = c;
    let _e11 = c_1;
    let _e13 = vec2(2f);
    return (vec2(1f) - abs(((_e11 - (floor((_e11 / _e13)) * _e13)) - vec2(1f))));
}

fn pixelate(uv: vec2<f32>, outPos: vec2<f32>, modelTransform: mat3x3<f32>, dithering: f32, paletteDim: vec2<f32>, ditheringPatternDim: vec2<f32>, pixelAspectRatio: f32) -> vec4<f32> {
    var uv_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var modelTransform_1: mat3x3<f32>;
    var dithering_1: f32;
    var paletteDim_1: vec2<f32>;
    var ditheringPatternDim_1: vec2<f32>;
    var pixelAspectRatio_1: f32;
    var u: vec2<f32>;
    var local: vec2<f32>;
    var pixDim: vec2<f32>;
    var iPos: vec2<f32>;
    var pix: vec2<f32>;
    var v: vec2<f32>;
    var col: vec4<f32>;
    var dPos: vec2<i32>;
    var patternCol: vec4<f32>;
    var n: i32;
    var minDist: f32 = 1000000000f;
    var bestColor: vec4<f32>;
    var i: i32 = 0i;
    var target_: vec4<f32>;
    var dist: f32;

    uv_1 = uv;
    outPos_1 = outPos;
    modelTransform_1 = modelTransform;
    dithering_1 = dithering;
    paletteDim_1 = paletteDim;
    ditheringPatternDim_1 = ditheringPatternDim;
    pixelAspectRatio_1 = pixelAspectRatio;
    let _e22 = modelTransform_1;
    let _e24 = uv_1;
    u = (_naga_inverse_3x3_f32(_e22) * vec3<f32>(_e24.x, _e24.y, 1f)).xy;
    let _e32 = pixelAspectRatio_1;
    if (_e32 >= 1f) {
        let _e35 = pixelAspectRatio_1;
        local = vec2<f32>(_e35, 1f);
    } else {
        let _e40 = pixelAspectRatio_1;
        local = vec2<f32>(1f, (1f / _e40));
    }
    let _e44 = local;
    pixDim = _e44;
    let _e46 = u;
    let _e47 = pixDim;
    iPos = round((_e46 / _e47));
    let _e51 = iPos;
    let _e52 = pixDim;
    pix = (_e51 * _e52);
    let _e55 = modelTransform_1;
    let _e56 = pix;
    let _e57 = _e56.xy;
    v = (_e55 * vec3<f32>(_e57.x, _e57.y, 1f)).xy;
    let _e65 = v;
    let _e69 = global.U[0];
    let _e72 = v;
    let _e81 = _mirror_wrap(((vec2<f32>((_e65.x / _e69.x), _e72.y) / vec2(2f)) + vec2(0.5f)));
    let _e82 = textureSample(t_source, samp, _e81);
    col = _e82;
    let _e84 = dithering_1;
    if (_e84 != 0f) {
        {
            let _e87 = iPos;
            let _e89 = ditheringPatternDim_1;
            let _e96 = iPos;
            let _e98 = ditheringPatternDim_1;
            dPos = vec2<i32>(i32((_e87.x - (floor((_e87.x / _e89.x)) * _e89.x))), i32((_e96.y - (floor((_e96.y / _e98.y)) * _e98.y))));
            let _e107 = dPos;
            let _e109 = textureLoad(t_ditheringPattern, _e107, 0i);
            patternCol = _e109;
            let _e111 = col;
            let _e113 = col;
            let _e115 = dithering_1;
            let _e116 = patternCol;
            let _e122 = (_e113.xyz + (_e115 * (_e116.xyz - vec3(0.5f))));
            col.x = _e122.x;
            col.y = _e122.y;
            col.z = _e122.z;
        }
    }
    let _e129 = paletteDim_1;
    n = i32(_e129.x);
    let _e135 = col;
    bestColor = _e135;
    loop {
        let _e139 = i;
        let _e140 = n;
        if !((_e139 < _e140)) {
            break;
        }
        {
            let _e146 = i;
            let _e150 = textureLoad(t_palette, vec2<i32>(_e146, 0i), 0i);
            target_ = _e150;
            let _e152 = col;
            let _e153 = target_;
            dist = length((_e152 - _e153).xyz);
            let _e158 = dist;
            let _e159 = minDist;
            if (_e158 < _e159) {
                {
                    let _e161 = dist;
                    minDist = _e161;
                    let _e162 = target_;
                    bestColor = _e162;
                }
            }
        }
        continuing {
            let _e143 = i;
            i = (_e143 + 1i);
        }
    }
    let _e163 = bestColor;
    return _e163;
}

fn main_1() {
    let _e10 = global.U[1];
    let _e11 = _e10.xyz;
    let _e14 = global.U[2];
    let _e15 = _e14.xyz;
    let _e18 = global.U[3];
    let _e19 = _e18.xyz;
    let _e34 = v_uv_1;
    let _e42 = global.U[0];
    let _e46 = (((_e34 - vec2(0.5f)) * 2f) * vec2<f32>(_e42.x, 1f));
    let _e53 = v_uv_1;
    let _e61 = global.U[0];
    let _e68 = global.U[8];
    let _e69 = _e68.xyz;
    let _e72 = global.U[9];
    let _e73 = _e72.xyz;
    let _e76 = global.U[10];
    let _e77 = _e76.xyz;
    let _e93 = global.U[11];
    let _e97 = global.U[4];
    let _e101 = global.U[5];
    let _e105 = global.U[6];
    let _e107 = pixelate((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e11.x, _e11.y, _e11.z), vec3<f32>(_e15.x, _e15.y, _e15.z), vec3<f32>(_e19.x, _e19.y, _e19.z))) * vec3<f32>(_e46.x, _e46.y, 1f)).xy, (((_e53 - vec2(0.5f)) * 2f) * vec2<f32>(_e61.x, 1f)), mat3x3<f32>(vec3<f32>(_e69.x, _e69.y, _e69.z), vec3<f32>(_e73.x, _e73.y, _e73.z), vec3<f32>(_e77.x, _e77.y, _e77.z)), _e93.x, _e97.xy, _e101.xy, _e105.x);
    fragColor = _e107;
    return;
}

@fragment 
fn main(@location(0) v_uv: vec2<f32>) -> FragmentOutput {
    v_uv_1 = v_uv;
    main_1();
    let _e17 = fragColor;
    return FragmentOutput(_e17);
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
