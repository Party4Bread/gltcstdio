#version 450
layout(location = 0) in vec2 v_uv;
layout(location = 0) out vec4 fragColor;

layout(binding = 0, std140) uniform Params {
    vec4 U[15];
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
#define u_intensity (U[9].x)
#define u_count (int(U[10].x))
#define u_model3DTransform (mat4(U[11], U[12], U[13], U[14]))

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


















































































































































































































































































































































float hmggl_height(float intensity, vec4 color) {
    return intensity*0.04* ((color.r + color.g + color.b)/3.0 - 0.5);
}

vec4 heightMapGlitchyGl(vec2 pos, vec2 outPos,
            int sourceBkg_specified, int sourceElevation_specified,
            float intensity, int count,
            vec2 sourceDim, vec2 sourceElevationDim,
            mat4 model3DTransform) {

            vec4 backgroundColor = vec4(0.0, 0.0, 0.0, 1.0);
            float D = 1.0;
            vec3 cameraPos = vec3(0., 0., 0.);
            mat4 m = inverse(model3DTransform);
            cameraPos = (m * vec4(cameraPos, 1.)).xyz;
            vec3 dir = vec3(pos.x*D, pos.y*D, -1.0);
            dir = normalize(mat3(m) * dir);

            bool heightMap = sourceElevation_specified==1;
            float maxZ = abs(intensity)*0.02;
            float ratio = heightMap ? (sourceElevationDim.x/sourceElevationDim.y) : (sourceDim.x/sourceDim.y);
            float dk = heightMap ? 2.0/sourceElevationDim.y : 2.0/sourceDim.y;

            float fResolution = float(count);
            float ballSize = 2.0/fResolution;
            maxZ += ballSize;
            float surfaceHeight = 2.0;

            float k1 = 0.0;
            float k2 = 100000000.0;

            if (dir.x!=0.0) {
                float s = sign(dir.x);
                float k3 = (-s*ratio-cameraPos.x)/dir.x;
                float k4 = (s*ratio-cameraPos.x)/dir.x;
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

            float maxZ2 = maxZ+0.0001;
            if (dir.z!=0.0) {
                float s = sign(dir.z);
                float k3 = (-s*maxZ2-cameraPos.z)/dir.z;
                float k4 = (s*maxZ2-cameraPos.z)/dir.z;
                k1 = max(k1, k3);
                k2 = min(k2, k4);
            }

            if (k1>k2) return sourceBkg_specified==1 ? __sourceBkg__(outPos) : vec4(0.0, 0.0, 0.0, 1.0);

            float k = k1;
            vec3 p = cameraPos + k*dir;

            vec4 color = sourceBkg_specified==1 ? __sourceBkg__(outPos) : vec4(0.0, 0.0, 0.0, 1.0);
            float intersected = 0.0;
            vec4 outColor = vec4(0.0, 0.0, 0.0, 0.0);

            int maxIter = 500;
            float minK = ballSize/4.0;
            vec3 step = minK*dir;

            while (intersected<1.0 && k<=k2 && maxIter>0) {
                vec4 hColor = heightMap ? __sourceElevation__(p.xy) : __source__(p.xy);
                float h = hmggl_height(intensity, hColor);

                if (h > p.z) {
                    outColor = __source__(p.xy);
                    intersected = 1.0;
                }

                k += minK;
                p += step;
                --maxIter;
            }

            return mix(color, vec4(outColor.rgb, color.a), outColor.a);
        }

void main() {
    fragColor = heightMapGlitchyGl((inverse(u_viewTransform) * vec3(((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), 1.0)).xy, ((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), u_sourceBkg_specified, u_sourceElevation_specified, u_intensity, u_count, u_sourceDim, u_sourceElevationDim, u_model3DTransform);
}
