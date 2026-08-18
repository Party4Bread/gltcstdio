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
#define u_source_specified (int(U[4].x))
#define u_outDim (U[5].xy)
#define u_modelTransform (mat3(U[6].xyz, U[7].xyz, U[8].xyz))
#define u_color1 (U[9])
#define u_color2 (U[10])
#define u_colorBorder (U[11])
#define u_radius (U[12].x)
#define u_randomSeed (U[13].x)
#define u_thickness (U[14].x)
#define u_mode (int(U[15].x))

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

































































































































































































































































































































































vec3 combine(vec3 a, vec3 b) {
    return vec3(a.x + b.x, min(a.y, b.y), min(a.z, b.z));
}

float sdVesica(vec2 u, float r, float d) {
    u = abs(u);
    float b = sqrt(r*r - d*d);
    return ((u.y - b)*d > u.x*b) ? length(u - vec2(0.0,b)) : length(u - vec2(-d,0.0))-r;
}

float inVesica(float r, vec2 p) {
    return sdVesica(p, r, r*0.4);
}

float inCircle2(float a, float d, float r, vec2 p) {
    float ca = cos(a);
    float sa = sin(a);
    p = mat2(ca, sa, sa, -ca) * p - vec2(0., d);
    //vec2 c = d*vec2(-sin(a), cos(a));
    
    return inVesica(r, p);

}

vec3 inRosace(float r1, float r2, int N, vec2 p) {
    float di = length(p);
    if (di<r1) return vec3(0.0, r1-di, r1-di);
    else if (di>r2) return vec3(0.0, di-r2, di-r2);

    float r = (r2-r1)/2.0;
    float d = r2-r;
    vec3 inside = vec3(0.0, 1e9, 1e9); // vec2(minDist, count)
    
    for(int i=0; i<N; ++i) {
        float a = PI2*float(i)/float(N);
        float dist = inCircle2(a, d, r, p);
        inside = combine(inside, vec3((dist<0.0 ? 1.0 : 0.0), dist, abs(dist)));
    }
    return inside;
}

