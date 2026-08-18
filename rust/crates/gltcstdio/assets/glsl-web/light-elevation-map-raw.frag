#version 450
layout(location = 0) in vec2 v_uv;
layout(location = 0) out vec4 fragColor;

layout(binding = 0, std140) uniform Params {
    vec4 U[18];
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
#define u_shape (U[11].x)
#define u_brightness (U[12].x)
#define u_bokeh (U[13].x)
#define u_model3DTransform (mat4(U[14], U[15], U[16], U[17]))

#define __source__texelFetch__(c) texelFetch(u_source, (c), 0)
#define __source__(p) textureLod(u_source, (vec2((p).x / u_worldAspect, (p).y) / 2.0 + 0.5), 0.0)
#define __sourceBkg__texelFetch__(c) texelFetch(u_sourceBkg, (c), 0)
#define __sourceBkg__(p) textureLod(u_sourceBkg, (vec2((p).x / u_worldAspect, (p).y) / 2.0 + 0.5), 0.0)
#define __sourceElevation__texelFetch__(c) texelFetch(u_sourceElevation, (c), 0)
#define __sourceElevation__(p) textureLod(u_sourceElevation, (vec2((p).x / u_worldAspect, (p).y) / 2.0 + 0.5), 0.0)




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





















































































































































































































































































































































float getDampening(float shape, vec2 pos, float ratio) {
    if (shape==0.) return 1.;
    else if (shape<0.25) {
        float p = pow(2., 0.25/shape);
//        float p = pow(2., mix(100., 1., shape*4.));
        return pow(pow(abs(pos.x)/ratio, p) + pow(abs(pos.y), p), 1./p)<1. ? 1. : 0.;
    }
    else if (shape<0.5) {
        float k = (shape-.25)* 4.;
        vec2 rr = ratio<1. ? vec2(1./ratio, 1./ratio) : vec2(1., 1.);
        return length(pos*mix(vec2(1./ratio, 1.), rr, k))<1. ? 1. : 0.;
    }
    else {
        float k = (shape-.5)*2.;
        float minR = min(ratio, 1.);
        return smoothstep(minR, minR*(1.-k), length(pos));
    }    
}

float getHeight(float intensity, vec4 color) {
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

vec4 sphereElevationMap(vec2 pos, vec2 outPos, int sourceBkg_specified, int sourceElevation_specified, 
    vec2 sourceDim, vec2 sourceElevationDim, int rezolution, float intensity,  float shape, float brightness, float bokeh,
    mat4 model3DTransform ) {
    
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
    if (k1>k2) return sourceBkg_specified==1 ? __sourceBkg__(outPos) : vec4(0.0, 0.0, 0.0, 1.0);

    float k = k1;
    vec3 p = cameraPos + k*dir;

//    vec4 color = getBackground(outPos);
    vec4 color = sourceBkg_specified==1 ? __sourceBkg__(outPos) : vec4(0.0, 0.0, 0.0, 1.0);
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

    vec4 outColor = color;
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
        float height = getHeight(intensity, hColor);
        sphereCenter.z = height;

        // compute sphere intersection
        if (/*abs(sphereCenter.z-p.z)<ballSize &&*/ abs(sphereCenter.x)<surfaceWidth/2.0 && abs(sphereCenter.y)<surfaceHeight/2.0) {
            vec3 intersection = sphereIntersectionWithNormedDir(sphereCenter, ballSize/2.0, cameraPos, dir);
            vec3 sv = sphereCenter - cameraPos;
            float dist = length(sv-dir*dot(sv, dir));
            float shapeDampen = getDampening(shape, sphereCenter.xy, ratio);
//            outColor.rgb += shapeDampen * smoothstep(ballSize/2.0, ballSize/4.0, dist) * __source__(sphereCenter.xy).rgb;
//            outColor.rgb += shapeDampen * smoothstep(ballSize/2.0, ballSize/4.0, dist) * __source__(sphereCenter.xy).rgb * 0.002/dist;
//            outColor.rgb += shapeDampen * smoothstep(ballSize/2.0, ballSize/4.0, dist) *  __source__(sphereCenter.xy).rgb * 0.5/fResolution/dist;

            float sharp = pow(1.-bokeh, abs(log(length(cameraPos-sphereCenter)/0.25)));
            outColor.rgb += shapeDampen * brightness * smoothstep(ballSize/2.0, ballSize/4.0, dist) * __source__(sphereCenter.xy).rgb * mix(1.0, max(0.5/fResolution/max(dist, 1./fResolution*(1.-sharp)), 1.), sharp);
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
        
    return clamp(color, 0.0, 1.0);
}

void main() {
    fragColor = sphereElevationMap((inverse(u_viewTransform) * vec3(((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), 1.0)).xy, ((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), u_sourceBkg_specified, u_sourceElevation_specified, u_sourceDim, u_sourceElevationDim, u_rezolution, u_intensity, u_shape, u_brightness, u_bokeh, u_model3DTransform);
}
