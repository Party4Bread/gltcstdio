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
#define u_iterations (int(U[7].x))
#define u_tolerance (U[8].x)
#define u_vignetting (U[9].x)
#define u_dampening (U[10].x)
#define u_color (U[11])
#define u_modelTransform (mat3(U[12].xyz, U[13].xyz, U[14].xyz))

#define __source__texelFetch__(c) texelFetch(u_source, (c), 0)
#define __source__(p) texture(u_source, __mirror_wrap__(vec2((p).x / u_worldAspect, (p).y) / 2.0 + 0.5))




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

float colorWeight(vec4 color, vec4 refColor, float tolerance) {
    float d = length(color.rgb-refColor.rgb);
    float maxDistance = tolerance*1.7320508075688772;
    return smoothstep(maxDistance, maxDistance*0.5, d);
}

vec2 tf(mat3 m, vec2 u) {
    return (m * vec3(u, 1.)).xy;
}

vec4 ghosting(vec2 uv, vec2 outPos, vec2 sourceDim, int mode, int iterations, float tolerance, float vignetting, float dampening, vec4 color, mat3 modelTransform) {
    mat3 inverseModelTransform = inverse(modelTransform);
    vec2 u = tf(inverseModelTransform, uv);
 
    vec4 totalColor = vec4(0.0, 0.0, 0.0, 0.0);
    float totalWeight = 0.0;
    vec2 delta = (u-uv) / float(iterations);
    float radius = min(1.0, sourceDim.x/sourceDim.y)*1.1;
    vec4 outColor;
    
    vec2 p = uv;
    if (mode==0) {
        for(int i=0; i<iterations; ++i) {
            vec4 color = __source__(p);
            float centrality = vignetting==0.0 ? 1. : smoothstep(radius/vignetting, radius*0.6, length(p));
            float weight = i==0 ? 1.0 : pow(1.0-dampening, float(i)/float(iterations-1)) * centrality;
            //float weight = 1.;
            totalColor += weight * color;
            totalWeight += weight;
            p += delta;
        }

        outColor = totalColor / totalWeight;
    }
    else if (mode==1) {
         for(int i=0; i<iterations; ++i) {
            vec4 color = __source__(p);
            if (i==0) totalColor = color;
            else {
                if ((color.r+color.g+color.b) >= pow(1.0-dampening, float(i)/float(iterations-1))*(totalColor.r+totalColor.g+totalColor.b)) totalColor = color;
            }
            float centrality = (vignetting==0.0) ? 1. : smoothstep(radius/vignetting, radius*0.6, length(p));
            outColor = i==0 ? totalColor : mix(outColor, totalColor, centrality);
            p += delta;
        }
    }
   else if (mode==2) {
         for(int i=0; i<iterations; ++i) {
            vec4 color = __source__(p);
            if (i==0) totalColor = color;
            else {
                if ((color.r+color.g+color.b) <= pow(1.0-dampening, float(i)/float(iterations-1))*(totalColor.r+totalColor.g+totalColor.b)) totalColor = color;
            }
            float centrality = (vignetting==0.0) ? 1. : smoothstep(radius/vignetting, radius*0.6, length(p));
            outColor = i==0 ? totalColor : mix(outColor, totalColor, centrality);
            p += delta;
        }           
    }
   else {
       for(int i=0; i<iterations; ++i) {
            vec4 col = __source__(p);
            float centrality = vignetting==0.0 ? 1. : smoothstep(radius/vignetting, radius*0.6, length(p));
            float weight = i==0 ? 1.0 : pow(1.0-dampening, float(i)/float(iterations-1)) * centrality * colorWeight(col, color, tolerance);
            //float weight = 1.;
            totalColor += weight * col;
            totalWeight += weight;
            p += delta;
        }

        outColor = totalColor / totalWeight;
    }
    
    return outColor;
}

void main() {
    fragColor = ghosting((inverse(u_viewTransform) * vec3(((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), 1.0)).xy, ((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), u_sourceDim, u_mode, u_iterations, u_tolerance, u_vignetting, u_dampening, u_color, u_modelTransform);
}
