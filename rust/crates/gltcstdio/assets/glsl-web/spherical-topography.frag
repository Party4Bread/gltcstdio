#version 450
layout(location = 0) in vec2 v_uv;
layout(location = 0) out vec4 fragColor;

layout(binding = 0, std140) uniform Params {
    vec4 U[19];
};
layout(binding = 1) uniform sampler samp;
layout(binding = 2) uniform texture2D t_source;
layout(binding = 3) uniform texture2D t_sourceBkg;

#define u_source sampler2D(t_source, samp)
#define u_sourceBkg sampler2D(t_sourceBkg, samp)
#define u_worldAspect (U[0].x)
#define u_viewTransform (mat3(U[1].xyz, U[2].xyz, U[3].xyz))
#define u_sourceDim (U[4].xy)
#define u_sourceBkg_specified (int(U[5].x))
#define u_outDim (U[6].xy)
#define u_intensity (U[7].x)
#define u_count (int(U[8].x))
#define u_overlap (U[9].x)
#define u_colorFog (U[10])
#define u_mode (int(U[11].x))
#define u_kernelRadius (U[12].x)
#define u_colorKernel (U[13])
#define u_blend (U[14].x)
#define u_model3DTransform (mat4(U[15], U[16], U[17], U[18]))

#define __source__texelFetch__(c) texelFetch(u_source, (c), 0)
#define __source__(p) textureLod(u_source, (vec2((p).x / u_worldAspect, (p).y) / 2.0 + 0.5), 0.0)
#define __sourceBkg__texelFetch__(c) texelFetch(u_sourceBkg, (c), 0)
#define __sourceBkg__(p) textureLod(u_sourceBkg, (vec2((p).x / u_worldAspect, (p).y) / 2.0 + 0.5), 0.0)




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

vec3 sphereFirstIntersection(vec3 center, float radius, vec3 origin, vec3 dir) {
    vec3 relOrigin = origin-center;
    float a = dot(dir, dir);
    float b = 2.0*dot(dir, relOrigin);
    float c = dot(relOrigin, relOrigin) - radius*radius;
    float delta = b*b - 4.0*a*c;
    if (delta>=0.0) {
        float sqrtDelta = sqrt(delta);
        float l1 = (-b - sqrtDelta) / (2.0*a);
        if (l1>0.0) {
            return origin + l1*dir;
        }
    }
    return vec3(INF);
}

vec3 sphereLastIntersection(vec3 center, float radius, vec3 origin, vec3 dir) {
    vec3 relOrigin = origin-center;
    float a = dot(dir, dir);
    float b = 2.0*dot(dir, relOrigin);
    float c = dot(relOrigin, relOrigin) - radius*radius;
    float delta = b*b - 4.0*a*c;
    if (delta>=0.0) {
        float sqrtDelta = sqrt(delta);
        float l2 = (-b + sqrtDelta) / (2.0*a);
        if (l2>0.0) {
            return origin + l2*dir;
        }
    }
    return vec3(INF);
}

