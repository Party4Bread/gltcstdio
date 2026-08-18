#version 450
layout(location = 0) in vec2 v_uv;
layout(location = 0) out vec4 fragColor;

layout(binding = 0, std140) uniform Params {
    vec4 U[25];
};
layout(binding = 1) uniform sampler samp;

#define u_worldAspect (U[0].x)
#define u_viewTransform (mat3(U[1].xyz, U[2].xyz, U[3].xyz))
#define u_outDim (U[4].xy)
#define u_time (U[5].x)
#define u_modelTransform (mat3(U[6].xyz, U[7].xyz, U[8].xyz))
#define u_treeColor (U[9])
#define u_treePattern (U[10].x)
#define u_treeTransform (mat3(U[11].xyz, U[12].xyz, U[13].xyz))
#define u_mountainColor (U[14])
#define u_mountainPattern (U[15].x)
#define u_mountainDetail (U[16].x)
#define u_mountainTransform (mat3(U[17].xyz, U[18].xyz, U[19].xyz))
#define u_hillColor (U[20])
#define u_hillPattern (U[21].x)
#define u_hillTransform (mat3(U[22].xyz, U[23].xyz, U[24].xyz))





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











































































































































































































































































































































#define MAXHEIGHT 0.75

#define RADIUS 0.1





























































vec4 getColorAtLayer2(vec4 col, float z, mat3 lighting) {
    vec3 lightAtSun = lighting[0];
    vec3 lightAtTop = lighting[1];
    vec2 sunPos = lighting[2].xy;
    vec3 midColor = mix(lightAtSun, lightAtTop, 0.5);
    float phaseOffset = lighting[2].z;
    float kMoonPower = 1.0-min(1.0, abs(phaseOffset)/(2.*RADIUS));

    float sunPower = smoothstep(-MAXHEIGHT*0.4, -MAXHEIGHT, sunPos.y);
    midColor = mix(midColor, 1.08*vec3(1.0, 1.0, 1.2), smoothstep(-MAXHEIGHT*0.4, -MAXHEIGHT, sunPos.y));
    //if (sunPower<=0.) midColor = mix(midColor, vec3(0.2, 0.5, 1.0), max(0., 1.-kMoonPower));
    //if (sunPos.y>0.) midColor = mix(midColor, vec3(0.4, 0.62, 1.0), smoothstep(0.0, 0.2, sunPos.y) * max(0., 1.-kMoonPower));
    if (sunPos.y>0.) midColor = mix(midColor, vec3(0.62, 0.78, 1.0), smoothstep(0.0, 0.2, sunPos.y) * pow(mix(0.1, 1., max(0., 1.-kMoonPower)), 0.5));

    z = mix(z, z*0.15, sunPower); // less layer darkening as more sun

    //vec4 lightedCol = col * vec4(0.1, 0.4, 1.0, 1.0);
    //vec4 lightedCol = col * vec4(0.2, 0.5, 1.0, 1.0);
    vec4 lightedCol = col * vec4(midColor, 1.0);
    vec4 haze = vec4(0.0, 0.02, 0.04, col.a);
    return mix(haze, lightedCol, pow(0.9, z));
}

vec3 interpolateCol5(float k0, vec3 col0, float k1, vec3 col1, float k2, vec3 col2, float k3, vec3 col3, float k4, vec3 col4, float k) {
    if (k<k1) return mix(col0, col1, (k-k0)/(k1-k0));
    if (k<k2) return mix(col1, col2, (k-k1)/(k2-k1));
    if (k<k3) return mix(col2, col3, (k-k2)/(k3-k2));
    return mix(col3, col4, (k-k3)/(k4-k3));
}

mat3 getLighting(float time) {
    float angle = time;
    vec2 moonPos = vec2(MAXHEIGHT, MAXHEIGHT) * vec2(sin(angle), -cos(angle));
    vec2 sunPos = -moonPos;
    vec3 lightAtSun = interpolateCol5(
        -MAXHEIGHT, vec3(0.1, 0.4, 1.0), //vec3(0.2, 0.8, 1.0),
        -MAXHEIGHT*0.3, vec3(1.0, 0.9, 0.2),
        MAXHEIGHT*0.1, vec3(0.5, 0.1, 0.0),
        MAXHEIGHT*0.2, vec3(0.1, 0.4, 1.0)*0.1,
        MAXHEIGHT, vec3(.0),
        sunPos.y);
    vec3 lightAtTop = interpolateCol5(
        -MAXHEIGHT, vec3(0.1, 0.4, 1.0),
        -MAXHEIGHT*0.3, vec3(0.3, 0.1, 0.8),
        MAXHEIGHT*0.1, vec3(0.3, 0.1, 0.8),
        MAXHEIGHT*0.2, vec3(0.1, 0.4, 1.0)*0.1,
        MAXHEIGHT, vec3(0.),
        sunPos.y);
    float phaseOffset = (fract(time*0.015) - 0.5) * (RADIUS * 4.6);
    return mat3(lightAtSun, lightAtTop, vec3(sunPos, phaseOffset));
}

