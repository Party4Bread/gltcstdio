#version 450
layout(location = 0) in vec2 v_uv;
layout(location = 0) out vec4 fragColor;

layout(binding = 0, std140) uniform Params {
    vec4 U[18];
};
layout(binding = 1) uniform sampler samp;
layout(binding = 2) uniform texture2D t_source;

#define u_source sampler2D(t_source, samp)
#define u_worldAspect (U[0].x)
#define u_viewTransform (mat3(U[1].xyz, U[2].xyz, U[3].xyz))
#define u_outDim (U[4].xy)
#define u_mode (U[5].x)
#define u_intensity (U[6].x)
#define u_balance (U[7].x)
#define u_coverage (U[8].x)
#define u_brightness (U[9].x)
#define u_contrast (U[10].x)
#define u_colorScheme (U[11].x)
#define u_randomSeed (U[12].x)
#define u_variability (U[13].x)
#define u_shapeAspectRatio (U[14].x)
#define u_modelTransform (mat3(U[15].xyz, U[16].xyz, U[17].xyz))

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











































































































































































































































































































































































































float bc(float x, float brightness, float contrast) {
    float y = x * (brightness+1.0);
    y = (y-0.5)*contrast + 0.5;
    return clamp(y, 0.0, 1.0);
}

float ccontrast(float x, float c) {
    return clamp(0.5 + (x-0.5)*(1.0+c), 0.0, 1.0);
}

