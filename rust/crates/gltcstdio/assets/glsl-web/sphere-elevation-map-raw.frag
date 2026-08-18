#version 450
layout(location = 0) in vec2 v_uv;
layout(location = 0) out vec4 fragColor;

layout(binding = 0, std140) uniform Params {
    vec4 U[19];
};
layout(binding = 1) uniform sampler samp;
layout(binding = 2) uniform texture2D t_source;
layout(binding = 3) uniform texture2D t_sourceBkg;
layout(binding = 4) uniform texture2D t_sourceElevation;

#define u_source sampler2D(t_source, samp)
#define u_sourceBkg sampler2D(t_sourceBkg, samp)
#define u_sourceElevation sampler2D(t_sourceElevation, samp)
#define u_worldAspect (U[0].x)
#define u_viewTransform (mat3(U[1].xyz, U[2].xyz, U[3].xyz))
#define u_sourceBkg_specified (int(U[4].x))
#define u_sourceElevation_specified (int(U[5].x))
#define u_sourceDim (U[6].xy)
#define u_sourceElevationDim (U[7].xy)
#define u_outDim (U[8].xy)
#define u_rezolution (int(U[9].x))
#define u_intensity (U[10].x)
#define u_specular (U[11].x)
#define u_sourceColor (U[12])
#define u_ambientColor (U[13])
#define u_colorFog (U[14])
#define u_model3DTransform (mat4(U[15], U[16], U[17], U[18]))

#define __source__texelFetch__(c) texelFetch(u_source, (c), 0)
#define __source__(p) textureLod(u_source, __mirror_wrap__(vec2((p).x / u_worldAspect, (p).y) / 2.0 + 0.5), 0.0)
#define __sourceBkg__texelFetch__(c) texelFetch(u_sourceBkg, (c), 0)
#define __sourceBkg__(p) textureLod(u_sourceBkg, __mirror_wrap__(vec2((p).x / u_worldAspect, (p).y) / 2.0 + 0.5), 0.0)
#define __sourceElevation__texelFetch__(c) texelFetch(u_sourceElevation, (c), 0)
#define __sourceElevation__(p) textureLod(u_sourceElevation, __mirror_wrap__(vec2((p).x / u_worldAspect, (p).y) / 2.0 + 0.5), 0.0)




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

float height(float intensity, vec4 color) {
    return intensity*0.04* ((color.r + color.g + color.b)/3.0 - 0.5);
}

vec3 sphereIntersectionWithNormedDir(vec3 center, float radius, vec3 origin, vec3 dir) {
    vec3 relOrigin = origin-center;
    float a = 1.0;
    float b = 2.0*dot(dir, relOrigin);
    float c = dot(relOrigin, relOrigin) - radius*radius;
    float delta = b*b - 4.0*a*c;
    if (delta>=0.0) {
        float sqrtDelta = sqrt(delta);
        float l1 = (-b - sqrtDelta) / (2.0*a);
        float l2 = (-b + sqrtDelta) / (2.0*a);
        float l = l1>0.0 ? l1 : (l2>0.0 ? l2 : -1.0);
        if (l>0.0) {
            return origin + l*dir;
        }
    }
    return vec3(INF);
}