float hash11(float x) {
    return fract(sin(x*45.34+123.131)*94.434);
}

vec4 mergeColor(vec4 bkg, vec4 front) {
    return vec4(mix(bkg.rgb, front.rgb, front.a + (1.0-bkg.a)*(1.0-front.a)), max(bkg.a, front.a));
}

vec2 hash22b(vec2 u) {
    return vec2(
        fract(sin(dot(u.xy, vec2(13.7545,78.224)))* 43758.5453123), 
        fract(sin(dot(u.xy, vec2(15.7545,73.224)))* 43758.5453123) );
}

vec2 rndUnit(vec2 p) {
    vec2 rnd = hash22b(p)-0.5;
    float len = length(rnd);
    if (len==0.0) return vec2(0., 1.0); else return rnd/len;
}

float dotGridGradient(vec2 g, vec2 u) {
    return dot(u-g, rndUnit(g));
}

float smix(float a, float b, float k) {
    return mix(a, b, smoothstep(0.0, 1.0, k));
}

float perlinNoise(vec2 p) {
    vec2 s = vec2(1.0, 0.0);
    vec2 f = floor(p);
    vec2 d = p-f;
    float ix0 = smix(dotGridGradient(f, p), dotGridGradient(f+s, p), d.x);
    float ix1 = smix(dotGridGradient(f+s.yx, p), dotGridGradient(f+s.xx, p), d.x);
    return 0.5+smix(ix0, ix1, d.y)*0.5;
}

float perlinOctaveNoise(vec2 uv, int n) {
    mat2 transform = 2.1111*mat2(sin(1.), cos(1.), -cos(1.), sin(1.));
    
    float k = 1.;
    float x = 0.;
    float total = 0.;
    
    for(int i=0; i<n; ++i) {
        x += k * perlinNoise(uv);
        total += k;
        k *= 0.5;
        uv = transform * uv;
    }
    
    x /= total;  
    return x;
}

mat2 rotation2(float angle) {
    float ca = cos(angle);
    float sa = sin(angle);
    return mat2(ca, sa, -sa, ca);
}

float sdTriangleIsosceles( in vec2 p, in vec2 q ) {
    p.x = abs(p.x);
    vec2 a = p - q*clamp( dot(p,q)/dot(q,q), 0.0, 1.0);
    vec2 b = p - q*vec2( clamp( p.x/q.x, 0.0, 1.0 ), 1.0);
    float s = -sign(q.y);
    vec2 d = min( vec2( dot(a,a), s*(p.x*q.y-p.y*q.x)), vec2( dot(b,b), s*(p.y-q.y)));
    return -sqrt(d.x)*sign(d.y);
}

float sdVesica(vec2 u, float r, float d) {
    u = abs(u);
    float b = sqrt(r*r - d*d);
    return ((u.y - b)*d > u.x*b) ? length(u - vec2(0.0,b)) : length(u - vec2(-d,0.0))-r;
}

