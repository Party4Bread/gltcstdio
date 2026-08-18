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
#define u_sourceDim (U[4].xy)
#define u_outDim (U[5].xy)
#define u_intensity (U[6].x)
#define u_mode (U[7].x)
#define u_scatter (U[8].x)
#define u_modelTransform (mat3(U[9].xyz, U[10].xyz, U[11].xyz))

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

float getRand(float x) {
    return (2.0*fract((fract(x*123.237+10.4343)+23.773)*434.4438))-1.0;
}

vec2 getHighVariance(vec2 p, float threshold, float k, mat3 invModelTransform) {
    p *= 10.0;
    float Y = p.y;
    float delta = 0.0;
    float scale = 0.5;
    for(int i=0; i<10; ++i) {
        float p0 = floor(p.y);
        float p1 = ceil(p.y);
        float f = fract(p.y);
        delta += mix(getRand(p0), getRand(p1), smoothstep(0.0, 1.0, f)) * scale;
        scale *= 0.5;
        p = p*2.0;
    }
    float l = smoothstep(threshold-0.2, threshold+0.2, delta);
    delta = l* sin(Y*100.0);

    return mat2(invModelTransform) / length(vec2(invModelTransform[0][0], invModelTransform[0][1]))
        * vec2(delta * k, 0.0);
}

float logistic(float x, float lambda, int n) {
    for(int i=0; i<12; ++i) {
        x = lambda*x*(1.0-x);
    }
    return x;
}

vec2 getLogistic(vec2 u, float intensity, float ratio, mat3 invModelTransform) {
    float Y = mod(u.y, 1.0)*4.0;

    float dx = logistic(0.5, Y, 15) - logistic(0.5, mod(Y*2.2, 4.0), 15);

    vec2 delta = vec2(ratio*dx * intensity, 0.0);
    delta *= mat2(invModelTransform) / length(vec2(invModelTransform[0][0], invModelTransform[0][1]));

    return delta;
}

vec2 getLogisticCompensated(vec2 u, float intensity, float ratio, mat3 invModelTransform) {
    float Y = mod(u.y, 1.0)*4.0;
    if (Y>1.0 && Y<3.5) {
        Y = 1.0 + pow((Y-1.0)/2.5, 12.0)*2.5;
    }
    float dx = logistic(0.5, Y, 15);// - logistic(0.5, mod(Y*2.2, 4.0), 15);

    vec2 delta = vec2(ratio*dx * intensity, 0.0);
    delta *= mat2(invModelTransform) / length(vec2(invModelTransform[0][0], invModelTransform[0][1]));

    return delta;
}

vec2 getMultiSine1(vec2 p, float k, mat3 invModelTransform) {
    p *= 4.0;
    vec2 delta = 0.3*k*vec2(
        (1.0+sin(0.54*p.y)) * sin(4.0*sin(0.98*p.y)*p.y)
        + (0.5+0.5*cos(1.54*p.y)) * cos(9.0*cos(3.75*p.y)*p.y)
        + (0.25+0.25*cos(3.421*p.y)) * cos(18.0*cos(8.5*p.y)*p.y),
        0.0);
    delta *= mat2(invModelTransform) / length(vec2(invModelTransform[0][0], invModelTransform[0][1]));
    return 0.5*delta;
}

vec2 getMultiSine2(vec2 p, float k, mat3 invModelTransform) {
    float z = fract(p.y*0.13123+565.444);
    z = fract(z*z*412.55);
    z = pow(abs(z*2.0-1.0), 4.0);
    float y = p.y;
    vec2 delta = z*k*vec2(
        (1.0+sin(0.4*y)) * sin(4.0*sin(0.98*y)*y)
        + (0.3+0.3*cos(1.54*y)) * cos(9.0*cos(3.75*y)*y),
        0.0);
    delta *= mat2(invModelTransform) / length(vec2(invModelTransform[0][0], invModelTransform[0][1]));
    return 0.5*delta;
}

vec2 getPerlin(vec2 p, float power, float k, mat3 invModelTransform) {
    p *= 10.0;
    float delta = 0.0;
    float scale = 0.5;
    for(int i=0; i<10; ++i) {
        float p0 = floor(p.y);
        float p1 = ceil(p.y);
        float f = fract(p.y);
        delta += mix(getRand(p0), getRand(p1), smoothstep(0.0, 1.0, f)) * scale;
        scale *= 0.5;
        p = p*2.0;
    }
    return mat2(invModelTransform) / length(vec2(invModelTransform[0][0], invModelTransform[0][1]))
        * vec2(delta * pow(clamp(abs(delta)*1.3, 0.0, 1.0), power-1.0) * k, 0.0);
}

vec4 getRand4(vec4 v) {
    return vec4(getRand(v.x), getRand(v.y), getRand(v.z), getRand(v.w));
}

