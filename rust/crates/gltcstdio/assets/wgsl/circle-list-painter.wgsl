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
var t_source: texture_2d<f32>;
@group(0) @binding(3) 
var t_source2_: texture_2d<f32>;
@group(0) @binding(4) 
var t_source3_: texture_2d<f32>;

fn _mirror_wrap(c: vec2<f32>) -> vec2<f32> {
    var c_1: vec2<f32>;

    c_1 = c;
    let _e11 = c_1;
    let _e13 = vec2(2f);
    return (vec2(1f) - abs(((_e11 - (floor((_e11 / _e13)) * _e13)) - vec2(1f))));
}

fn mergeColor(bkg: vec4<f32>, front: vec4<f32>) -> vec4<f32> {
    var bkg_1: vec4<f32>;
    var front_1: vec4<f32>;

    bkg_1 = bkg;
    front_1 = front;
    let _e12 = bkg_1;
    let _e14 = front_1;
    let _e16 = front_1;
    let _e19 = bkg_1;
    let _e23 = front_1;
    let _e29 = mix(_e12.xyz, _e14.xyz, vec3((_e16.w + ((1f - _e19.w) * (1f - _e23.w)))));
    let _e30 = bkg_1;
    let _e32 = front_1;
    return vec4<f32>(_e29.x, _e29.y, _e29.z, max(_e30.w, _e32.w));
}

