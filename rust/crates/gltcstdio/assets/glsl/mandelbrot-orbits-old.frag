#version 450
layout(location = 0) in vec2 v_uv;
layout(location = 0) out vec4 fragColor;

layout(binding = 0, std140) uniform Params {
    vec4 U[25];
};
layout(binding = 1) uniform sampler samp;

#define u_worldAspect (U[0].x)
#define u_viewTransform (mat3(U[1].xyz, U[2].xyz, U[3].xyz))
#define u_outDim (U[4].xy)
#define u_mode (int(U[5].x))
#define u_modelTransform (mat3(U[6].xyz, U[7].xyz, U[8].xyz))
#define u_offsetTransform (mat3(U[9].xyz, U[10].xyz, U[11].xyz))
#define u_transformRed (mat3(U[12].xyz, U[13].xyz, U[14].xyz))
#define u_transformGreen (mat3(U[15].xyz, U[16].xyz, U[17].xyz))
#define u_transformBlue (mat3(U[18].xyz, U[19].xyz, U[20].xyz))
#define u_iterations (int(U[21].x))
#define u_orbitSize (U[22].x)
#define u_julianess (U[23].x)
#define u_power (U[24].x)





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





















































































































































































































































































































































vec2 tf(mat3 m, vec2 u) {
    return (m * vec3(u, 1.)).xy;
}

float orbit(vec2 z, float orbitSize, mat3 t, int type) {
	//return 1.0/(abs(length(z) - 1.0));
    vec2 tz = tf(t, z);
    if (type==0) return length(tz);
    else if (type==1) return abs(length(tz) - orbitSize);
	else if (type==2)  return abs(tz.y);
    else return abs(max(abs(tz.x), abs(tz.y)) - orbitSize); 
}

float pointOrbit(vec2 z, vec2 a) {
	return length(z-a);
}

vec4 mandelbrotOrbits(vec2 pos, vec2 outPos, int mode, mat3 modelTransform, mat3 offsetTransform, mat3 transformRed, mat3 transformGreen, mat3 transformBlue, int iterations, float orbitSize, float julianess, float power) {
            float cj = cos(julianess * PI*0.5);
            float sj = sin(julianess * PI*0.5);
            
            mat3 invModelTransform = inverse(modelTransform);
            mat3 tR = inverse(transformRed);
            mat3 tG = inverse(transformGreen);
            mat3 tB = inverse(transformBlue); 
            int modeR = mode & 3;
            int modeG = (mode/4) & 3;
            int modeB = (mode/16) & 3;
            
            vec2 uv = tf(invModelTransform, pos);
            vec2 t = cj*uv + sj*offsetTransform[2].xy;
            vec2 z0 = sj*uv + cj*offsetTransform[2].xy;
            
            vec2 z = z0;
        
            vec2 prev = t;
        
            int iter = 0;
            float d2 = 0.0;
            bool outside = true;
            
            float distR = INF;
            float distG = INF;
            float distB = INF;       
            
        
            if (power == 2.0) {
                while (iter < iterations) {
                    ++iter;
                    prev = z;
                    z.x = prev.x*prev.x - prev.y*prev.y + t.x;
                    z.y = 2.0*prev.x*prev.y + t.y;
                    d2 = dot(z, z);
                    
                    distR = min(distR, orbit(z, orbitSize, tR, modeR));
                    distG = min(distG, orbit(z, orbitSize, tG, modeG));
                    distB = min(distB, orbit(z, orbitSize, tB, modeB));
                    
//                    distR = min(distR, pointOrbit(z, -transformRed[2].xy) * length(transformRed[0]));
//                    distG = min(distG, pointOrbit(z, -transformGreen[2].xy) * length(transformGreen[0]));
//                    distB = min(distB, pointOrbit(z, -transformBlue[2].xy) * length(transformBlue[0]));
                    
                    if (d2 > 400000000.0) {
                        outside = false;
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
                    
                    distR = min(distR, pointOrbit(z, -transformRed[2].xy) * length(transformRed[0]));
                    distG = min(distG, pointOrbit(z, -transformGreen[2].xy) * length(transformGreen[0]));
                    distB = min(distB, pointOrbit(z, -transformBlue[2].xy) * length(transformBlue[0]));
                    
                    if (d2 > 400000000.0) {
                        outside = false;
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
        
                    distR = min(distR, pointOrbit(z, -transformRed[2].xy) * length(transformRed[0]));
                    distG = min(distG, pointOrbit(z, -transformGreen[2].xy) * length(transformGreen[0]));
                    distB = min(distB, pointOrbit(z, -transformBlue[2].xy) * length(transformBlue[0]));
                    
                    d = length(z);
                    if (d > 20000.0) {
                        outside = false;
                        break;
                    }
                }
        
                d2 = d*d;
            }
        
        
            float angle = 0.0;
            float d = sqrt(d2);
            float ty = 1.0 + float(iter) - log(log(d))/log(power);
            float grey = (1.0/ty);
            return vec4(distR, distG, distB, 1.0);
        }

void main() {
    fragColor = mandelbrotOrbits((inverse(u_viewTransform) * vec3(((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), 1.0)).xy, ((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), u_mode, u_modelTransform, u_offsetTransform, u_transformRed, u_transformGreen, u_transformBlue, u_iterations, u_orbitSize, u_julianess, u_power);
}
