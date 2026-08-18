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
#define u_sourceDim (U[4].xy)
#define u_outDim (U[5].xy)
#define u_mode (int(U[6].x))
#define u_backgroundMode (int(U[7].x))
#define u_balance (U[8].x)
#define u_power (U[9].x)
#define u_offset (U[10].x)
#define u_colorScheme (U[11].x)
#define u_texTransform (mat3(U[12].xyz, U[13].xyz, U[14].xyz))

#define __source__texelFetch__(c) texelFetch(u_source, (c), 0)
#define __source__(p) textureLod(u_source, __mirror_wrap__(vec2((p).x / u_worldAspect, (p).y) / 2.0 + 0.5), 0.0)




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

vec4 getUnitColor(vec2 u) {
    float k = 0.0;
    vec2 v = u*10.0 - round(u*10.0);
    if (u.x>=0.0&&u.x<0.1 && u.y>=0.0&&u.y<0.1) k = 0.75;
    if (u.x>=0.0&&u.x<0.1 && u.y>=0.9&&u.y<1.) k = 0.75;
    if (u.x>=0.9&&u.x<1. && u.y>=0.0&&u.y<0.1) k = 0.75;
    if (u.x>=0.9&&u.x<1. && u.y>=0.9&&u.y<1.) k = 0.75;
    k = max(k, max(smoothstep(0.03, 0.02, abs(v.x)), smoothstep(0.03, 0.02, abs(v.y))));
    vec4 col = vec4(u.x, u.y, 0.5, 1.);
    if (abs(u.x-0.5)>0.5 || abs(u.y-0.5)>0.5) col.rgb *= 0.25;
    return mix(col, vec4(1.0), k);
}

float mir(float x, float a) {
    return a * (1. - abs(mod(x, 2.*a)/a - 1.));
}

vec2 tf(mat3 m, vec2 u) {
    return (m * vec3(u, 1.)).xy;
}

vec4 progressiveScaling(vec2 uv, vec2 outPos, vec2 sourceDim, int mode, int backgroundMode, float balance, float power, float offset, float colorScheme, mat3 texTransform) {
            if (mode>=100) { 
                uv = vec2(atan(uv.x, uv.y)/PI, length(uv));
                mode -= 100;
            }
            vec2 ar = vec2(sourceDim.x / sourceDim.y, 1.);
            
            bool inside = true;
            
            if (mode==0){
                float N = 200.;
                float S = 1.0;
                if (backgroundMode==1) uv.y = abs(uv.y);
                float y = -uv.y;
                float E = power;
                inside = false;
                if (y>0.0) {
                    //uv = uv*2.0 + ar;
                    uv = (outPos+1.0)*.5;
                }
                else {
                    float Y = 0.0;
                    for(float i=0.0; i<N; ++i) {
                        //float j = 2.*(i+2.);
                        float j = (i+3.);
                        Y += S/pow(j, E);
                        //if (abs(uv.y+Y)<0.02) { col = vec4(1.0); break; }
                        //if (y>-Y) { uv = ar + (uv-Y)*j*vec2(0.5,1./S); break; }
                        float sy = mix(pow(j, E)/S, Y*.5, balance);
                        if (y>-Y) { uv = ar + (uv-Y)*vec2(0.5*j, pow(j, E)/S); inside = true; break; }
                    }
                }
                uv.x += offset;
                uv = fract(uv);
            }
            else if (mode==1) {
//                float Y = floor(uv.y);
//                float circum = (Y+0.5) * 2. * PI;
//                float N = round(circum / 5.);
//                float sy = mix(1., Y*.5, balance);
//                uv = vec2(uv.x * N*.5, (uv.y - Y)*sy);
//                uv.x += offset;// * pow(Y, 0.8);
//                uv = fract(uv);
                
                float E = max(0.001, abs(power)) + 1.; // mirror around 1 and always ensure power!=1 as that is a singularity
                float S = 1./(1.-1./E);
                float y = backgroundMode==1 ? mir(uv.y, S) : uv.y;
                if (y>=0.0 && y<=S) {
                    float Y = floor(log((S-y)/S) / log(1./E));
//                    float ly = pow(E, -Y); // "glitchy" alternative: Y*.5;
                    float ly = mix(pow(E, -Y), Y*.5, balance); // "glitchy" alternative: Y*.5;
                    float y1 = S - S*ly;
                    float circum = (Y+0.5) * 2. * PI;
                    float N = round(circum / 5.);
                    uv = vec2(uv.x * N, (y - y1)/ly);
                    uv.x += offset;// * pow(Y, 0.8);
                    uv = fract(uv);
                }
                else {
                    inside = false;
                    uv = (outPos+1.0)*.5;
                }
            }
            else if (mode==2) {
                float E = max(0.001, abs(power)) + 1.; // mirror around 1 and always ensure power!=1 as that is a singularity
                float S = 1./(1.-1./E);
                float y = backgroundMode==1 ? mir(uv.y, S) : uv.y;
                if (y>=0.0 && y<=S) {
                    float Y = floor(log((S-y)/S) / log(1./E));
//                    float ly = pow(E, -Y); // "glitchy" alternative: Y*.5;
                    float ly = mix(pow(E, -Y), Y*.5, balance); // "glitchy" alternative: Y*.5;
                    float y1 = S - S*ly;
                    float N = pow(2., Y);
                    uv = vec2(uv.x * N, (y - y1)/ly);
                    uv.x += offset;// * pow(Y, 0.8);
                    uv = fract(uv);
                }
                else {
                    inside = false;
                    uv = (outPos+1.0)*.5;
                }
            }
        
        
            float kCol = colorScheme==1.0 ? 1.0 : fract(colorScheme * 5.);
            vec4 col1 = getUnitColor(uv);

            vec2 uv2 = (uv*2.0-1.0) * ar;
            uv2 = tf(inverse(texTransform), uv2);
            vec4 col3 = __source__(uv2);

            uv = tf(inverse(texTransform), uv);
            float g = fract(uv.x)<0.5 ? 1.0 : 0.0;
            float r = fract(uv.y);

            vec4 col2 = vec4(vec3(r, g, 0.5), 1.);
            vec4 col4 = vec4(vec3(g>0.5 ? 1.0 : 0.0), 1.);
            vec4 colSlopedThenGrad = vec4(vec3(kCol<=0.5 ? (uv.x-.5 > kCol*2.*(uv.y-.5) ? 0.0 : 1.0) : (kCol-0.5) + 0.25*((uv.y)/(kCol-.5)-(uv.x)/(kCol-.5))), 1.);

            
            vec4 colBorder = (abs(uv.x-0.5)>0.4 || abs(uv.y-0.5)>0.4) ? vec4(0., 0., 0., 1.) : col3; 
            
            vec4 resCol;
            if (colorScheme<0.2) resCol = mix(col3, colBorder, kCol);
            else if (colorScheme<0.4) resCol = mix(colBorder, col1, kCol);
            else if (colorScheme<0.6) resCol = mix(col1, col2, kCol);
            else if (colorScheme<0.8) resCol = mix(col2, col4, kCol);
            else resCol = colSlopedThenGrad;          
              
            if (inside || backgroundMode<=1) return resCol;
            else if (backgroundMode==2) return vec4(0., 0., 0., 1.);
            else if (backgroundMode==3) return vec4(1.);
            else return __source__(outPos);
        }

void main() {
    fragColor = progressiveScaling((inverse(u_viewTransform) * vec3(((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), 1.0)).xy, ((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), u_sourceDim, u_mode, u_backgroundMode, u_balance, u_power, u_offset, u_colorScheme, u_texTransform);
}
