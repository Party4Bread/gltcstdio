#version 450
layout(location = 0) in vec2 v_uv;
layout(location = 0) out vec4 fragColor;

layout(binding = 0, std140) uniform Params {
    vec4 U[14];
};
layout(binding = 1) uniform sampler samp;
layout(binding = 2) uniform texture2D t_source;

#define u_source sampler2D(t_source, samp)
#define u_worldAspect (U[0].x)
#define u_viewTransform (mat3(U[1].xyz, U[2].xyz, U[3].xyz))
#define u_sourceDim (U[4].xy)
#define u_outDim (U[5].xy)
#define u_balance (U[6].x)
#define u_variability (U[7].x)
#define u_borderColor (U[8])
#define u_thickness (U[9].x)
#define u_randomSeed (U[10].x)
#define u_modelTransform (mat3(U[11].xyz, U[12].xyz, U[13].xyz))

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










































































































































































































































































































































#define BASIC false




















float rnd2(vec2 u, float seed, float regularity) {
    float a = 5.0*fract(dot(u, u.yx+vec2(10.32777, 13.1123))+seed*0.977);
    float b = 5.0*fract(dot(vec2(a*u.y, u.x), -u.xy+0.55555));
    float r1 = fract(10.1545*a*b-dot(u, u));

    float R1 = floor(fract(seed*1.1+0.51)*4.0)/4.0;
    float R2 = floor(fract(seed*4.3)*4.0)/4.0;
    float R3 = floor(fract(seed*23.4)*4.0)/4.0;
    float R4 = floor(fract(seed*71.7)*4.0)/4.0;
    float a2 = (5.0+R4)*fract(dot(u, u.yx+vec2(5.0+R1, 4.0+R2)));
    float b2 = 5.0*fract(dot(vec2(a2*u.y, u.x), -u.xy+0.5+R3/2.0));
    float r2 = fract(10.5*a2*b2-dot(u, u));

    return (fract(seed+u.x*1.2337+u.y*3.23323)>regularity) ? r1 : r2;
}

float rnd2dir(vec2 u, vec2 dir, float seed, float regularity) {
    //return abs(dir.x)<abs(dir.y) ? 1.0: 0.0;
    return rnd2(2.0*u+1.0+dir, seed, regularity);
}

bool getDir(vec2 u, vec2 dir, float seed, float regularity) {
	return rnd2dir(u, dir, seed, regularity)<0.5;
}

float luma(vec3 c) {
    return (0.2989*c.r + 0.587*c.g + 0.114*c.b);
}

