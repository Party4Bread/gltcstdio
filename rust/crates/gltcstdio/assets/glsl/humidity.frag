#version 450
layout(location = 0) in vec2 v_uv;
layout(location = 0) out vec4 fragColor;

layout(binding = 0, std140) uniform Params {
    vec4 U[23];
};
layout(binding = 1) uniform sampler samp;
layout(binding = 2) uniform texture2D t_source;

#define u_source sampler2D(t_source, samp)
#define u_worldAspect (U[0].x)
#define u_viewTransform (mat3(U[1].xyz, U[2].xyz, U[3].xyz))
#define u_outDim (U[4].xy)
#define u_layerCount (int(U[5].x))
#define u_intensity (U[6].x)
#define u_balance (U[7].x)
#define u_stratification (U[8].x)
#define u_octaves (int(U[9].x))
#define u_power (U[10].x)
#define u_color (U[11])
#define u_color2 (U[12])
#define u_vignetting (U[13].x)
#define u_vignetteTransform (mat3(U[14].xyz, U[15].xyz, U[16].xyz))
#define u_layerTransform (mat3(U[17].xyz, U[18].xyz, U[19].xyz))
#define u_modelTransform (mat3(U[20].xyz, U[21].xyz, U[22].xyz))

#define __source__texelFetch__(c) texelFetch(u_source, (c), 0)
#define __source__(p) texture(u_source, (vec2((p).x / u_worldAspect, (p).y) / 2.0 + 0.5))




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

vec4 mergeColor(vec4 bkg, vec4 front) {
    return vec4(mix(bkg.rgb, front.rgb, front.a + (1.0-bkg.a)*(1.0-front.a)), max(bkg.a, front.a));
}

vec2 hash22b(vec2 u) {
    return vec2(
        fract(sin(dot(u.xy, vec2(13.7545,78.224)))* 43758.5453123), 
        fract(sin(dot(u.xy, vec2(15.7545,73.224)))* 43758.5453123) );
}

vec2 rndUnit(vec2 p) {
    vec2 rnd = hash22b(p)-0.5;
    float len = length(rnd);
    if (len==0.0) return vec2(0., 1.0); else return rnd/len;
}

float dotGridGradient(vec2 g, vec2 u) {
    return dot(u-g, rndUnit(g));
}

float smix(float a, float b, float k) {
    return mix(a, b, smoothstep(0.0, 1.0, k));
}

float perlinNoise(vec2 p) {
    vec2 s = vec2(1.0, 0.0);
    vec2 f = floor(p);
    vec2 d = p-f;
    float ix0 = smix(dotGridGradient(f, p), dotGridGradient(f+s, p), d.x);
    float ix1 = smix(dotGridGradient(f+s.yx, p), dotGridGradient(f+s.xx, p), d.x);
    return 0.5+smix(ix0, ix1, d.y)*0.5;
}

float perlinOctaveNoise(vec2 uv, int n) {
    mat2 transform = 2.1111*mat2(sin(1.), cos(1.), -cos(1.), sin(1.));
    
    float k = 1.;
    float x = 0.;
    float total = 0.;
    
    for(int i=0; i<n; ++i) {
        x += k * perlinNoise(uv);
        total += k;
        k *= 0.5;
        uv = transform * uv;
    }
    
    x /= total;  
    return x;
}

vec2 tf(mat3 m, vec2 u) {
    return (m * vec3(u, 1.)).xy;
}

float simpleVignette(float vignette, vec2 uv, mat3 vignetteTransform) {
    float d = length(tf(vignetteTransform, uv));
    return mix(1.0-vignette, 1.0, smoothstep(0.5, 1.0, d));
}

vec4 grain(vec2 pos, vec2 outPos, int layerCount, float intensity, float balance, float stratification, int octaves, float power, vec4 color, vec4 color2, float vignetting, mat3 vignetteTransform, mat3 layerTransform, mat3 modelTransform) {
            vec4 col = __source__(pos);

            vec2 u = tf(inverse(modelTransform), pos);

            float totalHum = 0.0;
            float k = 1.0;
            float totalK = 0.0;
            //mat3 transform = mat3(0.9, 0.7, 0.0, -0.7, 0.9, 0.0, 10.3, 4.4, 1.0);
            mat3 inverseLayerTransform = inverse(layerTransform);
            
            for(int i=0; i<layerCount; ++i) {
                float hum = 2.0 * (perlinOctaveNoise(u, octaves) - 0.5);
                
                hum = mod(hum*stratification, 2.) * 0.5;
                if (hum<balance) hum = hum/balance; else hum = 1.-(hum-balance)/(1.-balance);
                hum = pow(hum, power);
                totalHum += hum*k;
                totalK += k;
                k *= 0.6; 
                u = tf(inverseLayerTransform, u);
            }
            
            totalHum /= mix(1.0, totalK, pow(0.5, power));           
            
            vec4 hueShiftedCol = col; //hue==0.0 ? col : adjustColorHSLuv(col, 0.0, 1.0, 0.0, 0.0, 0.0, mix(0.0, hue, totalHum), vec4(0.)); // not convincing
            vec4 targetCol = totalHum<0.5 
                ? mix(hueShiftedCol, mergeColor(hueShiftedCol, color2), totalHum/0.5)  
//                : mergeColor(col, mix(color2, color, (totalHum-0.5)/0.5));                        
                : mix(mergeColor(hueShiftedCol, color2), mergeColor(hueShiftedCol, color), (totalHum-0.5)/0.5);                        
            col = mix(col, targetCol, intensity*simpleVignette(vignetting, pos, inverse(vignetteTransform)));
                        
//            totalHum *= simpleVignette(vignetting, pos, inverse(vignetteTransform));
//            col = mix(col, color, totalHum*intensity);
                         
            return col;
        }

void main() {
    fragColor = grain((inverse(u_viewTransform) * vec3(((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), 1.0)).xy, ((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), u_layerCount, u_intensity, u_balance, u_stratification, u_octaves, u_power, u_color, u_color2, u_vignetting, u_vignetteTransform, u_layerTransform, u_modelTransform);
}
