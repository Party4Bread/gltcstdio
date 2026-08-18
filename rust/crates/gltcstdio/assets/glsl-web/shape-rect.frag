#version 450
layout(location = 0) in vec2 v_uv;
layout(location = 0) out vec4 fragColor;

layout(binding = 0, std140) uniform Params {
    vec4 U[30];
};
layout(binding = 1) uniform sampler samp;
layout(binding = 2) uniform texture2D t_insideImage;
layout(binding = 3) uniform texture2D t_source;

#define u_insideImage sampler2D(t_insideImage, samp)
#define u_source sampler2D(t_source, samp)
#define u_worldAspect (U[0].x)
#define u_viewTransform (mat3(U[1].xyz, U[2].xyz, U[3].xyz))
#define u_insideImage_specified (int(U[4].x))
#define u_outDim (U[5].xy)
#define u_shapeAspectRatio (U[6].x)
#define u_shadows (U[7].x)
#define u_roundness (U[8].x)
#define u_multiplier (U[9].x)
#define u_colorOutline (U[10])
#define u_outlineThickness (U[11].x)
#define u_brightness (U[12].x)
#define u_contrast (U[13].x)
#define u_saturation (U[14].x)
#define u_hue (U[15].x)
#define u_colorIn (U[16])
#define u_colorOut (U[17])
#define u_colorShadow (U[18])
#define u_colorGlow (U[19])
#define u_insideLock (int(U[20].x))
#define u_modelTransform (mat3(U[21].xyz, U[22].xyz, U[23].xyz))
#define u_insideTransform (mat3(U[24].xyz, U[25].xyz, U[26].xyz))
#define u_shadowTransform (mat3(U[27].xyz, U[28].xyz, U[29].xyz))

#define __insideImage__texelFetch__(c) texelFetch(u_insideImage, (c), 0)
#define __insideImage__(p) textureLod(u_insideImage, __mirror_wrap__(vec2((p).x / u_worldAspect, (p).y) / 2.0 + 0.5), 0.0)
#define __source__texelFetch__(c) texelFetch(u_source, (c), 0)
#define __source__(p) textureLod(u_source, __mirror_wrap__(vec2((p).x / u_worldAspect, (p).y) / 2.0 + 0.5), 0.0)




// gltcstdio GLSL support library.
// Every function below was verified to compile against GL 3.3.
// Prototypes precede bodies so intra-library call order is irrelevant.

#define INF 1e20
#define PI 3.141592653589793
#define PI2 6.283185307179586
#define PI4 12.566370614359172
#define PI_2 1.5707963267948966
#define PI_3 1.0471975511965976
#define PI2_3 2.0943951023931953
#define SQRT3 1.7320508075688772
#define SQRT3_2 0.8660254037844386
#define SQRT3_6 0.288675134594813
#define SQRT2 1.4142135623730951
#define SQRT2_2 0.7071067811865476
#define THIRD 0.33333333333
#define TWO_THIRDS 0.666666666667

struct HexTile {
    vec2 center;
    vec2 pos;
    float angle;    
    float centerDist;
    float borderDist;
};
struct CairoTile {
    vec2 center;
    float borderDist;
};
struct TriangleTile {
    bool up;
    vec2 center;
    vec2 pos;
    float angle;    
    float centerDist;
    float borderDist;
};
struct Tile {
    float centerDist;
    vec2 tileId;
    float borderDist;
    vec2 center;
    vec2 borderNormal;
    float secondCenterDist;
    vec2 secondTileId;    
    float thirdCenterDist;
};

// ---- prototypes ----










































































































































































































// ---- bodies ----



















        























































































// allow vec4's












































































































































































































































































































































            


vec2 __mirror_wrap__(vec2 c) {
    return 1.0 - abs(mod(c, 2.0) - 1.0);
}

vec3 hsluv_lengthOfRayUntilIntersect(float theta, vec3 x, vec3 y) {
    vec3 len = y / (sin(theta) - x * cos(theta));
    if (len.r < 0.0) {len.r=1000.0;}
    if (len.g < 0.0) {len.g=1000.0;}
    if (len.b < 0.0) {len.b=1000.0;}
    return len;
}

