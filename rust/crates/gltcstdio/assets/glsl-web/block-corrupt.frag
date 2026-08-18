#version 450
layout(location = 0) in vec2 v_uv;
layout(location = 0) out vec4 fragColor;

layout(binding = 0, std140) uniform Params {
    vec4 U[15];
};
layout(binding = 1) uniform sampler samp;
layout(binding = 2) uniform texture2D t_source;

#define u_source sampler2D(t_source, samp)
#define u_worldAspect (U[0].x)
#define u_viewTransform (mat3(U[1].xyz, U[2].xyz, U[3].xyz))
#define u_sourceDim (U[4].xy)
#define u_outDim (U[5].xy)
#define u_mode (int(U[6].x))
#define u_count (int(U[7].x))
#define u_randomSeed (U[8].x)
#define u_objectTransform (mat3(U[9].xyz, U[10].xyz, U[11].xyz))
#define u_modelTransform (mat3(U[12].xyz, U[13].xyz, U[14].xyz))

#define __source__texelFetch__(c) texelFetch(u_source, (c), 0)
#define __source__(p) textureLod(u_source, (vec2((p).x / u_worldAspect, (p).y) / 2.0 + 0.5), 0.0)




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


















































































































































































































































































































































float getIndex(vec2 pos, vec2 blockSize, vec2 dim) {
    float columns = dim.x/blockSize.x;
    float lines = dim.y/blockSize.y;
    vec2 f = floor(pos/blockSize);
    return f.x+0.5*columns + (f.y+0.5*lines)*columns;
}

vec2 rand2(vec2 v) {
    float x = fract(sin(dot(v.xy ,vec2(12.9898,78.233))) * 43758.5453);
    float y = fract(sin(dot(vec2(x, v.x) ,vec2(12.9898,78.233))) * 43758.5453);
    return vec2(x, y);
}

float varyNoiseSmoothly(float noise, float k) {
    float phase = acos(2.0*noise-1.0);
    float freq = fract(noise*16.0) + 0.5;
    return (1.0+cos(phase+freq*k))*0.5;
}

vec2 varyVec2NoiseSmoothly(vec2 noise, float k) {
    return vec2(varyNoiseSmoothly(noise.x, k), varyNoiseSmoothly(noise.y, k));
}

vec2 rand2relSeeded(vec2 co, float seed) {
    return varyVec2NoiseSmoothly(rand2(co), seed)-0.5;
}

vec2 sineMix(vec2 val1, vec2 val2, float k) {
    return val1*(1.0+cos(k*PI))*0.5 + val2*(1.0+cos((1.0-k)*PI))*0.5;
}

