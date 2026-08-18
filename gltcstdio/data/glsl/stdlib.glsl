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
vec2 aRatio(float a);
vec4 adjustColor(vec4 col, float brightness, float contrast, float luminosity, float gamma, float saturation, float hue, vec4 tint);
vec4 adjustColorHSLuv(vec4 col, float brightness, float contrast, float luminosity, float gamma, float saturation, float hue, vec4 tint);
vec4 adjustColorHSLuvSafe(vec4 col, float brightness, float contrast, float luminosity, float gamma, float saturation, float hue, vec4 tint);
vec4 adjustGamma(vec4 col, float gamma);
vec4 blend(int mode, vec4 a, vec4 b);
float brightness(vec3 c);
CairoTile cairoTile(vec2 uv, float k);
float colorDistance(vec3 a, vec3 b);
vec2 complexExp(vec2 u);
vec2 complexLog(vec2 u);
vec2 complexMul(vec2 u, vec2 v);
vec2 complex_div(vec2 a, vec2 b);
vec2 complex_exp(vec2 a);
vec2 complex_from_polar(float r, float arg);
vec2 complex_inverse(vec2 a);
vec2 complex_log(vec2 a);
vec2 complex_mul(vec2 a, vec2 b);
vec2 complex_pow(vec2 w, vec2 z);
vec2 complex_sqrt(vec2 a);
vec2 complex_to_polar(vec2 a);
vec3 crissCross(vec2 u, float thicknessX, float thicknessY, bool horOver, float top, float right, float bottom, float left);
vec3 cubeIntersection(vec3 center, float radius, vec3 origin, vec3 dir);
vec2 cylinderIntersectionK(float radius, vec3 origin, vec3 dir);
vec2 dimFromShapeAspectRatio(float m, float ar);
float dot2(vec2 u);
float dotGridGradient(vec2 g, vec2 u);
float dotGridGradient3(vec3 g, vec3 u);
float fractalValueNoise(vec2 v, int count, float intensity);
vec2 fractalValueNoiseDisplace(vec2 u, vec2 v, int count, float intensity);
float gaussian(float x);
float getChannel(vec4 color, int channel);
float getChannelWithHsl(vec4 color, vec4 hsl, int channel);
mat3 getCoverFitTransform(float aspectRatio, vec2 imageDims);
vec2 getLineIntersection(vec2 sa, vec2 sb, vec2 ta, vec2 tb);
vec2 getSegmentIntersection(vec2 sa, vec2 sb, vec2 ta, vec2 tb);
vec4 getShapeOverlapColor(vec3 inside, int mode, float thickness, vec4 color1, vec4 color2, vec4 colorBorder);
Tile getVoronoiTile(vec2 u, float intensity);
float hash11(float x);
vec2 hash12(float x);
vec3 hash13(float x);
float hash21(vec2 p);
vec2 hash22(vec2 u);
vec2 hash22b(vec2 u);
vec3 hash23(vec2 u);
float hash31(vec3 u);
vec2 hash32(vec3 u);
vec3 hash33(vec3 u);
vec4 hexCoords(vec2 v);
float hexDist(vec2 p);
vec4 hexPolarBorderCoords(vec2 v);
vec4 hexPolarCoords(vec2 v);
HexTile hexTile(vec2 v);
vec3 hpluvToLch(vec3 tuple);
vec4 hpluvToLch4(vec4 c);
vec3 hpluvToRgb(vec3 tuple);
vec4 hpluvToRgb4(vec4 c);
vec3 hsl2rgb(vec3 c);
vec4 hslToRgb(vec4 inc);
vec3 hsluvToLch(vec3 tuple);
vec4 hsluvToLch4(vec4 c);
vec3 hsluvToRgb(vec3 tuple);
vec4 hsluvToRgb4(vec4 c);
vec4 hsluvToRgb4Safe(vec4 c);
vec3 hsluvToRgbSafe(vec3 t);
vec3 hsluv_distanceFromPole(vec3 pointx,vec3 pointy);
vec3 hsluv_fromLinear(vec3 c);
float hsluv_fromLinear1(float c);
vec3 hsluv_intersectLineLine(vec3 line1x, vec3 line1y, vec3 line2x, vec3 line2y);
float hsluv_lToY(float L);
vec3 hsluv_lengthOfRayUntilIntersect(float theta, vec3 x, vec3 y);
float hsluv_maxChromaForLH(float L, float H);
float hsluv_maxSafeChromaForL(float L);
vec3 hsluv_toLinear(vec3 c);
float hsluv_toLinear1(float c);
float hsluv_yToL(float Y);
float hueToRgb(float p, float q, float h);
bool inTriangle(in vec2 p, in vec2 a, in vec2 b, in vec2 c);
vec2 interpolatedRand2(vec2 v);
float interpolatedRand21(vec2 v);
vec3 lchToHpluv(vec3 tuple);
vec4 lchToHpluv4(vec4 c);
vec3 lchToHsluv(vec3 tuple);
vec4 lchToHsluv4(vec4 c);
vec3 lchToLuv(vec3 tuple);
vec4 lchToLuv4(vec4 c);
vec3 lchToRgb(vec3 tuple);
vec4 lchToRgb4(vec4 c);
float luma(vec3 c);
vec3 luvToLch(vec3 tuple);
vec4 luvToLch4(vec4 c);
vec3 luvToRgb(vec3 tuple);
vec4 luvToRgb4(vec4 c);
vec3 luvToXyz(vec3 tuple);
vec4 luvToXyz4(vec4 c);
float max2(vec2 u);
float max3(vec3 u);
float max3n(float a, float b, float c);
float max4n(float a, float b, float c, float d);
float measure(vec2 v, float power);
vec4 mergeColor(vec4 bkg, vec4 front);
vec4 mergeColorOpacifying(vec4 bkg, vec4 front);
vec4 mergeGlow(vec4 bkg, vec4 glow);
float min3n(float a, float b, float c);
float min4n(float a, float b, float c, float d);
float mir(float x, float a);
vec2 mirrorPoint(vec2 p, vec2 axisPoint, vec2 axisNormal);
vec4 mixColors(vec4 a, vec4 b, float k);
int ndfCharForSlot(int slot, int nint, bool neg, int decimals, float ipart, float av);
float ndfCurved(int ch, vec2 p);
float ndfDigital(int ch, vec2 p);
float ndfSdBezier(vec2 pos, vec2 A, vec2 B, vec2 C);
int ndfSevenSeg(int ch);
float opSdIntersection(float d1, float d2);
float opSdSubtraction(float d1, float d2);
float opSdUnion(float d1, float d2);
float perlinNoise(vec2 p);
float perlinNoise3(vec3 p);
float perlinOctaveNoise(vec2 uv, int n);
float perlinRelNoise3(vec3 p);
vec3 planeIntersection(vec3 planePoint, vec3 normal, vec3 origin, vec3 dir);
float planeIntersectionK(vec3 planePoint, vec3 normal, vec3 origin, vec3 dir);
vec2 polar(float r, float angle);
vec2 projEquirectangular(vec3 dir);
float rand(float x);
vec3 rand13relSeeded(float co, float seed);
vec2 rand2(vec2 v);
float rand21(vec2 v);
vec3 rand23relSeeded(vec2 co, float seed);
vec2 rand2rel(vec2 co);
vec2 rand2relSeeded(vec2 co, float seed);
vec4 rgbToHcv(in vec4 RGB);
vec3 rgbToHpluv(vec3 tuple);
vec4 rgbToHpluv4(vec4 c);
vec4 rgbToHsl(in vec4 RGB);
vec4 rgbToHsl0(vec4 inc);
vec4 rgbToHsl1(in vec4 c);
vec4 rgbToHslFromFloats(float r, float g, float b, float a);
vec3 rgbToHsluv(vec3 tuple);
vec4 rgbToHsluv4(vec4 c);
vec4 rgbToHsluv4Safe(vec4 c);
vec3 rgbToHsluvSafe(vec3 c);
vec3 rgbToLch(vec3 tuple);
vec4 rgbToLch4(vec4 c);
vec3 rgbToXyz(vec3 tuple);
vec4 rgbToXyz4(vec4 c);
vec2 rndUnit(vec2 p);
vec3 rndUnit3(vec3 p);
mat2 rotation2(float angle);
mat3 rotation3(float angle);
mat3 scaling3(float s);
float sdBox(vec3 p, vec3 b);
float sdCylinder(vec3 p, float r, float h);
float sdDisk(vec2 u, float r);
float sdEquiTriangle(vec2 u);
float sdHeart(vec2 u);
float sdNgon(vec2 p, float r, int n);
float sdOctahedron(vec3 p, float s);
float sdPyramid(vec3 p, float h);
float sdRectangle(vec2 u, vec2 halfSize);
float sdSegment(vec2 u, vec2 a, vec2 b);
float sdSegment3(vec3 u, vec3 a, vec3 b);
float sdStar(vec2 u, int spikeCount, float r, float m);
float sdStar5(in vec2 p, in float r, in float rf);
float sdTorus(vec3 p, float R, float rb);
float sdTriangleIsosceles(in vec2 p, in vec2 q);
float sdUnevenCapsule(vec2 p, float r1, float r2, float h);
float sdVesica(vec2 u, float r, float d);
bool segmentIntersects(vec2 sa, vec2 sb, vec2 ta, vec2 tb);
vec4 shiftHueWithSaturation(vec4 color, float hue, float saturation);
float simpleVignette(float vignette, vec2 uv, mat3 vignetteTransform);
vec2 sineMix(vec2 val1, vec2 val2, float k);
vec2 sineSurfaceRand2Seeded(vec2 v, float seed);
float smix(float a, float b, float k);
vec2 smoothmix2(vec2 a, vec2 b, float k);
vec2 solve2ndDegreePolynomial(float a, float b, float c);
vec3 sphereFirstIntersection(vec3 center, float radius, vec3 origin, vec3 dir);
vec3 sphereIntersection(vec3 center, float radius, vec3 origin, vec3 dir);
vec2 sphereIntersectionK(vec3 center, float radius, vec3 origin, vec3 dir);
vec3 sphereIntersectionWithNormedDir(vec3 center, float radius, vec3 origin, vec3 dir);
vec3 sphereLastIntersection(vec3 center, float radius, vec3 origin, vec3 dir);
vec4 spilloverChannels(vec4 c);
float star(vec2 uv, float pixel, float center, float flare1, float flare2);
float starFlare(vec2 uv, float pixel);
float stepWiseSCurve(float x, float k);
vec4 swapRGBHSL(vec4 rgb, float mode);
vec2 tf(mat3 m, vec2 u);
vec4 tintColor(vec4 col, vec4 tint);
mat3 translation3(vec2 t);
TriangleTile triangleTile(vec2 v);
float triangleToSquareWave(float x, float k);
float triangleWave(float x);
float varyNoiseSmoothly(float noise, float k);
vec2 varyVec2NoiseSmoothly(vec2 noise, float k);
vec3 varyVec3NoiseSmoothly(vec3 noise, float k);
float voronoiOctaveNoise(vec2 u, int n);
vec2 withShapeAspectRatio(vec2 u, float ar);
vec3 xyzToLuv(vec3 tuple);
vec4 xyzToLuv4(vec4 c);
vec3 xyzToRgb(vec3 tuple);
vec4 xyzToRgb4(vec4 c);