vec4 rabbit(vec2 v, float id) {
    //vec4 mainCol = vec4(0.8, 0.65, 0.5, 1.);
    vec4 mainCol = vec4(0.95, 0.93, 0.9, 1.);
    v.y += -0.08;
    float d;
    vec2 uv;
    

    uv = v - vec2(0.03, 0.2);
    // eyes
    vec2 u = vec2(abs(uv.x)-0.055, uv.y-0.0);
    if (length(u)-0.0125 < 0.0) return vec4(0.2, 0.2, 0.2, 1.);
    
    // nose
    u = uv - vec2(0., -0.06);
    if (sdTriangleIsosceles(u, vec2(0.010, 0.010))-0.005 < 0.0) return vec4(0.2, 0.2, 0.2, 1.);
    
    
    // head
    d = length(uv*vec2(1., 1.1))-0.1;
    if (d<0.) return mainCol;
    u = vec2(abs(uv.x)-0.06, uv.y+0.02);
    if (length(u)-0.06 < 0.0) return mainCol;
    d = length(uv*vec2(1., 3.)+vec2(0., 0.22))-0.1;
    if (d<0.) return vec4(mainCol.rgb*0.8, 1.);
       
    // ears
    uv = vec2(abs(uv.x)-0.07, uv.y-0.13);
    uv *= rotation2(-0.3);
    d = sdVesica(uv, 0.18, 0.15);
    if (d<0.) return vec4(mainCol.rgb*vec3(1., 0.9, 0.9), 1.);
    d = sdVesica(uv, 0.2, 0.15);
    if (d<0.) return vec4(mainCol.rgb*0.8, 1.);

    // body
    uv = v;
    d = min(length(uv*vec2(0.8, 1.))-0.13, length(uv-vec2(0.03, 0.08)*vec2(1.0, 0.8))-0.13);
    if (d<0.) return mainCol;
    d = length(uv+vec2(0.15, 0.05))-0.05;
    if (d<0.) return vec4(mainCol.rgb*0.95, 1.);


    else return vec4(0.);
}

float sdRectangle(vec2 u, vec2 halfSize) {
    u = abs(u)-halfSize;
    return (u.x>=0. && u.y>=0.) ? length(u) : max(u.x, u.y);
}

vec4 snowman(vec2 v, float id) {
    //vec4 mainCol = vec4(0.8, 0.65, 0.5, 1.);
    vec4 mainCol = vec4(0.9, 0.9, 0.9, 1.);
    v.y += -0.18-1.05;
    float d;
    vec2 uv, u;
    
    uv = v;

    // foreground arm    
    u = rotation2(-0.4) * (uv - vec2(0.39, -0.30));
    d = sdRectangle(u, vec2(0.2, 0.03));
    if (d<0.) return vec4(0.5, 0.3, 0.05, 1.); 
    u = rotation2(-0.8) * (uv - vec2(0.60, -0.15));
    d = sdRectangle(u, vec2(0.12, 0.025));
    if (d<0.) return vec4(0.5, 0.3, 0.05, 1.); 
    u = rotation2(-0.2) * (uv - vec2(0.68, -0.20));
    d = sdRectangle(u, vec2(0.15, 0.027));
    if (d<0.) return vec4(0.5, 0.3, 0.05, 1.); 


    // eyes
    u = vec2(abs(uv.x+0.1)-0.12, uv.y-0.05);
    if (length(u)-0.04 < 0.0) return vec4(0.2, 0.2, 0.2, 1.);
    
    // nose
    u = rotation2(1.0) * (uv+vec2(0.35, 0.2));
    if (sdTriangleIsosceles(u, vec2(0.040, 0.320))-0.01 < 0.0) return vec4(0.7, 0.4, 0.1, 1.);
    
    d = length(uv)-0.35;
    if (d<0.) return vec4(mainCol.rgb, 1.);
    
    uv.y += 0.45;
    
    // buttons
    u = vec2(uv.x+0.2, uv.y-0.1);
    if (length(u)-0.04 < 0.0) return vec4(0.2, 0.2, 0.2, 1.);
    u = vec2(uv.x+0.215, uv.y+0.05);
    if (length(u)-0.04 < 0.0) return vec4(0.2, 0.2, 0.2, 1.);
    u = vec2(uv.x+0.2, uv.y+0.2);
    if (length(u)-0.04 < 0.0) return vec4(0.2, 0.2, 0.2, 1.);
   
    d = length(uv)-0.4;
    if (d<0.) {
        d = length(uv-vec2(0., 0.4))-0.35;
        //if (d<0.) return vec4(mainCol.rgb*0.9, 1.);
        return vec4(mainCol.rgb, 1.);
    }
    
    uv.y += 0.525;
    d = length(uv)-0.5;
    if (d<0.) {
        d = length(uv-vec2(0., 0.4))-0.4;
        //if (d<0.) return vec4(mainCol.rgb*0.9, 1.);
        return vec4(mainCol.rgb, 1.);
    }

    uv.y -= 0.9;
    // hat
    
    u = rotation2(-2.7) * (uv - vec2(0.2, 0.68));
    d = sdTriangleIsosceles(u, vec2(0.18, 0.42))-0.0;
    if (d<0.) return vec4(0.8, 0.1, 0.1, 1.); 

    // foreground arm  
    uv.x = -uv.x;
    u = rotation2(-0.4) * (uv - vec2(0.39, -0.30));
    d = sdRectangle(u, vec2(0.2, 0.03));
    if (d<0.) return vec4(0.5, 0.3, 0.05, 1.); 
    u = rotation2(-0.8) * (uv - vec2(0.60, -0.15));
    d = sdRectangle(u, vec2(0.12, 0.025));
    if (d<0.) return vec4(0.5, 0.3, 0.05, 1.); 
    u = rotation2(-0.2) * (uv - vec2(0.68, -0.20));
    d = sdRectangle(u, vec2(0.15, 0.027));
    if (d<0.) return vec4(0.5, 0.3, 0.05, 1.); 
    
    return vec4(0.);
}

