#version 450
layout(location = 0) in vec2 v_uv;
layout(location = 0) out vec4 fragColor;

layout(binding = 0, std140) uniform Params {
    vec4 U[9];
};
layout(binding = 1) uniform sampler samp;
layout(binding = 2) uniform texture2D t_source;

#define u_source sampler2D(t_source, samp)
#define u_worldAspect (U[0].x)
#define u_viewTransform (mat3(U[1].xyz, U[2].xyz, U[3].xyz))
#define u_sourceDim (U[4].xy)
#define u_outDim (U[5].xy)
#define u_intensity (U[6].x)
#define u_delta (U[7].x)
#define u_balance (U[8].x)

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















































































































































































































































































































































float luma(vec3 c) {
    return (0.2989*c.r + 0.587*c.g + 0.114*c.b);
}

vec4 watercolor(vec2 pos, vec2 outPos, vec2 sourceDim, float intensity, float delta, float balance) {
    float lum = luma(__source__(pos).rgb);
    float intensityModifier;
    if (abs(balance)>=1.0) intensityModifier = balance;
    else {
        float a = balance>=0. ? 0.0 : -balance;
        float b = balance>=0. ? 1.0-balance : 1.0; 
        intensityModifier = smoothstep(a, b, lum)*2. - 1.;
    }
    intensity *= intensityModifier;
    
    int N = int(abs(intensity)*500.0);
    float step = 0.001 * sign(intensity);

    vec4 total = __source__(pos);
    float d = delta*.1;
    vec4 cx0 = __source__(vec2(pos.x-d, pos.y));
    vec4 cx1 = __source__(vec2(pos.x+d, pos.y));
    vec4 cy0 = __source__(vec2(pos.x, pos.y-d));
    vec4 cy1 = __source__(vec2(pos.x, pos.y+d));
    vec2 grad = vec2((length(cx1)-length(cx0))/(2.0*d), (length(cy1)-length(cy0))/(2.0*d)); // gradient
    
    if (grad.x==0.0 && grad.y==0.0) return total;
    grad = normalize(grad);
    for(int i=0; i<N; ++i) {
        vec4 cx0 = __source__(vec2(pos.x-d, pos.y));
        vec4 cx1 = __source__(vec2(pos.x+d, pos.y));
        vec4 cy0 = __source__(vec2(pos.x, pos.y-d));
        vec4 cy1 = __source__(vec2(pos.x, pos.y+d));
        vec2 g1 = vec2((length(cx1)-length(cx0))/(2.0*d), (length(cy1)-length(cy0))/(2.0*d)); // gradient
        
        if (g1.x==0.0 && g1.y==0.0) return total/float(i+1);
        vec2 g2 = grad + 0.5*normalize(g1);
        if (g2.x==0.0 && g2.y==0.0) return total/float(i+1);
        grad = normalize(g2);
        pos += sign(delta) * step * grad;

        if (length(pos)>3.0) return vec4(1.0, 0.0, 0.0, 1.0);
        else if (length(pos)<0.0001) return vec4(0.0, 1.0, 0.0, 1.0);

//        pos += step * vec2(grad.y, grad.x);
        total += __source__(pos);
    }
    return total/float(N+1);
}

void main() {
    fragColor = watercolor((inverse(u_viewTransform) * vec3(((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), 1.0)).xy, ((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), u_sourceDim, u_intensity, u_delta, u_balance);
}
