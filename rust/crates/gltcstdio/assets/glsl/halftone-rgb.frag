#version 450
layout(location = 0) in vec2 v_uv;
layout(location = 0) out vec4 fragColor;

layout(binding = 0, std140) uniform Params {
    vec4 U[23];
};
layout(binding = 1) uniform sampler samp;
layout(binding = 2) uniform texture2D t_source;

#define u_source sampler2D(t_source, samp)
#define u_worldAspect (U[0].x)
#define u_viewTransform (mat3(U[1].xyz, U[2].xyz, U[3].xyz))
#define u_outDim (U[4].xy)
#define u_smoothen (U[5].x)
#define u_intensity (U[6].x)
#define u_modelTransform (mat3(U[7].xyz, U[8].xyz, U[9].xyz))
#define u_redTransform (mat3(U[10].xyz, U[11].xyz, U[12].xyz))
#define u_greenTransform (mat3(U[13].xyz, U[14].xyz, U[15].xyz))
#define u_blueTransform (mat3(U[16].xyz, U[17].xyz, U[18].xyz))
#define u_color1 (U[19])
#define u_color2 (U[20])
#define u_sampling (int(U[21].x))
#define u_style (int(U[22].x))

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






























































































































































































































































































































































vec4 mergeColor(vec4 bkg, vec4 front) {
    return vec4(mix(bkg.rgb, front.rgb, front.a + (1.0-bkg.a)*(1.0-front.a)), max(bkg.a, front.a));
}

vec2 tf(mat3 m, vec2 u) {
    return (m * vec3(u, 1.)).xy;
}

vec3 patternConcentricLines(mat3 transform, vec2 uv) {
    vec2 u = tf(transform, uv);
    float d = round(length(u));
    vec2 center = d * normalize(u);
    float threshold = length(u-center)*2.0;
    return vec3(center, threshold);
}

vec3 patternDots(mat3 transform, vec2 uv) {
    vec2 u = tf(transform, uv);
    vec2 center = round(u);
    float threshold = length(u-center)*2.0;
    return vec3(center, threshold);
}

vec4 hexCoords(vec2 v) {
    vec2 r = vec2(1.0, SQRT3);
    vec2 h = r/2.0;
    vec2 a = vec2(mod(v.x, r.x), mod(v.y, r.y))-h;
    vec2 b = vec2(mod(v.x-h.x, r.x), mod(v.y-h.y, r.y))-h;
    vec2 hv = length(a)<length(b) ? a : b;
    vec2 id = v-hv;
    return vec4(hv, id);
}

vec3 patternHexDots(mat3 transform, vec2 uv) {
    vec2 u = tf(transform, uv);
    vec4 hex = hexCoords(u);
    float threshold = length(hex.xy)*2.0;
    return vec3(hex.zw, threshold);
}

vec3 patternLines(mat3 transform, vec2 uv) {
    vec2 u = tf(transform, uv);
    vec2 center = vec2(u.x, round(u.y));
    float threshold = length(u-center)*2.0;
    return vec3(center, threshold);
}

vec3 patternWavyLines(mat3 transform, vec2 uv) {
    vec2 u = tf(transform, uv);
    vec2 center = vec2(u.x, round(u.y - sin(u.x*0.5)*2.0) + sin(u.x*0.5)*1.5);
    float threshold = length(u-center)*2.0;
    return vec3(center, threshold);
}

mat3 rotation3(float angle) {
    float ca = cos(angle);
    float sa = sin(angle);
    return mat3(ca, sa, 0., -sa, ca, 0., 0., 0., 1.);
}

mat3 translation3(vec2 t) {
    return mat3(1., 0., 0., 0., 1., 0., t.x, t.y, 1.);
}