vec2 getPerlinSine(vec2 p, float threshold, float k, mat3 invModelTransform) {
    p *= 15.0;
    float Y = p.y;
    vec4 delta = vec4(0.0);
    float scale = 0.5;
    for(int i=0; i<10; ++i) {
        float p0 = floor(p.y);
        float p1 = ceil(p.y);
        float f = fract(p.y);
        delta += mix(getRand4(vec4(p0, p0+5.0, p0+50.0, p0+123.0)), getRand4(vec4(p1, p1+5.0, p1+50.0, p1+123.0)), smoothstep(0.0, 1.0, f)) * scale;
        scale *= 0.5;
        p = p*2.0;
    }
    //float d = delta * pow(clamp(abs(delta)*1.3, 0.0, 1.0), power-1.0) * k;
//    float A = smoothstep(-0.125, -1.0, delta.y);
//    float B = smoothstep(0.25, 1.0, delta.w);
    float A = smoothstep(-1.0+threshold, -1.0, delta.z*delta.y);
    float B = smoothstep(1.0-threshold, 1.0, delta.w*delta.x);
    float s = A*delta.x*sin(Y*(0.5+0.125*delta.y)) + B*delta.z*sin(Y*(6.0+2.0*delta.w));
    //float s = A*delta.x*sin(Y*(0.5+0.125*delta.y)) + B*pow(clamp(abs(delta.z)*1.3, 0.0, 1.0), power-1.0)*sin(Y*(6.0+2.0*delta.w));
    return mat2(invModelTransform) / length(vec2(invModelTransform[0][0], invModelTransform[0][1]))
        * vec2(s*k*10.0, 0.0);
}

vec2 getDelta(vec2 u, float intensity, float mode, float ratio, mat3 invModelTransform) {
    float modeCount = 11.0;
    float scaledMode = mode*0.1*(modeCount-1.0);
    float fractMode = fract(scaledMode);
    float lowMode = floor(scaledMode);
    float highwMode = ceil(scaledMode);
    if (lowMode==0.0) {
        return mix(getLogistic(u, intensity, ratio, invModelTransform), getMultiSine2(u, intensity, invModelTransform), fractMode);
    }
    else if (lowMode==1.0) {
        return mix(getMultiSine2(u, intensity, invModelTransform), getLogisticCompensated(u, intensity, ratio, invModelTransform), fractMode);
    }
    else if (lowMode==2.0) {
        return mix(getLogisticCompensated(u, intensity, ratio, invModelTransform), getMultiSine1(u, intensity, invModelTransform), fractMode);
    }
    else if (lowMode==3.0) {
        return mix(getMultiSine1(u, intensity, invModelTransform), getPerlin(u, 1.0, intensity, invModelTransform), fractMode);
    }
    else if (lowMode==4.0) {
        return getPerlin(u, mix(1.0, 5.0, fractMode), intensity, invModelTransform);
        //return mix(getPerlin(u, 1.0, intensity), getPerlin(u, 5.0, intensity), fractMode);
    }
    else if (lowMode==5.0) {
        //return getPerlin(u, mix(1.0, 5.0, fractMode), intensity);
        return mix(getPerlin(u, 5.0, intensity, invModelTransform), getPerlin(u, 2.0, intensity*0.1, invModelTransform), fractMode);
    }
//    else if (lowMode==6.0) {
//        //return getPerlin(u, mix(1.0, 5.0, fractMode), intensity);
//        return getPerlin(u, mix(2.0, 1.0, fractMode), mix(0.1, 1.0, fractMode)*intensity);
//    }
    else if (lowMode==6.0) {
        //return getPerlin(u, mix(1.0, 5.0, fractMode), intensity);
        return mix(getPerlin(u, 2.0, intensity*0.1, invModelTransform), getPerlinSine(u, 1.0, 1.0, invModelTransform), fractMode);
    }
    else if (lowMode==7.0) {
        //return getPerlin(u, mix(1.0, 5.0, fractMode), intensity);
        return getPerlinSine(u, mix(1.0, 5.0, fractMode), intensity*mix(1.0, 0.1, fractMode), invModelTransform);
    }
    else if (lowMode==8.0) {
        //return getPerlin(u, mix(1.0, 5.0, fractMode), intensity);
        return mix(getPerlinSine(u, 5.0, intensity*0.1, invModelTransform), getHighVariance(u, -0.5, intensity, invModelTransform), fractMode);
    }
    else if (lowMode==9.0) {
        //return getPerlin(u, mix(1.0, 5.0, fractMode), intensity);
        return getHighVariance(u, mix(-0.5, 0.5, fractMode), intensity, invModelTransform);
    }
    else {
        return getHighVariance(u, 0.5, intensity, invModelTransform);
    }
}

vec2 rand2rel(vec2 co) {
    float x = fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
    float y = fract(sin(dot(vec2(x, co.x) ,vec2(12.9898,78.233))) * 43758.5453);
    return vec2(x, y)-vec2(0.5, 0.5);
}

vec2 tf(mat3 m, vec2 u) {
    return (m * vec3(u, 1.)).xy;
}

vec4 multiShift(vec2 uv, vec2 outPos, vec2 sourceDim, float intensity, float mode, float scatter, mat3 modelTransform) {
    float ratio = sourceDim.x/sourceDim.y;
    mat3 invModelTransform = inverse(modelTransform);
    vec2 u = tf(invModelTransform, uv);
    vec2 delta = getDelta(u, intensity, mode, ratio, invModelTransform);

    scatter = scatter * 2.;
    if (scatter>0.0) {
        float scattering = smoothstep(1.0-scatter, 1.0-scatter*0.5, 0.5+0.5*sin(u.y*5.0));
        float k = mix(1.0, abs(rand2rel(u).x), scattering);
        delta = k*delta;
    }
    return __source__(uv + delta);
}

void main() {
    fragColor = multiShift((inverse(u_viewTransform) * vec3(((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), 1.0)).xy, ((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), u_sourceDim, u_intensity, u_mode, u_scatter, u_modelTransform);
}
