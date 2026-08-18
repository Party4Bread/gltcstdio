#version 450
layout(location = 0) in vec2 v_uv;
layout(location = 0) out vec4 fragColor;

layout(binding = 0, std140) uniform Params {
    vec4 U[17];
};
layout(binding = 1) uniform sampler samp;

#define u_worldAspect (U[0].x)
#define u_viewTransform (mat3(U[1].xyz, U[2].xyz, U[3].xyz))
#define u_outDim (U[4].xy)
#define u_mode1 (int(U[5].x))
#define u_mode2 (int(U[6].x))
#define u_hColor (U[7])
#define u_vColor (U[8])
#define u_hBorderColor (U[9])
#define u_vBorderColor (U[10])
#define u_colorShadow (U[11])
#define u_colorBkg (U[12])
#define u_randomSeed (U[13].x)
#define u_variability (U[14].x)
#define u_thickness (U[15].x)
#define u_shadows (U[16].x)





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

float getThick(float x, float thickness, float var, float seed) {
    if (var==0.0) return thickness;
    vec2 k = rand2relSeeded(vec2(x, x), seed) +.5;
    return mix(thickness*(1.-var), mix(thickness, 0.5, var), k.x);
}

bool isHor(vec2 id, float mode) {
                int m = int(mode);
                float a = float(m%4+1);
                m/=4; float b =float(m%4+1); 
                m/=4; float c =float(m%4+1);
                m/=4; float d =float(m%4+1); //256
                m/=4; float e =float(m%4+2);
                m/=4; float f =float(m%4+1);
                m/=4; float g =float(m%4+1);
                m/=4; float h =float(m%4+1); // 65536
                m/=4; float i =float(m%4+2)*3.;
                m/=4; float j =float(m%4+2)*3.;
                m/=4; float k =float(m%4+1);
                
                return mod(floor(id.x/a)+floor(id.y/b), e+mod(id.y, g)) == mod(floor(id.x/i)+floor(id.y/j), k)*mod(floor(id.x/c)+floor(id.y/d), f+mod(id.x, h));
////                float kx = mod(mode, 2.0) + 1.0;
////                mode /= 2.0; float ky = mod(mode, 2.0) + 1.0;
////                mode /= 2.0; float a = mod(mode, 4.0) ;
////                mode /= 4.0; float b = mod(mode, 4.0) ;
////                
////                return mod(kx*id.x + ky*id.y, 2.+mod(mod(a*id.y, 5.) + mod(b*id.x, 5.), 2.)) == 0.0;
//                float rem = mod(mode, 2.0);
//                mode /= 2.;
//                bool r = false;
//                if (mode==0.) r = mod(id.x+id.y, 2.) == 0.0;
//                else if (mode==1.) r = mod(id.x+id.y, 3.) == 0.0;
//                else if (mode==2.) r = mod(id.x+id.y, 4.) == 0.0;
//                else if (mode==3.) r = mod(id.x+id.y, 5.) == 0.0;
//                else if (mode==4.) r = mod(id.x*2.+id.y, 2.) == 0.0;
//                else if (mode==5.) r = mod(id.x+id.y*2., 2.) == 0.0;
//                else if (mode==6.) r = mod(id.x*2.+id.y, 3.) == 0.0;
//                else if (mode==7.) r = mod(id.x+id.y*2., 3.) == 0.0;
//                else if (mode==8.) r = mod(id.x*2.+id.y, 4.) == 0.0;
//                else if (mode==9.) r = mod(id.x+id.y*2., 4.) == 0.0;
//                else if (mode==10.) r = mod(id.x*2.+id.y, 5.) == 0.0;
//                else if (mode==11.) r = mod(id.x+id.y*2., 5.) == 0.0;
//                else if (mode==12.) r = mod(id.x+id.y, 2.+mod(id.y, 2.)) == 0.0;
//                else if (mode==13.) r = mod(id.x+id.y, 2.+mod(id.x, 2.)) == 0.0;
//                else if (mode==14.) r = mod(id.x+id.y, 2.+mod(id.y, 3.)) == 0.0;
//                else if (mode==15.) r = mod(id.x+id.y, 2.+mod(id.x, 3.)) == 0.0;
//                
//                return rem==0.0 ? r : !r;                
            }

bool isHor2(vec2 id, float a, float b, float c, float d, float e, float f, float g, float h, float i, float j, float k) {                
    return mod(floor(id.x*a)+floor(id.y*b), e+mod(id.y, g)) == mod(floor(id.x*i)+floor(id.y*j), k)*mod(floor(id.x*c)+floor(id.y*d), f+mod(id.x, h));
}

