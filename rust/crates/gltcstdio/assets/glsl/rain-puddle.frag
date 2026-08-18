#version 450
layout(location = 0) in vec2 v_uv;
layout(location = 0) out vec4 fragColor;

layout(binding = 0, std140) uniform Params {
    vec4 U[16];
};
layout(binding = 1) uniform sampler samp;
layout(binding = 2) uniform texture2D t_source;

#define u_source sampler2D(t_source, samp)
#define u_worldAspect (U[0].x)
#define u_viewTransform (mat3(U[1].xyz, U[2].xyz, U[3].xyz))
#define u_outDim (U[4].xy)
#define u_mode (int(U[5].x))
#define u_spacing (U[6].x)
#define u_intensity (U[7].x)
#define u_count (int(U[8].x))
#define u_radiusVariability (U[9].x)
#define u_time (U[10].x)
#define u_lighting (U[11].x)
#define u_specular (U[12].x)
#define u_modelTransform (mat3(U[13].xyz, U[14].xyz, U[15].xyz))

#define __source__texelFetch__(c) texelFetch(u_source, (c), 0)
#define __source__(p) texture(u_source, __mirror_wrap__(vec2((p).x / u_worldAspect, (p).y) / 2.0 + 0.5))




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

vec2 hash12(float x) {
    return vec2(
        fract(sin(x*776.4577)*45.77), 
        fract(sin(x*376.4517+1.2524)*88.77) );
}

float ripple_(vec2 center, float radius, float time, float fullCycle, vec2 u) {
    u -= center;
    float d = length(u) / radius;
    float dim = radius * 0.1;
    float dampCenter = 0.0+time*0.3;
    float dampRadius = dim*1.5 * (1.0+time*0.5);
    float dampX = (d-dampCenter) / dampRadius;
    float damp = (abs(dampX)>1.) ? 0.0 : (cos(dampX*3.1415)+1.)*0.5;
    float timeDamp = pow(0.01, time/fullCycle) * smoothstep(fullCycle, fullCycle*0.5, time);
    return cos(d/dim*3.1415*2. - time*20.) * damp * timeDamp;
}

float ripples_(float maxDist, int count, float radiusVariability, float time, float fullCycle, vec2 u) {
    float total = 0.;
    float timeSlice = floor(time/fullCycle * float(count));
    for(int i=0; i<=count; ++i) {
        float id = timeSlice - float(i);
        vec2 h =  hash12(id);
        float radius = max(0.1, 1.0 + radiusVariability*(fract(h.x*41.)-0.5)*2.0);
        vec2 center = (h-0.5)*maxDist*2.;
        float localTime = time - float(id)/float(count)*fullCycle;
        total += ripple_(center, radius, localTime, fullCycle, u);
    }
    return total;
}

vec2 ripplesNormal(float maxDist, int count, float radiusVariability, float time, float fullCycle, vec2 u) {
    float ri = ripples_(maxDist, count, radiusVariability, time, fullCycle, u);
    float delta = 0.0001;
    float riX = ripples_(maxDist, count, radiusVariability, time, fullCycle, u+vec2(delta, 0.));
    float riY = ripples_(maxDist, count, radiusVariability, time, fullCycle, u+vec2(0.0, delta));
    return vec2((riX-ri)/delta, (riY-ri)/delta);
}

vec2 tf(mat3 m, vec2 u) {
    return (m * vec3(u, 1.)).xy;
}

vec4 rainPuddle(vec2 uv, vec2 outPos, int mode, float spacing, float intensity, int count, float radiusVariability, float time, float lighting, float specular, mat3 modelTransform) {
    mat3 t = inverse(modelTransform);
    vec2 u = tf(t, uv);
    vec4 col;
    
    vec2 ripplesN = ripplesNormal(spacing, count, radiusVariability, time*1., 4., u);
    vec3 n = normalize(vec3(ripplesN, 1.));
    
    if (mode==2) {
        col = vec4(vec3((ripples_(spacing, count, radiusVariability, time*1., 4., u)+1.)*0.5) , 1.);
    }
    else if (mode==1) {
        col = vec4(n.x, n.y, n.z, 1.);
    }
    else {
        vec2 duv = tf(modelTransform, u + ripplesN*intensity * 0.02);
        col = __source__(duv);
    }
    
    float lum = dot(n, normalize(vec3(1., 1., 0.))) * lighting;
    float spec = pow(max(0.0, dot(n, normalize(vec3(u.x, u.y, 1.)))), 9.) * 2. * specular;
    lum += spec;
   
    col += vec4(lum, lum, lum, 1.); 
    return col;
}

void main() {
    fragColor = rainPuddle((inverse(u_viewTransform) * vec3(((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), 1.0)).xy, ((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), u_mode, u_spacing, u_intensity, u_count, u_radiusVariability, u_time, u_lighting, u_specular, u_modelTransform);
}
