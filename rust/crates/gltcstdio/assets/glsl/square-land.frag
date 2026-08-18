#version 450
layout(location = 0) in vec2 v_uv;
layout(location = 0) out vec4 fragColor;

layout(binding = 0, std140) uniform Params {
    vec4 U[10];
};
layout(binding = 1) uniform sampler samp;
layout(binding = 2) uniform texture2D t_source;

#define u_source sampler2D(t_source, samp)
#define u_worldAspect (U[0].x)
#define u_viewTransform (mat3(U[1].xyz, U[2].xyz, U[3].xyz))
#define u_source_specified (int(U[4].x))
#define u_outDim (U[5].xy)
#define u_iterations (int(U[6].x))
#define u_coverage (U[7].x)
#define u_color (U[8])
#define u_colorBkg (U[9])

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















































































































































































































































































































































float hash21(vec2 p) {
    vec2 a = fract(-45.3277*p.xy);
    vec2 b = a + dot(a, a+123.3371);
	return fract(b.x*b.y);  
}

vec2 hash22(vec2 u) {
    return vec2(
        fract(sin(u.x*776.45+u.y*453.24)*45.77), 
        fract(sin(u.x*376.45+u.y*853.24)*88.77) );
}

float max2(vec2 u) { 
    return max(u.x, u.y);
}

vec4 mergeColor(vec4 bkg, vec4 front) {
    return vec4(mix(bkg.rgb, front.rgb, front.a + (1.0-bkg.a)*(1.0-front.a)), max(bkg.a, front.a));
}

vec4 squareLand(vec2 uv, vec2 outPos, int source_specified, int iterations, float coverage, vec4 color, vec4 colorBkg) {
    
    vec2 id = floor(uv);    
    vec4 col = colorBkg;
    float X = mod(id.y, 64.0);
    if (X<16.) col = vec4(vec3(mix(0.1, mod(id.x+id.y, 2.0), X*0.1)), 1.);

    float levels = 2. * pow(2., float(iterations));
    uv = uv / levels;
    for(int i=0; i<iterations; ++i) {
        id = floor(uv);
        vec2 rnd = hash22(id);
        //float rndA = hash21(id);
        float d = max2(abs(fract(uv)-0.5));
        //if (rndA<0.01) d = 0.5-length(fract(uv)-0.5);
        float d1 = round(rnd.x*levels)/(levels*2.);
        float d2 = rnd.y*.5;

        if (hash21(id)<coverage && d>max(1./levels, d1)) {
            col = vec4(fract(rnd.x*10.), rnd.y, fract(rnd.y*10.), 1.);
            col = mix(col, round(col), 0.5);
            col = mergeColor(col, color);
        }
        uv = uv * 2.;
        levels /= 2.;
    }
        
    if (source_specified==1) return mergeColor(__source__(outPos), col);
    else return col;

}

void main() {
    fragColor = squareLand((inverse(u_viewTransform) * vec3(((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), 1.0)).xy, ((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), u_source_specified, u_iterations, u_coverage, u_color, u_colorBkg);
}