float hsluv_maxChromaForLH(float L, float H) {

    float hrad = radians(H);

    mat3 m2 = mat3(
         3.2409699419045214  ,-0.96924363628087983 , 0.055630079696993609,
        -1.5373831775700935  , 1.8759675015077207  ,-0.20397695888897657 ,
        -0.49861076029300328 , 0.041555057407175613, 1.0569715142428786  
    );
    float sub1 = pow(L + 16.0, 3.0) / 1560896.0;
    float sub2 = sub1 > 0.0088564516790356308 ? sub1 : L / 903.2962962962963;

    vec3 top1   = (284517.0 * m2[0] - 94839.0  * m2[2]) * sub2;
    vec3 bottom = (632260.0 * m2[2] - 126452.0 * m2[1]) * sub2;
    vec3 top2   = (838422.0 * m2[2] + 769860.0 * m2[1] + 731718.0 * m2[0]) * L * sub2;

    vec3 bound0x = top1 / bottom;
    vec3 bound0y = top2 / bottom;

    vec3 bound1x =              top1 / (bottom+126452.0);
    vec3 bound1y = (top2-769860.0*L) / (bottom+126452.0);

    vec3 lengths0 = hsluv_lengthOfRayUntilIntersect(hrad, bound0x, bound0y );
    vec3 lengths1 = hsluv_lengthOfRayUntilIntersect(hrad, bound1x, bound1y );

    return  min(lengths0.r,
            min(lengths1.r,
            min(lengths0.g,
            min(lengths1.g,
            min(lengths0.b,
                lengths1.b)))));
}

vec3 hsluvToLch(vec3 tuple) {
    tuple.g *= hsluv_maxChromaForLH(tuple.b, tuple.r) * .01;
    return tuple.bgr;
}

vec3 lchToLuv(vec3 tuple) {
    float hrad = radians(tuple.b);
    return vec3(
        tuple.r,
        cos(hrad) * tuple.g,
        sin(hrad) * tuple.g
    );
}

float hsluv_lToY(float L) {
    return L <= 8.0 ? L / 903.2962962962963 : pow((L + 16.0) / 116.0, 3.0);
}

vec3 luvToXyz(vec3 tuple) {
    float L = tuple.x;

    float U = tuple.y / (13.0 * L) + 0.19783000664283681;
    float V = tuple.z / (13.0 * L) + 0.468319994938791;

    float Y = hsluv_lToY(L);
    float X = 2.25 * U * Y / V;
    float Z = (3./V - 5.)*Y - (X/3.);

    return vec3(X, Y, Z);
}

float hsluv_fromLinear1(float c) {
    return c <= 0.0031308 ? 12.92 * c : 1.055 * pow(c, 1.0 / 2.4) - 0.055;
}

vec3 hsluv_fromLinear(vec3 c) {
    return vec3( hsluv_fromLinear1(c.r), hsluv_fromLinear1(c.g), hsluv_fromLinear1(c.b) );
}

vec3 xyzToRgb(vec3 tuple) {
    const mat3 m = mat3( 
        3.2409699419045214  ,-1.5373831775700935 ,-0.49861076029300328 ,
       -0.96924363628087983 , 1.8759675015077207 , 0.041555057407175613,
        0.055630079696993609,-0.20397695888897657, 1.0569715142428786  );
    
    return hsluv_fromLinear(tuple*m);
}

vec3 lchToRgb(vec3 tuple) {
    return xyzToRgb(luvToXyz(lchToLuv(tuple)));
}

vec3 hsluvToRgb(vec3 tuple) {
    return lchToRgb(hsluvToLch(tuple));
}

vec3 lchToHsluv(vec3 tuple) {
    tuple.g /= hsluv_maxChromaForLH(tuple.r, tuple.b) * .01;
    return tuple.bgr;
}

vec3 luvToLch(vec3 tuple) {
    float L = tuple.x;
    float U = tuple.y;
    float V = tuple.z;

    float C = length(tuple.yz);
    float H = degrees(atan(V,U));
    if (H < 0.0) {
        H = 360.0 + H;
    }
    
    return vec3(L, C, H);
}

float hsluv_toLinear1(float c) {
    return c > 0.04045 ? pow((c + 0.055) / (1.0 + 0.055), 2.4) : c / 12.92;
}

vec3 hsluv_toLinear(vec3 c) {
    return vec3( hsluv_toLinear1(c.r), hsluv_toLinear1(c.g), hsluv_toLinear1(c.b) );
}

vec3 rgbToXyz(vec3 tuple) {
    const mat3 m = mat3(
        0.41239079926595948 , 0.35758433938387796, 0.18048078840183429 ,
        0.21263900587151036 , 0.71516867876775593, 0.072192315360733715,
        0.019330818715591851, 0.11919477979462599, 0.95053215224966058 
    );
    return hsluv_toLinear(tuple) * m;
}

