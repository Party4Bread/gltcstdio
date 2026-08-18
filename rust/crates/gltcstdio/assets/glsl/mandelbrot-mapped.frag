#version 450
layout(location = 0) in vec2 v_uv;
layout(location = 0) out vec4 fragColor;

layout(binding = 0, std140) uniform Params {
    vec4 U[21];
};
layout(binding = 1) uniform sampler samp;
layout(binding = 2) uniform texture2D t_source;

#define u_source sampler2D(t_source, samp)
#define u_worldAspect (U[0].x)
#define u_viewTransform (mat3(U[1].xyz, U[2].xyz, U[3].xyz))
#define u_source_specified (int(U[4].x))
#define u_outDim (U[5].xy)
#define u_mode (int(U[6].x))
#define u_shadows (U[7].x)
#define u_modelTransform (mat3(U[8].xyz, U[9].xyz, U[10].xyz))
#define u_offsetTransform (mat3(U[11].xyz, U[12].xyz, U[13].xyz))
#define u_texTransform (mat3(U[14].xyz, U[15].xyz, U[16].xyz))
#define u_colorIn (U[17])
#define u_iterations (int(U[18].x))
#define u_julianess (U[19].x)
#define u_power (U[20].x)

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






























































































































































































































































































































































vec2 complexLog(vec2 u) {
    return vec2(log(length(u)), atan(u.y, u.x));
}

vec4 mergeColor(vec4 bkg, vec4 front) {
    return vec4(mix(bkg.rgb, front.rgb, front.a + (1.0-bkg.a)*(1.0-front.a)), max(bkg.a, front.a));
}

vec2 tf(mat3 m, vec2 u) {
    return (m * vec3(u, 1.)).xy;
}

vec4 mandelbrotMapped(vec2 pos, vec2 outPos, int source_specified, int mode, float shadows, mat3 modelTransform, mat3 offsetTransform, mat3 texTransform, vec4 colorIn, int iterations, float julianess, float power) {
    float cj = cos(julianess * PI*0.5);
    float sj = sin(julianess * PI*0.5);
    
    mat3 invModelTransform = inverse(modelTransform);
          
    vec2 uv = tf(invModelTransform, pos);
    vec2 t = cj*uv + sj*offsetTransform[2].xy;
    vec2 z0 = sj*uv + cj*offsetTransform[2].xy;
    
    vec2 z = z0;

    vec2 prev = t;

    int iter = 0;
    float d2 = 0.0;
    bool inside = true;
    
    int limitMode = mode%4;
    int baseMode = mode/4;
    float dLimit = 2.0;
    if (limitMode==1) { dLimit = 4.0; }
    else if (limitMode==2) { dLimit = 100.0; }
    else if (limitMode==3) { dLimit = 100000.0; }
    float d2Limit = dLimit*dLimit;
                
    if (mode==20) {
        if (power == 2.0) {
            while (iter < iterations) {
                ++iter;
                prev = z;
                z.x = prev.x*prev.x - prev.y*prev.y + t.x;
                z.y = 2.0*prev.x*prev.y + t.y;
                d2 = dot(z, z);
            }
        }
        else if (power == 3.0) {
            while (iter < iterations) {
                ++iter;
                prev = z;
                z.x = prev.x*prev.x*prev.x - 3.0*prev.y*prev.y*prev.x + t.x;
                z.y = -prev.y*prev.y*prev.y + 3.0*prev.x*prev.x*prev.y + t.y;
                d2 = dot(z, z);
            }
        }
        else {
            float d = length(z);
    
            while (iter < iterations) {
                ++iter;
                prev = z;
                float angle = atan(prev.y, prev.x);
                float dp = pow(d, power);
                z.x = dp*cos(power*angle) + t.x;
                z.y = dp*sin(power*angle) + t.y;
            }
        }
    
        return __source__(tf(inverse(texTransform), z));
    }
                
    if (power == 2.0) {
        while (iter < iterations) {
            ++iter;
            prev = z;
            z.x = prev.x*prev.x - prev.y*prev.y + t.x;
            z.y = 2.0*prev.x*prev.y + t.y;
            d2 = dot(z, z);
                                                    
            if (d2 > d2Limit) {
                inside = false;
                break;
            }
        }
    }
    else if (power == 3.0) {
        while (iter < iterations) {
            ++iter;
            prev = z;
            z.x = prev.x*prev.x*prev.x - 3.0*prev.y*prev.y*prev.x + t.x;
            z.y = -prev.y*prev.y*prev.y + 3.0*prev.x*prev.x*prev.y + t.y;
            d2 = dot(z, z);
                                
            if (d2 > d2Limit) {
                inside = false;
                break;
            }
        }
    }
    else {
        float d = length(z);

        while (iter < iterations) {
            ++iter;
            prev = z;
            float angle = atan(prev.y, prev.x);
            //if (angle<0.0) angle+=M_2PI;

            float dp = pow(d, power);
            z.x = dp*cos(power*angle) + t.x;
            z.y = dp*sin(power*angle) + t.y;
                    
            d = length(z);
            if (d > dLimit) {
                inside = false;
                break;
            }
        }

        d2 = d*d;
    }


    float d = sqrt(d2);
    float x = 1.0 + float(iter) - log(log(d))/log(2.0);
    vec2 l = complexLog(z);
    //float x = complexLog(l).x;
    //float y = 2.0*complexLog(p).y;
    //float y = 2.0*complexLog(l).y;
    float y = 2.0*l.y;
    
    vec2 w = z;
    if (baseMode==0) w = vec2(y*0.125, x);
    else if (baseMode==1) w = vec2(y, complexLog(l).x);
    else if (baseMode==2) w = vec2(y, l.x);
    else if (baseMode==3) w = vec2(2.0*complexLog(t).y, complexLog(l).x);
    
    vec4 outCol;
    if (source_specified==1) outCol = __source__(tf(inverse(texTransform), w));
    else outCol = vec4(tf(inverse(texTransform),fract(w)), 0.5, 1.0);
    if (shadows>0.0) {
        outCol = mix(outCol, colorIn, (x-float(iter))*d2Limit*shadows);
    }   
    //return vec2(y, x);
    //return vec2(y*0.125, 8.0*pow(d, 0.125));
    //return complexLog(z);
    if (inside) return mergeColor(outCol, colorIn); else return outCol;
}

void main() {
    fragColor = mandelbrotMapped((inverse(u_viewTransform) * vec3(((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), 1.0)).xy, ((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), u_source_specified, u_mode, u_shadows, u_modelTransform, u_offsetTransform, u_texTransform, u_colorIn, u_iterations, u_julianess, u_power);
}
