#version 450
layout(location = 0) in vec2 v_uv;
layout(location = 0) out vec4 fragColor;

layout(binding = 0, std140) uniform Params {
    vec4 U[15];
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
#define u_glow (U[10].x)
#define u_variability (U[11].x)
#define u_modelTransform (mat3(U[12].xyz, U[13].xyz, U[14].xyz))

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





































































































































































































































































































































































































float distToCrossPartial(vec2 p, vec2 center, float r1, float r2 ) {
    p = abs(p);
    p = vec2(max(p.x, p.y), min(p.x, p.y));
    return length(p - center - vec2(clamp(r1, r2, p.x), 0.0));
}

float distToSquare(vec2 p, vec2 center, float radius) {
    p = abs(p-center);
    p = vec2(max(p.x, p.y), min(p.x, p.y));
    return length(p - vec2(radius, clamp(0.0, radius, p.y)));
}

float distToTarget1(vec2 p, vec2 center, float r) {
    return min(
    distToSquare(p, center, r*0.3),
    distToCrossPartial(p, center, r*0.3, r));
}

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

float distToTarget2(vec2 p, vec2 center, float r) {
    return min(
    distToArc(p, center, r*0.5, -PI, PI),
    distToCrossPartial(p, center, r*0.5, r));
}

float distToFullCircle(vec2 p, vec2 center, float radius) {
    return max(0.0, (length(p-center)-radius));
}

float min4n(float a, float b, float c, float d) { 
    return min(min(a, d), min(b, c));
}

float distToTarget3(vec2 p, vec2 center, float r) {
    return min4n(
    distToArc(p, center, r*0.3, -PI+0.5, -0.5),
    distToArc(p, center, r*0.3, 0.5, PI-0.5),
    distToCrossPartial(p, center, r*0.3, r),
    distToFullCircle(p, center, r*0.1)
    );
}

float distToTarget4(vec2 p, vec2 center, float r) {
    return min4n(
    distToArc(p, center, r*0.15, -PI, PI),
    distToArc(p, center, r*0.3, -PI, PI),
    distToArc(p, center, r*0.45, -PI, PI),
    distToCrossPartial(p, center, r*0.15, r)
    );
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

float distToRadialTicks2(vec2 p, vec2 center, int n, float r1, float r2, float angBegin, float angEnd) {
    float d = 1e10;
    vec2 centerToP = p-center;
    float ang = atan(centerToP.y, centerToP.x);
    float dAng = (angEnd-angBegin)/float(n);
    float nd = floor(ang/dAng);

    vec2 dir1 = vec2(cos((nd)*dAng), sin((nd)*dAng));
    vec2 dir2 = vec2(cos((nd+1.0)*dAng), sin((nd+1.0)*dAng));
    d = min(d, distToSegment(p, center+r1*dir1, center+r2*dir1));
    d = min(d, distToSegment(p, center+r1*dir2, center+r2*dir2));

    return d;
}

float min3n(float a, float b, float c) { 
    return min(a, min(b, c));
}

float distToTarget5(vec2 p, vec2 center, float r) {
    return min3n(
    distToRadialTicks2(p, center, 32, r*0.3, r*0.45, -PI, PI),
    distToRadialTicks2(p, center, 8, r*0.3, r*0.6, -PI, PI),
    distToCrossPartial(p, center, r*0.3, r)
    );
}

float distToRect(vec2 p, vec2 center, float rx, float ry) {
    float radius = min(rx, ry);
    p = abs(p-center);
    if (rx>ry) {
        p.x = max(0.0, p.x-rx+ry);
    }
    else {
        p.y = max(0.0, p.y-ry+rx);
    }
    p = vec2(max(p.x, p.y), min(p.x, p.y));
    return length(p - vec2(radius, clamp(0.0, radius, p.y)));
}

float distToDottedRect(vec2 p, vec2 center, float rx, float ry) {
    return min(
        distToRect(p, center, rx, ry),
        0.5*distToFullCircle(p, center, min(rx, ry)*0.0001) );
}

float distToDottedSquare(vec2 p, vec2 center, float radius) {
    return min(
        distToSquare(p, center, radius),
        0.5*distToFullCircle(p, center, radius*0.0001) );
}

float distToTarget6(vec2 p, vec2 center, float r) {
    vec2 c = vec2(0.0, 0.0);
    vec2 dx = vec2(0.25, 0.0);
    vec2 dy = vec2(0.0, 0.15);
    p = abs(p);
    return min(
        min(distToDottedSquare(p, c, r),
            distToDottedRect(p, c + 2.0*dy, r, r*0.7) ),
        min(distToDottedRect(p, c + 2.0*dx , r*0.7, r),
        distToDottedRect(p, c + dx+dy, r*0.7, r) ) );
}

float distToTarget7(vec2 p, vec2 center, float r, float m) {
    float d = 1e10;
    vec2 c = vec2(0.0, 0.0);
    p = abs(p-center);
    if (mod(m, 2.0)>=1.0) d = min(d, distToCrossPartial(p, c, r*0.3, r));
    m /= 2.0;
    if (mod(m, 2.0)>=1.0) d = min(d, distToRadialTicks2(p, c, 32, r*0.3, r*0.45, -PI, PI));
    m /= 2.0;
    if (mod(m, 2.0)>=1.0) d = min(d, distToRadialTicks2(p, c, 8, r*0.3, r*0.6, -PI, PI));
    m /= 2.0;
    if (mod(m, 2.0)>=1.0) d = min(d, distToSquare(p, c, r*0.5));
    m /= 2.0;
    if (mod(m, 2.0)>=1.0) d = min(d, distToSquare(p, c, r*0.3));
    m /= 2.0;
    if (mod(m, 2.0)>=1.0) d = min(d, distToArc(p, c, r*0.5, -PI, PI));
    m /= 2.0;
    if (mod(m, 2.0)>=1.0) d = min(d, distToArc(p, c, r*0.3, -PI, PI));
    m /= 2.0;
    if (mod(m, 3.0)>=2.0) d = min(d, distToSquare(p, vec2(r*0.5, r*0.5), r*0.1));
    else if (mod(m, 3.0)>=1.0) d = min(d, distToArc(p, vec2(r*0.5, r*0.5), r*0.1, -PI, PI));
    m /= 3.0;
    if (mod(m, 3.0)>=2.0) d = min(d, distToSquare(p, vec2(r*0.8, 0.0), r*0.1));
    else if (mod(m, 3.0)>=1.0) d = min(d, distToArc(p, vec2(r*0.8, 0.0), r*0.1, -PI, PI));
    m /= 3.0;

    return d;
}

float distToTarget(vec2 u, float radius, int m) {
    if (m==0) return distToTarget6(u, vec2(0.0, 0.0), 0.035);
    else if (m==1) return distToTarget1(u, vec2(0.0, 0.0), radius);
    else if (m==2) return distToTarget2(u, vec2(0.0, 0.0), radius);
    else if (m==3) return distToTarget3(u, vec2(0.0, 0.0), radius);
    else if (m==4) return distToTarget4(u, vec2(0.0, 0.0), radius);
    else if (m==5) return distToTarget5(u, vec2(0.0, 0.0), radius);
    else return distToTarget7(u, vec2(0.0, 0.0), radius, float(m));
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

vec4 targetGraphics(vec2 uv, vec2 outPos, int count, int mode, float randomSeed, float thickness, vec4 color, float glow, float variability, mat3 modelTransform) {
            mat3 invModelTransform = inverse(modelTransform);
            vec2 u = tf(invModelTransform, uv);
        
            float scale = length(invModelTransform[0].xy);
        
            thickness = pow(thickness, 2.0)* 0.25 * scale;
            float cellScale = 1.0;
            float d;
            if (mode<0) {
                vec2 id = floor(u+0.5);
                int m = int(id.x + id.y*(50.0-mod(float(mode), 100.0)));
                cellScale = 1.0 - float(mode/100)*0.1;
                d = distToTarget((fract(u+0.5)-0.5)*cellScale, 0.5, m);
            }
            else {
                d = distToTarget(u, 0.5, mode);
            }
            
//            float r2 = 0.5;
//            int m = mode;
//            if (m==0) d = distToTarget6(u, vec2(0.0, 0.0), 0.035);
//            else if (m==1) d = distToTarget1(u, vec2(0.0, 0.0), r2);
//            else if (m==2) d = distToTarget2(u, vec2(0.0, 0.0), r2);
//            else if (m==3) d = distToTarget3(u, vec2(0.0, 0.0), r2);
//            else if (m==4) d = distToTarget4(u, vec2(0.0, 0.0), r2);
//            else if (m==5) d = distToTarget5(u, vec2(0.0, 0.0), r2);
//            else d = distToTarget7(u, vec2(0.0, 0.0), r2, float(mode));
        
            float blur = glow;
            float k = response(d, thickness * cellScale, blur * 0.2 * scale);
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
    fragColor = targetGraphics((inverse(u_viewTransform) * vec3(((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), 1.0)).xy, ((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), u_count, u_mode, u_randomSeed, u_thickness, u_color, u_glow, u_variability, u_modelTransform);
}