// ---- bodies ----
vec4 rgbToHslFromFloats(float r, float g, float b, float a) {
    //	Minimum and Maximum RGB values are used in the HSL calculations
    float mini = min(r, min(g, b));
    float maxi = max(r, max(g, b));

    //  Calculate the Hue
    float h = 0.0; // 98

    if (maxi == mini)
        h = 0.0;
    else if (maxi == r)
        h = mod(((60.0 * (g - b) / (maxi - mini)) + 360.0), 360.0);
    else if (maxi == g)
        h = (60.0 * (b - r) / (maxi - mini)) + 120.0;
    else if (maxi == b)
        h = (60.0 * (r - g) / (maxi - mini)) + 240.0;

    //  Calculate the Luminiance
    float l = (maxi + mini) / 2.0;

    //  Calculate the Saturation
    float s = 0.0;

    if (maxi == mini)
        s = 0.0;
    else if (l <= 0.5)
        s = (maxi - mini) / (maxi + mini);
    else
        s = (maxi - mini) / (2.0 - maxi - mini);

    vec4 hsl;
    hsl.r = h;
    hsl.g = s;
    hsl.b = l;
    hsl.a = a;
    return hsl;
}

vec4 rgbToHsl0(vec4 inc) {
    //  Get RGB values in the range 0 - 1
    float r = inc.r;
	float g = inc.g;
	float b = inc.b;

    //	Minimum and Maximum RGB values are used in the HSL calculations
    float mini = min(r, min(g, b));
    float maxi = max(r, max(g, b));

    //  Calculate the Hue
    float h = 0.0;

    if (maxi == mini)
        h = 0.0;
    else if (maxi == r)
        h = mod(((60.0 * (g - b) / (maxi - mini)) + 360.0), 360.0);
    else if (maxi == g)
        h = (60.0 * (b - r) / (maxi - mini)) + 120.0;
    else if (maxi == b)
        h = (60.0 * (r - g) / (maxi - mini)) + 240.0;
    
    //  Calculate the Luminance
    float l = (maxi + mini) / 2.0;

    //  Calculate the Saturation
    float s = 0.0;

    if (maxi == mini)
        s = 0.0;
    else if (l <= 0.5)
        s = (maxi - mini) / (maxi + mini);
    else
        s = (maxi - mini) / (2.0 - maxi - mini);

    vec4 hsl;
    hsl.r = h;
    hsl.g = s;
    hsl.b = l;
    hsl.a = inc.a;
    return hsl;
}

vec4 rgbToHsl1(in vec4 c){
    float h = 0.0;
	float s = 0.0;
	float l = 0.0;
	float r = c.r;
	float g = c.g;
	float b = c.b;
	float cMin = min( r, min( g, b ) );
	float cMax = max( r, max( g, b ) );

	l = ( cMax + cMin ) / 2.0;
	if ( cMax > cMin ) {
		float cDelta = cMax - cMin;
        
		s = l < .0 ? cDelta / ( cMax + cMin ) : cDelta / ( 2.0 - ( cMax + cMin ) );
        
		if ( r == cMax ) {
			h = ( g - b ) / cDelta;
		} else if ( g == cMax ) {
			h = 2.0 + ( b - r ) / cDelta;
		} else {
			h = 4.0 + ( r - g ) / cDelta;
		}

		if ( h < 0.0) {
			h += 6.0;
		}
		h = h / 6.0;
	}
	return vec4(h, s, l, c.a);
}

vec4 rgbToHcv(in vec4 RGB) {
    vec4 P = (RGB.g < RGB.b) ? vec4(RGB.bg, -1.0, 2.0/3.0) : vec4(RGB.gb, 0.0, -1.0/3.0);
    vec4 Q = (RGB.r < P.x) ? vec4(P.xyw, RGB.r) : vec4(RGB.r, P.yzx);
    float C = Q.x - min(Q.w, Q.y);
    float H = abs((Q.w - Q.y) / (6. * C + 1e-10) + Q.z);
    return vec4(H, C, Q.x, RGB.a);
}

vec4 rgbToHsl(in vec4 RGB) {
    vec4 HCV = rgbToHcv(RGB);
    float L = HCV.z - HCV.y * 0.5;
    float S = HCV.y / (1. - abs(L * 2. - 1.) + 1e-6);  // careful with the 1e-6 - used to be 1e-10 which caused errors because of low precision and we god NaNs. A test would be more clean but potentially slower.
    return vec4(HCV.x*360., S, L, RGB.a);
}

float hueToRgb(float p, float q, float h) {
    if (h < 0.0) h += 1.0;

    if (h > 1.0 ) h -= 1.0;

    if (6.0 * h < 1.0) {
        return p + ((q - p) * 6.0 * h);
    }

    if (2.0 * h < 1.0 ) {
        return  q;
    }

    if (3.0 * h < 2.0) {
        return p + ( (q - p) * 6.0 * ((2.0 / 3.0) - h) );
    }

    return p;
}

vec4 hslToRgb(vec4 inc) {
    //  Formula needs all values between 0 - 1.
    float h = mod(inc.r, 360.0);
    h /= 360.0;
    float s = inc.g;
    float l = inc.b;

    float q = 0.0;

    if (l < 0.5)
        q = l * (1.0 + s);
    else
        q = (l + s) - (s * l);

    float p = 2.0 * l - q;

    float r = max(0.0, hueToRgb(p, q, h + (1.0 / 3.0)));
    float g = max(0.0, hueToRgb(p, q, h));
    float b = max(0.0, hueToRgb(p, q, h - (1.0 / 3.0)));

    vec4 outc;
    outc.r = min(r, 1.0);
    outc.g = min(g, 1.0);
    outc.b = min(b, 1.0);
    outc.a = inc.a;

    return outc;
}        

vec3 hsl2rgb(vec3 c) {
    float t = c.y * ((c.z < 0.5) ? c.z : (1.0 - c.z));
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return (c.z + t) * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), 2.0*t / c.z);
}
vec3 hsluv_intersectLineLine(vec3 line1x, vec3 line1y, vec3 line2x, vec3 line2y) {
    return (line1y - line2y) / (line2x - line1x);
}

vec3 hsluv_distanceFromPole(vec3 pointx,vec3 pointy) {
    return sqrt(pointx*pointx + pointy*pointy);
}

vec3 hsluv_lengthOfRayUntilIntersect(float theta, vec3 x, vec3 y) {
    vec3 len = y / (sin(theta) - x * cos(theta));
    if (len.r < 0.0) {len.r=1000.0;}
    if (len.g < 0.0) {len.g=1000.0;}
    if (len.b < 0.0) {len.b=1000.0;}
    return len;
}

float hsluv_maxSafeChromaForL(float L){
    mat3 m2 = mat3(
         3.2409699419045214  ,-0.96924363628087983 , 0.055630079696993609,
        -1.5373831775700935  , 1.8759675015077207  ,-0.20397695888897657 ,
        -0.49861076029300328 , 0.041555057407175613, 1.0569715142428786  
    );
    float sub0 = L + 16.0;
    float sub1 = sub0 * sub0 * sub0 * .000000641;
    float sub2 = sub1 > 0.0088564516790356308 ? sub1 : L / 903.2962962962963;

    vec3 top1   = (284517.0 * m2[0] - 94839.0  * m2[2]) * sub2;
    vec3 bottom = (632260.0 * m2[2] - 126452.0 * m2[1]) * sub2;
    vec3 top2   = (838422.0 * m2[2] + 769860.0 * m2[1] + 731718.0 * m2[0]) * L * sub2;

    vec3 bounds0x = top1 / bottom;
    vec3 bounds0y = top2 / bottom;

    vec3 bounds1x =              top1 / (bottom+126452.0);
    vec3 bounds1y = (top2-769860.0*L) / (bottom+126452.0);

    vec3 xs0 = hsluv_intersectLineLine(bounds0x, bounds0y, -1.0/bounds0x, vec3(0.0) );
    vec3 xs1 = hsluv_intersectLineLine(bounds1x, bounds1y, -1.0/bounds1x, vec3(0.0) );

    vec3 lengths0 = hsluv_distanceFromPole( xs0, bounds0y + xs0 * bounds0x );
    vec3 lengths1 = hsluv_distanceFromPole( xs1, bounds1y + xs1 * bounds1x );

    return  min(lengths0.r,
            min(lengths1.r,
            min(lengths0.g,
            min(lengths1.g,
            min(lengths0.b,
                lengths1.b)))));
}

float hsluv_maxChromaForLH(float L, float H) {

    float hrad = radians(H);

    mat3 m2 = mat3(
         3.2409699419045214  ,-0.96924363628087983 , 0.055630079696993609,
        -1.5373831775700935  , 1.8759675015077207  ,-0.20397695888897657 ,
        -0.49861076029300328 , 0.041555057407175613, 1.0569715142428786  
    );
    float sub1 = pow(L + 16.0, 3.0) / 1560896.0;
    float sub2 = sub1 > 0.0088564516790356308 ? sub1 : L / 903.2962962962963;

    vec3 top1   = (284517.0 * m2[0] - 94839.0  * m2[2]) * sub2;
    vec3 bottom = (632260.0 * m2[2] - 126452.0 * m2[1]) * sub2;
    vec3 top2   = (838422.0 * m2[2] + 769860.0 * m2[1] + 731718.0 * m2[0]) * L * sub2;

    vec3 bound0x = top1 / bottom;
    vec3 bound0y = top2 / bottom;

    vec3 bound1x =              top1 / (bottom+126452.0);
    vec3 bound1y = (top2-769860.0*L) / (bottom+126452.0);

    vec3 lengths0 = hsluv_lengthOfRayUntilIntersect(hrad, bound0x, bound0y );
    vec3 lengths1 = hsluv_lengthOfRayUntilIntersect(hrad, bound1x, bound1y );

    return  min(lengths0.r,
            min(lengths1.r,
            min(lengths0.g,
            min(lengths1.g,
            min(lengths0.b,
                lengths1.b)))));
}

