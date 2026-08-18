#version 450
layout(location = 0) in vec2 v_uv;
layout(location = 0) out vec4 fragColor;

layout(binding = 0, std140) uniform Params {
    vec4 U[12];
};
layout(binding = 1) uniform sampler samp;
layout(binding = 2) uniform texture2D t_source;

#define u_source sampler2D(t_source, samp)
#define u_worldAspect (U[0].x)
#define u_viewTransform (mat3(U[1].xyz, U[2].xyz, U[3].xyz))
#define u_source_specified (int(U[4].x))
#define u_outDim (U[5].xy)
#define u_variability (U[6].x)
#define u_shadows (U[7].x)
#define u_color1 (U[8])
#define u_color2 (U[9])
#define u_offset (U[10].x)
#define u_banding (U[11].x)

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















































































































































































































































































































































vec2 hash22(vec2 u) {
    return vec2(
        fract(sin(u.x*776.45+u.y*453.24)*45.77), 
        fract(sin(u.x*376.45+u.y*853.24)*88.77) );
}

Tile getVoronoiTile(vec2 u, float intensity) {
    vec2 b = floor(u+0.5);
    float N = floor(2.0+0.5*abs(intensity));
    float minD = 1e10;
    float minB = 1e10;
    vec2 minId;
    vec2 minC;
    vec2 normal = vec2(0.0, 1.0);
    vec2 secId;
    float secD;
    float thirdD;
    for(float j=-N; j<=N; ++j) {
        for(float i=-N; i<=N; ++i) {
            vec2 id = b + vec2(i, j);
            vec2 c = id + intensity * (hash22(id)-0.5);
            float d = length(u-c);
            if (minD>=d) {
                secId = minId;
                thirdD = secD;
                secD = minD;
                minId = id;
                minD = d;
                minC = c;
            }
            else if (secD>=d) {
                secId = id;
                thirdD = secD;
                secD = d;
            }
            else if (thirdD>=d) {
                thirdD = d;
            }
        }    
    }
    for(float j=-N; j<=N; ++j) {
        for(float i=-N; i<=N; ++i) {
            vec2 id = b + vec2(i, j);
            if (id!=minId) {
                vec2 c = id + intensity * (hash22(id)-0.5);
                vec2 v = normalize(c-minC);
                float borderDist = length(minC-c)/2.0 - dot(u-minC, v);
                minB = min(borderDist, minB);
                if (minB==borderDist) normal = vec2(-v.x, v.y); 
            }
        }    
    }

    return Tile(minD, minId, minB, minC, normal, secD, secId, thirdD);
}

vec4 mergeColor(vec4 bkg, vec4 front) {
    return vec4(mix(bkg.rgb, front.rgb, front.a + (1.0-bkg.a)*(1.0-front.a)), max(bkg.a, front.a));
}

vec4 voronoiHatch(vec2 pos, vec2 outPos, int source_specified, mat3 viewTransform, float variability, float shadows, vec4 color1, vec4 color2, float offset, float banding) {
    vec2 u = pos;
    Tile cell = getVoronoiTile(u, variability);
    float d = cell.centerDist;
    float d2 = cell.secondCenterDist;
    float d3 = cell.thirdCenterDist;
    float rounded = min(2./(1./max(d2 - d, .001) + 1./max(d3 - d, .001)), 1.);
    float lightness = smoothstep(-0.001, shadows, abs(rounded));
    vec2 id = cell.tileId;
    float even = mod(id.x+id.y, 2.0);
    vec2 dir = normalize(mix( 
        vec2(even, 1.-even),
        hash22(id) - 0.5,
        variability));
    float k = lightness * (cos(dot(u-cell.center, dir)*banding + offset*PI)*.5+.5);
    vec4 outColor = mix(color2, color1, k);
    if (source_specified==1) return mergeColor(__source__(outPos), outColor);
    else return outColor;  
}

void main() {
    fragColor = voronoiHatch((inverse(u_viewTransform) * vec3(((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), 1.0)).xy, ((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), u_source_specified, u_viewTransform, u_variability, u_shadows, u_color1, u_color2, u_offset, u_banding);
}
