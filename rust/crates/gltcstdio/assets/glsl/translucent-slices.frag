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
#define u_intensity (U[6].x)
#define u_count (int(U[7].x))
#define u_overlap (U[8].x)
#define u_dampening (U[9].x)
#define u_mode (int(U[10].x))
#define u_model3DTransform (mat4(U[11], U[12], U[13], U[14]))

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





















































































































































































































































































































































vec4 getBackground(vec3 dir) {
    return vec4(0.0, 0.0, 0.0, 1.0);
}

float luma(vec3 c) {
    return (0.2989*c.r + 0.587*c.g + 0.114*c.b);
}

vec4 mergeColorOpacifying(vec4 bkg, vec4 front) {
    float a = (1.0-bkg.a)*(1.0-front.a);
    return vec4(mix(bkg.rgb, front.rgb, front.a + a), 1.0-a);
}

vec4 translucentSlices(vec2 pos, vec2 outPos, float intensity, int count, float overlap, float dampening, int mode, mat4 model3DTransform, vec2 sourceDim) {
            vec4 backgroundColor = vec4(0.0, 0.0, 0.0, 1.0);
            
            float D = 0.5;
            vec3 cameraPos = vec3(0., 0., 0.);
//            cameraPos = mat3(model3DTransform) * cameraPos;
            mat4 m = inverse(model3DTransform);
            cameraPos = (m * vec4(cameraPos, 1.)).xyz;
            vec3 dir = normalize(vec3(pos.x*D, pos.y*D, -1.0));
            dir = mat3(m) * dir;
    
            vec4 col = vec4(0.);
    
            if (dir.z==0.0) return col;
            float N = float(count);
            float layerSize = (1.0 + overlap*(N-1.0)) / N; // in luminosity "units"
            float layerOpaqueSize = 0.5 / N; // in luminosity "units"
            float maxDist = layerSize*.5-layerOpaqueSize;
            float layerOffset = (1.0-layerSize) / max(1.0, N-1.0); // in luminosity "units"
            float mid = (N-1.0) * .5;
            float zStep = D*2. * intensity/max(1.0, N-1.0);
            bool clip = mode==0;
            bool dual = false;
            float ratio = sourceDim.x/sourceDim.y;

            bool iterDir = dir.z*intensity>0.0;
            int i = iterDir ? 0 : count-1;
            int di = iterDir ? 1 : -1;
            while(true) {
                float z =  zStep * (float(i)-mid);
                float k = (z-cameraPos.z)/dir.z;
                if (dual || k>0.) {
                    vec2 uv = dir.xy * k + cameraPos.xy;
                    if (!clip || (abs(uv.x)<ratio && abs(uv.y)<1.)) {
                        vec4 sampleCol = __source__(uv);
                        float lum = luma(sampleCol.rgb);
                        float layerStart = layerOffset * float(i);
                        float layerEnd = layerStart + layerSize;
                        if (lum>=layerStart && lum<=layerEnd) { 
                            float lumCenter = (float(i)+.5)/N;
                            float lDist = abs(lum-lumCenter);
                            if (lDist<=layerOpaqueSize) {
                                col = mergeColorOpacifying(col, sampleCol);
                            }
                            else {
                                float ka = pow( max(0., 1.0-(lDist-layerOpaqueSize)/maxDist) , pow(10., dampening));
                                //col = mix(col, sampleCol, dampening);
                                col = mergeColorOpacifying(col, vec4(sampleCol.rgb, sampleCol.a*ka));
                                //col = mergeColorOpacifying(col, vec4(1.0, 0., 0., 0.2));
                            }
                            
                            if (col.a>0.995) break;
                        }
                    }
                }
                i += di;
                if ((iterDir && i>=count) || (!iterDir && i<0)) break;
                
            }
            
            col = mergeColorOpacifying(getBackground(dir), col);
                        
            return vec4(col.rgb, 1.);
        }

void main() {
    fragColor = translucentSlices((inverse(u_viewTransform) * vec3(((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), 1.0)).xy, ((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), u_intensity, u_count, u_overlap, u_dampening, u_mode, u_model3DTransform, u_sourceDim);
}
