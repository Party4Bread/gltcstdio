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
#define u_sourceDim (U[4].xy)
#define u_outDim (U[5].xy)
#define u_radius (U[6].x)
#define u_mode (int(U[7].x))
#define u_lighting (U[8].x)
#define u_model3DTransform (mat4(U[9], U[10], U[11], U[12]))

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

vec2 cylinderIntersectionK(float radius, vec3 origin, vec3 dir) {
    float a = dot(dir.xy, dir.xy);
    float b = 2. * dot(dir.xy, origin.xy);
    float c = dot(origin.xy, origin.xy) - radius*radius;
    vec2 k = solve2ndDegreePolynomial(a, b, c);
    return vec2(k.x<0.0 ? INF : k.x, k.y<0.0 ? INF : k.y);
}

vec4 getBackground(vec3 dir) {
    return vec4(0.0, 0.0, 0.0, 1.0);
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

float sdRectangle(vec2 u, vec2 halfSize) {
    u = abs(u)-halfSize;
    return (u.x>=0. && u.y>=0.) ? length(u) : max(u.x, u.y);
}

vec4 wallpaper(vec2 pos, vec2 outPos, float radius, int mode, float lighting, mat4 model3DTransform, vec2 sourceDim) {
            vec4 backgroundColor = vec4(0.0, 0.0, 0.0, 1.0);
            
            float D = 1.0;
            vec3 cameraPos = vec3(0., 0., 0.);
            //mat4 m = inverse(model3DTransform * mat4(1., 0., 0., 0., 0., 1., 0., 0., 0., 0., 1., 0., 0., 0., -1.0, 1.));
            mat4 m = inverse(model3DTransform);
            cameraPos = (m * vec4(cameraPos, 1.)).xyz;
            vec3 dir = normalize(vec3(pos.x*D, pos.y*D, -1.0));
            dir = mat3(m) * dir;
    
            vec4 col = getBackground(dir);
    
            if (dir.z==0.0) return col;
            bool clip = mode==0;
            float ratio = sourceDim.x/sourceDim.y;

            float z =  0.;
            float Y = 0.5;
            float kz = planeIntersectionK(vec3(0.0), vec3(0.0, 0.0, 1.0), cameraPos, dir);
            float ky = planeIntersectionK(vec3(0.0, Y, 0.0), vec3(0.0, 1.0, 0.0), cameraPos, dir);
            vec2 cylCenter = vec2(radius, Y-radius);
            vec2 kc = cylinderIntersectionK(radius, cameraPos.zyx-vec3(cylCenter, 0.), dir.zyx);
            float bestK = INF;
                        
            if (kc.x < bestK) {
                vec3 uv = cameraPos + kc.x*dir;
                if (uv.z<radius && uv.y>Y-radius)  { //will probably require inversion on Y
                    float angle = atan(uv.y-Y+radius, radius - uv.z);
                    float y = Y + radius * (angle - 1.0);
                    col = __source__(vec2(uv.x, y));
                    bestK = kc.x;
                }
            }
            if (kc.y < bestK) {
                vec3 uv = cameraPos + kc.y*dir;
                if (uv.z<radius && uv.y>Y-radius)  { //will probably require inversion on Y
                    float angle = atan(uv.y-Y+radius, radius - uv.z);
                    float y = Y + radius * (angle - 1.0);
                    col = __source__(vec2(uv.x, y));
                    bestK = kc.y;
                }
            }
            if (ky < bestK) {
                vec3 uv = cameraPos + ky*dir;
                if (uv.z>=radius) {
                    col = __source__(uv.xz + vec2(0.0, Y + radius * (PI_2-2.)));
                    bestK = ky;
                }
            }
            if (kz < bestK) {
                vec3 uv = cameraPos + kz*dir;
                if (uv.y<=Y-radius) {
                    col = __source__(uv.xy);
                    bestK = kz;
                }
            }
//            if (!found && kz!=INF) {
//                vec3 uv = cameraPos + kz*dir;
//                if (true || uv.y<=0.*(Y-radius)) {
//                    col = __source__(uv.xy);
//                    found = true;
//                }
//            }
            if (lighting>0.0) {
                vec3 intersection = cameraPos + bestK * dir;
                vec3 normal = vec3(0., 0., 1.);
//                if (abs(intersection.y-Y)<0.0001) normal = vec3(0., 1., 0.);
                if (intersection.z>=radius) normal = vec3(0., -1., 0.);
                else if (abs(intersection.z)>0.0001) normal = normalize(vec3(0., cylCenter.y-intersection.y, cylCenter.x-intersection.z));
//                if (intersection.z>=radius) return vec4(0., 1., 0., 1.);
//                else if (abs(intersection.z)>0.0001) return vec4(1., 0., 0., 1.);
//                else return vec4(0., 0., 1., 1.);
                
                vec3 lightPos = vec3(-10000.0, 20000.0, 40000.0);
                vec3 lightToIntersection = normalize(intersection-lightPos);
                float illum = dot(-lightToIntersection, normal);
                float k = mix(1.0, 0.7 + 0.3 * max(0.0, illum), min(1., lighting*2.));
                col.rgb *= k;
                
//                vec3 reflectDir = reflect(normalize(intersection-cameraPos), normal);
//                vec3 lpIntersection = planeIntersection(lightPos, vec3(0.0, 0.0, -1.0), intersection, reflectDir);
//                if (lpIntersection.x!=INF) {
//                    float d = sdRectangle(lpIntersection.xy-lightPos.xy, vec2(5000.));
//                    if (d<0.0) col.rgb += mix(0.0, 1.0, max(0., lighting*2.-1.));
//                }
                float specular = pow(max(0., dot(reflect(-lightToIntersection, normal), normalize(cameraPos-intersection))), 5.);
                col.rgb += mix(0.0, specular, max(0., lighting*2.-1.));
            }
    
            return col;
        }

void main() {
    fragColor = wallpaper((inverse(u_viewTransform) * vec3(((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), 1.0)).xy, ((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), u_radius, u_mode, u_lighting, u_model3DTransform, u_sourceDim);
}