vec2 tf(mat3 m, vec2 u) {
    return (m * vec3(u, 1.)).xy;
}

float sdStar5(in vec2 p, in float r, in float rf) {
    const vec2 k1 = vec2(0.809016994375, -0.587785252292);
    const vec2 k2 = vec2(-k1.x,k1.y);
    p.x = abs(p.x);
    p -= 2.0*max(dot(k1,p),0.0)*k1;
    p -= 2.0*max(dot(k2,p),0.0)*k2;
    p.x = abs(p.x);
    p.y -= r;
    vec2 ba = rf*vec2(-k1.y,k1.x) - vec2(0,1);
    float h = clamp( dot(p,ba)/dot(ba,ba), 0.0, r );
    return length(p-ba*h) * sign(p.y*ba.x-p.x*ba.y);
}

float triangleToSquareWave(float x, float k) {
    x = mod(x, 4.);
    float s = 1.0;
    if (x>2.0) { x = x - 2.0; s = -1.; }
    float m = k>0.0 ? 1.0 : pow(mix(5., 40., -k), -k);
    return m * s * (1. - pow(abs(x-1.), pow(100.0, k)));
}

vec4 tree4(vec2 uv, float id, float treePattern, vec4 treeColor, mat3 treeTransform) {
    float rnd = hash11(id);
    float angle = (rnd - 0.5)*0.15;
    //if (abs(angle)>0.05) return vec4(0.);
    float treeProb = sin(id*0.25);
//    if (fract(rnd*11.1)>0.25+0.5*sign(treeProb)*pow(treeProb, 3.)) return vec4(0.);
    if (fract(rnd*11.1)>0.25+0.5*treeProb*treeProb*treeProb) return vec4(0.);
    //mat2 rot = rotation2(angle);
    mat2 rot = rotation2(angle) * (1.05+6.*angle);
    uv = rot * uv;
    
    if (fract(rnd*10.0)<0.015) { // decorate tree
        if (length(uv-vec2(0.1, 0.80)) < 0.07) return vec4(0.9, 0.8, 0.04, 1.);
        if (length(uv-vec2(-0.1, 1.20)) < 0.07) return vec4(0.9, 0.8, 0.04, 1.);
        if (length(uv-vec2(0.1, 1.70)) < 0.07) return vec4(0.9, 0.8, 0.04, 1.);
        if (length(uv-vec2(-0.1, 2.00)) < 0.07) return vec4(0.9, 0.8, 0.04, 1.);
        if (length(uv-vec2(-0.2, 0.70)) < 0.07) return vec4(0.9, 0.1, 0.04, 1.);
        if (length(uv-vec2(0.2, 1.30)) < 0.07) return vec4(0.9, 0.1, 0.04, 1.);
        if (length(uv-vec2(0.05, 2.30)) < 0.07) return vec4(0.9, 0.1, 0.04, 1.);
        if (length(uv-vec2(-0.2, 1.50)) < 0.07) return vec4(0.9, 0.1, 0.04, 1.);
        if (length(uv-vec2(0.35, 0.45)) < 0.07) return vec4(0.9, 0.1, 0.04, 1.);
        if (sdStar5(uv-vec2(0., 2.75), 0.25, 0.45) < 0.) return vec4(0.9, 0.8, 0.04, 1.);
    }
    
    float d = 0.;
    if (d<0.0) return vec4(0.5, 0.25, 0.15, 1.0);
    d = min(d, sdTriangleIsosceles(vec2(uv.x, -uv.y+2.0), vec2(0.5, 1.5))-0.05 );
    d = min(d, sdTriangleIsosceles(vec2(uv.x, -uv.y+2.3), vec2(0.5, 1.5)*0.75)-0.05 );
    d = min(d, sdTriangleIsosceles(vec2(uv.x, -uv.y+2.6), vec2(0.5, 1.5)*0.5)-0.05 );
    
    //if (d<0.0) return vec4(0.9, 0.9, 0.9, 1.0);
    if (d<0.0) {
        float dShade = min(d, sdTriangleIsosceles(vec2(uv.x, -uv.y+1.85), vec2(0.5, 1.5)*1.0)-0.05 );
        vec4 col = vec4(0.1, 0.6, 0.3, 1.0);
        if (treePattern>1.0) {
            float colTransition = min(treePattern-1.0, 1.0);
            vec4 otherCol = mergeColor(col, vec4(treeColor.rgb, treeColor.a*colTransition));
            float intensity = max(0., treePattern-2.0) * 0.1;
            float shape = abs(mod((treePattern-1.0)*2., 2.)-1.)*2.-1.;
            vec2 u = tf(inverse(treeTransform), uv*4.);
            col = mix(col, otherCol, floor(mod(u.y + triangleToSquareWave(u.x, shape)*intensity, 2.0)));
        }
        return vec4(col.rgb * mix(0.8, 1.0, smoothstep(mix(-0.125, -0.25, min(1.0, treePattern)), 0.0, dShade)), col.a);
    }
    d = sdRectangle(uv-vec2(0., 0.0), vec2(0.1, 0.7));
    if (d<0.0) return mix(vec4(0.5, 0.25, 0.15, 1.0), vec4(0.25, 0.125, 0.075, 1.0), smoothstep(0.0, 0.5, uv.y));

    else return vec4(0.);
}

