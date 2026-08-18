struct Params {
    U: array<vec4<f32>, 7>,
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

fn seamless(uv: vec2<f32>, outPos: vec2<f32>, sourceDim: vec2<f32>, blend: f32) -> vec4<f32> {
    var uv_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var sourceDim_1: vec2<f32>;
    var blend_1: f32;
    var inRatio: f32;
    var margin: f32;
    var halfMargin: f32;
    var outRatio: f32;
    var outToInScale: f32;
    var u: vec2<f32>;
    var u2_: vec2<f32>;
    var k: vec2<f32> = vec2(1f);
    var lim: vec2<f32>;
    var mlim: vec2<f32>;

    uv_1 = uv;
    outPos_1 = outPos;
    sourceDim_1 = sourceDim;
    blend_1 = blend;
    let _e14 = sourceDim_1;
    let _e16 = sourceDim_1;
    inRatio = (_e14.x / _e16.y);
    let _e20 = blend_1;
    let _e21 = inRatio;
    margin = (_e20 * min(_e21, 1f));
    let _e26 = margin;
    halfMargin = (_e26 * 0.5f);
    let _e31 = inRatio;
    let _e33 = margin;
    let _e36 = margin;
    outRatio = (((2f * _e31) - _e33) / (2f - _e36));
    let _e41 = margin;
    outToInScale = ((2f - _e41) / 2f);
    let _e46 = uv_1;
    let _e47 = outToInScale;
    u = (_e46 * _e47);
    let _e50 = u;
    u2_ = _e50;
    let _e55 = inRatio;
    let _e58 = halfMargin;
    lim = (vec2<f32>(_e55, 1f) - vec2(_e58));
    let _e62 = inRatio;
    let _e65 = margin;
    mlim = (vec2<f32>(_e62, 1f) - vec2(_e65));
    let _e69 = u;
    let _e71 = mlim;
    if (_e69.x < -(_e71.x)) {
        {
            let _e76 = lim;
            let _e78 = u;
            let _e80 = lim;
            u2_.x = (_e76.x + (_e78.x + _e80.x));
            let _e86 = mlim;
            let _e89 = u;
            let _e92 = margin;
            k.x = (1f - ((-(_e86.x) - _e89.x) / _e92));
        }
    } else {
        let _e95 = u;
        let _e97 = mlim;
        if (_e95.x > _e97.x) {
            {
                let _e101 = inRatio;
                let _e103 = u;
                let _e105 = mlim;
                u2_.x = (-(_e101) + (_e103.x - _e105.x));
                let _e111 = u;
                let _e113 = mlim;
                let _e116 = margin;
                k.x = (1f - ((_e111.x - _e113.x) / _e116));
            }
        }
    }
    let _e119 = u;
    let _e121 = mlim;
    if (_e119.y < -(_e121.y)) {
        {
            let _e126 = lim;
            let _e128 = u;
            let _e130 = lim;
            u2_.y = (_e126.y + (_e128.y + _e130.y));
            let _e136 = mlim;
            let _e139 = u;
            let _e142 = margin;
            k.y = (1f - ((-(_e136.y) - _e139.y) / _e142));
        }
    } else {
        let _e145 = u;
        let _e147 = mlim;
        if (_e145.y > _e147.y) {
            {
                let _e153 = u;
                let _e155 = mlim;
                u2_.y = (-1f + (_e153.y - _e155.y));
                let _e161 = u;
                let _e163 = mlim;
                let _e166 = margin;
                k.y = (1f - ((_e161.y - _e163.y) / _e166));
            }
        }
    }
    let _e169 = k;
    let _e173 = k;
    if ((_e169.x != 1f) || (_e173.y != 1f)) {
        {
            let _e178 = u2_;
            let _e180 = u2_;
            let _e186 = global.U[0];
            let _e189 = u2_;
            let _e191 = u2_;
            let _e203 = textureSampleLevel(t_source, samp, ((vec2<f32>((vec2<f32>(_e178.x, _e180.y).x / _e186.x), vec2<f32>(_e189.x, _e191.y).y) / vec2(2f)) + vec2(0.5f)), 0f);
            let _e204 = u;
            let _e206 = u2_;
            let _e212 = global.U[0];
            let _e215 = u;
            let _e217 = u2_;
            let _e229 = textureSampleLevel(t_source, samp, ((vec2<f32>((vec2<f32>(_e204.x, _e206.y).x / _e212.x), vec2<f32>(_e215.x, _e217.y).y) / vec2(2f)) + vec2(0.5f)), 0f);
            let _e230 = k;
            let _e234 = u2_;
            let _e236 = u;
            let _e242 = global.U[0];
            let _e245 = u2_;
            let _e247 = u;
            let _e259 = textureSampleLevel(t_source, samp, ((vec2<f32>((vec2<f32>(_e234.x, _e236.y).x / _e242.x), vec2<f32>(_e245.x, _e247.y).y) / vec2(2f)) + vec2(0.5f)), 0f);
            let _e260 = u;
            let _e264 = global.U[0];
            let _e267 = u;
            let _e277 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e260.x / _e264.x), _e267.y) / vec2(2f)) + vec2(0.5f)), 0f);
            let _e278 = k;
            let _e282 = k;
            return mix(mix(_e203, _e229, vec4(_e230.x)), mix(_e259, _e277, vec4(_e278.x)), vec4(_e282.y));
        }
    } else {
        {
            let _e286 = u;
            let _e290 = global.U[0];
            let _e293 = u;
            let _e303 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e286.x / _e290.x), _e293.y) / vec2(2f)) + vec2(0.5f)), 0f);
            return _e303;
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
    let _e66 = global.U[4];
    let _e70 = global.U[6];
    let _e72 = seamless((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e9.x, _e9.y, _e9.z), vec3<f32>(_e13.x, _e13.y, _e13.z), vec3<f32>(_e17.x, _e17.y, _e17.z))) * vec3<f32>(_e44.x, _e44.y, 1f)).xy, (((_e51 - vec2(0.5f)) * 2f) * vec2<f32>(_e59.x, 1f)), _e66.xy, _e70.x);
    fragColor = _e72;
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