vec2 sineSurfaceRand2Seeded(vec2 v, float seed) {
    vec2 u00 = floor(v);
    vec2 u01 = vec2(floor(v.x), ceil(v.y));
    vec2 u10 = vec2(ceil(v.x), floor(v.y));
    vec2 u11 = ceil(v);

    vec2 r00 = varyVec2NoiseSmoothly(rand2(u00), seed)-vec2(0.5, 0.5);
    vec2 r01 = varyVec2NoiseSmoothly(rand2(u01), seed)-vec2(0.5, 0.5);
    vec2 r10 = varyVec2NoiseSmoothly(rand2(u10), seed)-vec2(0.5, 0.5);
    vec2 r11 = varyVec2NoiseSmoothly(rand2(u11), seed)-vec2(0.5, 0.5);

    return sineMix(
            sineMix(r00, r01, fract(v.y)),
            sineMix(r10, r11, fract(v.y)),
            fract(v.x));
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

float getChannel(vec4 color, int channel) {
    if (channel==0) return color.r;
    else if (channel==1) return color.g;
    else if (channel==2) return color.b;
    else if (channel==3) return rgbToHsl(color).x / 360.0;
    else if (channel==4) return rgbToHsl(color).y;
    else if (channel==5) return rgbToHsl(color).z;
    else if (channel==6) return rgbToHsluv(color.rgb).x / 360.0;
    else if (channel==7) return rgbToHsluv(color.rgb).y * 0.01;
    else if (channel==8) return rgbToHsluv(color.rgb).z * 0.01;
    else return 0.0;
}

float getChannelWithHsl(vec4 color, vec4 hsl, int channel) {
    if (channel==0) return color.r;
    else if (channel==1) return color.g;
    else if (channel==2) return color.b;
    else if (channel==3) return rgbToHsl(color).x / 360.0;
    else if (channel==4) return rgbToHsl(color).y;
    else if (channel==5) return rgbToHsl(color).z;
    else return 0.0;
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

vec4 swapRGBHSL(vec4 rgb, float mode) {
    float coding = floor(mode*0.01*2.0*6.0*6.0*6.0-1.0);
    bool toHsl = coding > 215.0;
    if (toHsl) coding = mod(coding, 216.0);

    vec4 hsl = rgbToHsl(rgb);
    hsl.r /= 360.0;
    int rChannel = int(mod(coding, 6.0));
    int gChannel = int(mod(coding/6.0, 6.0));
    int bChannel = int(mod(coding/36.0, 6.0));
    vec4 color = vec4(
        getChannelWithHsl(rgb, hsl, rChannel) * (toHsl ? 360.0 : 1.0),
        getChannelWithHsl(rgb, hsl, gChannel),
        getChannelWithHsl(rgb, hsl, bChannel),
//        getChannel(0, rgb, hsl) * (toHsl ? 360.0 : 1.0),
//        getChannel(1, rgb, hsl),
//        getChannel(2, rgb, hsl),
        rgb.a );

    return toHsl ? hslToRgb(color) : color;
}

vec2 tf(mat3 m, vec2 u) {
    return (m * vec3(u, 1.)).xy;
}

vec4 blockBW(vec2 pos, vec2 outPos, int mode, int count, float randomSeed, vec2 sourceDim, mat3 objectTransform, mat3 modelTransform) {
            vec4 inCol = __source__(pos);
            vec4 outCol = inCol;
        
            float ratio = sourceDim.x/sourceDim.y;
            vec2 dim = vec2(2.0*ratio, 2.0);
            vec2 blockSize = dim / vec2(160.0, 80.0);
            float columns = dim.x/blockSize.x;
            float lines = dim.y/blockSize.y;
            float blocks = columns*lines;
            vec2 uv = tf(inverse(modelTransform), pos);
            
            float index = getIndex(vec2(uv.x, mod(uv.y+3.0, 6.0)-3.0), blockSize, dim);
            randomSeed += floor((uv.y+3.0)/6.0); // every vert. window of height 6 has a different random seed
//            float index = getIndex(uv, blockSize, dim);
        
//            mat3 invModelTransform = inverse(modelTransform);
            float offset = objectTransform[2][0]*0.5*columns + objectTransform[2][1]*0.5*lines*columns + 0.5*blocks;
            float scale = length(objectTransform[0].xy);
                
            for(int i=0; i<count; ++i) {
                vec2 rnd = sineSurfaceRand2Seeded(vec2(10.0-float(i), 15.0+5.0*float(i)), randomSeed+4.46);
                float center = offset + rnd.x*blocks;
                float bSize = (rnd.x<-0.5+float(i)*0.1)? 0.5 : abs(rnd.y)*blocks*scale;
                float ind1 = center-bSize;
                float ind2 = center+bSize;
        
                bool inside = (index>=ind1 && index<=ind2);
                if (inside) {
                    if (mode==0) { // BW
                        float subMode = floor(mod(rnd.x*15.0, 9.0));
                        float g = 0.0;
                        if (subMode==0.0) {
                            g = fract(rand2relSeeded(floor(uv*320.0), randomSeed).x) > 0.5 ? 1.0 : 0.0;
                        }
                        else if (subMode==1.0) {
                            g = fract(rand2relSeeded(floor(uv*160.0), randomSeed).x) > 0.5 ? 1.0 : 0.0;
                        }
                        else if (subMode==2.0) {
                            g = fract(uv.x*40.0)>0.5 ? 1.0 : 0.0;
                        }
                        else if (subMode==3.0) {
                            g = fract(uv.x*80.0)>0.5 ? 1.0 : 0.0;
                        }
                        else if (subMode==6.0) {
                            g = fract(uv.x*80.0)>length(inCol.rgb)/1.7 ? 1.0 : 0.0;
                        }
                        else if (subMode==7.0) {
                            g = fract(uv.x*10.0)<length(inCol.rgb)/1.7 ? 1.0 : 0.0;
                        }
                        else if (subMode==4.0) {
                            g = mod((fract(uv.x*80.0)>0.5 ? 1.0 : 0.0) + (fract(uv.y*40.0)>0.5 ? 1.0 : 0.0), 2.0);
                        }
                        else if (subMode==5.0) {
                            g = fract(rand2relSeeded(floor(uv*160.0), randomSeed).x) < length(inCol.rgb)/1.7 ? 1.0 : 0.0;
                        }
                        else {
                            g = mod((fract(uv.x*40.0)>0.5 ? 1.0 : 0.0) + (fract(uv.y*20.0)>0.5 ? 1.0 : 0.0), 2.0);
                        }
                        outCol = vec4(g, g, g, 1.0);
                    }
                    else if (mode==1) { // color = channel swap
                        float mode = (rnd.x+0.5)*4096.0;
                        outCol = swapRGBHSL(outCol, mode);
                    }
                    else if (mode==2) { // channel+pos
                        int channel = int(mod(rnd.x*100.0, 3.0));
                        vec2 delta = fract(rnd*10.0)*2.0-vec2(1.0, 1.0);
                        outCol[channel] = __source__(pos+delta)[channel];
                    }
                    else if (mode==3) { // pos
                        vec2 delta = fract(rnd*10.0)*2.0-vec2(1.0, 1.0);
                        outCol = __source__(pos+delta);
                    }
                    
                    return outCol;
                }
            }
        
            return inCol;
        }

void main() {
    fragColor = blockBW((inverse(u_viewTransform) * vec3(((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), 1.0)).xy, ((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), u_mode, u_count, u_randomSeed, u_sourceDim, u_objectTransform, u_modelTransform);
}
