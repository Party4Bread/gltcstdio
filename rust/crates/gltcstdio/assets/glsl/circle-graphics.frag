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
#define u_count (int(U[5].x))
#define u_mode (int(U[6].x))
#define u_randomSeed (U[7].x)
#define u_thickness (U[8].x)
#define u_color (U[9])
#define u_radius (U[10].x)
#define u_glow (U[11].x)
#define u_variability (U[12].x)
#define u_modelTransform (mat3(U[13].xyz, U[14].xyz, U[15].xyz))

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




































































































































































































































































































































































float distToArc(vec2 p, vec2 center, float radius, float angBegin, float angEnd) {
    vec2 centerToP = p-center;
    float angle = atan(centerToP.y, centerToP.x);
    if (angle>=angBegin && angle<=angEnd) {
        return abs(length(p-center)-radius);
    }
    else {
        vec2 a = center + radius*vec2(cos(angBegin), sin(angBegin));
        vec2 b = center + radius*vec2(cos(angEnd), sin(angEnd));
        return min(length(p-a), length(p-b));
    }
}

float distToSegment(vec2 p, vec2 a, vec2 b) {
    vec2 ab = b-a;
    float abLen = length(ab);
    if (abLen==0.0) return length(p-a);
    vec2 abNorm = ab/abLen;
    vec2 ap = p-a;
    float abProj = dot(ap, abNorm);
    if (abProj>=0.0 && abProj<=abLen) {
        return abs(dot(ap, vec2(abNorm.y, -abNorm.x)));
    }
    else {
        return min(length(ap), length(p-b));
    }
}

vec2 rand2(vec2 v) {
    float x = fract(sin(dot(v.xy ,vec2(12.9898,78.233))) * 43758.5453);
    float y = fract(sin(dot(vec2(x, v.x) ,vec2(12.9898,78.233))) * 43758.5453);
    return vec2(x, y);
}

float varyNoiseSmoothly(float noise, float k) {
    float phase = acos(2.0*noise-1.0);
    float freq = fract(noise*16.0) + 0.5;
    return (1.0+cos(phase+freq*k))*0.5;
}

vec2 varyVec2NoiseSmoothly(vec2 noise, float k) {
    return vec2(varyNoiseSmoothly(noise.x, k), varyNoiseSmoothly(noise.y, k));
}

vec2 rand2relSeeded(vec2 co, float seed) {
    return varyVec2NoiseSmoothly(rand2(co), seed)-0.5;
}

float distToDisjointPiePieces(vec2 p, vec2 center, int n, float r1, float r2, float angBegin, float angEnd, float varia, float randomSeed) {
    float d = 1e10;
    vec2 centerToP = p-center;
    float ang = atan(centerToP.y, centerToP.x);
    float dAng = (angEnd-angBegin)/float(n);
//    float eAng = dAng * 0.075;
    float eAng = dAng * 0.1;
    float nd = floor(ang/dAng);

    float a1 = nd*dAng+eAng;
    vec2 dir1 = vec2(cos(a1), sin(a1));

    float a2 = nd*dAng+dAng-eAng;
    vec2 dir2 = vec2(cos(a2), sin(a2));
    if (varia!=0.0) {
        if (ang<-PI+dAng/2.0 && mod(float(n), 2.0)==1.0) nd = floor((ang+2.0*PI)/dAng);
        float dr = varia * rand2relSeeded(vec2(float(nd), float(nd)), randomSeed).x;
        if (varia>0.0) r2 = max(r1, r2+dr);
        else r1 = max(0.0, min(r2, r1+dr));
    }

    d = min(d, distToSegment(p, center+r1*dir1, center+r2*dir1));
    d = min(d, distToSegment(p, center+r1*dir2, center+r2*dir2));
    d = min(d, distToArc(p, center, r1, a1, a2));
    d = min(d, distToArc(p, center, r2, a1, a2));

    return d;
}

float distToPiePiece(vec2 p, vec2 center, int n, float r1, float r2, float angBegin, float angEnd) {
    float d = min(
        distToArc(p, center, r1, angBegin, angEnd),
        distToArc(p, center, r2, angBegin, angEnd)
    );
    vec2 centerToP = p-center;
    float ang = atan(centerToP.y, centerToP.x);
    float dAng = (angEnd-angBegin)/float(n);
    float nd = floor(ang/dAng);

    vec2 dir = vec2(cos((nd+0.5)*dAng), sin((nd+0.5)*dAng));
    d = min(d, distToSegment(p, center+r1*dir, center+r2*dir));

    return d;
}

float distToPolyPiece(vec2 p, vec2 center, int n, float r1, float r2, float angBegin, float angEnd) {
    float d = 1e10;
    vec2 centerToP = p-center;
    float ang = atan(centerToP.y, centerToP.x);
    float dAng = (angEnd-angBegin)/float(n);
    float nd = floor(ang/dAng);

    float a1 = nd*dAng;
    vec2 dir1 = vec2(cos(a1), sin(a1));

    float a2 = nd*dAng+dAng;
    vec2 dir2 = vec2(cos(a2), sin(a2));

    d = min(d, distToSegment(p, center+r1*dir1, center+r2*dir1));
    d = min(d, distToSegment(p, center+r1*dir2, center+r2*dir2));
    d = min(d, distToSegment(p, center+r2*dir1, center+r2*dir2));
    d = min(d, distToSegment(p, center+r1*dir1, center+r1*dir2));

    return d;
}