float hsluv_yToL(float Y){
    return Y <= 0.0088564516790356308 ? Y * 903.2962962962963 : 116.0 * pow(Y, 1.0 / 3.0) - 16.0;
}

vec3 xyzToLuv(vec3 tuple){
    float X = tuple.x;
    float Y = tuple.y;
    float Z = tuple.z;

    float L = hsluv_yToL(Y);
    
    float div = 1./dot(tuple,vec3(1,15,3)); 

    return vec3(
        1.,
        (52. * (X*div) - 2.57179),
        (117.* (Y*div) - 6.08816)
    ) * L;
}

vec3 rgbToLch(vec3 tuple) {
    return luvToLch(xyzToLuv(rgbToXyz(tuple)));
}

vec3 rgbToHsluv(vec3 tuple) {
    return lchToHsluv(rgbToLch(tuple));
}

float hueToRgb(float p, float q, float h) {
    if (h < 0.0) h += 1.0;

    if (h > 1.0 ) h -= 1.0;

    if (6.0 * h < 1.0) {
        return p + ((q - p) * 6.0 * h);
    }

    if (2.0 * h < 1.0 ) {
        return  q;
    }

    if (3.0 * h < 2.0) {
        return p + ( (q - p) * 6.0 * ((2.0 / 3.0) - h) );
    }

    return p;
}

vec4 hslToRgb(vec4 inc) {
    //  Formula needs all values between 0 - 1.
    float h = mod(inc.r, 360.0);
    h /= 360.0;
    float s = inc.g;
    float l = inc.b;

    float q = 0.0;

    if (l < 0.5)
        q = l * (1.0 + s);
    else
        q = (l + s) - (s * l);

    float p = 2.0 * l - q;

    float r = max(0.0, hueToRgb(p, q, h + (1.0 / 3.0)));
    float g = max(0.0, hueToRgb(p, q, h));
    float b = max(0.0, hueToRgb(p, q, h - (1.0 / 3.0)));

    vec4 outc;
    outc.r = min(r, 1.0);
    outc.g = min(g, 1.0);
    outc.b = min(b, 1.0);
    outc.a = inc.a;

    return outc;
}

vec4 rgbToHcv(in vec4 RGB) {
    vec4 P = (RGB.g < RGB.b) ? vec4(RGB.bg, -1.0, 2.0/3.0) : vec4(RGB.gb, 0.0, -1.0/3.0);
    vec4 Q = (RGB.r < P.x) ? vec4(P.xyw, RGB.r) : vec4(RGB.r, P.yzx);
    float C = Q.x - min(Q.w, Q.y);
    float H = abs((Q.w - Q.y) / (6. * C + 1e-10) + Q.z);
    return vec4(H, C, Q.x, RGB.a);
}

vec4 rgbToHsl(in vec4 RGB) {
    vec4 HCV = rgbToHcv(RGB);
    float L = HCV.z - HCV.y * 0.5;
    float S = HCV.y / (1. - abs(L * 2. - 1.) + 1e-6);  // careful with the 1e-6 - used to be 1e-10 which caused errors because of low precision and we god NaNs. A test would be more clean but potentially slower.
    return vec4(HCV.x*360., S, L, RGB.a);
}

vec4 tintColor(vec4 col, vec4 tint) {
    vec3 colHsl = rgbToHsl(col).rgb;
    vec3 tintHsl = rgbToHsl(tint).rgb;
    float gamma = pow(5., 0.5-tintHsl.z);
    vec4 target = hslToRgb(vec4(tintHsl.xy, pow(colHsl.z, gamma), col.a));        
    return mix(col, target, tint.a);
}

vec4 adjustColorHSLuv(vec4 col, float brightness, float contrast, float luminosity, float gamma, float saturation, float hue, vec4 tint) {
        if (luminosity != 0.) {
            col.rgb += luminosity;
        }
        
        if (brightness != 0.) {
            col.rgb *= (1. + brightness);
        }
        
        if (gamma != 0.) {
            float p = pow(2., -gamma);
            col.r = pow(col.r, p);
            col.g = pow(col.g, p);
            col.b = pow(col.b, p);
        }
        
        if (contrast != 0.) {
            float c = abs(contrast)>1.0 ? sign(contrast) * pow(abs(contrast), 2.0) : contrast;
            col.rgb = (col.rgb - 0.5) * c + 0.5;
        }
        bool white = col.r == 1.0 && col.g == 1.0 && col.b == 1.0; // HSLuv conversion methods don't seem to play well when the color is white
        bool requireHsl = (saturation!=0.0 || hue!=0.0) && !white; 
        if (requireHsl) {
            vec3 hsl = rgbToHsluv(col.rgb);
//            hsl[1] = clamp(hsl[1]+saturation*100.0, 0., 100.);
            hsl[1] = clamp(hsl[1] * (1.0+saturation), 0., 100.);
            hsl[0] += hue;
            col.rgb = hsluvToRgb(hsl);
        }

        if (tint.a!=0.0) {
            col = tintColor(col, tint);
        }

        return col;
    }