vec4 hills3(vec2 uv, float hillPattern, vec4 hillColor, mat3 hillTransform, float treePattern, vec4 treeColor, mat3 treeTransform) {
    float y = -uv.y;
    float h = perlinOctaveNoise(vec2(uv.x, 0.), 1)-0.5;
    float dx = 0.02;
    float h2 = perlinOctaveNoise(vec2(uv.x+dx, 0.), 1)-0.5;
    float dy = (h2-h)/dx;
    //float hh = h-0.04;
    float hh = min(h-0.04, h + dy*2.);
    if (y < h) {
        vec4 col = vec4(0.9, 0.9, 0.9, 1.0);
        if (hillPattern!=0.) {
            vec4 otherCol = mergeColor(col, hillColor);
            col = mix(col, otherCol, floor(mod(pow(abs(tf(hillTransform, vec2(uv.x, -uv.y)).y-h), hillPattern*2.)*20., 2.0)));
        }
        col.rgb *= mix(1.0, 0.9, smoothstep(h, hh, y));
        return col;
    }
    else {
        if (y-h>0.32) return vec4(0.); // optimization if we're above tree line, return immediately
        
        float X, x, hh, hh2;
        
        // rabbit & snowman
        X = (round(uv.x*5.00) -.0) / 5.;
        if (abs(uv.x-X)<0.06 && abs(y-h)<0.2) {
            //return vec4(1., 0., 0., 1.);
            float rnd = hash11(X);
            float rnd2 = fract(rnd*34.3+0.333);
            if (rnd2<0.025) {
                x = (uv.x-X)*5.;//round(uv.x*8.00) - 0.5;
                hh = perlinOctaveNoise(vec2(X, 0.), 1)-0.5;
                hh2 = perlinOctaveNoise(vec2(X+dx, 0.), 1)-0.5;
                float dy = (hh2-hh)/dx;
                if (abs(dy)<0.15) {
                    vec4 rabbitCol = rabbit(3.*vec2(x, (y-hh)*5.), X);
                    if (rabbitCol.a!=0.) return rabbitCol;
                }
            }
            if (rnd2>0.985) {
                x = (uv.x-X)*5.;//round(uv.x*8.00) - 0.5;
                hh = perlinOctaveNoise(vec2(X, 0.), 1)-0.5;
                vec4 snowmanCol = snowman(5.*vec2(x, (y-hh)*5.), X);
                if (snowmanCol.a!=0.) return snowmanCol;  
            }
        }

        X = (round(uv.x*8.00) -.0) / 8.;
        x = (uv.x-X)*8.;//round(uv.x*8.00) - 0.5;
        hh = perlinOctaveNoise(vec2(X, 0.), 1)-0.5;
        vec4 treeCol = tree4(2.*vec2(x, (y-hh)*8.), X, treePattern, treeColor, treeTransform);
        if (treeCol.a!=0.) return treeCol;

        // more trees
        float delta = 0.0625;
        X = (round((uv.x+delta)*8.00)) / 8.;
        x = ((uv.x+delta)-X)*8.;
        hh = perlinOctaveNoise(vec2(X-delta, 0.), 1)-0.5;
        treeCol = tree4(2.*vec2(x, (y-hh)*8.), X-delta, treePattern, treeColor, treeTransform)*vec4(vec3(0.9), 1.);
        if (treeCol.a!=0.) return treeCol;

        return vec4(0.);
    }
}

