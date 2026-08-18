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
#define u_sourceDim (U[4].xy)
#define u_sourceElevationDim (U[5].xy)
#define u_sourceBkg_specified (int(U[6].x))
#define u_sourceElevation_specified (int(U[7].x))
#define u_outDim (U[8].xy)
#define u_intensity (U[9].x)
#define u_rezolution (int(U[10].x))
#define u_model3DTransform (mat4(U[11], U[12], U[13], U[14]))
#define u_thickness (U[15].x)
#define u_glow (U[16].x)
#define u_colorLines (U[17])

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



























































































































































































































































































































































bool close(float a, float b) {
    return abs(a-b) < 0.00001;
}

float height(float intensity, vec4 color) {
    return intensity*0.04* ((color.r + color.g + color.b)/3.0 - 0.5);
}

float intersectX_hmwgl(vec3 _p, vec3 cameraPos, vec3 cameraDir, float h, float thickness, float glow) {
    float dist = dot(cameraDir, _p-cameraPos);
    float t = thickness*0.01;
    float b = glow*0.1;
    float maxDist = (t+b)*dist;
    maxDist /= abs(normalize(cameraPos.xz-vec2(_p.x, h)).x);
    float proxim = abs(_p.z-h) / maxDist;
    if (proxim>1.0) return 0.0;
    return 1.0 - pow(smoothstep(t/(t+b), 1.0, proxim), 0.5);
}

float intersectY_hmwgl(vec3 _p, vec3 cameraPos, vec3 cameraDir, float h, float thickness, float glow) {
    float dist = dot(cameraDir, _p-cameraPos);
    float t = thickness*0.01;
    float b = glow*0.1;
    float maxDist = (t+b)*dist;
    maxDist /= abs(normalize(cameraPos.yz-vec2(_p.y, h)).x);
    float proxim = abs(_p.z-h) / maxDist;
    if (proxim>1.0) return 0.0;
    return 1.0 - pow(smoothstep(t/(t+b), 1.0, proxim), 0.5);
}

vec4 heightMapWireframeGl(vec2 pos, vec2 outPos,
            float intensity, int rezolution, mat4 model3DTransform, vec2 sourceDim, vec2 sourceElevationDim,
            int sourceBkg_specified, int sourceElevation_specified,
            float thickness, float glow,
            vec4 colorLines
        ) {
            float D = 1.0;
            vec3 cameraPos = vec3(0.0, 0.0, 0.0);
            mat4 m = inverse(model3DTransform);
            cameraPos = (m * vec4(cameraPos, 1.0)).xyz;
            vec3 dir = normalize(vec3(pos.x*D, pos.y*D, -1.0));
            dir = mat3(m) * dir;
            vec3 cameraDir = normalize(vec3(0.0, 0.0, -1.0));
            cameraDir = mat3(m) * cameraDir;

            bool heightMap = sourceElevation_specified==1;

            float maxZ = abs(intensity)*0.02;
            float ratio = heightMap ? (sourceElevationDim.x/sourceElevationDim.y) : (sourceDim.x/sourceDim.y);
            float dk = heightMap ? 2.0/sourceElevationDim.y : 2.0/sourceDim.y;
            vec3 step = dir * dk;

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

            float maxZ2 = maxZ+0.0001; // prevent flickering on edge case
            if (dir.z!=0.0) {
                float s = sign(dir.z);
                float k3 = (-s*maxZ2-cameraPos.z)/dir.z;
                float k4 = (s*maxZ2-cameraPos.z)/dir.z;
                k1 = max(k1, k3);
                k2 = min(k2, k4);
            }

            if (k1>k2) return sourceBkg_specified==1 ? __sourceBkg__(outPos) : __source__(outPos);

            float k = k1;
            vec3 p = cameraPos + k*dir;

            // Pap shader uses u_Count (scalar). We pass rezolution as int — same role.
            float strideX = ratio*2.0/float(rezolution);
            float countY = floor(2.0/strideX + 0.5); // round(2.0/strideX)
            float strideY = 2.0/countY;

            float intersected = 0.0;
            float _h;

            // ----- Y-scanline pass -----
            float yPos = (p.y+1.0)/strideY;
            float yIndex = floor(yPos + 0.5); // round
            if (close(yPos, yIndex)) {
                _h = height(intensity, heightMap ? __sourceElevation__(p.xy) : __source__(p.xy));
                intersected += intersectY_hmwgl(p, cameraPos, cameraDir, _h, thickness, glow);
            }

            if (dir.y!=0.0) {
                float advanceY = (sign(dir.y)>0.0 ? ceil(yPos)-yPos : floor(yPos)-yPos) * strideY;
                float deltaK = advanceY/dir.y;
                k += deltaK;
                p += deltaK*dir;

                float deltaY = sign(dir.y) * strideY;
                deltaK = deltaY/dir.y;
                int maxIter = 1500;
                while (abs(p.y)<=1.0 && k<=k2 && maxIter>0) {
                    _h = height(intensity, heightMap ? __sourceElevation__(p.xy) : __source__(p.xy));
                    intersected += intersectY_hmwgl(p, cameraPos, cameraDir, _h, thickness, glow);
                    if (intersected>=1.0) break;
                    k += deltaK;
                    p += deltaK*dir;
                    --maxIter;
                }
            }

            // ----- X-scanline pass (reset & sweep) -----
            k = k1;
            p = cameraPos + k*dir;

            float xPos = (p.x+1.0)/strideX;
            float xIndex = floor(xPos + 0.5);
            if (close(xPos, xIndex)) {
                _h = height(intensity, heightMap ? __sourceElevation__(p.xy) : __source__(p.xy));
                intersected += intersectX_hmwgl(p, cameraPos, cameraDir, _h, thickness, glow);
            }

            if (dir.x!=0.0) {
                float advanceX = (sign(dir.x)>0.0 ? ceil(xPos)-xPos : floor(xPos)-xPos) * strideX;
                float deltaK = advanceX/dir.x;
                k += deltaK;
                p += deltaK*dir;

                float deltaX = sign(dir.x) * strideX;
                deltaK = deltaX/dir.x;
                int maxIter = 1500;
                while (abs(p.x)<=ratio && k<=k2 && maxIter>0) {
                    _h = height(intensity, heightMap ? __sourceElevation__(p.xy) : __source__(p.xy));
                    intersected += intersectX_hmwgl(p, cameraPos, cameraDir, _h, thickness, glow);
                    if (intersected>=1.0) break;
                    k += deltaK;
                    p += deltaK*dir;
                    --maxIter;
                }
            }

            vec4 wireColor = colorLines;
            return mix(sourceBkg_specified==1 ? __sourceBkg__(outPos) : __source__(outPos), wireColor, clamp(intersected, 0.0, 1.0));
        }

void main() {
    fragColor = heightMapWireframeGl((inverse(u_viewTransform) * vec3(((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), 1.0)).xy, ((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), u_intensity, u_rezolution, u_model3DTransform, u_sourceDim, u_sourceElevationDim, u_sourceBkg_specified, u_sourceElevation_specified, u_thickness, u_glow, u_colorLines);
}
