#version 450
layout(location = 0) in vec2 v_uv;
layout(location = 0) out vec4 fragColor;

layout(binding = 0, std140) uniform Params {
    vec4 U[18];
};
layout(binding = 1) uniform sampler samp;
layout(binding = 2) uniform texture2D t_source;

#define u_source sampler2D(t_source, samp)
#define u_worldAspect (U[0].x)
#define u_viewTransform (mat3(U[1].xyz, U[2].xyz, U[3].xyz))
#define u_source_specified (int(U[4].x))
#define u_outDim (U[5].xy)
#define u_modelTransform (mat3(U[6].xyz, U[7].xyz, U[8].xyz))
#define u_offsetTransform (mat3(U[9].xyz, U[10].xyz, U[11].xyz))
#define u_iterations (int(U[12].x))
#define u_balance (U[13].x)
#define u_julianess (U[14].x)
#define u_power (U[15].x)
#define u_colorIn (U[16])
#define u_colorOut (U[17])

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















































































































































































































































































































































mat2 rotation2(float angle) {
    float ca = cos(angle);
    float sa = sin(angle);
    return mat2(ca, sa, -sa, ca);
}

vec2 tf(mat3 m, vec2 u) {
    return (m * vec3(u, 1.)).xy;
}

vec4 mandelbrotFeather(vec2 pos, vec2 outPos, int source_specified, mat3 modelTransform, mat3 offsetTransform, int iterations, float balance, float julianess, float power, vec4 colorIn, vec4 colorOut) {
            float cj = cos(julianess * PI*0.5);
            float sj = sin(julianess * PI*0.5);
            
            mat3 invModelTransform = inverse(modelTransform);

            vec2 uv = tf(invModelTransform, pos);
            vec2 t = cj*uv + sj*offsetTransform[2].xy;
            vec2 z0 = sj*uv + cj*offsetTransform[2].xy;
            
            vec2 z = z0;
            vec2 w;
        
            vec2 prev = t;
        
            int iter = 0;
            float d2 = 0.0;
                    
            if (power == 2.0) {
                while (iter < iterations) {
                    ++iter;
                    prev = z;
                    z.x = prev.x*prev.x - prev.y*prev.y + t.x;
                    z.y = abs(2.0*prev.x*prev.y) + t.y;
                    d2 = dot(z, z);
                                        
                    w = rotation2(float(iter) * balance*PI2)*z;
                    if (w.y > 5.0) {
                        break;
                    }
                }
            }
            else if (power == 3.0) {
                while (iter < iterations) {
                    ++iter;
                    prev = abs(z);
                    z.x = prev.x*prev.x*prev.x - 3.0*prev.y*prev.y*prev.x + t.x;
                    z.y = -prev.y*prev.y*prev.y + 3.0*prev.x*prev.x*prev.y + t.y;
                    d2 = dot(z, z);
                                        
                    w = rotation2(float(iter) * balance*PI2)*z;
                    if (w.y > 5.0) {
                        break;
                    }
                }
                w = z;
            }
            else {
                float d = length(z);
        
                while (iter < iterations) {
                    ++iter;
                    prev = abs(z);
                    float angle = atan(prev.y, prev.x);
                    //if (angle<0.0) angle+=M_2PI;
        
                    float dp = pow(d, power);
                    z.x = dp*cos(power*angle) + t.x;
                    z.y = dp*sin(power*angle) + t.y;
                    
                    d = length(z);
                                        
                    w = rotation2(float(iter) * balance*PI2)*z;
                    if (w.y > 5.0) {
                        break;
                    }
                }
                w = z;

                d2 = d*d;
            }  
        
            float angle = 0.0;
            float d = sqrt(d2);
            float ty = 1.0 + float(iter) - log(log(d))/log(power);
            float grey = (1.0/ty);
            vec4 color;
            if (iter==iterations) {
                grey = abs(w.y);
                color = colorIn;
            } //0.0;
//            else grey = -z.y*0.1 + float(iter)/float(iterations);
//            else grey = 3.0/pow(w.y, 0.25) * (1.0-pow(0.9, float(iter)));
            else {
                grey = 1.0/pow(w.y, 0.25) + 0.5*(1.0-pow(0.9, float(iter)));
                color = colorOut;
            }
//            else grey = .5 + .5*cos(PI2 * (0.41 + 1.0/z.y + float(iter)/64.));
//            else grey = z.y*0.01;
            
            if (source_specified==0) return vec4(grey*color.rgb*2.0, color.a);
            else return __source__(vec2(0.0, grey*2.-1.0));
        }

void main() {
    fragColor = mandelbrotFeather((inverse(u_viewTransform) * vec3(((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), 1.0)).xy, ((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), u_source_specified, u_modelTransform, u_offsetTransform, u_iterations, u_balance, u_julianess, u_power, u_colorIn, u_colorOut);
}