float makeDivisible(float a, float b) {
    if (a>b) {
        return b*floor(a/b+0.5);
    }
    else {
        return a*floor(b/a+0.5);
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

vec3 getInsideRosace(vec2 u, vec2 id, float radius, float randomSeed) {
    vec2 pos = u / radius;
    float l = length(pos);
    if (l>0.75) return vec3(0.0, l-0.75, abs(l-0.75));
    
    vec3 inside = vec3(0.0, 1e9, 1e9); // vec2(count, minDist, border dist)

    vec2 rnd = rand2relSeeded(id, randomSeed)+vec2(0.5, 0.5);

    int levels = int(1.0 + floor(rnd.x*3.0));

    float N = 1.0;
    float r1 = 0.75;
    float r2;

    if (id.x==0.0 && id.y==0.0 && randomSeed==0.0) {
        inside = combine(inside, inRosace(0.0, 0.25, 24, pos));
        inside = combine(inside, inRosace(0.25, 0.35, 12, pos));
        inside = combine(inside, inRosace(0.35, 0.75, 60, pos));
    }
    else for(int j=0; j<levels; ++j) {
        rnd = rand2relSeeded(rnd, randomSeed)+vec2(0.5, 0.5);
        r2 = r1;
        r1 = r1 * rnd.x;
        if (r1/r2>0.9) r1 = r2*0.9;
        if (r1<0.05) r1 = 0.0;
        N = makeDivisible(N, floor(rnd.y*rnd.y*60.0)+2.0);
        inside = combine(inside, inRosace(r1, r2, int(N), pos));
    }
    
    return inside;
}

vec4 getShapeOverlapColor(vec3 inside, int mode, float thickness, vec4 color1, vec4 color2, vec4 colorBorder) {
    float count = inside.x;
    float dist = inside.y;
    float borderDist = inside.z;
    
    float k;    
    if (mode==0) k = mod(count, 2.0)<1.0 ? 1.0 : 0.0;
    else if (mode==1) k = pow(0.8, count);
    else if (mode==2) k = mod(count, 2.0)<1.0 ? pow(0.8, count) : 1.0-pow(0.8, count);
    else if (mode==3) k = dist;
    else if (mode==4) k = -2.*dist;
    else k = 0.5;

    vec4 color = mix(color2, color1, k);
    if (borderDist<thickness*0.005) return colorBorder;
    else return color;
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

vec4 hexPolarCoords(vec2 v) {
    vec2 r = vec2(1.0, SQRT3);
    vec2 h = r/2.0;
    vec2 a = vec2(mod(v.x, r.x), mod(v.y, r.y))-h;
    vec2 b = vec2(mod(v.x-h.x, r.x), mod(v.y-h.y, r.y))-h;
    vec2 hv = length(a)<length(b) ? a : b;
    float x = atan(hv.y, hv.x);
    float y = length(hv);
    vec2 id = v-hv;
    return vec4(x, y, id);
}

vec4 mergeColor(vec4 bkg, vec4 front) {
    return vec4(mix(bkg.rgb, front.rgb, front.a + (1.0-bkg.a)*(1.0-front.a)), max(bkg.a, front.a));
}

vec4 rosette(vec2 uv, vec2 outPos, mat3 modelTransform, vec4 color1, vec4 color2, vec4 colorBorder, float radius, float randomSeed, float thickness, int mode, int source_specified) {
    vec2 pos = uv;

    vec4 hexCoord = hexCoords(pos);
    vec2 gridPos = hexCoord.xy;
    vec2 gridIndex = floor(hexCoord.zw * vec2(2.0, 2.0*SQRT3) + 0.5);

//    vec4 hexCoord = hexPolarCoords(pos);
//    vec2 gridPos = hexCoord.y*vec2(cos(hexCoord.x), sin(hexCoord.x));
//    vec2 gridIndex = floor(hexCoord.zw*1000.+0.5)*0.001;

    pos = gridPos / radius;
    vec3 inside = getInsideRosace(gridPos, gridIndex, radius, randomSeed);
    if (radius>0.66) {
        inside = combine(inside, getInsideRosace(gridPos-vec2(1., 0.), gridIndex+vec2(2., 0.), radius, randomSeed));
        inside = combine(inside, getInsideRosace(gridPos+vec2(1., 0.), gridIndex-vec2(2., 0.), radius, randomSeed));
        inside = combine(inside, getInsideRosace(gridPos-vec2(0.5, SQRT3_2), gridIndex+vec2(1., 3.), radius, randomSeed));
        inside = combine(inside, getInsideRosace(gridPos-vec2(-0.5, SQRT3_2), gridIndex+vec2(-1., 3.), radius, randomSeed));
        inside = combine(inside, getInsideRosace(gridPos-vec2(0.5, -SQRT3_2), gridIndex+vec2(1., -3.), radius, randomSeed));
        inside = combine(inside, getInsideRosace(gridPos-vec2(-0.5, -SQRT3_2), gridIndex+vec2(-1., -3.), radius, randomSeed));
    }

    /*vec2 rnd = rand2relSeeded(gridIndex, randomSeed)+vec2(0.5, 0.5);

    int levels = int(1.0 + floor(rnd.x*3.0));

    float N = 1.0;
    float r1 = 0.75;
    float r2;

    if (gridIndex.x==0.0 && gridIndex.y==0.0 && randomSeed==0.0) {
        inside += inRosace(0.0, 0.25, 24, pos);
        inside += inRosace(0.25, 0.35, 12, pos);
        inside += inRosace(0.35, 0.75, 60, pos);
    }
    else for(int j=0; j<levels; ++j) {
        rnd = rand2relSeeded(rnd, randomSeed)+vec2(0.5, 0.5);
        r2 = r1;
        r1 = r1 * rnd.x;
        if (r1/r2>0.9) r1 = r2*0.9;
        if (r1<0.05) r1 = 0.0;
        N = makeDivisible(N, floor(rnd.y*rnd.y*60.0)+2.0);
        inside += inRosace(r1, r2, int(N), pos);
    }*/
    
    vec4 color = getShapeOverlapColor(inside, mode, thickness, color1, color2, colorBorder);
    if (source_specified==1 && color.a<1.0) {
        vec4 bkg = __source__(uv);
        return mergeColor(bkg, color);
    }
    else {
        return color;
    }
//    float k;
//    float count = inside.x;
//    float dist = inside.y;
//    float borderDist = inside.z;
//    
//    
//     if (mode==0) k = mod(count, 2.0)<1.0 ? 1.0 : 0.0;
//     else if (mode==1) k = pow(0.8, count);
//     else if (mode==2) k = mod(count, 2.0)<1.0 ? pow(0.8, count) : 1.0-pow(0.8, count);
//     else if (mode==3) k = dist;
//     else if (mode==4) k = -2.*dist;
//     else k = 0.5;
//
//    vec4 color = mix(color2, color1, k);
//    if (borderDist<thickness*0.005) return colorBorder;
//    else return color;
}

void main() {
    fragColor = rosette((inverse(u_viewTransform) * vec3(((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), 1.0)).xy, ((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), u_modelTransform, u_color1, u_color2, u_colorBorder, u_radius, u_randomSeed, u_thickness, u_mode, u_source_specified);
}