vec4 sphericalTopography(vec2 pos, vec2 outPos, vec2 sourceDim, float intensity, int count, float overlap, 
        int sourceBkg_specified, vec4 colorFog, int mode, float kernelRadius, vec4 colorKernel, float blend,
        mat4 model3DTransform) {
            vec4 backgroundColor = vec4(0.0, 0.0, 0.0, 1.0);
            float ratio = sourceDim.x/sourceDim.y;
            float blendedWidth = sourceDim.x * (1.0-blend*0.5);
            float blendedRatio = blendedWidth / sourceDim.y;
            
            float D = 1.0;
            vec3 cameraPos = vec3(0., 0., 0.);
//            cameraPos = mat3(model3DTransform) * cameraPos;
            mat4 m = inverse(model3DTransform);
            cameraPos = (m * vec4(cameraPos, 1.)).xyz;
            vec3 dir = vec3(pos.x*D, pos.y*D, -1.0);
            dir = normalize(mat3(m) * dir);
            
//            float D = 5.;
//            vec3 cameraPos = vec3(0., 0., D);
//            cameraPos = ((model3DTransform) * vec4(cameraPos, 1.)).xyz;
//            vec3 target = vec3(0.);
//            vec3 dir = getRay(pos, cameraPos, target, D);


            float kFog = 1e9;
            vec4 col = colorFog.a!=0.0 ? vec4(colorFog.rgb, 1.0) : sourceBkg_specified==1 ? __sourceBkg__(outPos) : vec4(0.0, 0.0, 0.0, 1.0);
    
            if (dir.z==0.0) return col;
            float N = float(count);
            float layerSize = (1.0 + overlap*(N-1.0)) / N; // in luminosity "units"
            float layerOffset = (1.0-layerSize) / max(1.0, N-1.0); // in luminosity "units"
            float mid = (N-1.0) * .5;
            //float zStep = D*2. * intensity/max(1.0, N-1.0);
            
            if (mode==2) intensity = -intensity;

            vec3 normalPoint = cameraPos + dot(dir, -cameraPos)*dir;
            float kNormal = dot(normalPoint-cameraPos, dir);
            float startLayer = (length(cameraPos)-1.0)*N/intensity + mid;
            float normalLayer = (length(normalPoint)-1.0)*N/intensity + mid;
//            float N0 = kNormal>=0.0 ? ceil(startLayer) : floor(startLayer);
//            float N1 = kNormal>=0.0 ? floor(normalLayer) : N-1.0;
            float iterDir = (mode==2 ? -1.0 : 1.0) * (intensity >= 0.0 ? 1.0 : -1.0);
            float N0 = clamp(ceil(startLayer), 0.0, N-1.);
            float N1 = clamp(floor(normalLayer), 0.0, N-1.);
            float N2 = (iterDir>=0.0) ? N-1.0 : 0.0;
            
            float opacity = 0.0;
            
            vec3 intersection;      
            if (N0*iterDir>=N1*iterDir) {
                for(float i=N0; i*iterDir>=N1*iterDir; i -= iterDir) {
                    float radius = 1.0 + (i-mid)/N*intensity;
                    intersection = sphereFirstIntersection(vec3(0.), radius, cameraPos, dir);
                    if (intersection.x<INF) {
                        float angle = atan(intersection.x, intersection.z);

                        vec4 sampleCol;
                        float x = angle/PI;
                        float X = x * (1.0+blend); 
                        if (abs(x)<=1.0-blend) {
                            vec2 q = vec2(x/(1.0+blend)*ratio, intersection.y/radius);
                            sampleCol = __source__(q);
                        }
                        else {
                            float x1 = x/(1.0+blend);
                            float x2 = sign(x) * (-1. + (abs(x)-(1.0-blend))/(1.0+blend));
                            vec2 q1 = vec2(x1*ratio, intersection.y/radius);
                            vec2 q2 = vec2(x2*ratio, intersection.y/radius);
                            float k = 0.5*(abs(x)-(1.0-blend))/blend;
                            sampleCol = mix(__source__(q1), __source__(q2), k);
                        }                            
                        
                        if (radius<=kernelRadius) {
                            kFog = length(cameraPos - intersection);
                            col = mergeColor(sampleCol, colorKernel); 
                            opacity = 1.0;
                            break;                         
                        } 
                        float lum = luma(sampleCol.rgb);
                        float layerStart = layerOffset * float(i);
                        float layerEnd = layerStart + layerSize;
                        if (lum>=layerStart && lum<=layerEnd) { 
                            kFog = length(cameraPos - intersection);
                            col = sampleCol; 
                            opacity = 1.0;
                            break; 
                        }
                    }
                }
            }
            if (opacity!=1.0 && N1*iterDir<=N2*iterDir) {
                for(float i=N1; i*iterDir<=N2*iterDir; i += iterDir) {
                    float radius = 1.0 + (i-mid)/N*intensity;
                    intersection = sphereLastIntersection(vec3(0.), radius, cameraPos, dir);
                    if (intersection.x<INF) {
                        float angle = atan(intersection.x, intersection.z);
                        
                        vec4 sampleCol;
                        float x = angle/PI;
                        float X = x * (1.0+blend); 
                        if (abs(x)<=1.0-blend) {
                            vec2 q = vec2(x/(1.0+blend)*ratio, intersection.y/radius);
                            sampleCol = __source__(q);
                        }
                        else {
                            float x1 = x/(1.0+blend);
                            float x2 = sign(x) * (-1. + (abs(x)-(1.0-blend))/(1.0+blend));
                            vec2 q1 = vec2(x1*ratio, intersection.y/radius);
                            vec2 q2 = vec2(x2*ratio, intersection.y/radius);
                            float k = 0.5*(abs(x)-(1.0-blend))/blend;
                            sampleCol = mix(__source__(q1), __source__(q2), k);
                        }        
                        
                        if (radius<=kernelRadius) {
                            kFog = length(cameraPos - intersection);
                            col = mergeColor(sampleCol, colorKernel); 
                            opacity = 1.0;
                            break;                         
                        } 
                        float lum = luma(sampleCol.rgb);
                        float layerStart = layerOffset * float(i);
                        float layerEnd = layerStart + layerSize;
                        if (lum>=layerStart && lum<=layerEnd) { 
                            kFog = length(cameraPos - intersection);
                            col = sampleCol; 
                            opacity = 1.0;
                            break; 
                        }
                    }
                }            
            }
            
            if (colorFog.a!=0.0) {
                float nearDist = 2.0 * (1.-colorFog.a);
                float farDist = 2.*nearDist;
                kFog = smoothstep(nearDist, farDist, kFog); //1.0 - pow(0.4, colorFog.a * max(0.0, kFog-0.1));
                col.rgb = mix(col.rgb, colorFog.rgb, kFog);
            }
//     col.r = (length(normalPoint)>=1.0 ? 1.0 : 0.0);
//     col.g = (length(normalPoint)>=1.5 ? 1.0 : 0.0);
            return col;
        }

void main() {
    fragColor = sphericalTopography((inverse(u_viewTransform) * vec3(((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), 1.0)).xy, ((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), u_sourceDim, u_intensity, u_count, u_overlap, u_sourceBkg_specified, u_colorFog, u_mode, u_kernelRadius, u_colorKernel, u_blend, u_model3DTransform);
}