vec4 mergeColor(vec4 bkg, vec4 front) {
    return vec4(mix(bkg.rgb, front.rgb, front.a + (1.0-bkg.a)*(1.0-front.a)), max(bkg.a, front.a));
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

vec2 tf(mat3 m, vec2 u) {
    return (m * vec3(u, 1.)).xy;
}

        vec4 tiledStreak(vec2 uv, vec2 outPos, vec2 sourceDim, float balance, float variability, vec4 borderColor, float thickness, float randomSeed, mat3 modelTransform) {
            float regularity = 1. - variability;
            
            vec2 u = (inverse(modelTransform) * vec3(uv, 1.0)).xy;
        
            vec2 c = floor(u);
            vec2 f = u-c;
            vec2 cell = abs(f-0.5);
            float k = max(cell.x, cell.y);
            
            float d = max(abs(cell.x), abs(cell.y));
            bool onBorder = d>0.5-0.5*thickness;
            if (onBorder && borderColor.a==1.0) return borderColor;
        
            bool dirBottom = getDir(c, vec2(0.0, -1.0), randomSeed, regularity); // true = horizontal
            bool dirTop = getDir(c, vec2(0.0, 1.0), randomSeed, regularity);
            bool dirLeft= getDir(c, vec2(-1.0, 0.0), randomSeed, regularity);
            bool dirRight = getDir(c, vec2(1.0, 0.0), randomSeed, regularity);
        
            if (pow(1.0-fract(randomSeed*0.11111), 10.0-regularity*9.)>0.95) {
                dirBottom = dirTop = false;
                dirLeft = dirRight = true;
            }
        
            if (rand2relSeeded(c, randomSeed).x+0.5 < abs(balance)) {
                vec2 delta = vec2(0.3, 0.0);
                vec2 dir, v;
                
                dir = vec2(0.0, -1.0);
                v = c+0.5+0.5*dir;
                dirBottom = abs(luma(__source__(tf(modelTransform, v+delta)).rgb)-luma(__source__(tf(modelTransform, v-delta)).rgb)) + abs(luma(__source__(tf(modelTransform, v+delta.yx+delta)).rgb)-luma(__source__(tf(modelTransform, v+delta.yx-delta)).rgb)) + abs(luma(__source__(tf(modelTransform, v-delta.yx+delta)).rgb)-luma(__source__(tf(modelTransform, v-delta.yx-delta)).rgb)) <
        abs(luma(__source__(tf(modelTransform, v+delta.yx)).rgb)-luma(__source__(tf(modelTransform, v-delta.yx)).rgb)) + abs(luma(__source__(tf(modelTransform, v+delta+delta.yx)).rgb)-luma(__source__(tf(modelTransform, v+delta-delta.yx)).rgb)) + abs(luma(__source__(tf(modelTransform, v-delta+delta.yx)).rgb)-luma(__source__(tf(modelTransform, v-delta-delta.yx)).rgb));
        
                dir = vec2(0.0, 1.0);
                v = c+0.5+0.5*dir;
                dirTop = abs(luma(__source__(tf(modelTransform, v+delta)).rgb)-luma(__source__(tf(modelTransform, v-delta)).rgb)) + abs(luma(__source__(tf(modelTransform, v+delta.yx+delta)).rgb)-luma(__source__(tf(modelTransform, v+delta.yx-delta)).rgb)) + abs(luma(__source__(tf(modelTransform, v-delta.yx+delta)).rgb)-luma(__source__(tf(modelTransform, v-delta.yx-delta)).rgb)) <
        abs(luma(__source__(tf(modelTransform, v+delta.yx)).rgb)-luma(__source__(tf(modelTransform, v-delta.yx)).rgb)) + abs(luma(__source__(tf(modelTransform, v+delta+delta.yx)).rgb)-luma(__source__(tf(modelTransform, v+delta-delta.yx)).rgb)) + abs(luma(__source__(tf(modelTransform, v-delta+delta.yx)).rgb)-luma(__source__(tf(modelTransform, v-delta-delta.yx)).rgb));
        
                dir = vec2(-1.0, 0.0);
                v = c+0.5+0.5*dir;
                dirLeft = abs(luma(__source__(tf(modelTransform, v+delta)).rgb)-luma(__source__(tf(modelTransform, v-delta)).rgb)) + abs(luma(__source__(tf(modelTransform, v+delta.yx+delta)).rgb)-luma(__source__(tf(modelTransform, v+delta.yx-delta)).rgb)) + abs(luma(__source__(tf(modelTransform, v-delta.yx+delta)).rgb)-luma(__source__(tf(modelTransform, v-delta.yx-delta)).rgb)) <
        abs(luma(__source__(tf(modelTransform, v+delta.yx)).rgb)-luma(__source__(tf(modelTransform, v-delta.yx)).rgb)) + abs(luma(__source__(tf(modelTransform, v+delta+delta.yx)).rgb)-luma(__source__(tf(modelTransform, v+delta-delta.yx)).rgb)) + abs(luma(__source__(tf(modelTransform, v-delta+delta.yx)).rgb)-luma(__source__(tf(modelTransform, v-delta-delta.yx)).rgb));
        
                dir = vec2(1.0, 0.0);
                v = c+0.5+0.5*dir;
                dirRight = abs(luma(__source__(tf(modelTransform, v+delta)).rgb)-luma(__source__(tf(modelTransform, v-delta)).rgb)) + abs(luma(__source__(tf(modelTransform, v+delta.yx+delta)).rgb)-luma(__source__(tf(modelTransform, v+delta.yx-delta)).rgb)) + abs(luma(__source__(tf(modelTransform, v-delta.yx+delta)).rgb)-luma(__source__(tf(modelTransform, v-delta.yx-delta)).rgb)) <
        abs(luma(__source__(tf(modelTransform, v+delta.yx)).rgb)-luma(__source__(tf(modelTransform, v-delta.yx)).rgb)) + abs(luma(__source__(tf(modelTransform, v+delta+delta.yx)).rgb)-luma(__source__(tf(modelTransform, v+delta-delta.yx)).rgb)) + abs(luma(__source__(tf(modelTransform, v-delta+delta.yx)).rgb)-luma(__source__(tf(modelTransform, v-delta-delta.yx)).rgb));
        
                if (balance<0.0) {
                    dirTop = !dirTop; dirBottom = !dirBottom; dirLeft = !dirLeft; dirRight = !dirRight;
                }
            }
        
            vec4 col = vec4(0.0, 1.0, 0.0, 1.0);
        
            if (dirTop==dirBottom && dirTop==dirLeft && dirTop==dirRight) {
                if (dirTop) {
                    col = mix(__source__(tf(modelTransform, vec2(c.x, u.y))), __source__(tf(modelTransform, vec2(c.x+1.0, u.y))), u.x-c.x);
                }
                else {
                    col = mix(__source__(tf(modelTransform, vec2(u.x, c.y))), __source__(tf(modelTransform, vec2(u.x, c.y+1.0))), u.y-c.y);
                }
            }
            else if (dirTop && dirBottom && dirLeft && !dirRight) {
                if (BASIC) {
                    col = mix(__source__(tf(modelTransform, vec2(c.x, u.y))), __source__(tf(modelTransform, vec2(c.x+1.0, u.y))), u.x-c.x);
                }
                else {
                    col = vec4(0.0, 1.0, 0.0, 1.0);
                    float X = c.x+0.5 + abs(u.y-c.y-0.5);
                    if (u.x<X) col = mix(__source__(tf(modelTransform, vec2(c.x, u.y))), __source__(tf(modelTransform, vec2(X, u.y))), (u.x-c.x)/(X-c.x));
                    else {
                        float Y = abs(u.x-c.x-0.5);
                        col = mix(__source__(tf(modelTransform, vec2(u.x, c.y+0.5-Y))), __source__(tf(modelTransform, vec2(u.x, c.y+0.5+Y))), (u.y-c.y-0.5+Y)/(2.0*Y));
                    }
                }
            }
            else if (dirTop && dirBottom && !dirLeft && dirRight) {
                if (BASIC) {
                    col = mix(__source__(tf(modelTransform, vec2(c.x, u.y))), __source__(tf(modelTransform, vec2(c.x+1.0, u.y))), u.x-c.x);
                }
                else {
                    float X = c.x+0.5 - abs(u.y-c.y-0.5);
                    if (u.x>X) col = mix(__source__(tf(modelTransform, vec2(X, u.y))), __source__(tf(modelTransform, vec2(c.x+1.0, u.y))), (u.x-X)/(c.x+1.0-X));
                    else {
                        float Y = abs(u.x-c.x-0.5);
                        col = mix(__source__(tf(modelTransform, vec2(u.x, c.y+0.5-Y))), __source__(tf(modelTransform, vec2(u.x, c.y+0.5+Y))), (u.y-c.y-0.5+Y)/(2.0*Y));
                    }
                }
            }
            else if (dirTop && !dirBottom && dirLeft && dirRight) {
                vec2 center = c+0.5 -0.5*(vec2(0.0, 1.0)+vec2(-1.0, 0.0));
vec2 rel = u-center;
float len = length(rel);
if (len<1.0) {
    float a = atan(dot(u-center, vec2(-1.0, 0.0)), dot(u-center, vec2(0.0, 1.0)));
    col = mix(__source__(tf(modelTransform, center+len*vec2(0.0, 1.0))), __source__(tf(modelTransform, center+len*vec2(-1.0, 0.0))), a/PI_2);
}
else {
    col = mix(__source__(tf(modelTransform, vec2(c.x, u.y))), __source__(tf(modelTransform, vec2(c.x+1.0, u.y))), u.x-c.x);
}  ;
            }
            else if (!dirTop && dirBottom && dirLeft && dirRight) {
                vec2 center = c+0.5 -0.5*(vec2(-1.0, 0.0)+vec2(0.0, -1.0));
vec2 rel = u-center;
float len = length(rel);
if (len<1.0) {
    float a = atan(dot(u-center, vec2(0.0, -1.0)), dot(u-center, vec2(-1.0, 0.0)));
    col = mix(__source__(tf(modelTransform, center+len*vec2(-1.0, 0.0))), __source__(tf(modelTransform, center+len*vec2(0.0, -1.0))), a/PI_2);
}
else {
    col = mix(__source__(tf(modelTransform, vec2(c.x, u.y))), __source__(tf(modelTransform, vec2(c.x+1.0, u.y))), u.x-c.x);
}  ;
            }
            else if (dirTop && dirBottom && !dirLeft && !dirRight) {
                if (BASIC) {
                    col = mix(__source__(tf(modelTransform, vec2(c.x, u.y))), __source__(tf(modelTransform, vec2(c.x+1.0, u.y))), u.x-c.x);
                }
                else {
                    float X = abs(u.y-c.y-0.5);
                    float Y = abs(u.x-c.x-0.5);
                    if (X>Y) col = mix(__source__(tf(modelTransform, vec2(c.x+0.5-X, u.y))), __source__(tf(modelTransform, vec2(c.x+0.5+X, u.y))), (u.x-c.x-0.5+X)/(2.0*X));
                    else col = mix(__source__(tf(modelTransform, vec2(u.x, c.y+0.5-Y))), __source__(tf(modelTransform, vec2(u.x, c.y+0.5+Y))), (u.y-c.y-0.5+Y)/(2.0*Y));
                }
            }
            else if (!dirTop && dirBottom && dirLeft && !dirRight) {
                        vec2 center = c+0.5 -0.5*(vec2(0.0, -1.0)+vec2(1.0, 0.0));
        vec2 rel = u-center;
        float len = length(rel);
        if (len<1.0) {
            float a = atan(dot(u-center, vec2(1.0, 0.0)), dot(u-center, vec2(0.0, -1.0)));
            col = mix(__source__(tf(modelTransform, center+len*vec2(0.0, -1.0))), __source__(tf(modelTransform, center+len*vec2(1.0, 0.0))), a/PI_2);
        }
        else {
//        col = vec4(1., 0., 0, 1.);
            if (BASIC) {
                col = mix(__source__(tf(modelTransform, vec2(c.x, u.y))), __source__(tf(modelTransform, vec2(c.x+1.0, u.y))), u.x-c.x);
            }
            else {
                col = mix(__source__(tf(modelTransform, vec2(c.x, u.y))), __source__(tf(modelTransform, vec2(c.x+1.0, u.y))), u.x-c.x);
                // GL code used to do this but it doesn't work well here!
//                float X = abs(u.y-c.y-0.5);
//                float Y = abs(u.x-c.x-0.5);
//                if (X>Y) col = mix(__source__(tf(modelTransform, vec2(c.x+0.5-X, u.y))), __source__(tf(modelTransform, vec2(c.x+0.5+X, u.y))), (u.x-c.x-0.5+X)/(2.0*X));
//                col = mix(__source__(tf(modelTransform, vec2(u.x, c.y+0.5-Y))), __source__(tf(modelTransform, vec2(u.x, c.y+0.5+Y))), (u.y-c.y-0.5+Y)/(2.0*Y));
            }
        }        
            }
            else if (dirTop && !dirBottom && dirLeft && !dirRight) {
                        vec2 center = c+0.5 -0.5*(vec2(1.0, 0.0)+vec2(0.0, 1.0));
        vec2 rel = u-center;
        float len = length(rel);
        if (len<1.0) {
            float a = atan(dot(u-center, vec2(0.0, 1.0)), dot(u-center, vec2(1.0, 0.0)));
            col = mix(__source__(tf(modelTransform, center+len*vec2(1.0, 0.0))), __source__(tf(modelTransform, center+len*vec2(0.0, 1.0))), a/PI_2);
        }
        else {
//        col = vec4(1., 0., 0, 1.);
            if (BASIC) {
                col = mix(__source__(tf(modelTransform, vec2(c.x, u.y))), __source__(tf(modelTransform, vec2(c.x+1.0, u.y))), u.x-c.x);
            }
            else {
                col = mix(__source__(tf(modelTransform, vec2(c.x, u.y))), __source__(tf(modelTransform, vec2(c.x+1.0, u.y))), u.x-c.x);
                // GL code used to do this but it doesn't work well here!
//                float X = abs(u.y-c.y-0.5);
//                float Y = abs(u.x-c.x-0.5);
//                if (X>Y) col = mix(__source__(tf(modelTransform, vec2(c.x+0.5-X, u.y))), __source__(tf(modelTransform, vec2(c.x+0.5+X, u.y))), (u.x-c.x-0.5+X)/(2.0*X));
//                col = mix(__source__(tf(modelTransform, vec2(u.x, c.y+0.5-Y))), __source__(tf(modelTransform, vec2(u.x, c.y+0.5+Y))), (u.y-c.y-0.5+Y)/(2.0*Y));
            }
        }        
            }
            else if (!dirTop && dirBottom && !dirLeft && dirRight) {
                        vec2 center = c+0.5 -0.5*(vec2(-1.0, 0.0)+vec2(0.0, -1.0));
        vec2 rel = u-center;
        float len = length(rel);
        if (len<1.0) {
            float a = atan(dot(u-center, vec2(0.0, -1.0)), dot(u-center, vec2(-1.0, 0.0)));
            col = mix(__source__(tf(modelTransform, center+len*vec2(-1.0, 0.0))), __source__(tf(modelTransform, center+len*vec2(0.0, -1.0))), a/PI_2);
        }
        else {
//        col = vec4(1., 0., 0, 1.);
            if (BASIC) {
                col = mix(__source__(tf(modelTransform, vec2(c.x, u.y))), __source__(tf(modelTransform, vec2(c.x+1.0, u.y))), u.x-c.x);
            }
            else {
                col = mix(__source__(tf(modelTransform, vec2(c.x, u.y))), __source__(tf(modelTransform, vec2(c.x+1.0, u.y))), u.x-c.x);
                // GL code used to do this but it doesn't work well here!
//                float X = abs(u.y-c.y-0.5);
//                float Y = abs(u.x-c.x-0.5);
//                if (X>Y) col = mix(__source__(tf(modelTransform, vec2(c.x+0.5-X, u.y))), __source__(tf(modelTransform, vec2(c.x+0.5+X, u.y))), (u.x-c.x-0.5+X)/(2.0*X));
//                col = mix(__source__(tf(modelTransform, vec2(u.x, c.y+0.5-Y))), __source__(tf(modelTransform, vec2(u.x, c.y+0.5+Y))), (u.y-c.y-0.5+Y)/(2.0*Y));
            }
        }        
            }
            else if (dirTop && !dirBottom && !dirLeft && dirRight) {
                        vec2 center = c+0.5 -0.5*(vec2(0.0, 1.0)+vec2(-1.0, 0.0));
        vec2 rel = u-center;
        float len = length(rel);
        if (len<1.0) {
            float a = atan(dot(u-center, vec2(-1.0, 0.0)), dot(u-center, vec2(0.0, 1.0)));
            col = mix(__source__(tf(modelTransform, center+len*vec2(0.0, 1.0))), __source__(tf(modelTransform, center+len*vec2(-1.0, 0.0))), a/PI_2);
        }
        else {
//        col = vec4(1., 0., 0, 1.);
            if (BASIC) {
                col = mix(__source__(tf(modelTransform, vec2(c.x, u.y))), __source__(tf(modelTransform, vec2(c.x+1.0, u.y))), u.x-c.x);
            }
            else {
                col = mix(__source__(tf(modelTransform, vec2(c.x, u.y))), __source__(tf(modelTransform, vec2(c.x+1.0, u.y))), u.x-c.x);
                // GL code used to do this but it doesn't work well here!
//                float X = abs(u.y-c.y-0.5);
//                float Y = abs(u.x-c.x-0.5);
//                if (X>Y) col = mix(__source__(tf(modelTransform, vec2(c.x+0.5-X, u.y))), __source__(tf(modelTransform, vec2(c.x+0.5+X, u.y))), (u.x-c.x-0.5+X)/(2.0*X));
//                col = mix(__source__(tf(modelTransform, vec2(u.x, c.y+0.5-Y))), __source__(tf(modelTransform, vec2(u.x, c.y+0.5+Y))), (u.y-c.y-0.5+Y)/(2.0*Y));
            }
        }        
            }
            else if (!dirTop && !dirBottom && dirLeft && !dirRight) {
                if (rnd2(c, randomSeed, regularity)<0.5) { vec2 center = c+0.5 -0.5*(vec2(0.0, -1.0)+vec2(1.0, 0.0));
vec2 rel = u-center;
float len = length(rel);
if (len<1.0) {
    float a = atan(dot(u-center, vec2(1.0, 0.0)), dot(u-center, vec2(0.0, -1.0)));
    col = mix(__source__(tf(modelTransform, center+len*vec2(0.0, -1.0))), __source__(tf(modelTransform, center+len*vec2(1.0, 0.0))), a/PI_2);
}
else {
    col = mix(__source__(tf(modelTransform, vec2(u.x, c.y))), __source__(tf(modelTransform, vec2(u.x, c.y+1.0))), u.y-c.y);
}   }
                else { vec2 center = c+0.5 -0.5*(vec2(1.0, 0.0)+vec2(0.0, 1.0));
vec2 rel = u-center;
float len = length(rel);
if (len<1.0) {
    float a = atan(dot(u-center, vec2(0.0, 1.0)), dot(u-center, vec2(1.0, 0.0)));
    col = mix(__source__(tf(modelTransform, center+len*vec2(1.0, 0.0))), __source__(tf(modelTransform, center+len*vec2(0.0, 1.0))), a/PI_2);
}
else {
    col = mix(__source__(tf(modelTransform, vec2(u.x, c.y))), __source__(tf(modelTransform, vec2(u.x, c.y+1.0))), u.y-c.y);
}   }
            }
            else if (!dirTop && !dirBottom && !dirLeft && dirRight) {
                if (rnd2(c, randomSeed, regularity)<0.5) { vec2 center = c+0.5 -0.5*(vec2(0.0, 1.0)+vec2(-1.0, 0.0));
vec2 rel = u-center;
float len = length(rel);
if (len<1.0) {
    float a = atan(dot(u-center, vec2(-1.0, 0.0)), dot(u-center, vec2(0.0, 1.0)));
    col = mix(__source__(tf(modelTransform, center+len*vec2(0.0, 1.0))), __source__(tf(modelTransform, center+len*vec2(-1.0, 0.0))), a/PI_2);
}
else {
    col = mix(__source__(tf(modelTransform, vec2(u.x, c.y))), __source__(tf(modelTransform, vec2(u.x, c.y+1.0))), u.y-c.y);
}   }
                else { vec2 center = c+0.5 -0.5*(vec2(-1.0, 0.0)+vec2(0.0, -1.0));
vec2 rel = u-center;
float len = length(rel);
if (len<1.0) {
    float a = atan(dot(u-center, vec2(0.0, -1.0)), dot(u-center, vec2(-1.0, 0.0)));
    col = mix(__source__(tf(modelTransform, center+len*vec2(-1.0, 0.0))), __source__(tf(modelTransform, center+len*vec2(0.0, -1.0))), a/PI_2);
}
else {
    col = mix(__source__(tf(modelTransform, vec2(u.x, c.y))), __source__(tf(modelTransform, vec2(u.x, c.y+1.0))), u.y-c.y);
}   }
            }
            else if (dirTop && !dirBottom && !dirLeft && !dirRight) {
                if (BASIC) {
                    col = mix(__source__(tf(modelTransform, vec2(u.x, c.y))), __source__(tf(modelTransform, vec2(u.x, c.y+1.0))), u.y-c.y);
                }
                else {
                    float Y = c.y+0.5 + abs(u.x-c.x-0.5);
                    if (u.y<Y) col = mix(__source__(tf(modelTransform, vec2(u.x, c.y))), __source__(tf(modelTransform, vec2(u.x, Y))), (u.y-c.y)/(Y-c.y));
                    else {
                        float X = abs(u.y-c.y-0.5);
                        col = mix(__source__(tf(modelTransform, vec2(c.x+0.5-X, u.y))), __source__(tf(modelTransform, vec2(c.x+0.5+X, u.y))), (u.x-c.x-0.5+X)/(2.0*X));
                    }
                }
            }
            else if (!dirTop && dirBottom && !dirLeft && !dirRight) {
                if (BASIC) {
                    col = mix(__source__(tf(modelTransform, vec2(u.x, c.y))), __source__(tf(modelTransform, vec2(u.x, c.y+1.0))), u.y-c.y);
                }
                else {
                    float Y = c.y+0.5 - abs(u.x-c.x-0.5);
                    if (u.y>Y) col = mix(__source__(tf(modelTransform, vec2(u.x, Y))), __source__(tf(modelTransform, vec2(u.x, c.y+1.0))), (u.y-Y)/(c.y+1.0-Y));
                    else {
                        float X = abs(u.y-c.y-0.5);
                        col = mix(__source__(tf(modelTransform, vec2(c.x+0.5-X, u.y))), __source__(tf(modelTransform, vec2(c.x+0.5+X, u.y))), (u.x-c.x-0.5+X)/(2.0*X));
                    }
                }
            }
            else if (!dirTop && !dirBottom && dirLeft && dirRight) {
                vec4 col1, col2, col3, col4;
                {
    vec2 center = c+0.5 -0.5*(vec2(1.0, 0.0)+vec2(0.0, 1.0));
    vec2 rel = u-center;
    float len = length(rel);
    if (len<1.0) {
        float a = atan(dot(u-center, vec2(0.0, 1.0)), dot(u-center, vec2(1.0, 0.0)));
        col1 = mix(__source__(tf(modelTransform, center+len*vec2(1.0, 0.0))), __source__(tf(modelTransform, center+len*vec2(0.0, 1.0))), a/PI_2);
    }
    else {
        col1 = vec4(0.);
    }  
}
                {
    vec2 center = c+0.5 -0.5*(vec2(0.0, -1.0)+vec2(1.0, 0.0));
    vec2 rel = u-center;
    float len = length(rel);
    if (len<1.0) {
        float a = atan(dot(u-center, vec2(1.0, 0.0)), dot(u-center, vec2(0.0, -1.0)));
        col2 = mix(__source__(tf(modelTransform, center+len*vec2(0.0, -1.0))), __source__(tf(modelTransform, center+len*vec2(1.0, 0.0))), a/PI_2);
    }
    else {
        col2 = vec4(0.);
    }  
}
                {
    vec2 center = c+0.5 -0.5*(vec2(-1.0, 0.0)+vec2(0.0, -1.0));
    vec2 rel = u-center;
    float len = length(rel);
    if (len<1.0) {
        float a = atan(dot(u-center, vec2(0.0, -1.0)), dot(u-center, vec2(-1.0, 0.0)));
        col3 = mix(__source__(tf(modelTransform, center+len*vec2(-1.0, 0.0))), __source__(tf(modelTransform, center+len*vec2(0.0, -1.0))), a/PI_2);
    }
    else {
        col3 = vec4(0.);
    }  
}
                {
    vec2 center = c+0.5 -0.5*(vec2(0.0, 1.0)+vec2(-1.0, 0.0));
    vec2 rel = u-center;
    float len = length(rel);
    if (len<1.0) {
        float a = atan(dot(u-center, vec2(-1.0, 0.0)), dot(u-center, vec2(0.0, 1.0)));
        col4 = mix(__source__(tf(modelTransform, center+len*vec2(0.0, 1.0))), __source__(tf(modelTransform, center+len*vec2(-1.0, 0.0))), a/PI_2);
    }
    else {
        col4 = vec4(0.);
    }  
}
                mat4 cols = mat4(col1, col2, col3, col4);
                float r = rnd2(c, randomSeed, regularity);
                for(int i=0; i<5; ++i) {
                    int i1 = int(floor(r*4.0));
                    int i2 = i1+1; if (i2>=4) i2 = 0;
                    vec4 tmp = cols[i1];
                    cols[i1] = cols[i2];
                    cols[i2] = tmp;
                    r *= 0.25;
                }
                for(int i=0; i<4; ++i) {
                    col = cols[i];
                    if (col.a==1.0) break;
                }
            }
        
            if (onBorder) return mergeColor(col, borderColor);
            else return col;
        }

void main() {
    fragColor = tiledStreak((inverse(u_viewTransform) * vec3(((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), 1.0)).xy, ((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), u_sourceDim, u_balance, u_variability, u_borderColor, u_thickness, u_randomSeed, u_modelTransform);
}