float multiSine(float x, int n, float kf, float power) {
    float y = 0.;
    float k = 1.;
    float f = 1.;
    float totalK = 0.;
    for(int i=0; i<n; ++i) {
        //y += sin(x*f+1.) * k;
        //y += 2.*abs(abs(sin(x*f+1.))-0.5) * k;
        y += k * (0.75-abs(sin(x*f+1.)-0.5)) / 0.75;
        totalK += k;
        k *= 0.35;
        f *= kf;
    }
    return pow(abs(y / totalK), power) * sign(y);
}

vec4 mountains4(vec2 uv, float kf, float mountainPattern, float mountainDetail, vec4 mountainColor, mat3 mountainTransform) {
    float y = -uv.y;
    if (y>1.0) return vec4(0.); // optim
    int N = 6;
    float msd = multiSine(uv.x, N, kf, 2.);
    float h = 0.75 * msd + 0.002*(perlinOctaveNoise(vec2(uv.x, 0.), 1)-0.5) + 0.2;
    float dx = 0.02;
    float msd2 = multiSine(uv.x+dx, N, kf, 2.);
    float dy = (msd2-msd)/dx;
    float snowloss;
    if (mountainDetail<=1.0) {
        snowloss = pow(0.5, h*10.) - mix(0., 0.1, mountainDetail) * (1. + mix(dy, abs(dy), 0.45));
    }
    else if (mountainDetail<=2.0) {
        snowloss = (pow(0.5, h*10.) - 0.1 - 0.1*mix(dy, abs(dy), 0.45)) + mix(0., 1., mountainDetail-1.0) * smoothstep(0.0, 0.5, y)*(perlinOctaveNoise(uv*15.0, 2)-0.5);
    }
    else if (mountainDetail<=3.0) {
        snowloss = (pow(0.5, h*10.) - mix(0.1, 0.0, mountainDetail-2.) * (1. + mix(dy, abs(dy), 0.45))) + mix(1., 0., mountainDetail-2.0) * smoothstep(0.0, 0.5, y)*(perlinOctaveNoise(uv*15.0, 2)-0.5);
    }
    //float snowloss = pow(0.5, h*10.) - 0.1 - 0.1*mix(dy, abs(dy), 0.45);
    //float snowloss = (pow(0.5, h*10.) - 0.1 - 0.1*mix(dy, abs(dy), 0.45)) + 0.5*smoothstep(0.0, 0.5, y)*(perlinOctaveNoise(uv*15.0, 2)-0.5);
    //float snowloss = -h*0.1*mix(dy, abs(dy), 0.45) + 1.5*abs(h*h)*(perlinOctaveNoise(uv*15.0, 3)-0.5);
    //float snowloss = -h*0.1*mix(dy, abs(dy), 0.45) + 0.65*(perlinOctaveNoise(uv*vec2(20.0, 10.), 2)-0.5);
    //float snowloss = pow(0.5, h*10.) - 0.1*mix(dy, abs(dy), 0.0);
    float h2 = h + snowloss;
    vec4 col;
    if (y > h) col = vec4(0.);
    else if (y<h2) col = vec4(0.9, 0.9, 0.9, 1.0);
    else col = vec4(0.5, 0.5, 0.5, 1.0);//vec4(0.1, 0.6, 0.3, 1.0);
    if (mountainPattern!=0.0 && y<=h) {
        float colTransition = min(mountainPattern, 1.0);
        vec4 otherCol = mergeColor(col, vec4(mountainColor.rgb, mountainColor.a*colTransition));
        float intensity = max(0., mountainPattern-2.0) * 0.1;
        float shape = abs(mod((mountainPattern-1.0)*2., 2.)-1.)*2.-1.;
        vec2 u = tf(inverse(mountainTransform), (uv+vec2(0., h * smoothstep(2., 1., mountainPattern)))*20.);
        col = mix(col, otherCol, floor(mod(u.y + triangleToSquareWave(u.x, shape)*intensity, 2.0)));
    }
    return col;
}