vec2 dimFromShapeAspectRatio(float m, float ar) {
    return ar>1. ? vec2(m, m/ar) : vec2(m*ar, m);
}

vec4 mergeColor(vec4 bkg, vec4 front) {
    return vec4(mix(bkg.rgb, front.rgb, front.a + (1.0-bkg.a)*(1.0-front.a)), max(bkg.a, front.a));
}

vec4 mergeGlow(vec4 bkg, vec4 glow) {
    return vec4(bkg.rgb + glow.rgb*glow.a, bkg.a);
}

float sdRectangle(vec2 u, vec2 halfSize) {
    u = abs(u)-halfSize;
    return (u.x>=0. && u.y>=0.) ? length(u) : max(u.x, u.y);
}

vec2 tf(mat3 m, vec2 u) {
    return (m * vec3(u, 1.)).xy;
}

vec4 basicInterpolatedShapes(vec2 uv, vec2 outPos, int insideImage_specified, float shapeAspectRatio, 
        float shadows, float roundness, float multiplier,
        vec4 colorOutline, float outlineThickness,
        float brightness, float contrast, float saturation, float hue,
        vec4 colorIn, vec4 colorOut, vec4 colorShadow, vec4 colorGlow, 
        int insideLock, mat3 modelTransform, mat3 insideTransform, mat3 shadowTransform) {
    vec2 u = tf(inverse(modelTransform), uv);
    
    float d = 0.0;
    d = sdRectangle(u, dimFromShapeAspectRatio(0.5, shapeAspectRatio));     
    d = d*multiplier - roundness;
    
    float shadow = 0.0;
    vec4 tint = vec4(0.0);
    vec2 v = uv;
    bool inside = d<=0.0;
    if (inside) {
        if (shadows<0.0) {
            u = tf(inverse(shadowTransform), u);
            float saveD = d;
            d = d*multiplier - roundness;
             d = sdRectangle(u, dimFromShapeAspectRatio(0.5, shapeAspectRatio));     
            shadow = 0.7*smoothstep(shadows, 0., d); // d is shadow d here
            d = saveD;
        }
        tint = colorIn;
        mat3 iTransform = insideLock==0 ? insideTransform : modelTransform*insideTransform;
        v = tf(inverse(iTransform), uv);
    }
    else {
        if (shadows>0.0) {
            u = tf(inverse(shadowTransform), u);
            float saveD = d;
            d = d*multiplier - roundness;
             d = sdRectangle(u, dimFromShapeAspectRatio(0.5, shapeAspectRatio));     
            shadow = 0.7*smoothstep(shadows, 0., d); // d is shadow d here
            d = saveD;
        }
        tint = colorOut;
    }
    
    vec4 sColor = (insideImage_specified==1 && inside) ? __insideImage__(v) : __source__(v);
    vec4 color = sColor;
    if (inside) color = adjustColorHSLuv(color, brightness, contrast, 0.0, 0.0, saturation, hue, vec4(0.0));
    vec4 glow = (colorGlow.a!=0.0) ? vec4(colorGlow.rgb * 0.01/abs(d), min(1.0, colorGlow.a* 0.01/abs(d))) : vec4(0.);           
    color = mergeGlow(mergeColor(mergeColor(color, tint), vec4(colorShadow.rgb, colorShadow.a*shadow)), glow);
    if (abs(d)<outlineThickness*.5) {
        color = mergeColor(color, colorOutline);
        shadow = 0.0;
    }
    return color;
}

void main() {
    fragColor = basicInterpolatedShapes((inverse(u_viewTransform) * vec3(((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), 1.0)).xy, ((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), u_insideImage_specified, u_shapeAspectRatio, u_shadows, u_roundness, u_multiplier, u_colorOutline, u_outlineThickness, u_brightness, u_contrast, u_saturation, u_hue, u_colorIn, u_colorOut, u_colorShadow, u_colorGlow, u_insideLock, u_modelTransform, u_insideTransform, u_shadowTransform);
}