float hsluv_fromLinear1(float c) {
    return c <= 0.0031308 ? 12.92 * c : 1.055 * pow(c, 1.0 / 2.4) - 0.055;
}
vec3 hsluv_fromLinear(vec3 c) {
    return vec3( hsluv_fromLinear1(c.r), hsluv_fromLinear1(c.g), hsluv_fromLinear1(c.b) );
}

float hsluv_toLinear1(float c) {
    return c > 0.04045 ? pow((c + 0.055) / (1.0 + 0.055), 2.4) : c / 12.92;
}

vec3 hsluv_toLinear(vec3 c) {
    return vec3( hsluv_toLinear1(c.r), hsluv_toLinear1(c.g), hsluv_toLinear1(c.b) );
}

float hsluv_yToL(float Y){
    return Y <= 0.0088564516790356308 ? Y * 903.2962962962963 : 116.0 * pow(Y, 1.0 / 3.0) - 16.0;
}

float hsluv_lToY(float L) {
    return L <= 8.0 ? L / 903.2962962962963 : pow((L + 16.0) / 116.0, 3.0);
}

vec3 xyzToRgb(vec3 tuple) {
    const mat3 m = mat3( 
        3.2409699419045214  ,-1.5373831775700935 ,-0.49861076029300328 ,
       -0.96924363628087983 , 1.8759675015077207 , 0.041555057407175613,
        0.055630079696993609,-0.20397695888897657, 1.0569715142428786  );
    
    return hsluv_fromLinear(tuple*m);
}

vec3 rgbToXyz(vec3 tuple) {
    const mat3 m = mat3(
        0.41239079926595948 , 0.35758433938387796, 0.18048078840183429 ,
        0.21263900587151036 , 0.71516867876775593, 0.072192315360733715,
        0.019330818715591851, 0.11919477979462599, 0.95053215224966058 
    );
    return hsluv_toLinear(tuple) * m;
}

vec3 xyzToLuv(vec3 tuple){
    float X = tuple.x;
    float Y = tuple.y;
    float Z = tuple.z;

    float L = hsluv_yToL(Y);
    
    float div = 1./dot(tuple,vec3(1,15,3)); 

    return vec3(
        1.,
        (52. * (X*div) - 2.57179),
        (117.* (Y*div) - 6.08816)
    ) * L;
}


vec3 luvToXyz(vec3 tuple) {
    float L = tuple.x;

    float U = tuple.y / (13.0 * L) + 0.19783000664283681;
    float V = tuple.z / (13.0 * L) + 0.468319994938791;

    float Y = hsluv_lToY(L);
    float X = 2.25 * U * Y / V;
    float Z = (3./V - 5.)*Y - (X/3.);

    return vec3(X, Y, Z);
}

vec3 luvToLch(vec3 tuple) {
    float L = tuple.x;
    float U = tuple.y;
    float V = tuple.z;

    float C = length(tuple.yz);
    float H = degrees(atan(V,U));
    if (H < 0.0) {
        H = 360.0 + H;
    }
    
    return vec3(L, C, H);
}

vec3 lchToLuv(vec3 tuple) {
    float hrad = radians(tuple.b);
    return vec3(
        tuple.r,
        cos(hrad) * tuple.g,
        sin(hrad) * tuple.g
    );
}

vec3 hsluvToLch(vec3 tuple) {
    tuple.g *= hsluv_maxChromaForLH(tuple.b, tuple.r) * .01;
    return tuple.bgr;
}

vec3 lchToHsluv(vec3 tuple) {
    tuple.g /= hsluv_maxChromaForLH(tuple.r, tuple.b) * .01;
    return tuple.bgr;
}

vec3 hpluvToLch(vec3 tuple) {
    tuple.g *= hsluv_maxSafeChromaForL(tuple.b) * .01;
    return tuple.bgr;
}

vec3 lchToHpluv(vec3 tuple) {
    tuple.g /= hsluv_maxSafeChromaForL(tuple.r) * .01;
    return tuple.bgr;
}

vec3 lchToRgb(vec3 tuple) {
    return xyzToRgb(luvToXyz(lchToLuv(tuple)));
}

vec3 rgbToLch(vec3 tuple) {
    return luvToLch(xyzToLuv(rgbToXyz(tuple)));
}

vec3 hsluvToRgb(vec3 tuple) {
    return lchToRgb(hsluvToLch(tuple));
}

vec3 rgbToHsluv(vec3 tuple) {
    return lchToHsluv(rgbToLch(tuple));
}

vec3 hpluvToRgb(vec3 tuple) {
    return lchToRgb(hpluvToLch(tuple));
}

vec3 rgbToHpluv(vec3 tuple) {
    return lchToHpluv(rgbToLch(tuple));
}

vec3 luvToRgb(vec3 tuple){
    return xyzToRgb(luvToXyz(tuple));
}