vec2 hash12(float x) {
    return vec2(
        fract(sin(x*776.4577)*45.77), 
        fract(sin(x*376.4517+1.2524)*88.77) );
}

float sdUnevenCapsule( vec2 p, float r1, float r2, float h ) {
    p.x = abs(p.x);
    float b = (r1-r2)/h;
    float a = sqrt(1.0-b*b);
    float k = dot(p,vec2(-b,a));
    if (k < 0.0) return length(p) - r1;
    if (k > a*h) return length(p-vec2(0.0,h)) - r2;
    return dot(p, vec2(a,b) ) - r1;
}

vec4 shootingStarLayer(vec2 uv, float time) {
    float k = 0.;
    float N = 5.0;
    for(float i=0.; i<N; ++i) {
        vec2 rnd = hash12(i);
        float radius = (1. + fract(rnd.x*10.0)) * 350.;
        float strength = 0.2 + fract(rnd.x*23.32);
        vec2 point = (rnd-0.5)*40. + vec2(0., 0.);
        vec2 dir = normalize(point);
        vec2 center = point - dir*radius;
        //if (length(uv)<1.0) return vec4(0., 1., 1., 0.5);
        //if (length(center-uv)<0.8) return vec4(1., 1., 0., 0.5);
        //if (length(point-uv)<0.8) return vec4(1., 0., 0., 0.5);
        //if (abs(length(uv-center)-radius)<0.1) return vec4(1., 1., 1., 0.15);
        float startAngle = fract(rnd.y*10.)*6.28;
        float angle = startAngle + time*1.;
        vec2 pos = center + radius * vec2(cos(angle), sin(angle));
        dir = normalize(pos-center);
        vec2 trailUv = mat2(1., 0., 0., -1.) * inverse(mat2(dir, vec2(-dir.y, dir.x))) * (uv-pos);
        
        k += 0.05/pow(length(trailUv), 2.) * strength;
        float trailD = sdUnevenCapsule(trailUv, 0.5, 0.005, 15.0);
        /*if (trailD<0.) k += 1.; else*/ 
        k += 1./pow(trailD+1.5, 3.) * strength;
    }
    return vec4(1., 1., 1., k);
}

vec4 starLayer(vec2 uv) {
    float N = 1.0;
    vec2 id = round(uv);
    //vec4 col = vec4(0.);
    float total = 0.;
    for(float x = -N; x<=N; ++x) {
        for(float y = -N; y<=N; ++y) {
            vec2 starId = vec2(id.x+x, id.y+y);
            vec2 rnd = hash22b(starId);
            vec2 starCenter = starId + (rnd-.5)*2.;
            float r = pow(fract((rnd.x + rnd.y)*10.), 15.) * 0.15+0.00001;
            //col = mergeColor(col, smoothstep(r*1.5, r*0.5, length(uv-starCenter)) *vec4(1.));
            total += smoothstep(r*1.5, r*0.5, length(uv-starCenter));
        }
    }
    return vec4(1., 1., 1., total); //col;
}

