#version 450
layout(location = 0) in vec2 v_uv;
layout(location = 0) out vec4 fragColor;

layout(binding = 0, std140) uniform Params {
    vec4 U[13];
};
layout(binding = 1) uniform sampler samp;
layout(binding = 2) uniform texture2D t_source;

#define u_source sampler2D(t_source, samp)
#define u_worldAspect (U[0].x)
#define u_viewTransform (mat3(U[1].xyz, U[2].xyz, U[3].xyz))
#define u_outDim (U[4].xy)
#define u_thickness (U[5].x)
#define u_count (int(U[6].x))
#define u_balance (U[7].x)
#define u_len (U[8].x)
#define u_angle (U[9].x)
#define u_modelTransform (mat3(U[10].xyz, U[11].xyz, U[12].xyz))

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

vec2 tf(mat3 m, vec2 u) {
    return (m * vec3(u, 1.)).xy;
}

vec4 radialInterpolate(vec2 pos, vec2 outPos, float thickness, int count, float balance, float len, float angle, mat3 modelTransform) {
    float thickn = thickness;
    float ha = angle/2.0;
    float angleRange = angle/float(count);

    vec2 u = tf(inverse(modelTransform), pos);

    if (angle <= PI2) {

        float halfThickPos = 1.0-thickn/2.0;

        float phase = 0.0;
        vec2 center = vec2(0.0, 0.0);

        for(int i=0; i<int(ceil(len)); ++i) {
            float d = length(u - center);
            if (d>=1.0-thickn && d<=1.0) {

                float da = 0.0;
                if (d > 0.0) {
                    float ang = acos((u.x-center.x)/d);
                    if (u.y-center.y < 0.0) ang = PI2 - ang;

                    ang += phase + PI/2.0 + ha;
                    ang = mod(ang + PI2, PI2);
                    if (ang <= angle) {
                        ang = angle-ang;
                        float index = floor(ang/angle*float(count));
                        float ang1 = phase -ha + angleRange*index;
                        float ang2 = phase -ha + angleRange*(index+1.0);
                        vec2 pos1 = tf(modelTransform, vec2(center.x-d*sin(ang1), center.y-d*cos(ang1)));
                        vec4 col1 = __source__(pos1);
                        vec2 pos2 = tf(modelTransform, vec2(center.x-d*sin(ang2), center.y-d*cos(ang2)));
                        vec4 col2 = __source__(pos2);

                        //return mix(col1, col2, (ang-angleRange*index)/angleRange);
                        float ka = (ang-angleRange*index)/angleRange;
                        return mix(col1, col2, mix(1.0-ka, ka, 0.5+0.5*balance));
                    }
                }
            }

            float endAng = phase -ha + ((mod(float(i), 2.0)==0.0) ? angle : 0.0);
            vec2 posH = vec2(center.x-halfThickPos*sin(endAng), center.y-halfThickPos*cos(endAng));
            center = 2.0*posH - center;
            phase += PI;
        }

//        phase = 0.0;
        float endAng = -ha;
        vec2 posH = vec2(-halfThickPos*sin(endAng), -halfThickPos*cos(endAng));
        center = 2.0*posH;
        phase = PI;

        for(int i=1; i<int(ceil(len)); ++i) {
            float d = length(u - center);
            if (d>=1.0-thickn && d<=1.0) {

                float da = 0.0;
                if (d > 0.0) {
                    float ang = acos((u.x-center.x)/d);
                    if (u.y-center.y < 0.0) ang = PI2 - ang;

                    ang += phase + PI/2.0 + ha;
                    ang = mod(ang + PI2, PI2);
                    if (ang <= angle) {
                        ang = angle-ang;
                        float index = floor(ang/angle*float(count));
                        float ang1 = phase -ha + angleRange*index;
                        float ang2 = phase -ha + angleRange*(index+1.0);
                        vec2 pos1 = tf(modelTransform, vec2(center.x-d*sin(ang1), center.y-d*cos(ang1)));
                        vec4 col1 = __source__(pos1);
                        vec2 pos2 = tf(modelTransform, vec2(center.x-d*sin(ang2), center.y-d*cos(ang2)));
                        vec4 col2 = __source__(pos2);

                        //return mix(col1, col2, (ang-angleRange*index)/angleRange);
                        float ka = (ang-angleRange*index)/angleRange;
                        return mix(col1, col2, mix(1.0-ka, ka, 0.5+0.5*balance));
                    }
                }
            }

            float endAng = phase -ha + ((mod(float(i), 2.0)==1.0) ? angle : 0.0);
            vec2 posH = vec2(center.x-halfThickPos*sin(endAng), center.y-halfThickPos*cos(endAng));
            center = 2.0*posH - center;
//            center += vec2(1.0, 0.0);
            phase += PI;
        }

    }

    return __source__(pos);
}

void main() {
    fragColor = radialInterpolate((inverse(u_viewTransform) * vec3(((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), 1.0)).xy, ((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), u_thickness, u_count, u_balance, u_len, u_angle, u_modelTransform);
}
