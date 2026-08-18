#version 450
layout(location = 0) in vec2 v_uv;
layout(location = 0) out vec4 fragColor;

layout(binding = 0, std140) uniform Params {
    vec4 U[18];
};
layout(binding = 1) uniform sampler samp;

#define u_worldAspect (U[0].x)
#define u_viewTransform (mat3(U[1].xyz, U[2].xyz, U[3].xyz))
#define u_outDim (U[4].xy)
#define iTime (U[5].x)
#define u_model3DTransform (mat4(U[6], U[7], U[8], U[9]))
#define u_lightSourceTransform (mat4(U[10], U[11], U[12], U[13]))
#define u_camera3DTransform (mat4(U[14], U[15], U[16], U[17]))


const float SKY = 0.;
const float WATER = 10.;
const float SHALLOWWATER = 11.;
const float GROUND = 21.;
const float CLOUD = 22.;
const float RINGS = 50.;



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


















































































































































































































































































































































#define HH 0.175














        






































#define MAX_STEPS 1000
#define MAX_DIST 100.0




struct Intersection {
    vec3 p;
    float material;
    vec4 diffCol;
    float minD;
};


























vec3 hash33(vec3 u) {
    return vec3(
        fract(sin(u.x*776.45+u.y*453.24+u.z*553.25)*45.77), 
        fract(sin(u.x*376.45+u.y*853.24+u.z*153.84)*88.77),
        fract(sin(u.x*457.77+u.y*667.17+u.z*355.94)*65.57) );
}

mat4 rotX(float ang) {
    return mat4(1.0, 0.0, 0.0, 0.0,
                0.0, cos(ang), sin(ang), 0.0,
                0.0, sin(ang), -cos(ang), 0.0,
                0.0, 0.0, 0.0, 1.0);

}

mat4 rotZ(float ang) {
    return mat4(cos(ang), sin(ang), 0.0, 0.0,
                sin(ang), -cos(ang), 0.0, 0.0,
                0.0, 0.0, 1.0, 0.0,
                0.0, 0.0, 0.0, 1.0);

}

float sdSegment3(vec3 u, vec3 a, vec3 b) {
    vec3 ua = u-a;
    vec3 ba = b-a;
    float h = clamp(dot(ua, ba)/dot(ba, ba), 0., 1.);
    return length(ua - ba*h);
}

vec2 clouds3(vec3 p) {
    int N = 6;
    float d = 1e6;
    for(int i=0; i<N; ++i) {
        vec3 rnd = hash33(vec3(float(i-13)));
        mat4 t = rotX((rnd.y-0.5)*2.0) *rotZ(rnd.x*6.28) ;
        vec3 q = (t * vec4(p, 1.)).xyz;
        float l1 = 0.05+rnd.y*0.05;
        float a1 = 1.02 + 0.05*floor(rnd.z*3.);
        //float delta = (rnd.x-0.5) * 4. * l1;
        float delta = pow(rnd.x, 0.2) * 2. * l1;
        float l2 = 0.05+rnd.z*0.05;
        float d2 = sdSegment3(q, vec3(-l1, a1, 0.), vec3(l1, a1, 0.));
        d2 = min(d2, sdSegment3(q, vec3(delta-l2, a1, l1*0.9), vec3(delta+l2, a1, l1*0.9)));
        d2 = d2 - 0.10;
        d2 = max(d2, abs(length(q)-a1)-0.00);
        d = min(d, d2);
    }
    d = d - 0.01;
    return vec2(d, CLOUD);
}

vec2 minMat(vec2 a, vec2 b) {
    return a.x<b.x ? a : b;
}

vec2 minMat3(vec2 a, vec2 b, vec2 c) {
    return minMat(a, minMat(b, c));
}

vec2 noclouds(vec3 p) {
    return vec2(10000., CLOUD);
}

vec3 rndUnit3(vec3 p) {
    vec3 u = fract(p * vec3(.1031, .1030, .0973));
    u += dot(u, u.yxz+33.33);
    vec3 h = fract((u.xxy + u.yxx)*u.zyx);
    return normalize(h-0.5);
}

float dotGridGradient3(vec3 g, vec3 u) {
    return dot(u-g, rndUnit3(g));
}

float smix(float a, float b, float k) {
    return mix(a, b, smoothstep(0.0, 1.0, k));
}

float perlinRelNoise3(vec3 p) {
    vec3 s = vec3(1.0, 0.0, 0.0);
    vec3 f = floor(p);
    vec3 d = p-f;
    float ix00 = smix(dotGridGradient3(f, p), dotGridGradient3(f+s, p), d.x);
    float ix10 = smix(dotGridGradient3(f+s.yxz, p), dotGridGradient3(f+s.xxz, p), d.x);
    float ix01 = smix(dotGridGradient3(f+s.yyx, p), dotGridGradient3(f+s.xyx, p), d.x);
    float ix11 = smix(dotGridGradient3(f+s.yxx, p), dotGridGradient3(f+s.xxx, p), d.x);
    float iy0 = smix(ix00, ix10, d.y);
    float iy1 = smix(ix01, ix11, d.y);
    return smix(iy0, iy1, d.z);
}

