#version 450
layout(location = 0) in vec2 v_uv;
layout(location = 0) out vec4 fragColor;

layout(binding = 0, std140) uniform Params {
    vec4 U[19];
};
layout(binding = 1) uniform sampler samp;
layout(binding = 2) uniform texture2D t_source;

#define u_source sampler2D(t_source, samp)
#define u_worldAspect (U[0].x)
#define u_viewTransform (mat3(U[1].xyz, U[2].xyz, U[3].xyz))
#define u_sourceDim (U[4].xy)
#define u_outDim (U[5].xy)
#define u_intensity (U[6].x)
#define u_thickness (U[7].x)
#define u_smoothen (U[8].x)
#define u_step (U[9].x)
#define u_color1 (U[10])
#define u_color2 (U[11])
#define u_contrast (U[12].x)
#define u_brightness (U[13].x)
#define u_vignetting (U[14].x)
#define u_scanlines (U[15].x)
#define u_modelTransform (mat3(U[16].xyz, U[17].xyz, U[18].xyz))

#define __source__texelFetch__(c) texelFetch(u_source, (c), 0)
#define __source__(p) textureLod(u_source, (vec2((p).x / u_worldAspect, (p).y) / 2.0 + 0.5), 0.0)




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


















































































































































































































































































































































vec2 tf(mat3 m, vec2 u) {
    return (m * vec3(u, 1.)).xy;
}

vec4 modulation(vec2 pos, vec2 outPos, float intensity, float thickness, float smoothen, float step, vec4 color1, vec4 color2, float contrast, float brightness, float vignetting, float scanlines, vec2 sourceDim, mat3 modelTransform) {
    vec2 centre = tf(modelTransform, vec2(0.));
    
    float ratio = sourceDim.x / sourceDim.y;
    vec2 dir = normalize(pos - centre);

    float pixel = 2.0/sourceDim.y;
    step = pixel * 1.0 * step;

    vec2 dim = vec2(ratio, 1.0);
    vec2 p = centre;
    float k = 0.0;
    float acc = 0.0;
    float diag = length(dim);

    float radius = thickness*0.02;
    float weight = step*333.33*intensity;
    //int N = int(ceil((length(p-pos)+radius)/step));
    int N = int(min((dim.x+dim.y)*2.01/pixel, ceil((length(p-pos)+radius)/step))); // min to prevent huge N coming from who knows where
    float bestL = 1e10;
    //int N = int(min(ceil((length(p-pos)+radius)/step), 2000.0));
    if (vignetting==0.0 && contrast==0.0 && brightness==0.0 && smoothen==0.0) {
        for (int i=0; i<N; ++i) {
            vec4 c = __source__(p);
            float val = (c.r+c.g+c.b);
            acc += weight*val;
            if (acc>=1.0) {
                vec2 dd = p-pos; bestL = min(bestL, dot(dd, dd)); // squared distance
                acc = 0.0;
            }
            p += step*dir;
        }
        k = smoothstep(radius, 0.0, sqrt(bestL));
    }
    else {
        for (int i=0; i<N; ++i) {
            vec4 c = __source__(p);
            float val = (c.r+c.g+c.b);
            val = (val-0.5)*contrast + 0.5 + brightness;
            if (vignetting!=0.0) {
                float vignette = mix(1.0, smoothstep(1.0, 0.0, length(p)/diag), vignetting);
                val *= vignette;
            }
            acc += weight*val;
            if (acc>=1.0) {
//                vec2 dd = p-pos; bestL = min(bestL, dot(dd, dd)); // squared distance
                bestL = min(bestL, length(p-pos));
                acc = 0.0;
            }

            if (smoothen>0.0) {
                acc = mix(acc, 0.5+0.5*sin(p.x*100.0), smoothen*91. * pixel);
            }

            p += step*dir;
        }
        k = smoothstep(radius, 0.0, bestL);
    }

    vec4 bkgCol = __source__(pos);
    vec4 lineColor = vec4(mix(bkgCol.rgb, color2.rgb, color2.a), bkgCol.a);
    vec4 backColor = vec4(mix(bkgCol.rgb, color1.rgb, color1.a), bkgCol.a);
    vec4 color = mix(backColor, lineColor, clamp(k, 0.0, 1.0));

    vec4 outColor = color;//mix(bkgCol, vec4(mix(bkgCol.rgb, color.rgb, color.a), bkgCol.a), 1.0);
    if (scanlines!=0.0) {
        outColor.rgb *= mix(1.0, pow((1.1+sin(pos.y*400.0/ratio))*0.5, 0.4), scanlines);
    }
    
    return outColor;
}

void main() {
    fragColor = modulation((inverse(u_viewTransform) * vec3(((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), 1.0)).xy, ((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), u_intensity, u_thickness, u_smoothen, u_step, u_color1, u_color2, u_contrast, u_brightness, u_vignetting, u_scanlines, u_sourceDim, u_modelTransform);
}