float distToRadialTicks(vec2 p, vec2 center, int n, float r1, float r2, float angBegin, float angEnd, float varia, float randomSeed) {
    float d = 1e10;
    vec2 centerToP = p-center;
    float ang = atan(centerToP.y, centerToP.x);
    float dAng = (angEnd-angBegin)/float(n);
    float nd = floor(ang/dAng);

    if (varia!=0.0) {
        if (ang<-PI+dAng/2.0 && mod(float(n), 2.0)==1.0) nd = floor((ang+2.0*PI)/dAng);
        float dr = varia * rand2relSeeded(vec2(float(nd), float(nd)), randomSeed).x;
        r2 = max(r1, r2+dr);
    }

    vec2 dir = vec2(cos((nd+0.5)*dAng), sin((nd+0.5)*dAng));
    d = min(d, distToSegment(p, center+r1*dir, center+r2*dir));

    return d;
}

vec4 mergeColor(vec4 bkg, vec4 front) {
    return vec4(mix(bkg.rgb, front.rgb, front.a + (1.0-bkg.a)*(1.0-front.a)), max(bkg.a, front.a));
}

float response(float d, float thickness, float blur) {
    return  pow(smoothstep(thickness, thickness+blur, d), 0.3);
}

vec2 tf(mat3 m, vec2 u) {
    return (m * vec3(u, 1.)).xy;
}

vec4 circleGraphics(vec2 uv, vec2 outPos, int count, int mode, float randomSeed, float thickness, vec4 color, float radius, float glow, float variability, mat3 modelTransform) {
    mat3 invModelTransform = inverse(modelTransform);
    vec2 u = tf(invModelTransform, uv);

    float scale = length(invModelTransform[0].xy);

    thickness = pow(thickness, 2.0)* 0.25 * scale;

    float varia = variability;
    int m = mode;//int(mod(float(u_Mode), 4.0));
    float d = 1e10;
    float r2 = 0.5;
    float r1 = r2 * radius;
    if (m==0) d = distToPiePiece(u, vec2(0.0, 0.0), int(count), r1, r2, -PI, PI);
    else if (m==1) d = distToPolyPiece(u, vec2(0.0, 0.0), int(count), r1, r2, -PI, PI);
    else if (m==2) d = distToDisjointPiePieces(u, vec2(0.0, 0.0), int(count), r1, r2, -PI, PI, varia, randomSeed);
    else if (m==3) d = distToRadialTicks(u, vec2(0.0, 0.0), int(count), r1, r2, -PI, PI, varia, randomSeed);
    else {
        int N = int(mod(float(mode), 5.0)+2.0);
        vec2 rnd = rand2relSeeded(vec2(mode, mode), 0.0);
        for(int i=0; i<N; ++i) {
            m = int(mod(4.0*(rnd.y+0.5), 4.0));
            float kv = floor(rnd.y*2.0+0.5)-0.5;
            if (m==0) d = min(d, distToPiePiece(u, vec2(0.0, 0.0), int(count), r1, r2, -PI, PI));
            else if (m==1) d = min(d, distToPolyPiece(u, vec2(0.0, 0.0), int(count), r1, r2, -PI, PI));
            else if (m==2) d = min(d, distToDisjointPiePieces(u, vec2(0.0, 0.0), int(count), r1, r2, -PI, PI, varia*kv, randomSeed));
            else d = min(d, distToRadialTicks(u, vec2(0.0, 0.0), int(count), r1, r2, -PI, PI, varia*kv, randomSeed));
            float scale = 0.5 + 0.9*rnd.x;
            if (scale<0.05) break;
            r1 *= scale;
            r2 *= scale;
            rnd = rand2relSeeded(rnd, 0.0);
        }
    }

    float blur = glow;
    float k = response(d, thickness, blur * 0.2 * scale);
    float gg = 0.025*max(0.0, blur*100.0-50.0) *pow(1.0-k, 10.0); 
    float addK = smoothstep(0.5, 1.0, blur);
    vec4 bkgCol = __source__(uv);
    vec3 shapeRgb = (color.rgb+vec3(gg, gg, gg))*(gg+1.0);
    // k is 0 on the shape and 1 outside it, so coverage is 1-k.
    vec4 overCol = mergeColor(bkgCol, vec4(shapeRgb, color.a*(1.0-k)));
    // Additive branch: weight the shape colour away from a transparent source's
    // meaningless rgb, and let the added light carry its own alpha.
    vec3 addRgb = mix(bkgCol.rgb, shapeRgb, color.a + (1.0-bkgCol.a)*(1.0-color.a));
    vec4 addCol = vec4(addRgb*(1.0-k) + bkgCol.rgb*bkgCol.a, min(1.0, bkgCol.a + color.a*(1.0-k)));
    vec4 outCol = mix(overCol, addCol, addK);

    return outCol;
}

void main() {
    fragColor = circleGraphics((inverse(u_viewTransform) * vec3(((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), 1.0)).xy, ((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), u_count, u_mode, u_randomSeed, u_thickness, u_color, u_radius, u_glow, u_variability, u_modelTransform);
}