vec4 halftoneRGB(vec2 uv, vec2 outPos, float smoothen, float intensity, mat3 modelTransform, mat3 redTransform, mat3 greenTransform, mat3 blueTransform, vec4 color1, vec4 color2, int sampling, int style) {
    vec3 patternR, patternG, patternB;
    
    mat3 transformR, invTransformR, transformG, invTransformG, transformB, invTransformB;
    transformG = modelTransform;
    if (style==3) {
        transformR = modelTransform * translation3(30.*vec2(0.5, SQRT3_2));
        transformB = modelTransform * translation3(30.*vec2(-0.5, SQRT3_2));            
    }
    else if (style==1) {
        transformR = modelTransform * rotation3(0.4);
        transformB = modelTransform * rotation3(1.6);                            
    }
    else {
        transformR = modelTransform * rotation3(0.2618);
        transformB = modelTransform * rotation3(1.309);                            
    }
    
    transformR = transformR * redTransform;
    transformG = transformG * greenTransform;
    transformB = transformB * blueTransform;
    
    invTransformR = inverse(transformR);
    invTransformG = inverse(transformG);
    invTransformB = inverse(transformB);
    
    { int _sw_sel = int(style);
if (_sw_sel == int(0)) { patternG = patternDots(inverse(modelTransform), uv); patternR = patternDots(invTransformR, uv); patternB = patternDots(invTransformB, uv); }
else if (_sw_sel == int(1)) { patternG = patternHexDots(inverse(modelTransform), uv); patternR = patternHexDots(invTransformR, uv); patternB = patternHexDots(invTransformB, uv); }
else if (_sw_sel == int(2)) { patternG = patternLines(inverse(modelTransform), uv); patternR = patternLines(invTransformR, uv); patternB = patternLines(invTransformB, uv); }
else if (_sw_sel == int(3)) { patternG = patternConcentricLines(inverse(modelTransform), uv); patternR = patternConcentricLines(invTransformR, uv); patternB = patternConcentricLines(invTransformB, uv); }
else if (_sw_sel == int(4)) { patternG = patternWavyLines(inverse(modelTransform), uv); patternR = patternWavyLines(invTransformR, uv); patternB = patternWavyLines(invTransformB, uv); }
}
    
    float thresholdR = patternR.z * intensity;
    float thresholdG = patternG.z * intensity;
    float thresholdB = patternB.z * intensity;
    
    
    vec4 color = vec4(0.0);
    float kR, kG, kB;
    
    { int _sw_sel = int(sampling);
if (_sw_sel == int(0)) { {
            vec2 samplePosR = tf(transformR, patternR.xy); 
            if (smoothen>0.0) {
                int N = 5;
                float r = length(transformR[0].xy) * smoothen * 3.0;
                float step = r/float(N);
                for(int j=-N; j<=N; ++j) {
                    for(int i=-N; i<=N; ++i) {
                        color += __source__(samplePosR + vec2(float(i), float(j)) * step);
                    }
                }
                color /= float((2*N+1)*(2*N+1));
            }
            else {
                color = __source__(samplePosR);
            }
            kR = color.r>thresholdR ? 1.0 : 0.0;
            color = vec4(0.0);
            
            vec2 samplePosG = tf(transformG, patternG.xy); 
            if (smoothen>0.0) {
                int N = 5;
                float r = length(transformG[0].xy) * smoothen * 3.0;
                float step = r/float(N);
                for(int j=-N; j<=N; ++j) {
                    for(int i=-N; i<=N; ++i) {
                        color += __source__(samplePosG + vec2(float(i), float(j)) * step);
                    }
                }
                color /= float((2*N+1)*(2*N+1));
            }
            else {
                color = __source__(samplePosG);
            }
            kG = color.g>thresholdG ? 1.0 : 0.0;
            color = vec4(0.0);
            
            vec2 samplePosB = tf(transformB, patternB.xy); 
            if (smoothen>0.0) {
                int N = 5;
                float r = length(transformB[0].xy) * smoothen * 3.0;
                float step = r/float(N);
                for(int j=-N; j<=N; ++j) {
                    for(int i=-N; i<=N; ++i) {
                        color += __source__(samplePosB + vec2(float(i), float(j)) * step);
                    }
                }
                color /= float((2*N+1)*(2*N+1));
            }
            else {
                color = __source__(samplePosB);
            }
            kB = color.b>thresholdB ? 1.0 : 0.0;                    
            
            
        } }
else { {
            vec2 samplePos = uv; 
            if (smoothen>0.0) {
                int N = 5;
                float r = length(modelTransform[0].xy) * smoothen * 3.0;
                float step = r/float(N);
                for(int j=-N; j<=N; ++j) {
                    for(int i=-N; i<=N; ++i) {
                        color += __source__(samplePos + vec2(float(i), float(j)) * step);
                    }
                }
                color /= float((2*N+1)*(2*N+1));
            }
            else {
                color = __source__(samplePos);
            }
            kR = color.r>thresholdR ? 1.0 : 0.0;
            kG = color.g>thresholdG ? 1.0 : 0.0;
            kB = color.b>thresholdB ? 1.0 : 0.0;
            
        } }
}
                
    vec4 outColor = vec4(mix(color2.r, color1.r, kR), mix(color2.g, color1.g, kG), mix(color2.b, color1.b, kB), mix(color2.a, color1.a, 0.5));
    //vec4 bkgColor = __source__(uv);
    return mergeColor(color, outColor);
}

void main() {
    fragColor = halftoneRGB((inverse(u_viewTransform) * vec3(((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), 1.0)).xy, ((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), u_smoothen, u_intensity, u_modelTransform, u_redTransform, u_greenTransform, u_blueTransform, u_color1, u_color2, u_sampling, u_style);
}