vec2 planet2(vec3 p) {
    float lp = length(p);
    if (lp>1.+HH*2. || lp<1.0) return vec2(length(lp) - 1., WATER);

    //float main = perlinRelNoise3(p*2.55);
    float main1 = 0.05 + perlinRelNoise3(p*1.56) + 0.5*perlinRelNoise3(p*4.79) + 0.25*perlinRelNoise3(p*10.3);
    float main2 = main1  + 0.125*perlinRelNoise3(p*21.0);//+ 0.0625*perlinRelNoise3(p*53.0);
    float main = main2;
    //float main = 0.05 + perlinRelNoise3(p*1.55) + 0.5*perlinRelNoise3(p*4.78);// + 0.25*perlinRelNoise3(p*10.0) + 0.125*perlinRelNoise3(p*22.0);
    vec3 q = p * (1. + HH * main);
    //return minMat(vec2(length(q) - 1., GROUND), vec2(length(lp) - 1., main>0.0625 ? WATER : SHALLOWWATER));
    return minMat(vec2(length(q) - 1., GROUND), vec2(length(lp) - 1., WATER + clamp(main1, 0., 1.)));
}

vec2 rings(vec3 p) {
    float thickness = 0.008;
    float width = 0.2;
    float R = 1.8;
    float r = thickness;
    float a = abs(sqrt(p.x*p.x + p.y*p.y) - R);
    vec2 q = vec2(a, p.z);
    vec2 c1 = vec2(min(a, width), 0.);
    return vec2((length(q-c1) - r), RINGS);
}

vec2 sdf(vec3 p) {
    //return planet2(p);
    return minMat3(planet2(p), rings(p), noclouds(p));
    //return minMat(planet2(p), clouds3(p));
}

vec3 getNormal(vec3 p) {
    float d = 0.0001;
    float d2 = d*2.0;
    return normalize(vec3(
        (sdf(vec3(p.x-d, p.y, p.z)).x-sdf(vec3(p.x+d, p.y, p.z)).x)/d2,
        (sdf(vec3(p.x, p.y-d, p.z)).x-sdf(vec3(p.x, p.y+d, p.z)).x)/d2,
        (sdf(vec3(p.x, p.y, p.z-d)).x-sdf(vec3(p.x, p.y, p.z+d)).x)/d2
        ));
}

vec3 getRay(vec2 uv, vec3 camera, vec3 target, float focalDist) {
    vec3 camZ = normalize(target-camera);
    vec3 camX = normalize(cross(vec3(0.,1.,0.), camZ));
    vec3 camY = cross(camZ,camX);
    return normalize(camZ*focalDist + uv.x*camX + uv.y*camY);
}

bool isWater(float material) { return material>=WATER && material<=SHALLOWWATER; }

float getSpecular(float material, vec3 camDir, vec3 normal, vec3 lightDir) {
    vec3 ref = reflect(lightDir, normal);
    float k = 0.;
    if (isWater(material)) k = .9;
    else if (material==GROUND) k = .1;
    else if (material==RINGS) k = .5;
    return pow(max(0., dot(ref, camDir)), 9.) * k;
}

vec3 groundColor(vec3 p) {
    vec3 col = mix(vec3(0.15, 0.5, 0.15), vec3(0.55, 0.44, 0.39), smoothstep(0.05, 0.35, perlinRelNoise3(p*5.22)));

    float d = (length(p) - 1.) / HH;
    if (d<0.1) col = mix(vec3(0.9, 0.8, 0.35), col, smoothstep(0.05, 0.06, d));
    else if (d>0.1) col = mix(col, vec3(1.), smoothstep(0.45, 0.5, d));

    float pole = smoothstep(0.8, 0.9, abs(p.z));
    col = mix(col, vec3(1.), pole);

    return col;
}

float perlinNoise3(vec3 p) {
    return 0.5+perlinRelNoise3(p)*0.5;
}

float getCloudDensity(vec3 p) {
    float d = length(p);
    return smoothstep(0.1, 0.05, abs(d-1.05)) * smoothstep(0.5, 0.7, perlinNoise3(p*vec3(1.5, 1.5, 3.)*pow(length(p), 3.)));
}