// allow vec4's
vec4   xyzToRgb4(vec4 c) {return vec4(   xyzToRgb( vec3(c.x,c.y,c.z) ), c.a);}
vec4   rgbToXyz4(vec4 c) {return vec4(   rgbToXyz( vec3(c.x,c.y,c.z) ), c.a);}
vec4   xyzToLuv4(vec4 c) {return vec4(   xyzToLuv( vec3(c.x,c.y,c.z) ), c.a);}
vec4   luvToXyz4(vec4 c) {return vec4(   luvToXyz( vec3(c.x,c.y,c.z) ), c.a);}
vec4   luvToLch4(vec4 c) {return vec4(   luvToLch( vec3(c.x,c.y,c.z) ), c.a);}
vec4   lchToLuv4(vec4 c) {return vec4(   lchToLuv( vec3(c.x,c.y,c.z) ), c.a);}
vec4 hsluvToLch4(vec4 c) {return vec4( hsluvToLch( vec3(c.x,c.y,c.z) ), c.a);}
vec4 lchToHsluv4(vec4 c) {return vec4( lchToHsluv( vec3(c.x,c.y,c.z) ), c.a);}
vec4 hpluvToLch4(vec4 c) {return vec4( hpluvToLch( vec3(c.x,c.y,c.z) ), c.a);}
vec4 lchToHpluv4(vec4 c) {return vec4( lchToHpluv( vec3(c.x,c.y,c.z) ), c.a);}
vec4   lchToRgb4(vec4 c) {return vec4(   lchToRgb( vec3(c.x,c.y,c.z) ), c.a);}
vec4   rgbToLch4(vec4 c) {return vec4(   rgbToLch( vec3(c.x,c.y,c.z) ), c.a);}
vec4 hsluvToRgb4(vec4 c) {return vec4( hsluvToRgb( vec3(c.x,c.y,c.z) ), c.a);}
vec4 rgbToHsluv4(vec4 c) {return vec4( rgbToHsluv( vec3(c.x,c.y,c.z) ), c.a);}
vec4 hpluvToRgb4(vec4 c) {return vec4( hpluvToRgb( vec3(c.x,c.y,c.z) ), c.a);}
vec4 rgbToHpluv4(vec4 c) {return vec4( rgbToHpluv( vec3(c.x,c.y,c.z) ), c.a);}
vec4   luvToRgb4(vec4 c) {return vec4(   luvToRgb( vec3(c.x,c.y,c.z) ), c.a);}
vec3 rgbToHsluvSafe(vec3 c) { vec4 hsl = rgbToHsl(vec4(c, 1.0)); return vec3(hsl.x, hsl.y * 100.0, hsl.z * 100.0); }
vec3 hsluvToRgbSafe(vec3 t) { return hslToRgb(vec4(t.x, t.y * 0.01, t.z * 0.01, 1.0)).rgb; }
vec4 rgbToHsluv4Safe(vec4 c) { return vec4(rgbToHsluvSafe(c.rgb), c.a); }
vec4 hsluvToRgb4Safe(vec4 c) { return vec4(hsluvToRgbSafe(c.rgb), c.a); }
float mir(float x, float a) {
    return a * (1. - abs(mod(x, 2.*a)/a - 1.));
}
float max2(vec2 u) { 
    return max(u.x, u.y);
}
float max3(vec3 u) { 
    return max(u.x, max(u.y, u.z));
}
float min3n(float a, float b, float c) { 
    return min(a, min(b, c));
}
float min4n(float a, float b, float c, float d) { 
    return min(min(a, d), min(b, c));
}
float max3n(float a, float b, float c) { 
    return max(a, max(b, c));
}
float max4n(float a, float b, float c, float d) { 
    return max(max(a, d), max(b, c));
}
float dot2(vec2 u) {
    return dot(u, u);
}
vec2 hash12(float x) {
    return vec2(
        fract(sin(x*776.4577)*45.77), 
        fract(sin(x*376.4517+1.2524)*88.77) );
}
vec3 hash13(float x) {
//    return vec3(
//        fract(sin(x*776.4577)*45.771), 
//        fract(cos(x*442.8831)*65.111), 
//        fract(sin(x*376.4517+1.2524)*88.771) );
    return fract(vec3(
        sin(x*776.4577)*45.771, 
        cos(x*442.8831)*65.111, 
        sin(x*376.4517+1.2524)*88.771) );
}
float hash11(float x) {
    return fract(sin(x*45.34+123.131)*94.434);
}
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
vec2 hash22b(vec2 u) {
    return vec2(
        fract(sin(dot(u.xy, vec2(13.7545,78.224)))* 43758.5453123), 
        fract(sin(dot(u.xy, vec2(15.7545,73.224)))* 43758.5453123) );
}
float hash31(vec3 u) {
    return fract(sin(u.x*776.45+u.y*453.24+u.z*553.25)*45.77);
}
vec2 hash32(vec3 u) {
    return vec2(
        fract(sin(u.x*776.45+u.y*453.24+u.z*553.25)*45.77), 
        fract(sin(u.x*376.45+u.y*853.24+u.z*153.84)*88.77) );
}
vec3 hash23(vec2 u) {
    return vec3(
        fract(sin(u.x*776.45+u.y*453.24)*45.77), 
        fract(sin(u.x*376.45+u.y*853.24)*88.77),
        fract(sin(u.x*457.77+u.y*667.17)*65.57) );
}
vec3 hash33(vec3 u) {
    return vec3(
        fract(sin(u.x*776.45+u.y*453.24+u.z*553.25)*45.77), 
        fract(sin(u.x*376.45+u.y*853.24+u.z*153.84)*88.77),
        fract(sin(u.x*457.77+u.y*667.17+u.z*355.94)*65.57) );
}
float rand(float x) {
    return fract(sin(x * 43758.5453));
}
float rand21(vec2 v) {
    return fract(sin(dot(v.xy ,vec2(12.9898,78.233))) * 43758.5453);
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
vec3 varyVec3NoiseSmoothly(vec3 noise, float k) {
    return vec3(varyNoiseSmoothly(noise.x, k), varyNoiseSmoothly(noise.y, k), varyNoiseSmoothly(noise.z, k));
}
float interpolatedRand21(vec2 v) {
    float fractY = fract(v.y);
    return mix(
        mix(rand21(floor(v)), rand21(vec2(floor(v.x), ceil(v.y))), fractY),
        mix(rand21(vec2(ceil(v.x), floor(v.y))), rand21(ceil(v)), fractY),
        fract(v.x) );
}
vec2 interpolatedRand2(vec2 v) {
    float fractY = fract(v.y);
    return mix(
        mix(rand2(floor(v)), rand2(vec2(floor(v.x), ceil(v.y))), fractY),
        mix(rand2(vec2(ceil(v.x), floor(v.y))), rand2(ceil(v)), fractY),
        fract(v.x) );
}
vec2 rand2rel(vec2 co) {
    float x = fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
    float y = fract(sin(dot(vec2(x, co.x) ,vec2(12.9898,78.233))) * 43758.5453);
    return vec2(x, y)-vec2(0.5, 0.5);
}
vec2 rand2relSeeded(vec2 co, float seed) {
    return varyVec2NoiseSmoothly(rand2(co), seed)-0.5;
}
vec3 rand23relSeeded(vec2 co, float seed) {
    return varyVec3NoiseSmoothly(hash23(co), seed)-0.5;
}
vec3 rand13relSeeded(float co, float seed) {
    return varyVec3NoiseSmoothly(hash13(co), seed)-0.5;
}
vec2 sineMix(vec2 val1, vec2 val2, float k) {
    return val1*(1.0+cos(k*PI))*0.5 + val2*(1.0+cos((1.0-k)*PI))*0.5;
}
vec2 sineSurfaceRand2Seeded(vec2 v, float seed) {
    vec2 u00 = floor(v);
    vec2 u01 = vec2(floor(v.x), ceil(v.y));
    vec2 u10 = vec2(ceil(v.x), floor(v.y));
    vec2 u11 = ceil(v);

    vec2 r00 = varyVec2NoiseSmoothly(rand2(u00), seed)-vec2(0.5, 0.5);
    vec2 r01 = varyVec2NoiseSmoothly(rand2(u01), seed)-vec2(0.5, 0.5);
    vec2 r10 = varyVec2NoiseSmoothly(rand2(u10), seed)-vec2(0.5, 0.5);
    vec2 r11 = varyVec2NoiseSmoothly(rand2(u11), seed)-vec2(0.5, 0.5);

    return sineMix(
            sineMix(r00, r01, fract(v.y)),
            sineMix(r10, r11, fract(v.y)),
            fract(v.x));
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
vec2 aRatio(float a) {
	return vec2(a, 1.0)/(1.0+a)*2.0;
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
float voronoiOctaveNoise(vec2 u, int n) {
    float noise = 0.0;
    float amplitude = 0.6;

    for(int k=0; k<n; ++k) {
        vec2 v = floor(vec2(u.x+0.5, u.y+0.5));
        float closest = 1e9;
        for(int j=-2; j<=2; ++j) {
            for(int i=-2; i<=2; ++i) {
                vec2 point = vec2(v.x+float(i), v.y+float(j));
                vec2 displace = (rand2(point) - vec2(0.5, 0.5))* 2.0;
                float distance = length(point+displace - u);
                if (distance < closest) {
                    closest = distance;
                }
            }
        }
        noise += amplitude * closest;
        amplitude *= 0.5;
        u = u*2.0 + vec2(1.34, 2.55);
    }

    return noise;
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
float perlinNoise3(vec3 p) {
    return 0.5+perlinRelNoise3(p)*0.5;
}
float fractalValueNoise(vec2 v, int count, float intensity) {
    float s = 1.0;
    float k = intensity;
    float total;
    float totalMul = 0.;

    for(int i = 0; i<count; ++i) {
        total += k * interpolatedRand21(v*s);
        totalMul += k;
        k *= 0.5;
        s *= 2.1055472;
    }

    return total / totalMul;
}
vec2 fractalValueNoiseDisplace(vec2 u, vec2 v, int count, float intensity) {
    float s = 1.0;
    float maxDisplacement = intensity; 

    vec2 totalDisp = vec2(0.);

    for(int i = 0; i<count; ++i) {
        vec2 disp = interpolatedRand2(v*s);
        totalDisp += maxDisplacement * (disp - vec2(0.5, 0.5))*2.0;

        maxDisplacement *= 0.5;
        s *= 2.1055472;
    }

    return u + totalDisp;
}
vec2 solve2ndDegreePolynomial(float a, float b, float c) {
    float delta = b*b - 4.0*a*c;
    if (delta>=0.0) {
        float sqrtDelta = sqrt(delta);
        float l1 = (-b - sqrtDelta) / (2.0*a);
        float l2 = (-b + sqrtDelta) / (2.0*a);
        return vec2(min(l1, l2), max(l1, l2));
    }
    return vec2(INF, INF);
}
vec2 smoothmix2(vec2 a, vec2 b, float k) {
    return vec2(mix(a.x, b.x, smoothstep(0.0, 1.0, k)), mix(a.y, b.y, smoothstep(0.0, 1.0, k)));
}
vec2 complexMul(vec2 u, vec2 v) {
    return vec2(u.x*v.x-u.y*v.y, dot(u, v.yx));  
}
vec2 complexExp(vec2 u) {
    return exp(u.x) * vec2(cos(u.y), sin(u.y));
}
vec2 complexLog(vec2 u) {
    return vec2(log(length(u)), atan(u.y, u.x));
}
float measure(vec2 v, float power) {
    float low = min(abs(v.x), abs(v.y));
    float high = max(abs(v.x), abs(v.y));
    return high==0.0 ? 0.0 : high * pow(1.0 + pow(low/high, power), 1.0/power);
}
vec2 tf(mat3 m, vec2 u) {
    return (m * vec3(u, 1.)).xy;
}
mat3 getCoverFitTransform(float aspectRatio, vec2 imageDims) {
    float srcAr = imageDims.x / imageDims.y;
    float h = min(1.0, srcAr / aspectRatio);
    return mat3(h, 0.0, 0.0, 0.0, h, 0.0, 0.0, 0.0, 1.0);
}
vec2 withShapeAspectRatio(vec2 u, float ar) {
    return vec2(u.x*ar, u.y) * 2.0/(1. + ar);
}
vec2 dimFromShapeAspectRatio(float m, float ar) {
    return ar>1. ? vec2(m, m/ar) : vec2(m*ar, m);
}
mat2 rotation2(float angle) {
    float ca = cos(angle);
    float sa = sin(angle);
    return mat2(ca, sa, -sa, ca);
}
mat3 rotation3(float angle) {
    float ca = cos(angle);
    float sa = sin(angle);
    return mat3(ca, sa, 0., -sa, ca, 0., 0., 0., 1.);
}
mat3 scaling3(float s) {
    return mat3(s, 0., 0., 0., s, 0., 0., 0., 1.);
}
mat3 translation3(vec2 t) {
    return mat3(1., 0., 0., 0., 1., 0., t.x, t.y, 1.);
}
float gaussian(float x) {
    return (x>0.5) ? (1.0-x)*(1.0-x)*2.0 : 1.0 - x*x*2.0;
}
vec2 mirrorPoint(vec2 p, vec2 axisPoint, vec2 axisNormal) {
    float d = dot(p-axisPoint, axisNormal);
    return d<=0.0 ? p : p - 2.0*d*axisNormal;
}
float triangleWave(float x) {
    x = mod(x, 4.);
    float s = 1.0;
    if (x>2.0) { x = x - 2.0; s = -1.; }
    return s * (1. - abs(x-1.));
}
float triangleToSquareWave(float x, float k) {
    x = mod(x, 4.);
    float s = 1.0;
    if (x>2.0) { x = x - 2.0; s = -1.; }
    float m = k>0.0 ? 1.0 : pow(mix(5., 40., -k), -k);
    return m * s * (1. - pow(abs(x-1.), pow(100.0, k)));
}
float stepWiseSCurve(float x, float k) {
    float y = mod(x+1., 2.) - 1.0;
    return floor(x*0.5+0.5)*2.0 + sign(y) * pow(abs(y), pow(10.0, k));
}
vec2 polar(float r, float angle) {
    return r * vec2(cos(angle), sin(angle));
}
float hexDist(vec2 p) {
    p = abs(p);
    return max(p.x, dot(p, normalize(vec2(1.0, SQRT3))));
}
TriangleTile triangleTile(vec2 v) {
vec2 r = vec2(1.0, SQRT3_2);
    float offset = floor(v.y / SQRT3_2)*0.5;
    vec2 a = mod(v + vec2(offset, 0.), r);
    bool up = SQRT3_2 - abs(0.5-a.x)*SQRT3 > a.y;
    vec2 hv = up ? vec2(a.x-0.5, a.y-SQRT3_6) : vec2(a.x<0.5 ? a.x : a.x-1., a.y-SQRT3/3.);
    vec2 center = v-hv;
    float borderDist = up ? min(min(SQRT3_6-dot(vec2(-SQRT3_2, 0.5), hv), SQRT3_6-dot(vec2(SQRT3_2, 0.5), hv)), SQRT3_6+hv.y) 
        : min(min(SQRT3_6-dot(vec2(-SQRT3_2, -0.5), hv), SQRT3_6-dot(vec2(SQRT3_2, -0.5), hv)), SQRT3_6-hv.y);
    float angle = atan(hv.y, hv.x);
    float dist = length(hv);
    return TriangleTile(up, center, hv, angle, dist, borderDist);
}
HexTile hexTile(vec2 v) {
    vec2 r = vec2(1.0, SQRT3);
    vec2 h = r/2.0;
    vec2 a = vec2(mod(v.x, r.x), mod(v.y, r.y))-h;
    vec2 b = vec2(mod(v.x-h.x, r.x), mod(v.y-h.y, r.y))-h;
    vec2 hv = length(a)<length(b) ? a : b;
    float angle = atan(hv.y, hv.x);
    float dist = length(hv);
    float borderDist = 0.5-hexDist(hv);
    vec2 center = v-hv;
    return HexTile(center, hv, angle, dist, borderDist);
}
CairoTile cairoTile(vec2 uv, float k) {
    vec2 id = floor(uv);
    float alt = mod(id.x + id.y, 2.0);
    uv = fract(uv) - .5;
    vec2 p = abs(uv);
    if (alt==1.) p = p.yx;
    float ang = (k*0.5 + 0.5) * PI;
    vec2 n = vec2(sin(ang), cos(ang));
    float d = dot(p-.5, n);
    
    if (d*(alt-.5) < 0.0)
        id.x += sign(uv.x) * .5;
    else 
        id.y += sign(uv.y) * .5;
    
    d = min(d, p.x);
    d = max(d, -p.y);
    d = abs(d);
    d = min(d, dot(p-.5, vec2(n.y, -n.x)));
    
    return CairoTile(id+.5, d);
}
vec4 hexPolarBorderCoords(vec2 v) {
    vec2 r = vec2(1.0, SQRT3);
    vec2 h = r/2.0;
    vec2 a = vec2(mod(v.x, r.x), mod(v.y, r.y))-h;
    vec2 b = vec2(mod(v.x-h.x, r.x), mod(v.y-h.y, r.y))-h;
    vec2 hv = length(a)<length(b) ? a : b;
    float x = atan(hv.y, hv.x);
    float y = 0.5-hexDist(hv);
    vec2 id = v-hv;
    return vec4(x, y, id);
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
vec4 hexCoords(vec2 v) {
    vec2 r = vec2(1.0, SQRT3);
    vec2 h = r/2.0;
    vec2 a = vec2(mod(v.x, r.x), mod(v.y, r.y))-h;
    vec2 b = vec2(mod(v.x-h.x, r.x), mod(v.y-h.y, r.y))-h;
    vec2 hv = length(a)<length(b) ? a : b;
    vec2 id = v-hv;
    return vec4(hv, id);
}
float brightness(vec3 c) {
    return (c.r + c.g + c.b)/3.0;
}
float luma(vec3 c) {
    return (0.2989*c.r + 0.587*c.g + 0.114*c.b);
}
float colorDistance(vec3 a, vec3 b) {
    return length(a-b);
}
vec4 mixColors(vec4 a, vec4 b, float k) {
    float ka = mix(a.a, b.a, k);
    return ka==0.0 
        ? mix(a, b, k)
        : vec4(mix(a.rgb*a.a, b.rgb*b.a, k)/ka, mix(a.a, b.a, k));
}
vec4 mergeColor(vec4 bkg, vec4 front) {
    return vec4(mix(bkg.rgb, front.rgb, front.a + (1.0-bkg.a)*(1.0-front.a)), max(bkg.a, front.a));
}
vec4 mergeColorOpacifying(vec4 bkg, vec4 front) {
    float a = (1.0-bkg.a)*(1.0-front.a);
    return vec4(mix(bkg.rgb, front.rgb, front.a + a), 1.0-a);
}
vec4 tintColor(vec4 col, vec4 tint) {
    vec3 colHsl = rgbToHsl(col).rgb;
    vec3 tintHsl = rgbToHsl(tint).rgb;
    float gamma = pow(5., 0.5-tintHsl.z);
    vec4 target = hslToRgb(vec4(tintHsl.xy, pow(colHsl.z, gamma), col.a));        
    return mix(col, target, tint.a);
}
vec4 mergeGlow(vec4 bkg, vec4 glow) {
    return vec4(bkg.rgb + glow.rgb*glow.a, bkg.a);
}
vec4 blend(int mode, vec4 a, vec4 b) {
    vec3 aa = a.rgb;
    vec3 bb = b.rgb;
    vec3 cc;
    switch (mode) {
        case 1: cc = aa + bb; break;
        case 2: cc = aa * bb; break;
        case 3: cc = aa - bb; break;
        case 4: cc = abs(aa - bb); break;
        case 5: cc = aa / bb; break;
        case 10: return max(a, b); //cc = max(aa, bb); break;
        case 11: return min(a, b); //cc = min(aa, bb); break;
        default: return b; //cc = bb;
    }
    return vec4(cc, mix(a.a, b.a, 0.5));
}
vec4 spilloverChannels(vec4 c) {
    float overflow = (max(c.r-1.0, 0.0) + max(c.g-1.0, 0.0) + max(c.b-1.0, 0.0)) / 3.0;
    c.r += overflow;
    c.g += overflow;
    c.b += overflow;
    return c;
}
float getChannel(vec4 color, int channel) {
    if (channel==0) return color.r;
    else if (channel==1) return color.g;
    else if (channel==2) return color.b;
    else if (channel==3) return rgbToHsl(color).x / 360.0;
    else if (channel==4) return rgbToHsl(color).y;
    else if (channel==5) return rgbToHsl(color).z;
    else if (channel==6) return rgbToHsluv(color.rgb).x / 360.0;
    else if (channel==7) return rgbToHsluv(color.rgb).y * 0.01;
    else if (channel==8) return rgbToHsluv(color.rgb).z * 0.01;
    else return 0.0;
}
float getChannelWithHsl(vec4 color, vec4 hsl, int channel) {
    if (channel==0) return color.r;
    else if (channel==1) return color.g;
    else if (channel==2) return color.b;
    else if (channel==3) return rgbToHsl(color).x / 360.0;
    else if (channel==4) return rgbToHsl(color).y;
    else if (channel==5) return rgbToHsl(color).z;
    else return 0.0;
}
vec4 swapRGBHSL(vec4 rgb, float mode) {
    float coding = floor(mode*0.01*2.0*6.0*6.0*6.0-1.0);
    bool toHsl = coding > 215.0;
    if (toHsl) coding = mod(coding, 216.0);

    vec4 hsl = rgbToHsl(rgb);
    hsl.r /= 360.0;
    int rChannel = int(mod(coding, 6.0));
    int gChannel = int(mod(coding/6.0, 6.0));
    int bChannel = int(mod(coding/36.0, 6.0));
    vec4 color = vec4(
        getChannelWithHsl(rgb, hsl, rChannel) * (toHsl ? 360.0 : 1.0),
        getChannelWithHsl(rgb, hsl, gChannel),
        getChannelWithHsl(rgb, hsl, bChannel),
//        getChannel(0, rgb, hsl) * (toHsl ? 360.0 : 1.0),
//        getChannel(1, rgb, hsl),
//        getChannel(2, rgb, hsl),
        rgb.a );

    return toHsl ? hslToRgb(color) : color;
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
vec4 adjustColor(vec4 col, float brightness, float contrast, float luminosity, float gamma, float saturation, float hue, vec4 tint) {
    if (luminosity != 0.) {
        col.rgb += luminosity;
    }
    
    if (brightness != 0.) {
        col.rgb *= (1. + brightness);
    }
    
    if (gamma != 0.) {
        float p = pow(2., -gamma);
        col.r = pow(col.r, p);
        col.g = pow(col.g, p);
        col.b = pow(col.b, p);
    }
    
    if (contrast != 0.) {
        float c = abs(contrast)>1.0 ? sign(contrast) * pow(abs(contrast), 2.0) : contrast;
        col.rgb = (col.rgb - 0.5) * c + 0.5;
    }
    
    bool requireHsl = saturation!=0.0 || hue!=0.0;
    if (requireHsl) {
        vec4 hsl = rgbToHsl(col);
        //hsl[1] = clamp(hsl[1]+saturation, 0.0, 1.0);
        hsl[1] = clamp(hsl[1] * (1.0+saturation), 0.0, 1.0);
        hsl[0] += hue;
        col = hslToRgb(hsl);
    }
    
    if (tint.a!=0.0) {
        col = tintColor(col, tint);
    }
    
    return col;
}
vec4 adjustColorHSLuv(vec4 col, float brightness, float contrast, float luminosity, float gamma, float saturation, float hue, vec4 tint) {
        if (luminosity != 0.) {
            col.rgb += luminosity;
        }
        
        if (brightness != 0.) {
            col.rgb *= (1. + brightness);
        }
        
        if (gamma != 0.) {
            float p = pow(2., -gamma);
            col.r = pow(col.r, p);
            col.g = pow(col.g, p);
            col.b = pow(col.b, p);
        }
        
        if (contrast != 0.) {
            float c = abs(contrast)>1.0 ? sign(contrast) * pow(abs(contrast), 2.0) : contrast;
            col.rgb = (col.rgb - 0.5) * c + 0.5;
        }
        bool white = col.r == 1.0 && col.g == 1.0 && col.b == 1.0; // HSLuv conversion methods don't seem to play well when the color is white
        bool requireHsl = (saturation!=0.0 || hue!=0.0) && !white; 
        if (requireHsl) {
            vec3 hsl = rgbToHsluv(col.rgb);
//            hsl[1] = clamp(hsl[1]+saturation*100.0, 0., 100.);
            hsl[1] = clamp(hsl[1] * (1.0+saturation), 0., 100.);
            hsl[0] += hue;
            col.rgb = hsluvToRgb(hsl);
        }

        if (tint.a!=0.0) {
            col = tintColor(col, tint);
        }

        return col;
    }
vec4 adjustColorHSLuvSafe(vec4 col, float brightness, float contrast, float luminosity, float gamma, float saturation, float hue, vec4 tint) {
    if (luminosity != 0.) col.rgb += luminosity;
    if (brightness != 0.) col.rgb *= (1. + brightness);
    if (gamma != 0.) { float p = pow(2., -gamma); col.r = pow(col.r, p); col.g = pow(col.g, p); col.b = pow(col.b, p); }
    if (contrast != 0.) { float cc = abs(contrast) > 1.0 ? sign(contrast) * pow(abs(contrast), 2.0) : contrast; col.rgb = (col.rgb - 0.5) * cc + 0.5; }
    if (saturation != 0.0 || hue != 0.0) {
        vec3 hsl = rgbToHsluvSafe(col.rgb);
        hsl[1] = clamp(hsl[1] * (1.0 + saturation), 0., 100.);
        hsl[0] += hue;
        col.rgb = hsluvToRgbSafe(hsl);
    }
    if (tint.a != 0.0) col = tintColor(col, tint);
    return col;
}
vec4 adjustGamma(vec4 col, float gamma) {
    if (gamma != 0.) {
        float p = pow(2., -gamma);
        col.r = pow(col.r, p);
        col.g = pow(col.g, p);
        col.b = pow(col.b, p);
    }
    
    return col;
}
vec4 shiftHueWithSaturation(vec4 color, float hue, float saturation) {
    vec4 hsl = rgbToHsl(color);
    hsl.x += hue;
    hsl.y = 1.0*saturation + hsl.y*(1.0-saturation);
    return hslToRgb(hsl);
}
vec2 complex_mul(vec2 a, vec2 b) {
    return vec2(a.x*b.x-a.y*b.y, a.x*b.y+a.y*b.x);
}
vec2 complex_sqrt(vec2 a) {
    vec2 p = complex_to_polar(a);
    float ang = a.y * .5;
    return sqrt(a.x) * vec2(cos(ang), sin(ang));
}
vec2 complex_inverse(vec2 a) {
    float r = a.x*a.x + a.y*a.y;
    return vec2(a.x/r, -a.y/r);
}
vec2 complex_div(vec2 a, vec2 b) {
    return complex_mul(a, complex_inverse(b));
}
vec2 complex_to_polar(vec2 a) {
    float r = sqrt(a.x*a.x + a.y*a.y);
    float arg = atan(a.y, a.x); //may require something else
    return vec2(r, arg);
}
vec2 complex_from_polar(float r, float arg) {
    return vec2(r*cos(arg), r*sin(arg));
}
vec2 complex_log(vec2 a) {
    vec2 polar = complex_to_polar(a);
    float r = log(polar.x);
    return vec2(r, polar.y);
}
vec2 complex_exp(vec2 a) {
    float r = exp(a.x);
    return vec2(r*cos(a.y), r*sin(a.y));
}
vec2 complex_pow(vec2 w, vec2 z) {
    vec2 wp = complex_to_polar(w);
    float r = wp.x;
    float theta = wp.y;
    float c = z.x;
    float d = z.y;
    float R = pow(r, c) * exp(-d*theta);
    float A = d*log(r)+c*theta;
    return R * vec2(cos(A), sin(A));
}
Tile getVoronoiTile(vec2 u, float intensity) {
    vec2 b = floor(u+0.5);
    float N = floor(2.0+0.5*abs(intensity));
    float minD = 1e10;
    float minB = 1e10;
    vec2 minId;
    vec2 minC;
    vec2 normal = vec2(0.0, 1.0);
    vec2 secId;
    float secD;
    float thirdD;
    for(float j=-N; j<=N; ++j) {
        for(float i=-N; i<=N; ++i) {
            vec2 id = b + vec2(i, j);
            vec2 c = id + intensity * (hash22(id)-0.5);
            float d = length(u-c);
            if (minD>=d) {
                secId = minId;
                thirdD = secD;
                secD = minD;
                minId = id;
                minD = d;
                minC = c;
            }
            else if (secD>=d) {
                secId = id;
                thirdD = secD;
                secD = d;
            }
            else if (thirdD>=d) {
                thirdD = d;
            }
        }    
    }
    for(float j=-N; j<=N; ++j) {
        for(float i=-N; i<=N; ++i) {
            vec2 id = b + vec2(i, j);
            if (id!=minId) {
                vec2 c = id + intensity * (hash22(id)-0.5);
                vec2 v = normalize(c-minC);
                float borderDist = length(minC-c)/2.0 - dot(u-minC, v);
                minB = min(borderDist, minB);
                if (minB==borderDist) normal = vec2(-v.x, v.y); 
            }
        }    
    }

    return Tile(minD, minId, minB, minC, normal, secD, secId, thirdD);
}
bool inTriangle( in vec2 p, in vec2 a, in vec2 b, in vec2 c )
{
    vec2 e0 = b-a, e1 = c-b, e2 = a-c;
    vec2 v0 = p -a, v1 = p -b, v2 = p -c;
    float s = sign(e0.x*e2.y - e0.y*e2.x);
    return s*(v0.x*e0.y-v0.y*e0.x)>0.0 
        && s*(v1.x*e1.y-v1.y*e1.x)>0.0 
        && s*(v2.x*e2.y-v2.y*e2.x)>0.0; 
}
float sdSegment(vec2 u, vec2 a, vec2 b) {
    vec2 ua = u-a;
    vec2 ba = b-a;
    float h = clamp(dot(ua, ba)/dot(ba, ba), 0., 1.);
    return length(ua - ba*h);
}
float sdDisk(vec2 u, float r) {
    return length(u)-r;
}
float sdRectangle(vec2 u, vec2 halfSize) {
    u = abs(u)-halfSize;
    return (u.x>=0. && u.y>=0.) ? length(u) : max(u.x, u.y);
}
float sdEquiTriangle(vec2 u) {
    u.x = abs(u.x) - 1.;
    u.y = u.y + 1./SQRT3;
    if (u.x+SQRT3*u.y>0.) u = vec2(u.x-SQRT3*u.y, -SQRT3*u.x-u.y)/2.;
    u.x -= clamp(u.x, -2., 0.);
    return -length(u) * sign(u.y);
}
float sdVesica(vec2 u, float r, float d) {
    u = abs(u);
    float b = sqrt(r*r - d*d);
    return ((u.y - b)*d > u.x*b) ? length(u - vec2(0.0,b)) : length(u - vec2(-d,0.0))-r;
}
float sdTriangleIsosceles( in vec2 p, in vec2 q ) {
    p.x = abs(p.x);
    vec2 a = p - q*clamp( dot(p,q)/dot(q,q), 0.0, 1.0);
    vec2 b = p - q*vec2( clamp( p.x/q.x, 0.0, 1.0 ), 1.0);
    float s = -sign(q.y);
    vec2 d = min( vec2( dot(a,a), s*(p.x*q.y-p.y*q.x)), vec2( dot(b,b), s*(p.y-q.y)));
    return -sqrt(d.x)*sign(d.y);
}
float sdStar(vec2 u, int spikeCount, float r, float m) {
    float an = PI/float(spikeCount);
    float en = PI/m;  
    vec2  acs = vec2(cos(an),sin(an));
    vec2  ecs = vec2(cos(en),sin(en));

    float bn = mod(atan(u.x,u.y),2.0*an) - an;
    u = length(u)*vec2(cos(bn),abs(sin(bn)));
    u -= r*acs;
    u += ecs*clamp(-dot(u,ecs), 0.0, r*acs.y/ecs.y);
    return length(u)*sign(u.x);
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
float sdHeart(vec2 u) {
    u.x = abs(u.x);

    if (u.y+u.x>1.0) return sqrt(dot2(u-vec2(0.25, 0.75))) - sqrt(2.0)/4.0;
    return sqrt(min(dot2(u-vec2(0.0, 1.0)), dot2(u-0.5*max(u.x+u.y,0.0)))) * sign(u.x-u.y);
}
float sdNgon(vec2 p, float r, int n) {
    float an = PI / float(n);
    float bn = mod(atan(p.y, p.x) + an, 2.0 * an) - an;
    return length(p) * cos(bn) - r * cos(an);
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
vec3 crissCross(vec2 u, float thicknessX, float thicknessY,
    bool horOver, float top, float right, float bottom, float left) {
    float dx = abs(u.x) - thicknessX;
    float dy = abs(u.y) - thicknessY;

    if (horOver) {
        if (dy<0.0) {
            float shadow = min(1.0-right - u.x, u.x - (-1.0+left));
            return vec3(1.0, shadow, u.y);
        }
        else if (dx<0.0) {
            float shadow = min(dy, min(1.0-top - u.y, u.y - (-1.0+bottom)));
            return vec3(0.0, shadow, u.x);
        }
    }
    else {
        if (dx<0.0) {
            float shadow = min(1.0-top - u.y, u.y - (-1.0+bottom));
            return vec3(0.0, shadow, u.x);
        }
        else if (dy<0.0) {
            float shadow = min(dx, min(1.0-right - u.x, u.x - (-1.0+left)));
            return vec3(1.0, shadow, u.y);
        }
    }
    return vec3(-1.0, 0.0, 0.0);
}
float opSdUnion( float d1, float d2 ) { return min(d1,d2); }
float opSdSubtraction( float d1, float d2 ) { return max(-d1,d2); }
float opSdIntersection( float d1, float d2 ) { return max(d1,d2); }
float sdTorus( vec3 p, float R, float rb ) {
  vec2 q = vec2(length(p.xy)-R,p.z);
  return length(q)-rb;
}
float sdSegment3(vec3 u, vec3 a, vec3 b) {
    vec3 ua = u-a;
    vec3 ba = b-a;
    float h = clamp(dot(ua, ba)/dot(ba, ba), 0., 1.);
    return length(ua - ba*h);
}
float sdBox( vec3 p, vec3 b ) {
  vec3 q = abs(p) - b;
  return length(max(q,0.0)) + min(max(q.x,max(q.y,q.z)),0.0);
}
float sdCylinder( vec3 p, float r, float h ) {
  vec2 d = vec2( length(p.xy)-r, abs(p.z) - h );
  return min(max(d.x,d.y),0.0) + length(max(d,0.0));
}
float sdPyramid( vec3 p, float h) {
  float m2 = h*h + 0.25;

  p.xz = abs(p.xz);
  p.xz = (p.z>p.x) ? p.zx : p.xz;
  p.xz -= 0.5;

  vec3 q = vec3( p.z, h*p.y - 0.5*p.x, h*p.x + 0.5*p.y);

  float s = max(-q.x,0.0);
  float t = clamp( (q.y-0.5*p.z)/(m2+0.25), 0.0, 1.0 );

  float a = m2*(q.x+s)*(q.x+s) + q.y*q.y;
  float b = m2*(q.x+0.5*t)*(q.x+0.5*t) + (q.y-m2*t)*(q.y-m2*t);

  float d2 = min(q.y,-q.x*m2-q.y*0.5) > 0.0 ? 0.0 : min(a,b);

  return sqrt( (d2+q.z*q.z)/m2 ) * sign(max(q.z,-p.y));
}
float sdOctahedron(vec3 p, float s) {
    p = abs(p);
    float m = p.x+p.y+p.z-s;
    vec3 q;
    if (3.*p.x < m) q = p.xyz;
    else if (3.*p.y < m) q = p.yzx;
    else if (3.*p.z < m) q = p.zxy;
    else return m*0.57735027;
    float k = clamp(0.5*(q.z-q.y+s),0.0,s); 
    return length(vec3(q.x,q.y-s+k,q.z-k)); 
}
vec2 projEquirectangular(vec3 dir) {
    vec3 u = normalize(dir);
    float lambda = atan(u.z, u.x); // longitude
    float phi = asin(u.y); // latitude
    return vec2(lambda, phi);
}
vec3 sphereIntersection(vec3 center, float radius, vec3 origin, vec3 dir) {
    vec3 relOrigin = origin-center;
    float a = dot(dir, dir);
    float b = 2.0*dot(dir, relOrigin);
    float c = dot(relOrigin, relOrigin) - radius*radius;
    float delta = b*b - 4.0*a*c;
    if (delta>=0.0) {
        float sqrtDelta = sqrt(delta);
        float l1 = (-b - sqrtDelta) / (2.0*a);
        float l2 = (-b + sqrtDelta) / (2.0*a);
        float l = l1>0.0 ? l1 : (l2>0.0 ? l2 : -1.0);
        if (l>0.0) {
            return origin + l*dir;
        }
    }
    return vec3(INF);
}
vec3 sphereFirstIntersection(vec3 center, float radius, vec3 origin, vec3 dir) {
    vec3 relOrigin = origin-center;
    float a = dot(dir, dir);
    float b = 2.0*dot(dir, relOrigin);
    float c = dot(relOrigin, relOrigin) - radius*radius;
    float delta = b*b - 4.0*a*c;
    if (delta>=0.0) {
        float sqrtDelta = sqrt(delta);
        float l1 = (-b - sqrtDelta) / (2.0*a);
        if (l1>0.0) {
            return origin + l1*dir;
        }
    }
    return vec3(INF);
}
vec3 sphereLastIntersection(vec3 center, float radius, vec3 origin, vec3 dir) {
    vec3 relOrigin = origin-center;
    float a = dot(dir, dir);
    float b = 2.0*dot(dir, relOrigin);
    float c = dot(relOrigin, relOrigin) - radius*radius;
    float delta = b*b - 4.0*a*c;
    if (delta>=0.0) {
        float sqrtDelta = sqrt(delta);
        float l2 = (-b + sqrtDelta) / (2.0*a);
        if (l2>0.0) {
            return origin + l2*dir;
        }
    }
    return vec3(INF);
}
vec3 sphereIntersectionWithNormedDir(vec3 center, float radius, vec3 origin, vec3 dir) {
    vec3 relOrigin = origin-center;
    float a = 1.0;
    float b = 2.0*dot(dir, relOrigin);
    float c = dot(relOrigin, relOrigin) - radius*radius;
    float delta = b*b - 4.0*a*c;
    if (delta>=0.0) {
        float sqrtDelta = sqrt(delta);
        float l1 = (-b - sqrtDelta) / (2.0*a);
        float l2 = (-b + sqrtDelta) / (2.0*a);
        float l = l1>0.0 ? l1 : (l2>0.0 ? l2 : -1.0);
        if (l>0.0) {
            return origin + l*dir;
        }
    }
    return vec3(INF);
}
vec2 sphereIntersectionK(vec3 center, float radius, vec3 origin, vec3 dir) {
    vec3 relOrigin = origin-center;
    float a = dot(dir, dir);
    float b = 2.0*dot(dir, relOrigin);
    float c = dot(relOrigin, relOrigin) - radius*radius;
    float delta = b*b - 4.0*a*c;
    if (delta>=0.0) {
        float sqrtDelta = sqrt(delta);
        float l1 = (-b - sqrtDelta) / (2.0*a);
        float l2 = (-b + sqrtDelta) / (2.0*a);
        float l = l1>0.0 ? l1 : (l2>0.0 ? l2 : -1.0);
        return vec2(l1, l2);
    }
    return vec2(INF);
}
vec3 planeIntersection(vec3 planePoint, vec3 normal, vec3 origin, vec3 dir) {
    vec3 relPlane = planePoint-origin;
    float div = dot(dir, normal);
    if (div==0.0) return vec3(INF);
    float k = dot(relPlane, normal) / div;
    return k>0.0 ? origin + dir * k : vec3(INF);
}
float planeIntersectionK(vec3 planePoint, vec3 normal, vec3 origin, vec3 dir) {
    vec3 relPlane = planePoint-origin;
    float div = dot(dir, normal);
    if (div==0.0) return INF;
    float k = dot(relPlane, normal) / div;
    return k>0.0 ? k : INF;
}
vec2 cylinderIntersectionK(float radius, vec3 origin, vec3 dir) {
    float a = dot(dir.xy, dir.xy);
    float b = 2. * dot(dir.xy, origin.xy);
    float c = dot(origin.xy, origin.xy) - radius*radius;
    vec2 k = solve2ndDegreePolynomial(a, b, c);
    return vec2(k.x<0.0 ? INF : k.x, k.y<0.0 ? INF : k.y);
}
vec3 cubeIntersection(vec3 center, float radius, vec3 origin, vec3 dir) {
    vec3 relOrigin = origin-center;
    float kOut = INF;
    float kIn = 0.0;
    if (dir.x!=0.0) {
        float k1 = -(relOrigin.x-radius)/dir.x;
        float k2 = -(relOrigin.x+radius)/dir.x;
        kIn = max(kIn, min(k1, k2));
        kOut = min(kOut, max(k1, k2));
    }
    else if (abs(relOrigin.x)>radius) return vec3(INF, INF, INF);

    if (dir.y!=0.0) {
        float k1 = -(relOrigin.y-radius)/dir.y;
        float k2 = -(relOrigin.y+radius)/dir.y;
        kIn = max(kIn, min(k1, k2));
        kOut = min(kOut, max(k1, k2));
    }
    else if (abs(relOrigin.y)>radius) return vec3(INF, INF, INF);

    if (dir.z!=0.0) {
        float k1 = -(relOrigin.z-radius)/dir.z;
        float k2 = -(relOrigin.z+radius)/dir.z;
        kIn = max(kIn, min(k1, k2));
        kOut = min(kOut, max(k1, k2));
    }
    else if (abs(relOrigin.z)>radius) return vec3(INF, INF, INF);

//    if (k1>k2) return vec3(INF, INF, INF);
//    return origin + k1*dir;
    float k = kIn>0.0 ? kIn : kOut;
    if (k<=0.0 || kOut<kIn) return vec3(INF, INF, INF);
    vec3 inters = origin + k*dir;
//    float err = 0.00001;
//    if (kIn<=0.0 || abs(inters.x-center.x)>radius+err || abs(inters.y-center.y)>radius+err || abs(inters.z-center.z)>radius+err) return vec3(INF, INF, INF);
    return inters;
}
bool segmentIntersects(vec2 sa, vec2 sb, vec2 ta, vec2 tb) {
    float d = (tb.y-ta.y)*(sb.x-sa.x)-(tb.x-ta.x)*(sb.y-sa.y);
    float u = (tb.x-ta.x)*(sa.y-ta.y)-(tb.y-ta.y)*(sa.x-ta.x);
    float v = (sb.x-sa.x)*(sa.y-ta.y)-(sb.y-sa.y)*(sa.x-ta.x);
    if (d<0.0) {
        u = -u;
        v = -v;
        d = -d;
    }
    return (0.0<u && u<d) && (0.0<v && v<d);
}
vec2 getLineIntersection(vec2 sa, vec2 sb, vec2 ta, vec2 tb) {
    float sdx = sb.x - sa.x;
    float sdy = sb.y - sa.y;
    float tdx = tb.x - ta.x;
    float tdy = tb.y - ta.y;

    float determinant = sdy * tdx - sdx * tdy;
    if (determinant == 0.0) return vec2(INF);

    float k2 = ((sa.x - ta.x) * sdy + (ta.y - sa.y) * sdx) / determinant;
    return vec2(ta.x + k2 * tdx, ta.y + k2 * tdy);
}
vec2 getSegmentIntersection(vec2 sa, vec2 sb, vec2 ta, vec2 tb) {
    return segmentIntersects(sa, sb, ta, tb) ? getLineIntersection(sa, sb, ta, tb) : vec2(INF);
}
float starFlare(vec2 uv, float pixel) {
    uv = abs(uv);
    float spike = uv.y>uv.x ? (log(max((uv.x+pixel), 0.001))-log(max((uv.x-pixel), 0.001))) / uv.y
            : (log(max((uv.y+pixel), 0.001))-log(max((uv.y-pixel), 0.001))) / uv.x;
    return spike;
}
float star(vec2 uv, float pixel, float center, float flare1, float flare2) {
    mat2 rot45 = mat2(SQRT2_2, SQRT2_2, -SQRT2_2, SQRT2_2);
    return center/pow(length(uv), 2.) + flare1*starFlare(uv, pixel) + flare2*starFlare(rot45*uv, pixel);
}
float simpleVignette(float vignette, vec2 uv, mat3 vignetteTransform) {
    float d = length(tf(vignetteTransform, uv));
    return mix(1.0-vignette, 1.0, smoothstep(0.5, 1.0, d));
}
float ndfSdBezier(vec2 pos, vec2 A, vec2 B, vec2 C) {
    vec2 a = B - A;
    vec2 b = A - 2.0*B + C;
    vec2 c = a * 2.0;
    vec2 d = A - pos;
    float bb = dot(b,b);
    if (bb < 1e-7) return length(pos - mix(A, C, clamp(dot(pos-A, C-A)/max(dot(C-A,C-A),1e-7), 0.0, 1.0)));
    float kk = 1.0 / bb;
    float kx = kk * dot(a,b);
    float ky = kk * (2.0*dot(a,a)+dot(d,b)) / 3.0;
    float kz = kk * dot(d,a);
    float res = 0.0;
    float p = ky - kx*kx;
    float p3 = p*p*p;
    float q = kx*(2.0*kx*kx - 3.0*ky) + kz;
    float h = q*q + 4.0*p3;
    if (h >= 0.0) {
        h = sqrt(h);
        vec2 x = (vec2(h,-h) - q) / 2.0;
        vec2 uv = sign(x)*pow(abs(x), vec2(1.0/3.0));
        float t = clamp(uv.x+uv.y-kx, 0.0, 1.0);
        vec2 dd = d + (c + b*t)*t;
        res = dot(dd, dd);
    } else {
        float z = sqrt(-p);
        float v = acos(clamp(q/(p*z*2.0), -1.0, 1.0)) / 3.0;
        float m = cos(v);
        float n = sin(v)*1.732050808;
        vec3 t = clamp(vec3(m+m, -n-m, n-m)*z - kx, 0.0, 1.0);
        vec2 d1 = d + (c + b*t.x)*t.x;
        vec2 d2 = d + (c + b*t.y)*t.y;
        res = min(dot(d1,d1), dot(d2,d2));
    }
    return sqrt(res);
}
int ndfSevenSeg(int ch) {
    if (ch==0) return 63;
    if (ch==1) return 6;
    if (ch==2) return 91;
    if (ch==3) return 79;
    if (ch==4) return 102;
    if (ch==5) return 109;
    if (ch==6) return 125;
    if (ch==7) return 7;
    if (ch==8) return 127;
    if (ch==9) return 111;
    if (ch==11) return 64;
    return 0;
}
float ndfDigital(int ch, vec2 p) {
    if (ch==10) return length(p - vec2(0.0, -0.66));
    int m = ndfSevenSeg(ch);
    float X = 0.24, Yt = 0.66, Ym = 0.0, Yb = -0.66;
    float d = 1e9;
    if ((m &  1)!=0) d = min(d, sdSegment(p, vec2(-X,Yt), vec2( X,Yt)));
    if ((m &  2)!=0) d = min(d, sdSegment(p, vec2( X,Ym), vec2( X,Yt)));
    if ((m &  4)!=0) d = min(d, sdSegment(p, vec2( X,Yb), vec2( X,Ym)));
    if ((m &  8)!=0) d = min(d, sdSegment(p, vec2(-X,Yb), vec2( X,Yb)));
    if ((m & 16)!=0) d = min(d, sdSegment(p, vec2(-X,Yb), vec2(-X,Ym)));
    if ((m & 32)!=0) d = min(d, sdSegment(p, vec2(-X,Ym), vec2(-X,Yt)));
    if ((m & 64)!=0) d = min(d, sdSegment(p, vec2(-X,Ym), vec2( X,Ym)));
    return d;
}
float ndfCurved(int ch, vec2 p) {
    float ym = 0.0, yt = 0.70, yb = -0.70;
    if (ch==10) return length(p - vec2(0.0, -0.56));
    if (ch==11) return sdSegment(p, vec2(-0.20, ym), vec2(0.20, ym));
    float d = 1e9;
    if (ch==0) {
        d = min(d, ndfSdBezier(p, vec2( 0.0,  yt), vec2( 0.25, yt), vec2( 0.25, ym)));
        d = min(d, ndfSdBezier(p, vec2( 0.25, ym), vec2( 0.25, yb), vec2( 0.0,  yb)));
        d = min(d, ndfSdBezier(p, vec2( 0.0,  yb), vec2(-0.25, yb), vec2(-0.25, ym)));
        d = min(d, ndfSdBezier(p, vec2(-0.25, ym), vec2(-0.25, yt), vec2( 0.0,  yt)));
    } else if (ch==1) {
        d = min(d, sdSegment(p, vec2( 0.03, yt), vec2( 0.03, yb)));
        d = min(d, sdSegment(p, vec2(-0.16, 0.50), vec2( 0.03, yt)));
        d = min(d, sdSegment(p, vec2(-0.13, yb), vec2( 0.19, yb)));
    } else if (ch==2) {
        d = min(d, ndfSdBezier(p, vec2(-0.24, 0.36), vec2(-0.24, yt), vec2( 0.04, yt)));
        d = min(d, ndfSdBezier(p, vec2( 0.04, yt), vec2( 0.30, yt), vec2( 0.30, 0.34)));
        d = min(d, ndfSdBezier(p, vec2( 0.30, 0.34), vec2( 0.30, 0.25), vec2( 0.07,-0.14)));
        d = min(d, sdSegment(p, vec2( 0.07,-0.14), vec2(-0.25, yb)));
        d = min(d, sdSegment(p, vec2(-0.25, yb), vec2( 0.30, yb)));
    } else if (ch==3) {
        d = min(d, ndfSdBezier(p, vec2(-0.14, 0.56), vec2( 0.14, 0.84), vec2( 0.28, 0.44)));
        d = min(d, ndfSdBezier(p, vec2( 0.28, 0.44), vec2( 0.30, 0.06), vec2(-0.04, ym)));
        d = min(d, ndfSdBezier(p, vec2(-0.04, ym),   vec2( 0.30,-0.06), vec2( 0.28,-0.44)));
        d = min(d, ndfSdBezier(p, vec2( 0.28,-0.44), vec2( 0.14,-0.84), vec2(-0.14,-0.56)));
    } else if (ch==4) {
        d = min(d, sdSegment(p, vec2( 0.19, yt), vec2(-0.26,-0.22)));
        d = min(d, sdSegment(p, vec2(-0.26,-0.22), vec2( 0.27,-0.22)));
        d = min(d, sdSegment(p, vec2( 0.19, yt), vec2( 0.19, yb)));
    } else if (ch==5) {
        d = min(d, sdSegment(p, vec2(-0.20, yt), vec2( 0.24, yt)));
        d = min(d, sdSegment(p, vec2(-0.20, yt), vec2(-0.20, 0.06)));
        d = min(d, ndfSdBezier(p, vec2(-0.20, 0.06), vec2( 0.30, 0.10), vec2( 0.28,-0.30)));
        d = min(d, ndfSdBezier(p, vec2( 0.28,-0.30), vec2( 0.28,-0.70), vec2( 0.0, yb)));
        d = min(d, ndfSdBezier(p, vec2( 0.0,  yb),   vec2(-0.22,-0.70), vec2(-0.22,-0.42)));
    } else if (ch==6) {
        d = min(d, ndfSdBezier(p, vec2( 0.0, -0.02), vec2( 0.25,-0.02), vec2( 0.25,-0.34)));
        d = min(d, ndfSdBezier(p, vec2( 0.25,-0.34), vec2( 0.25, yb),   vec2( 0.0,  yb)));
        d = min(d, ndfSdBezier(p, vec2( 0.0,  yb),   vec2(-0.25, yb),   vec2(-0.25,-0.34)));
        d = min(d, ndfSdBezier(p, vec2(-0.25,-0.34), vec2(-0.25,-0.02), vec2( 0.0, -0.02)));
        d = min(d, ndfSdBezier(p, vec2( 0.18, yt),   vec2(-0.22, 0.34), vec2(-0.25,-0.30)));
    } else if (ch==7) {
        d = min(d, sdSegment(p, vec2(-0.22, yt), vec2( 0.26, yt)));
        d = min(d, ndfSdBezier(p, vec2( 0.26, yt), vec2( 0.06, 0.0), vec2(-0.10, yb)));
    } else if (ch==8) {
        d = min(d, ndfSdBezier(p, vec2( 0.0,  yt),   vec2( 0.19, yt),   vec2( 0.19, 0.35)));
        d = min(d, ndfSdBezier(p, vec2( 0.19, 0.35), vec2( 0.19, ym),   vec2( 0.0,  ym)));
        d = min(d, ndfSdBezier(p, vec2( 0.0,  ym),   vec2(-0.19, ym),   vec2(-0.19, 0.35)));
        d = min(d, ndfSdBezier(p, vec2(-0.19, 0.35), vec2(-0.19, yt),   vec2( 0.0,  yt)));
        d = min(d, ndfSdBezier(p, vec2( 0.0,  ym),   vec2( 0.24, ym),   vec2( 0.24,-0.36)));
        d = min(d, ndfSdBezier(p, vec2( 0.24,-0.36), vec2( 0.24, yb),   vec2( 0.0,  yb)));
        d = min(d, ndfSdBezier(p, vec2( 0.0,  yb),   vec2(-0.24, yb),   vec2(-0.24,-0.36)));
        d = min(d, ndfSdBezier(p, vec2(-0.24,-0.36), vec2(-0.24, ym),   vec2( 0.0,  ym)));
    } else if (ch==9) {
        d = min(d, ndfSdBezier(p, vec2( 0.0,  0.02), vec2( 0.25, 0.02), vec2( 0.25, 0.34)));
        d = min(d, ndfSdBezier(p, vec2( 0.25, 0.34), vec2( 0.25, yt),   vec2( 0.0,  yt)));
        d = min(d, ndfSdBezier(p, vec2( 0.0,  yt),   vec2(-0.25, yt),   vec2(-0.25, 0.34)));
        d = min(d, ndfSdBezier(p, vec2(-0.25, 0.34), vec2(-0.25, 0.02), vec2( 0.0,  0.02)));
        d = min(d, ndfSdBezier(p, vec2(-0.18, yb),   vec2( 0.22,-0.34), vec2( 0.25, 0.30)));
    }
    return d;
}
int ndfCharForSlot(int slot, int nint, bool neg, int decimals, float ipart, float av) {
    if (slot < 0) return 12;
    if (neg && slot == 0) return 11;
    int idx = slot - (neg ? 1 : 0);
    if (idx < 0) return 12;
    if (idx < nint) {
        int posFromRight = (nint - 1) - idx;
        float dv = floor(ipart / pow(10.0, float(posFromRight)));
        return int(mod(dv, 10.0));
    } else if (decimals > 0 && idx == nint) {
        return 10;
    } else {
        int fpos = idx - nint - 1;
        if (fpos < 0 || fpos >= decimals) return 12;
        float dv = floor(av * pow(10.0, float(fpos + 1)));
        return int(mod(dv, 10.0));
    }
}
