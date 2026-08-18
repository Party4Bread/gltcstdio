#version 450
layout(location = 0) in vec2 v_uv;
layout(location = 0) out vec4 fragColor;

layout(binding = 0, std140) uniform Params {
    vec4 U[12];
};
layout(binding = 1) uniform sampler samp;

#define u_worldAspect (U[0].x)
#define u_viewTransform (mat3(U[1].xyz, U[2].xyz, U[3].xyz))
#define u_outDim (U[4].xy)
#define u_mode (int(U[5].x))
#define u_colorBleed (U[6].x)
#define u_variability (U[7].x)
#define u_shadows (U[8].x)
#define u_specular (U[9].x)
#define u_color1 (U[10])
#define u_colorVariability (U[11].x)





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

vec3 color(vec2 id) {
    return vec3(0.25+0.75*hash22(id), 0.5+0.05*hash22(id+123.0).x);
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

vec4 voronoiGems(vec2 pos, vec2 outPos, int mode, float colorBleed, float variability, float shadows, float specular, vec4 color1, float colorVariability) {
    vec2 uv = pos;
    
    Tile cell = getVoronoiTile(uv, variability*3.0);
    //return vec4(fract(cell.tileId.xy)*0.1, fract(cell.secondTileId.x*0.1), 1.0);
    
    float d = cell.centerDist;
    float d2 = cell.secondCenterDist;
    vec2 id = cell.tileId;
    vec2 secId = cell.secondTileId;
    float b = cell.borderDist;
    
    if (mode==3) return vec4(vec3(b*1.5), 1.);
    
    vec2 normal = cell.borderNormal;
    
    float s = dot(normal, vec2(0.0, 1.0));
    float light = pow(b, 0.35*pow(1.06, shadows*50.0-50.0));
     
    float plight = 1.0 + 1.5*smoothstep(0.6, 1.0, s);
    float nlight = (1.0-light) * (1.5 + smoothstep(0.25, 1.0, -s));
    light *= mix(1.0, mix(nlight, plight, smoothstep(-0.2, 0.2, s)), specular);
    //light *= mix(nlight, plight, smoothstep(-0.2, 0.2, s));
    
    float cb = 0.05*smoothstep(0.0, 0.9, d) + 0.25*smoothstep(2.0, 1.0, d2/d);
    vec3 faceColor = mode==1 ? color(id) : vec3(normal.x*0.5+0.5, normal.y*0.5+0.5, 0.5);
    vec3 rgb = mix(color1.rgb, faceColor, colorVariability);
    vec3 col = mix(rgb, color(secId), colorBleed*cb) * light; // gems    

    return vec4(col, 1.0);
}

void main() {
    fragColor = voronoiGems((inverse(u_viewTransform) * vec3(((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), 1.0)).xy, ((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), u_mode, u_colorBleed, u_variability, u_shadows, u_specular, u_color1, u_colorVariability);
}
