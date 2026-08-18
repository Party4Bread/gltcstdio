#version 450
layout(location = 0) in vec2 v_uv;
layout(location = 0) out vec4 fragColor;

layout(binding = 0, std140) uniform Params {
    vec4 U[10];
};
layout(binding = 1) uniform sampler samp;

#define u_worldAspect (U[0].x)
#define u_viewTransform (mat3(U[1].xyz, U[2].xyz, U[3].xyz))
#define u_outDim (U[4].xy)
#define u_modelTransform (mat3(U[5].xyz, U[6].xyz, U[7].xyz))
#define u_count (int(U[8].x))
#define u_orbitSize (U[9].x)





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
























































































































































































































































































































































void constants() {
}

vec2 complexExp(vec2 u) {
    return exp(u.x) * vec2(cos(u.y), sin(u.y));
}

vec2 complexMul(vec2 u, vec2 v) {
    return vec2(u.x*v.x-u.y*v.y, dot(u, v.yx));  
}

vec2 gg(vec2 z, vec2 c) {
    //return complexMul(z,c) - 1.0*complexExp(z-c) + c;
    //return ((7.0*z+2.0) - complexMul(5.0*z+2.0, complexExp(vec2(-PI*c.y, PI*c.x)))) * 0.25;
    //return ((7.0*z+2.0) - complexMul(5.0*c+2.0, complexExp(PI*(complexMul(z,c))))) * 0.25;
    return complexMul(z, z) + c;
}

float orbit(vec2 z, float orbitSize) {
	//return 1.0/(abs(length(z) - 1.0));
	return abs(length(z) - orbitSize);
    /*float d = orbitSize;
    vec2 zz = abs(z-vec2(-0.0, 0.0));
    return min(length(zz-vec2(min(d, zz.x), 0.0)), length(zz-vec2(0.0, min(d, zz.y))));*/ 
}

vec4 mandelbrot(vec2 pos, vec2 outPos, mat3 modelTransform, int count, float orbitSize) {
    constants();
    vec3 lookDir = normalize(vec3(pos, 1.0));
    vec2 uv = (inverse(modelTransform) * vec3(pos, 1.0)).xy;
    
    float dist = INF;
    float distx = INF;
    float disty = INF;
    vec2 z = vec2(0.0, 0.0);
   
    float delta = 0.001/length(modelTransform[0].xy);
    vec2 uvx = uv + vec2(delta, 0.0);
    vec2 uvy = uv + vec2(0.0, delta);
    vec2 zx = z;
    vec2 zy = z;
    for(int i = 0; i<count; ++i) {
        z = gg(z, uv);    
        zx = gg(zx, uvx);
        zy = gg(zy, uvy);
        
        dist = min(dist, orbit(z, orbitSize));
        distx = min(distx, orbit(zx, orbitSize));
        disty = min(disty, orbit(zy, orbitSize));
    }
    //float g = i==N ? 1.0 : i/N;
    //g = (1.0-dist*0.05)*0.05;
    float g = dist;
    
    vec3 normal = normalize(vec3((distx-dist)/delta, (disty-dist)/delta, 1.0));
    vec3 sourceDir = normalize(vec3(0.0, 0.5, 1.0));
    float lum = smoothstep(-1.0, 1.0, dot(sourceDir, normal)) * 0.7;
    float specular = dot(lookDir, reflect(sourceDir, normal));
    //lum += 0.7*smoothstep(0.99, 1.0, specular) + 0.2*smoothstep(0.95, 1.0, specular);
    lum += 0.7*pow(smoothstep(0.95, 1.0, specular), 3.0);
    
    return vec4(vec3(lum), 1.0);
}

void main() {
    fragColor = mandelbrot((inverse(u_viewTransform) * vec3(((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), 1.0)).xy, ((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), u_modelTransform, u_count, u_orbitSize);
}