vec4 getDiffusion2(vec4 diffCol, vec3 p, float dist, vec3 lightDir) {

    float c = 1.5*smoothstep(1.5, 1.08, length(p));
    float illum = pow(max(0., 0.35+dot(p, lightDir)), 0.35);
    float cloud = getCloudDensity(p);

    vec3 base = mix(vec3(0.2, 0.75, 1.5) * illum, vec3(illum*.8+.2), cloud);
    c = mix(c, 25., cloud);

    vec4 col = vec4(base, min(c * dist * (.5+.5* illum), 1.));

    return vec4(mix(diffCol.rgb, col.rgb, col.a), mix(diffCol.a, 1.0, col.a));
}

Intersection rayMarch(vec3 p0, vec3 dir, vec3 lightDir) {
    vec2 d = sdf(p0);
    float s = sign(d.x);
    float totalD = 0.0;
    int step = 0;
    vec4 diffCol = vec4(0.);
    float minD = 1e9;
    while (step < MAX_STEPS && d.x<MAX_DIST) {
        float stepD = d.x*0.85;
        totalD += stepD;
        vec3 p = p0 + totalD*dir;

        d = sdf(p);
        minD = min(d.x/totalD, minD);
        diffCol = getDiffusion2(diffCol, p, stepD, lightDir);
        if (diffCol.a>0.95) return Intersection(p, d.y, diffCol, minD);
        if (abs(d.x)<0.0001) return Intersection(p, d.y, diffCol, minD);
        ++step;
    }
    return Intersection(vec3(INF), SKY, diffCol, minD);
}

vec3 ringsColor(vec3 p) {
    float d = length(p);
    //vec3 col = vec3(0.6, 0.5, 0.35) * (1.5 + 0.3 * pow(sin(d*5.+sin(d*40.0)), 3.));
    vec3 col = vec3(0.5, 0.6, 0.7) * (1.5 + 0.3 * pow(sin(d*5.+sin(d*40.0)), 3.));
    return col;
}

vec4 planet(vec2 uv, vec2 outPos, mat4 model3DTransform, mat4 lightSourceTransform, mat4 camera3DTransform) {
    float D = 0.5;
//vec3 camera = vec3(0., 0., D);
    vec3 camera = vec3(0., 0., 0.);
    camera = ((camera3DTransform) * vec4(camera, 1.)).xyz;

    vec3 target = vec3(0.);
    vec3 camDir = getRay(uv, camera, target, 1.); // no longer used
    
//mat4 invModelTransform = inverse(model3DTransform);
//mat3 model3DTransform3 = mat3(model3DTransform);
//camera = (invModelTransform * vec4(camera, 1.)).xyz;
//camDir = mat3(invModelTransform) * camDir; 
    
    mat4 invModelTransform = inverse(model3DTransform);
    mat3 model3DTransform3 = mat3(model3DTransform);
    camera = (invModelTransform * vec4(camera, 1.)).xyz;
    vec3 dir = normalize(vec3(uv.x*D, uv.y*D, -1.0));
    dir = mat3(camera3DTransform) * dir;
    camDir = normalize(mat3(invModelTransform) * dir);
    
    vec3 lightPos = (lightSourceTransform * vec4(0.0, 0.0, 0.0, 1.0)).xyz;
    vec3 lightDir = -lightPos;
    vec3 p = camera;

    vec3 col = vec3(0.0);

    Intersection intersection = rayMarch(p, camDir, lightDir);
    vec3 q = intersection.p;
    float material = intersection.material;
    vec3 normal = getNormal(q);
    if (material==SKY) col = vec3(0.1, 0.2, 0.3);
    else if (isWater(material)) col = mix(vec3(0.2, 0.75, 1.0), vec3(0.1, 0.2, 0.8), smoothstep(0.05, 0.4, material-WATER));
    //else if (material==WATER) col = vec3(0.15, 0.3, 1.0);
    //else if (material==SHALLOWWATER) col = vec3(0.3, 0.6, 1.0);
    else if (material==GROUND) col = groundColor(q);
    else if (material==RINGS) col = ringsColor(q);
    else if (material==CLOUD) col = vec3(1.);
    else if (q.x!=INF) col = normal*0.5+0.5;



    float illum = max(0., dot(normal, -lightDir));
    if (q.x!=INF) { // shadows
        vec3 start = q - camDir*0.0005;
        Intersection intersection = rayMarch(start, lightDir, lightDir);
        if (intersection.p.x!=INF) illum = 0.;
        else illum *= clamp(intersection.minD*25., 0., 1.); // penumbra - completely ad-hoc
    }
    col *= (0.15 + 1.*illum);

    vec4 diffCol = intersection.diffCol;
    col = mix(col.rgb, diffCol.rgb, diffCol.a);

    float spec = getSpecular(material, camDir, normal, lightDir);
    col += spec;

    return vec4(col,1.0);
}

void main() {
    fragColor = planet((inverse(u_viewTransform) * vec3(((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), 1.0)).xy, ((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), u_model3DTransform, u_lightSourceTransform, u_camera3DTransform);
}
