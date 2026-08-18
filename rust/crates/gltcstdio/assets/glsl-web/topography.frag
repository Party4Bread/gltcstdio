#version 450
layout(location = 0) in vec2 v_uv;
layout(location = 0) out vec4 fragColor;

layout(binding = 0, std140) uniform Params {
    vec4 U[16];
};
layout(binding = 1) uniform sampler samp;
layout(binding = 2) uniform texture2D t_source;
layout(binding = 3) uniform texture2D t_sourceBkg;

#define u_source sampler2D(t_source, samp)
#define u_sourceBkg sampler2D(t_sourceBkg, samp)
#define u_worldAspect (U[0].x)
#define u_viewTransform (mat3(U[1].xyz, U[2].xyz, U[3].xyz))
#define u_sourceBkg_specified (int(U[4].x))
#define u_sourceDim (U[5].xy)
#define u_outDim (U[6].xy)
#define u_intensity (U[7].x)
#define u_count (int(U[8].x))
#define u_overlap (U[9].x)
#define u_mode (int(U[10].x))
#define u_colorFog (U[11])
#define u_model3DTransform (mat4(U[12], U[13], U[14], U[15]))

#define __source__texelFetch__(c) texelFetch(u_source, (c), 0)
#define __source__(p) textureLod(u_source, __mirror_wrap__(vec2((p).x / u_worldAspect, (p).y) / 2.0 + 0.5), 0.0)
#define __sourceBkg__texelFetch__(c) texelFetch(u_sourceBkg, (c), 0)
#define __sourceBkg__(p) textureLod(u_sourceBkg, __mirror_wrap__(vec2((p).x / u_worldAspect, (p).y) / 2.0 + 0.5), 0.0)




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

vec3 getRay(vec2 uv, vec3 camera, vec3 target, float focalDist) {
    vec3 camZ = normalize(target-camera);
    vec3 camX = normalize(cross(vec3(0.,1.,0.), camZ));
    //vec3 camX = normalize(cross(vec3(0.,0.,1.), camZ));
    vec3 camY = cross(camZ,camX);
    return normalize(camZ*focalDist + uv.x*camX + uv.y*camY);
}

float luma(vec3 c) {
    return (0.2989*c.r + 0.587*c.g + 0.114*c.b);
}

vec4 mergeColor(vec4 bkg, vec4 front) {
    return vec4(mix(bkg.rgb, front.rgb, front.a + (1.0-bkg.a)*(1.0-front.a)), max(bkg.a, front.a));
}

vec4 mergeColorOpacifying(vec4 bkg, vec4 front) {
    float a = (1.0-bkg.a)*(1.0-front.a);
    return vec4(mix(bkg.rgb, front.rgb, front.a + a), 1.0-a);
}

vec4 topography(vec2 pos, vec2 outPos, float intensity, int count, float overlap, int mode, 
        int sourceBkg_specified, vec4 colorFog, 
        mat4 model3DTransform, vec2 sourceDim) {
            vec4 backgroundColor = vec4(0.0, 0.0, 0.0, 1.0);
            
            float D = 0.5;
            vec3 cameraPos = vec3(0., 0., 0.);
//            cameraPos = mat3(model3DTransform) * cameraPos;
            mat4 m = inverse(model3DTransform);
            cameraPos = (m * vec4(cameraPos, 1.)).xyz;
            //<ray-dir>
            vec3 dir = normalize(vec3(pos.x*D, pos.y*D, -1.0));
            //</ray-dir>
            dir = mat3(m) * dir;

//            float D = 5.;
//            vec3 cameraPos = vec3(0., 0., D);
////            cameraPos = mat3(model3DTransform) * cameraPos;
//            cameraPos = ((model3DTransform) * vec4(cameraPos, 1.)).xyz;
//            vec3 target = vec3(0.);
//            vec3 dir = getRay(pos, cameraPos, target, D);

//            vec3 cameraPos = vec3(0.0, 0.0, D);
//            vec3 dir = normalize(vec3(pos.x, pos.y, 0.0) - cameraPos);
//            cameraPos = (inverseModel3DTransform * vec4(cameraPos, 1.0)).xyz;
////            cameraPos = (inverse(inverseModel3DTransform) * vec4(cameraPos, 1.0)).xyz;
//            dir = mat3(inverseModel3DTransform) * dir;
            float kFog = 1e9;
            //vec4 col = colorFog.a!=0.0 ? vec4(colorFog.rgb, 1.0) : sourceBkg_specified==1 ? __sourceBkg__(outPos) : vec4(0.0, 0.0, 0.0, 1.0);
            vec4 col = vec4(0.0, 0.0, 0.0, 0.0);

            if (dir.z==0.0) return col;
            float N = float(count);
            float layerSize = (1.0 + overlap*(N-1.0)) / N; // in luminosity "units"
            float layerOffset = (1.0-layerSize) / max(1.0, N-1.0); // in luminosity "units"
            float mid = (N-1.0) * .5;
            float zStep = D*2. * intensity/max(1.0, N-1.0);
            bool clip = mode==0;
            bool dual = false;
            float ratio = sourceDim.x/sourceDim.y;

            bool iterDir = dir.z*intensity>0.0;
            int i = iterDir ? 0 : count-1;
            int di = iterDir ? 1 : -1;
            while (true) {
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
                            vec3 intersection = dir * k + cameraPos;
                            kFog = length(cameraPos - intersection);
                            //col = sampleCol;
                            col = mergeColorOpacifying(col, sampleCol); // works well for fully transparent, not so well for partially transparent
                            if (col.a==1.0) break; 
                        }
                    }
                }
                i += di;
                if ((iterDir && i>=count) || (!iterDir && i<0)) break;    
            }
                    
            if (col.a<1.0) {
                vec4 bkg = colorFog.a!=0.0 ? vec4(colorFog.rgb, 1.0) : sourceBkg_specified==1 ? __sourceBkg__(outPos) : vec4(0.0, 0.0, 0.0, 1.0);
                col = mergeColor(bkg, col);
            }
                    
            if (colorFog.a!=0.0) {
                float nearDist = 2.0 * (1.-colorFog.a);
                float farDist = 2.*nearDist;
                kFog = smoothstep(nearDist, farDist, kFog); //1.0 - pow(0.4, colorFog.a * max(0.0, kFog-0.1));
                col.rgb = mix(col.rgb, colorFog.rgb, kFog);
            }
            
            return col;
        }

void main() {
    fragColor = topography((inverse(u_viewTransform) * vec3(((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), 1.0)).xy, ((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), u_intensity, u_count, u_overlap, u_mode, u_sourceBkg_specified, u_colorFog, u_model3DTransform, u_sourceDim);
}