vec4 sphereElevationMap(vec2 pos, vec2 outPos, int sourceBkg_specified, int sourceElevation_specified, vec2 sourceDim, vec2 sourceElevationDim, int rezolution, float intensity, float specular, vec4 sourceColor, vec4 ambientColor, vec4 colorFog, mat4 model3DTransform) {
    vec4 backgroundColor = vec4(0.0, 0.0, 0.0, 1.0);
    float D = 1.0;
    vec3 cameraPos = vec3(0., 0., 0.);
//            cameraPos = mat3(model3DTransform) * cameraPos;
    mat4 m = inverse(model3DTransform);
    cameraPos = (m * vec4(cameraPos, 1.)).xyz;
    vec3 dir = vec3(pos.x*D, pos.y*D, -1.0);
    dir = normalize(mat3(m) * dir);

    float maxZ = abs(intensity)*0.02;
    bool heightMap = sourceElevation_specified==1;
    float ratio = heightMap ? (sourceElevationDim.x/sourceElevationDim.y) : (sourceDim.x/sourceDim.y);
    float dk = heightMap ? 2.0/sourceElevationDim.y : 2.0/sourceDim.y;
    vec3 step = dir * dk;

    float fResolution = float(rezolution);
    float ballSize = 2.0/fResolution;
    maxZ += ballSize;
    float surfaceWidth = round((2.0*ratio)/ballSize)*ballSize;
    float surfaceHeight = 2.0;

    float k1 = 0.0;
    float k2 = 100000000.0;
    
    if (dir.x!=0.0) {
        float s = sign(dir.x);
        float k3 = (-s*surfaceWidth/2.0-cameraPos.x)/dir.x;
        float k4 = (s*surfaceWidth/2.0-cameraPos.x)/dir.x;
        k1 = max(k1, k3);
        k2 = min(k2, k4);
    }
    
    if (dir.y!=0.0) {
        float s = sign(dir.y);
        float k3 = (-s-cameraPos.y)/dir.y;
        float k4 = (s-cameraPos.y)/dir.y;
        k1 = max(k1, k3);
        k2 = min(k2, k4);
    }

    float maxZ2 = maxZ+0.0001; // prevent flickering on edge case
    if (dir.z!=0.0) {
        float s = sign(dir.z);
        float k3 = (-s*maxZ2-cameraPos.z)/dir.z;
        float k4 = (s*maxZ2-cameraPos.z)/dir.z;
        k1 = max(k1, k3);
        k2 = min(k2, k4);
    }

//    if (k1>k2) return getBackground(outPos);
    if (k1>k2) return colorFog.a!=0.0 ? vec4(colorFog.rgb, 1.0) : sourceBkg_specified==1 ? __sourceBkg__(outPos) : vec4(0.0, 0.0, 0.0, 1.0);

    float k = k1;
    vec3 p = cameraPos + k*dir;

//    vec4 color = getBackground(outPos);
    vec4 color = colorFog.a!=0.0 ? vec4(colorFog.rgb, 1.0) : sourceBkg_specified==1 ? __sourceBkg__(outPos) : vec4(0.0, 0.0, 0.0, 1.0);
    float h = 0.0;
    float dz = 0.0;
    float prevDz;
    vec4 prevColor;
    float prevH;
    bool stop;

    float strideX = sign(dir.x) * ballSize;
    float strideY = sign(dir.y) * ballSize;

    float intersected = 0.0;
    float kFog = 1e9;

    vec4 outColor = vec4(0.0, 0.0, 0.0, 0.0);//color; //backgroundColor;
    vec2 nextLines = sign(dir.xy)*ballSize/2.0; //vec2(sign(dir.x)*ballSize, sign(dir.y)*ballSize)/2.0;
int maxIter = 1000;
    while (intersected<1.0 && k<=k2 && maxIter>0) {
        // compute pixel center
        float indexX = (p.x+surfaceWidth/2.0)/ballSize;
        float indexY = (p.y+surfaceHeight/2.0)/ballSize;
        float fX = fract(indexX);
        float fY = fract(indexY);
        vec3 sphereCenter;

        if (fX>0.9999 && dir.x>0.0) sphereCenter.x = (ceil(indexX)+0.5)*ballSize;
        else if (fX<0.0001 && dir.x<0.0) sphereCenter.x = (floor(indexX)-0.5)*ballSize;
        else
        sphereCenter.x = (floor(indexX)+0.5)*ballSize;
        sphereCenter.x -= surfaceWidth/2.0;

        if (fY>0.9999 && dir.y>0.0) sphereCenter.y = (ceil(indexY)+0.5)*ballSize;
        else if (fY<0.0001 && dir.y<0.0) sphereCenter.y = (floor(indexY)-0.5)*ballSize;
        else
        sphereCenter.y = (floor(indexY)+0.5)*ballSize;
        sphereCenter.y -= surfaceHeight/2.0;
//        sphereCenter = p;

        // compute height and color
        vec4 hColor = heightMap ? __sourceElevation__(sphereCenter.xy) : __source__(sphereCenter.xy);
        sphereCenter.z = height(intensity, hColor);

        // compute sphere intersection
        if (/*abs(sphereCenter.z-p.z)<ballSize &&*/ abs(sphereCenter.x)<surfaceWidth/2.0 && abs(sphereCenter.y)<surfaceHeight/2.0) {
            vec3 intersection = sphereIntersectionWithNormedDir(sphereCenter, ballSize/2.0, cameraPos, dir);

            if (intersection.x!=INF) {
                kFog = length(cameraPos - intersection.xyz);
                vec4 col = __source__(sphereCenter.xy);
                vec4 sampled = col * vec4(ambientColor.rgb*2.0, ambientColor.a);
                if (length(sourceColor.rgb)!=0.0) { // light source
                    vec3 normal = intersection-sphereCenter;

                    if (length(normal)>0.0) {
                        float alpha = sampled.a;
                        normal = normalize(normal);
                        vec3 lightDir = normalize(vec3(1.0, 1.0, 1.0));
                        sampled += col*vec4(sourceColor.rgb*2.0, 1.0) * clamp(dot(lightDir, normal), 0.0, 1.0);

                        if (specular!=0.0) {
                            vec3 reflectLightDir = reflect(lightDir, normal);
                            float spec = specular;
                            vec4 specularColor = sourceColor * (specular<0.25?specular*4.0:1.0) * pow(clamp(dot(dir, reflectLightDir), 0.0, 1.0), 10.0-specular*10.0);//(dot(dir, reflectLightDir)) * vec4(spec, spec, spec, 1.0);
                            sampled = sampled + specularColor;
                        }
                        sampled.a = alpha;
                    }
                    
//                    sampled.rgb = normal + 0.5;
                }

                outColor =  intersected==0.0 ? sampled : vec4(mix(outColor.rgb, sampled.rgb, intersected/(intersected+sampled.a)), outColor.a+(1.0-outColor.a)*sampled.a);
                intersected += sampled.a;
            }

        }


        // advance
        vec2 next = sphereCenter.xy + nextLines;
        vec2 deltaK = (next-p.xy)/dir.xy;
        float minK = min(deltaK.x, deltaK.y); //if (minK<0.0001) minK = max(deltaK.x, deltaK.y);
        k += minK;
        p += minK*dir;
        --maxIter;
    }
    
    color = mix(color, vec4(outColor.rgb, color.a), outColor.a);
    
    if (colorFog.a!=0.0) {
        float nearDist = 2.0 * (1.-colorFog.a);
        float farDist = 2.*nearDist;
        kFog = smoothstep(nearDist, farDist, kFog); //1.0 - pow(0.4, colorFog.a * max(0.0, kFog-0.1));
        color.rgb = mix(color.rgb, colorFog.rgb, kFog);
    }
    
    return clamp(color, 0.0, 1.0);
}

void main() {
    fragColor = sphereElevationMap((inverse(u_viewTransform) * vec3(((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), 1.0)).xy, ((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), u_sourceBkg_specified, u_sourceElevation_specified, u_sourceDim, u_sourceElevationDim, u_rezolution, u_intensity, u_specular, u_sourceColor, u_ambientColor, u_colorFog, u_model3DTransform);
}