vec4 mergeColor(vec4 bkg, vec4 front) {
    return vec4(mix(bkg.rgb, front.rgb, front.a + (1.0-bkg.a)*(1.0-front.a)), max(bkg.a, front.a));
}

float shade(float shadow, float dist) {
    return smoothstep(shadow, shadow*0.35, dist);
}

vec4 crossStitch(vec2 uv, vec2 outPos, int mode1, int mode2, vec4 hColor, vec4 vColor, vec4 hBorderColor, vec4 vBorderColor, vec4 colorShadow, vec4 colorBkg, float randomSeed, float variability, float thickness, float shadows) {
    thickness *= 0.5;
    
    vec2 id = floor(uv);
    float mo = float(mode1) + float(mode2)*4096.;
                int m = int(mo);
                float pa = 1./float(m%4+1);
                m/=4; float pb =1./float(m%4+1); 
                m/=4; float pc =1./float(m%4+1);
                m/=4; float pd =1./float(m%4+1); //256
                m/=4; float pe =float(m%4+2);
                m/=4; float pf =float(m%4+1);
                m/=4; float pg =float(m%4+1);
                m/=4; float ph =float(m%4+1); // 65536
                m/=4; float pi =1./float(m%4+2)*3.;
                m/=4; float pj =1./float(m%4+2)*3.;
                m/=4; float pk =float(m%4+1);

    float thickVar = variability;
    float thicknessX = getThick(id.x, thickness, thickVar, randomSeed);
    float thicknessY = getThick(id.y, thickness, thickVar, randomSeed);
    float shadow = 0.5;

    vec2 u = fract(uv) - .5;
    vec2 unit = vec2(1.0, 0.0);

//    float top = (isHor(id+unit.yx, mo)) ? getThick(id.y+1.0, thickness, thickVar, randomSeed) : -1.0;
//    float bottom = (isHor(id-unit.yx, mo)) ? getThick(id.y-1.0, thickness, thickVar, randomSeed) : -1.0;
//    float right = (!isHor(id+unit, mo)) ? getThick(id.x+1.0, thickness, thickVar, randomSeed) : -1.0;
//    float left = (!isHor(id-unit, mo)) ? getThick(id.x-1.0, thickness, thickVar, randomSeed) : -1.0;
//
//    vec3 cc = crissCross(u, thicknessX, thicknessY, isHor(id, mo), top, right, bottom, left);
    float top = (isHor2(id+unit.yx, pa, pb, pc, pd, pe, pf, pg, ph, pi, pj, pk)) ? getThick(id.y+1.0, thickness, thickVar, randomSeed) : -1.0;
    float bottom = (isHor2(id-unit.yx, pa, pb, pc, pd, pe, pf, pg, ph, pi, pj, pk)) ? getThick(id.y-1.0, thickness, thickVar, randomSeed) : -1.0;
    float right = (!isHor2(id+unit, pa, pb, pc, pd, pe, pf, pg, ph, pi, pj, pk)) ? getThick(id.x+1.0, thickness, thickVar, randomSeed) : -1.0;
    float left = (!isHor2(id-unit, pa, pb, pc, pd, pe, pf, pg, ph, pi, pj, pk)) ? getThick(id.x-1.0, thickness, thickVar, randomSeed) : -1.0;

    vec3 cc = crissCross(u, thicknessX, thicknessY, isHor2(id, pa, pb, pc, pd, pe, pf, pg, ph, pi, pj, pk), top, right, bottom, left);

    vec4 col = colorBkg;

    if (cc.x==1.0) { // vertical ribbon
        col = hColor;
        if (abs(cc.z)>thicknessX*.8) col = mergeColor(hColor, hBorderColor);
    }
    else if (cc.x==0.0) { // horizontal ribbon
        col = vColor;
        if (abs(cc.z)>thicknessY*.8) col = mergeColor(vColor, vBorderColor);
    }
    if (cc.x!=-1.0) {
        col = mergeColor(col, vec4(colorShadow.rgb, colorShadow.a * shade(shadows, cc.y)));
    }

    return col;
}

void main() {
    fragColor = crossStitch((inverse(u_viewTransform) * vec3(((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), 1.0)).xy, ((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), u_mode1, u_mode2, u_hColor, u_vColor, u_hBorderColor, u_vBorderColor, u_colorShadow, u_colorBkg, u_randomSeed, u_variability, u_thickness, u_shadows);
}
