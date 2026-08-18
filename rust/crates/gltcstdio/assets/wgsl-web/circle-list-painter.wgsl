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
        let _e119 = textureSampleLevel(t_source3_, samp, _e117, 0f);
        local = _e119;
    } else {
        local = vec4<f32>(0f, 0f, 0f, 1f);
    }
    let _e126 = local;
    bkgCol = _e126;
    let _e128 = bkgCol;
    color = _e128;
    loop {
        let _e136 = stop;
        let _e138 = xx;
        if !((!(_e136) && (_e138 < 400i))) {
            break;
        }
        {
            let _e143 = xx;
            let _e146 = y;
            let _e149 = textureLoad(t_source2_, vec2<i32>((_e143 * 2i), _e146), 0i);
            first = (_e149 * 255f);
            let _e153 = xx;
            let _e158 = y;
            let _e161 = textureLoad(t_source2_, vec2<i32>(((_e153 * 2i) + 1i), _e158), 0i);
            second = (_e161 * 255f);
            let _e165 = first;
            stop = (_e165.w == 0f);
            let _e169 = stop;
            if !(_e169) {
                {
                    let _e171 = xx;
                    xx = (_e171 + 1i);
                    let _e174 = first;
                    let _e179 = first;
                    x = ((round(_e174.x) * 256f) + _e179.y);
                    let _e183 = x;
                    if (_e183 >= 32768f) {
                        let _e186 = x;
                        x = (_e186 - 65536f);
                    }
                    let _e189 = x;
                    x = (_e189 / 32768f);
                    let _e192 = first;
                    let _e197 = second;
                    y_1 = ((round(_e192.z) * 256f) + _e197.x);
                    let _e201 = y_1;
                    if (_e201 >= 32768f) {
                        let _e204 = y_1;
                        y_1 = (_e204 - 65536f);
                    }
                    let _e207 = y_1;
                    y_1 = (_e207 / 32768f);
                    let _e210 = second;
                    let _e215 = second;
                    r = ((round(_e210.y) * 256f) + _e215.z);
                    let _e219 = r;
                    if (_e219 >= 32768f) {
                        let _e222 = r;
                        r = (_e222 - 65536f);
                    }
                    let _e225 = r;
                    r = (_e225 / 32768f);
                    let _e228 = x;
                    let _e229 = y_1;
                    center = vec2<f32>(_e228, _e229);
                    let _e232 = ar;
                    if (_e232 > 1f) {
                        {
                            let _e235 = center;
                            let _e236 = ar;
                            center = (_e235 * _e236);
                            let _e238 = r;
                            let _e239 = ar;
                            r = (_e238 * _e239);
                        }
                    }
                    let _e241 = pos_1;
                    let _e242 = center;
                    delta = (_e241 - _e242);
                    let _e245 = delta;
                    let _e246 = delta;
                    let _e248 = r;
                    let _e249 = r;
                    if (dot(_e245, _e246) < (_e248 * _e249)) {
                        {
                            let _e252 = center;
                            let _e254 = center;
                            let _e256 = r;
                            bestCircle = vec3<f32>(_e252.x, _e254.y, _e256);
                        }
                    }
                }
            }
        }
    }
    let _e258 = bestCircle;
    if (_e258.z > 0f) {
        {
            let _e263 = padding_1;
            let _e265 = bestCircle;
            trueRadius = ((1f - _e263) * _e265.z);
            let _e270 = thickness_1;
            let _e272 = trueRadius;
            innerBorderRadius = ((1f - _e270) * _e272);
            let _e275 = bestCircle;
            center_1 = _e275.xy;
            let _e278 = pos_1;
            let _e279 = center_1;
            d = length((_e278 - _e279));
            let _e283 = pixel;
            aar = (_e283 * 0.5f);
            let _e287 = trueRadius;
            let _e288 = aar;
            let _e290 = trueRadius;
            let _e291 = aar;
            let _e293 = d;
            k = smoothstep((_e287 + _e288), (_e290 - _e291), _e293);
            let _e296 = k;
            if (_e296 == 0f) {
                let _e299 = bkgCol;
                return _e299;
            }
            let _e300 = innerBorderRadius;
            let _e301 = aar;
            let _e303 = innerBorderRadius;
            let _e304 = aar;
            let _e306 = d;
            kb = smoothstep((_e300 + _e301), (_e303 - _e304), _e306);
            let _e309 = center_1;
            let _e313 = global.U[0];
            let _e316 = center_1;
            let _e326 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e309.x / _e313.x), _e316.y) / vec2(2f)) + vec2(0.5f)), 0f);
            centerCol = _e326;
            let _e328 = centerCol;
            circleCol = _e328;
            let _e330 = kb;
            if (_e330 < 1f) {
                {
                    let _e333 = centerCol;
                    let _e334 = borderColor_1;
                    let _e335 = mergeColor(_e333, _e334);
                    borderColor_2 = _e335;
                    let _e337 = borderColor_2;
                    let _e338 = centerCol;
                    let _e339 = kb;
                    circleCol = mix(_e337, _e338, vec4(_e339));
                }
            }
            let _e342 = bkgCol;
            let _e343 = circleCol;
            let _e344 = k;
            return mix(_e342, _e343, vec4(_e344));
        }
    } else {
        {
            let _e347 = bkgCol;
            return _e347;
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