vec3 colorSchemeF(vec3 rgb, float k) {
    float grey = (rgb.r+rgb.g+rgb.b)/3.0;
    if (k<0.2) return mix(vec3(rgb.g), vec3(grey), k*5.0);
    if (k<0.4) return mix(vec3(grey), rgb, (k-0.2)*5.0);
    return rgb;
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

float perlin(vec2 p) {
    vec2 s = vec2(1.0, 0.0);
    vec2 f = floor(p);
    vec2 d = p-f;
    //return dotGridGradient(f, p);
    float ix0 = smix(dotGridGradient(f, p), dotGridGradient(f+s, p), d.x);
    float ix1 = smix(dotGridGradient(f+s.yx, p), dotGridGradient(f+s.xx, p), d.x);
    return 0.5+smix(ix0, ix1, d.y)*0.5;
}

float perlin4(vec2 p) {
    return (perlin(p)+0.5*perlin(p*2.0)+0.25*perlin(p*4.0)+0.125*perlin(p*8.0))*0.6;
}

vec2 aRatio(float a) {
	return vec2(a, 1.0)/(1.0+a)*2.0;
}

float hash1(vec2 p, float randomSeed) {
//    vec2 a = fract((u_Seed-145.3277)*p.xy);
//    vec2 b = a + dot(a, a+123.3371);
//	return fract(b.x*b.y);
    vec2 a = fract((randomSeed-145.3277)*p.xy);
    vec2 b = a + dot(a, a+vec2(-4.434, 43.3371));
	return fract(b.x*b.y);
}

float noise1(vec2 p, float randomSeed) {
    vec2 s = vec2(1.0, 0.0);
    vec2 f = floor(p);
    vec2 d = p-f;
    float h00 = hash1(f, randomSeed);
    float h10 = hash1(f+s, randomSeed);
    float h01 = hash1(f+s.yx, randomSeed);
    float h11 = hash1(f+s.xx, randomSeed);

	return mix(mix(h00, h10, smoothstep(0.0, 1.0, d.x)), mix(h01, h11, smoothstep(0.0, 1.0, d.x)), smoothstep(0.0, 1.0, d.y));
}

float hashBanding(vec2 p, float randomSeed) {
    p += 5000.0;
    float k = 10.11+randomSeed;
    vec2 a = fract(k*p)*k;
    a = fract(k*a)*k;
    vec2 b = a + 0.0*dot(a, a);
	return abs(sin(p.x*b.x*0.001)*sin(p.y*b.y*0.001));
}

float noiseBanding(vec2 p, float randomSeed) {
    vec2 s = vec2(1.0, 0.0);
    vec2 f = floor(p);
    vec2 d = p-f;
    float h00 = hashBanding(f, randomSeed);
    float h10 = hashBanding(f+s, randomSeed);
    float h01 = hashBanding(f+s.yx, randomSeed);
    float h11 = hashBanding(f+s.xx, randomSeed);

	return mix(mix(h00, h10, smoothstep(0.0, 1.0, d.x)), mix(h01, h11, smoothstep(0.0, 1.0, d.x)), smoothstep(0.0, 1.0, d.y));
}

float hashMoireCurve(vec2 p, float randomSeed) {
    vec2 a = (10.11+20.0*sin(randomSeed*vec2(0.1, 0.166)))*(p+5000.0+randomSeed);
    vec2 b = a*0.001 + dot(a*0.001, a*0.001);
	return clamp(0.5+sin(p.x*b.x*0.001)*sin(p.y*b.y*0.001), 0.0, 1.0);
}

float noiseMoireCurve(vec2 p, float randomSeed) {
    vec2 s = vec2(1.0, 0.0);
    vec2 f = floor(p);
    vec2 d = p-f;
    float h00 = hashMoireCurve(f, randomSeed);
    float h10 = hashMoireCurve(f+s, randomSeed);
    float h01 = hashMoireCurve(f+s.yx, randomSeed);
    float h11 = hashMoireCurve(f+s.xx, randomSeed);

	return mix(mix(h00, h10, smoothstep(0.0, 1.0, d.x)), mix(h01, h11, smoothstep(0.0, 1.0, d.x)), smoothstep(0.0, 1.0, d.y));
}

float hashRep(vec2 p, float randomSeed) {
    vec2 a = fract(vec2(15.3*(p.x+randomSeed), 60.15*(p.y-randomSeed+333.3)+10.1));
    vec2 b = a + 1.0*dot(a.yx, a+100.0+randomSeed);
	return fract(b.x*b.y);
}

float noiseRep(vec2 p, float randomSeed) {
    vec2 s = vec2(1.0, 0.0);
    vec2 f = floor(p);
    vec2 d = p-f;
    float h00 = hashRep(f, randomSeed);
    float h10 = hashRep(f+s, randomSeed);
    float h01 = hashRep(f+s.yx, randomSeed);
    float h11 = hashRep(f+s.xx, randomSeed);

	return mix(mix(h00, h10, smoothstep(0.0, 1.0, d.x)), mix(h01, h11, smoothstep(0.0, 1.0, d.x)), smoothstep(0.0, 1.0, d.y));
}

float staticNoiseF(vec2 u, float k, float shapeAspectRatio, float randomSeed) {
    float baseScale = 500.0;
    vec2 ar = aRatio(shapeAspectRatio);
    if (k<0.25)  return mix(noise1(u*baseScale*ar, randomSeed), noiseMoireCurve(u*baseScale*ar, randomSeed), k*4.0);
    if (k<0.5)   return mix(noiseMoireCurve(u*baseScale*ar, randomSeed), noiseRep(u*baseScale*ar, randomSeed), (k-0.25)*4.0);
    if (k<0.75)  return mix(noiseRep(u*baseScale*ar, randomSeed), noiseBanding(u*baseScale*ar, randomSeed), (k-0.5)*4.0);
    else		 return mix(noiseBanding(u*baseScale*ar, randomSeed), noise1(u*baseScale*ar, randomSeed), (k-0.75)*4.0);
}

vec2 tf(mat3 m, vec2 u) {
    return (m * vec3(u, 1.)).xy;
}

vec4 staticNoise(vec2 pos, vec2 outPos, float mode, float intensity, float balance, float coverage, float brightness, float contrast, float colorScheme, float randomSeed, float variability, float shapeAspectRatio, mat3 modelTransform) {
    mat3 invModelTransform = inverse(modelTransform);
    vec2 u = tf(invModelTransform, pos);
    float scale = length(invModelTransform[0].xy);
    mode *= 0.1;
    
    vec4 inCol = __source__(pos);
    float alpha = clamp(coverage + ccontrast(perlin4(u*0.1*vec2(variability*10.0, 100.0)), -5.0), 0.0, 1.0);
    alpha = smoothstep(0.15, 1.0, pow(alpha, 2.0)) * intensity;

    float delta = (colorScheme<0.4 ? 1.0 : colorScheme-0.39)*10.0;
    vec3 rnd = vec3(staticNoiseF(pos, mode, shapeAspectRatio, randomSeed), staticNoiseF(pos+delta, mode, shapeAspectRatio, randomSeed), staticNoiseF(pos-delta, mode, shapeAspectRatio, randomSeed));
    vec3 rgb = vec3(bc(rnd.r, brightness, contrast), bc(rnd.g, brightness, contrast), bc(rnd.b, brightness, contrast));

    vec2 d = (rnd.xy-0.5)*0.5;
    balance = (balance+1.0)/2.0;
    vec4 baseCol = __source__(pos + alpha*d*min(1.0, 2.0*(1.0-balance)));
    vec4 outCol = mix(baseCol, vec4(colorSchemeF(rgb, colorScheme), 1.0), alpha * min(1.0, 2.0*balance));

    return outCol;      
}

void main() {
    fragColor = staticNoise((inverse(u_viewTransform) * vec3(((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), 1.0)).xy, ((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), u_mode, u_intensity, u_balance, u_coverage, u_brightness, u_contrast, u_colorScheme, u_randomSeed, u_variability, u_shapeAspectRatio, u_modelTransform);
}