fn circleListPainter(pos: vec2<f32>, outPos: vec2<f32>, sourceDim: vec2<f32>, source2Dim: vec2<f32>, outDim: vec2<f32>, count: i32, padding: f32, thickness: f32, borderColor: vec4<f32>, source3_specified: i32) -> vec4<f32> {
    var pos_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var sourceDim_1: vec2<f32>;
    var source2Dim_1: vec2<f32>;
    var outDim_1: vec2<f32>;
    var count_1: i32;
    var padding_1: f32;
    var thickness_1: f32;
    var borderColor_1: vec4<f32>;
    var source3_specified_1: i32;
    var ar: f32;
    var pixel: f32;
    var maxLen: f32;
    var gridSize: f32;
    var sizePix: vec4<f32>;
    var gridWidth: f32;
    var gridHeight: f32;
    var cell: vec2<f32>;
    var y: i32;
    var xx: i32 = 0i;
    var stop: bool = false;
    var local: vec4<f32>;
    var bkgCol: vec4<f32>;
    var color: vec4<f32>;
    var bestCircle: vec3<f32> = vec3<f32>(0f, 0f, -1f);
    var first: vec4<f32>;
    var second: vec4<f32>;
    var x: f32;
    var y_1: f32;
    var r: f32;
    var center: vec2<f32>;
    var delta: vec2<f32>;
    var trueRadius: f32;
    var innerBorderRadius: f32;
    var center_1: vec2<f32>;
    var d: f32;
    var aar: f32;
    var k: f32;
    var kb: f32;
    var centerCol: vec4<f32>;
    var circleCol: vec4<f32>;
    var borderColor_2: vec4<f32>;

    pos_1 = pos;
    outPos_1 = outPos;
    sourceDim_1 = sourceDim;
    source2Dim_1 = source2Dim;
    outDim_1 = outDim;
    count_1 = count;
    padding_1 = padding;
    thickness_1 = thickness;
    borderColor_1 = borderColor;
    source3_specified_1 = source3_specified;
    let _e28 = sourceDim_1;
    let _e30 = sourceDim_1;
    ar = (_e28.x / _e30.y);
    let _e35 = outDim_1;
    pixel = (2f / _e35.y);
    let _e40 = ar;
    maxLen = max(1f, _e40);
    let _e43 = maxLen;
    gridSize = (_e43 / 8f);
    let _e51 = textureLoad(t_source2_, vec2<i32>(0i, 0i), 0i);
    sizePix = (_e51 * 255f);
    let _e55 = sizePix;
    gridWidth = round(_e55.y);
    let _e59 = sizePix;
    gridHeight = round(_e59.z);
    let _e63 = pos_1;
    let _e65 = gridSize;
    let _e68 = pos_1;
    let _e70 = gridSize;
    cell = vec2<f32>(floor((_e63.x / _e65)), floor((_e68.y / _e70)));
    let _e75 = cell;
    let _e77 = gridWidth;
    let _e81 = cell;
    let _e83 = gridHeight;
    let _e87 = gridWidth;
    y = (i32(((_e75.x + (_e77 / 2f)) + ((_e81.y + (_e83 / 2f)) * _e87))) + 1i);
    let _e98 = source3_specified_1;
    if (_e98 == 1i) {
        let _e101 = pos_1;
        let _e105 = global.U[0];
        let _e108 = pos_1;
        let _e117 = _mirror_wrap(((vec2<f32>((_e101.x / _e105.x), _e108.y) / vec2(2f)) + vec2(0.5f)));
        let _e118 = textureSample(t_source3_, samp, _e117);
        local = _e118;
    } else {
        local = vec4<f32>(0f, 0f, 0f, 1f);
    }
    let _e125 = local;
    bkgCol = _e125;
    let _e127 = bkgCol;
    color = _e127;
    loop {
        let _e135 = stop;
        let _e137 = xx;
        if !((!(_e135) && (_e137 < 400i))) {
            break;
        }
        {
            let _e142 = xx;
            let _e145 = y;
            let _e148 = textureLoad(t_source2_, vec2<i32>((_e142 * 2i), _e145), 0i);
            first = (_e148 * 255f);
            let _e152 = xx;
            let _e157 = y;
            let _e160 = textureLoad(t_source2_, vec2<i32>(((_e152 * 2i) + 1i), _e157), 0i);
            second = (_e160 * 255f);
            let _e164 = first;
            stop = (_e164.w == 0f);
            let _e168 = stop;
            if !(_e168) {
                {
                    let _e170 = xx;
                    xx = (_e170 + 1i);
                    let _e173 = first;
                    let _e178 = first;
                    x = ((round(_e173.x) * 256f) + _e178.y);
                    let _e182 = x;
                    if (_e182 >= 32768f) {
                        let _e185 = x;
                        x = (_e185 - 65536f);
                    }
                    let _e188 = x;
                    x = (_e188 / 32768f);
                    let _e191 = first;
                    let _e196 = second;
                    y_1 = ((round(_e191.z) * 256f) + _e196.x);
                    let _e200 = y_1;
                    if (_e200 >= 32768f) {
                        let _e203 = y_1;
                        y_1 = (_e203 - 65536f);
                    }
                    let _e206 = y_1;
                    y_1 = (_e206 / 32768f);
                    let _e209 = second;
                    let _e214 = second;
                    r = ((round(_e209.y) * 256f) + _e214.z);
                    let _e218 = r;
                    if (_e218 >= 32768f) {
                        let _e221 = r;
                        r = (_e221 - 65536f);
                    }
                    let _e224 = r;
                    r = (_e224 / 32768f);
                    let _e227 = x;
                    let _e228 = y_1;
                    center = vec2<f32>(_e227, _e228);
                    let _e231 = ar;
                    if (_e231 > 1f) {
                        {
                            let _e234 = center;
                            let _e235 = ar;
                            center = (_e234 * _e235);
                            let _e237 = r;
                            let _e238 = ar;
                            r = (_e237 * _e238);
                        }
                    }
                    let _e240 = pos_1;
                    let _e241 = center;
                    delta = (_e240 - _e241);
                    let _e244 = delta;
                    let _e245 = delta;
                    let _e247 = r;
                    let _e248 = r;
                    if (dot(_e244, _e245) < (_e247 * _e248)) {
                        {
                            let _e251 = center;
                            let _e253 = center;
                            let _e255 = r;
                            bestCircle = vec3<f32>(_e251.x, _e253.y, _e255);
                        }
                    }
                }
            }
        }
    }
    let _e257 = bestCircle;
    if (_e257.z > 0f) {
        {
            let _e262 = padding_1;
            let _e264 = bestCircle;
            trueRadius = ((1f - _e262) * _e264.z);
            let _e269 = thickness_1;
            let _e271 = trueRadius;
            innerBorderRadius = ((1f - _e269) * _e271);
            let _e274 = bestCircle;
            center_1 = _e274.xy;
            let _e277 = pos_1;
            let _e278 = center_1;
            d = length((_e277 - _e278));
            let _e282 = pixel;
            aar = (_e282 * 0.5f);
            let _e286 = trueRadius;
            let _e287 = aar;
            let _e289 = trueRadius;
            let _e290 = aar;
            let _e292 = d;
            k = smoothstep((_e286 + _e287), (_e289 - _e290), _e292);
            let _e295 = k;
            if (_e295 == 0f) {
                let _e298 = bkgCol;
                return _e298;
            }
            let _e299 = innerBorderRadius;
            let _e300 = aar;
            let _e302 = innerBorderRadius;
            let _e303 = aar;
            let _e305 = d;
            kb = smoothstep((_e299 + _e300), (_e302 - _e303), _e305);
            let _e308 = center_1;
            let _e312 = global.U[0];
            let _e315 = center_1;
            let _e324 = textureSample(t_source, samp, ((vec2<f32>((_e308.x / _e312.x), _e315.y) / vec2(2f)) + vec2(0.5f)));
            centerCol = _e324;
            let _e326 = centerCol;
            circleCol = _e326;
            let _e328 = kb;
            if (_e328 < 1f) {
                {
                    let _e331 = centerCol;
                    let _e332 = borderColor_1;
                    let _e333 = mergeColor(_e331, _e332);
                    borderColor_2 = _e333;
                    let _e335 = borderColor_2;
                    let _e336 = centerCol;
                    let _e337 = kb;
                    circleCol = mix(_e335, _e336, vec4(_e337));
                }
            }
            let _e340 = bkgCol;
            let _e341 = circleCol;
            let _e342 = k;
            return mix(_e340, _e341, vec4(_e342));
        }
    } else {
        {
            let _e345 = bkgCol;
            return _e345;
        }
    }
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
    let _e68 = global.U[4];
    let _e72 = global.U[5];
    let _e76 = global.U[6];
    let _e80 = global.U[8];
    let _e85 = global.U[9];
    let _e89 = global.U[10];
    let _e93 = global.U[11];
    let _e96 = global.U[7];
    let _e99 = circleListPainter((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e11.x, _e11.y, _e11.z), vec3<f32>(_e15.x, _e15.y, _e15.z), vec3<f32>(_e19.x, _e19.y, _e19.z))) * vec3<f32>(_e46.x, _e46.y, 1f)).xy, (((_e53 - vec2(0.5f)) * 2f) * vec2<f32>(_e61.x, 1f)), _e68.xy, _e72.xy, _e76.xy, i32(_e80.x), _e85.x, _e89.x, _e93, i32(_e96.x));
    fragColor = _e99;
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