vec4 skyWithMoon(vec2 uv, float time) {
    float y = clamp(uv.y*0.5+0.5, 0., 1.0);

    //float phaseOffset = (fract(time*1.1/*0.015*/) - 0.5) * (RADIUS * 4.6);

    mat3 lighting = getLighting(time);
    vec3 lightAtSun = lighting[0];
    vec3 lightAtTop = lighting[1];
    vec2 sunPos = lighting[2].xy;
    float phaseOffset = lighting[2].z;
    vec2 moonPos = -sunPos;

    float dMoon = length(uv-moonPos) - RADIUS;
    float dShadow = length(uv-(moonPos+vec2(phaseOffset, 0.0)))-RADIUS;
    float dd = max(dMoon, -dShadow);
    if (dd<0.) return vec4(1.);
    float kMoonPower = 1.0-min(1.0, abs(phaseOffset)/(2.*RADIUS));
    vec4 moonGlowCol = vec4(0.5, 0.7, 1., 1.) * (1.0-0.8*kMoonPower);

    float dSun = length(uv-sunPos) - RADIUS;
    if (dSun<0.) return vec4(1.);
    vec4 sunGlowCol = vec4(1.0, 1.0, 0.8, 1.);

    float dy = uv.y-sunPos.y;
//if (abs(dy)<0.01) return vec4(1.0);// else return vec4(vec3(-dy), 1.);
    //vec4 baseSky = vec4(mix(lightAtSun, lightAtTop, -(uv.y-sunPos.y)*0.25), 1.0); //vec4(y*0.1, y*0.4, y, 1.0);
    vec4 baseSky = vec4(mix(lightAtSun, lightAtTop, -dy), 1.0);
    //vec4 baseSky = vec4(mix(vec3(0., 1., 0.), vec3(0.), -dy), 1.0);
//return baseSky;
    //if (dMoon<0.) return baseSky + moonGlowCol;//mix(baseSky, moonGlowCol, 1.0);
    if (dMoon<0.) return mix(vec4(1.), baseSky + moonGlowCol, clamp(-dShadow/0.005, 0., 1.));//mix(baseSky, moonGlowCol, 1.0);
    //if (length(uv-moonPos)<0.) return vec4(1.);
    float moonPower = mix(2.0, 12.0, kMoonPower);
    float sunPower = mix(13., 3., smoothstep(-MAXHEIGHT*0.7, -MAXHEIGHT, sunPos.y));

    vec2 starUv = (rotation2(time*0.5)*(uv-vec2(0., -0.75))+vec2(0., -0.75))*50.;
    float kNight = smoothstep(-MAXHEIGHT*0.35, MAXHEIGHT*0.3, sunPos.y);
    baseSky = mergeColor(baseSky, starLayer(starUv) * vec4(vec3(1.), kNight));
    baseSky = mergeColor(baseSky, shootingStarLayer(starUv, time) * kNight);

    vec4 withMoon = baseSky + mix(baseSky, moonGlowCol, 1./pow((dMoon+1.)*1.00, moonPower)) * smoothstep(-MAXHEIGHT*0.2, -MAXHEIGHT*0.5, moonPos.y);
    vec4 withSun = mix(withMoon, sunGlowCol, 1./pow((dSun+1.)*1.00, sunPower));
    return withSun;

    //else return mix(baseSky, vec4(0.8, 0.9, 1., 1.), 1./pow((d+1.)*1.00, 2.));
}

vec4 winterWonderland(vec2 uv, vec2 outPos, float time, mat3 modelTransform,
    vec4 treeColor, float treePattern, mat3 treeTransform,
    vec4 mountainColor, float mountainPattern, float mountainDetail, mat3 mountainTransform,
    vec4 hillColor, float hillPattern, mat3 hillTransform) {
    
    mat3 inverseModelTransform = inverse(modelTransform);
    vec2 delta = 2.5 * tf(inverseModelTransform, vec2(0., 0.));
    float scaling = length(inverseModelTransform[0].xy);
    vec4 col = vec4(0.);
    float t = time * PI / 5.;
    mat3 lighting = getLighting(t);
    //if (col.a==0.0) col = getColorAtLayer2(hills3(uv*0.125*scaling + vec2(11., -0.3)+ delta*1., hillPattern, hillColor, hillTransform, treePattern, treeColor, treeTransform), 1.0, lighting);
    
    if (col.a==0.0) col = getColorAtLayer2(hills3(uv*0.5*scaling + vec2(11., -0.2)+ delta*1., hillPattern, hillColor, hillTransform, treePattern, treeColor, treeTransform), 1.0, lighting);

    if (col.a==0.0) col = getColorAtLayer2(hills3(uv*scaling + delta*.75, hillPattern, hillColor, hillTransform, treePattern, treeColor, treeTransform), 3., lighting);

    if (col.a==0.0) col = getColorAtLayer2(hills3(uv*1.5*scaling + vec2(11., 0.2)+ delta* 0.5, hillPattern, hillColor, hillTransform, treePattern, treeColor, treeTransform), 5.0, lighting);

    if (col.a==0.0) col = getColorAtLayer2(mountains4(uv*scaling + delta* 0.1, 2.823, mountainPattern, mountainDetail, mountainColor, mountainTransform), 7.0, lighting);

    if (col.a==0.0) col = getColorAtLayer2(mountains4(uv*1.5*scaling + vec2(11., 0.2) + delta* 0.075, 2.4754, mountainPattern, mountainDetail, mountainColor, mountainTransform), 10.0, lighting);

    if (col.a==0.0) col = skyWithMoon(uv, t);
    
    return col;
}

void main() {
    fragColor = winterWonderland((inverse(u_viewTransform) * vec3(((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), 1.0)).xy, ((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), u_time, u_modelTransform, u_treeColor, u_treePattern, u_treeTransform, u_mountainColor, u_mountainPattern, u_mountainDetail, u_mountainTransform, u_hillColor, u_hillPattern, u_hillTransform);
}
