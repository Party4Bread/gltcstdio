#version 450
layout(location = 0) in vec2 v_uv;
layout(location = 0) out vec4 fragColor;

layout(binding = 0, std140) uniform Params {
    vec4 U[27];
};
layout(binding = 1) uniform sampler samp;
layout(binding = 2) uniform texture2D t_source;

#define u_source sampler2D(t_source, samp)
#define u_worldAspect (U[0].x)
#define u_viewTransform (mat3(U[1].xyz, U[2].xyz, U[3].xyz))
#define u_sourceDim (U[4].xy)
#define u_outDim (U[5].xy)
#define u_radius (U[6].x)
#define u_angle (U[7].x)
#define u_count (int(U[8].x))
#define u_roundness (U[9].x)
#define u_blend (U[10].x)
#define u_colorFog (U[11])
#define u_sourceColor (U[12])
#define u_ambientColor (U[13])
#define u_backgroundStyle (int(U[14].x))
#define u_specular (U[15].x)
#define u_model3DTransform (mat4(U[16], U[17], U[18], U[19]))
#define u_texTransform (mat3(U[20].xyz, U[21].xyz, U[22].xyz))
#define u_lightSourceTransform (mat4(U[23], U[24], U[25], U[26]))

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























































































































































































































































































































































//vec3 getIntersectionD(vec3 origin, vec3 dir, float radius, int count, float roundness, float angle) {
//    float minDist = 1e9;
//    float k = 0.0;
////    vec2 kBounds = sphereIntersectionSpec(vec3(0.0, 0.0, 0.0), 0.5*(1.0+radius*2.0), origin, dir);
////    float kk = kBounds.x;
////    if (kk<0.0) return vec3(kk, 0.0, minDist);
//
//    float de = 0.0001;
//    int maxIter = 1256;
//    int iter = 0;
//    vec3 p = origin;
//    float dist = implicitFn(p, radius, count, roundness, angle);
//    while (iter<maxIter) {
//        k += (dist);
//        p = origin + k*dir;
//        dist = length(p) - radius;// implicitFn(p, radius, count, roundness, angle);
//        minDist = min(minDist, abs(dist));
//        if (abs(dist)<0.0001) return vec3(k, iter, minDist);
//        ++iter;
//    }
//    return dist<de ? vec3(k, iter, minDist) : vec3(k, iter, minDist);
//}
//














            


float getFog(float dist, float alpha) {
    return max((dist-0.5)*4.0, 0.0) * alpha;
}

float implicitFn(vec3 p, float radius, int count, float roundness, float angle) {
    float R = 0.5;
    float r = R*radius;
    float a = sqrt(p.x*p.x + p.z*p.z) - R;
//return length(p) - R;
////return sqrt(a*a + p.y*p.y) - r;
//    //if (length(p) > 2.*(R+r)) return length(p)-R-r;
    
    float ang = angle + atan(p.z, p.x) *0.25 * (float(count)-1.0);
    float ca = cos(ang);
    float sa = sin(ang);
    mat2 rot = mat2(ca, sa, sa, -ca);
    vec2 q = rot * vec2(a, p.y);
    vec2 d = abs(q)-r;
    float compensation = mix(0.7, 0.2, float(count)*0.01);
    return compensation*(length(max(d,0.0)) + min(max(d.x,d.y),0.0)) - roundness;
}

vec2 sphereIntersectionSpec(vec3 center, float radius, vec3 origin, vec3 dir) {
    vec3 relOrigin = origin-center;
    float a = dot(dir, dir);
    float b = 2.0*dot(dir, relOrigin);
    float c = dot(relOrigin, relOrigin) - radius*radius;
    float delta = b*b - 4.0*a*c; //147
    if (delta>=0.0) {
        float sqrtDelta = sqrt(delta);
        float l1 = (-b - sqrtDelta) / (2.0*a);
        float l2 = (-b + sqrtDelta) / (2.0*a);
        float l = l1>0.0 ? l1 : (l2>0.0 ? l2 : -1.0);
        if (l>0.0) {
            return vec2(max(0.0, l1), l2);
        }
    }
    return vec2(-1.0, -1.0);
}

vec3 getIntersectionD(vec3 origin, vec3 dir, float radius, int count, float roundness, float angle) {
    float minDist = 1e9;
    float k = 0.0;
//    vec2 kBounds = sphereIntersectionSpec(vec3(0.0, 0.0, 0.0), 0.5*(1.0+radius*2.0), origin, dir);
//    float kk = kBounds.x;
//    if (kk<0.0) return vec3(kk, 0.0, minDist);

    float de = 0.0001;
    int maxIter = 1256;
    int iter = 0;
    vec3 p = origin;
    float dist = implicitFn(p, radius, count, roundness, angle);
    while (abs(dist)>de && iter<maxIter) {
        k += abs(dist);
        p = origin + k*dir;
        dist = implicitFn(p, radius, count, roundness, angle);
        minDist = min(minDist, abs(dist));
        ++iter;
    }
    return dist<de ? vec3(k, iter, minDist) : vec3(-1.0, iter, minDist);
}

vec3 getNormal(vec3 p, float radius, int count, float roundness, float angle) {
    float d = 0.0001;
    float d2 = d*2.0;
    return normalize(vec3(
        (implicitFn(vec3(p.x-d, p.y, p.z), radius, count, roundness, angle)-implicitFn(vec3(p.x+d, p.y, p.z), radius, count, roundness, angle))/d2,
        (implicitFn(vec3(p.x, p.y-d, p.z), radius, count, roundness, angle)-implicitFn(vec3(p.x, p.y+d, p.z), radius, count, roundness, angle))/d2,
        (implicitFn(vec3(p.x, p.y, p.z-d), radius, count, roundness, angle)-implicitFn(vec3(p.x, p.y, p.z+d), radius, count, roundness, angle))/d2
        ));
}

vec3 rayMarch(vec3 p0, vec3 dir, float side, float radius, int count, float roundness, float angle) {
    float d = implicitFn(p0, radius, count, roundness, angle);
    float s = sign(d);
    float totalD = 0.0;
    int step = 0;
    while (step < 1000 && d<100.) {
        totalD += d*side;
        vec3 p = p0 + totalD*dir;
        d = implicitFn(p, radius, count, roundness, angle);
        if (abs(d)<0.0001) return p;
        ++step;
    }
    return vec3(INF);
}

vec2 tf(mat3 m, vec2 u) {
    return (m * vec3(u, 1.)).xy;
}

        vec4 torusMap(vec2 pos, vec2 outPos, float radius, float angle, int count, float roundness, float blend, vec4 colorFog, vec4 sourceColor, vec4 ambientColor, vec2 sourceDim, int backgroundStyle, float specular, mat4 model3DTransform, mat3 texTransform, mat4 lightSourceTransform) {
            vec4 backgroundColor = vec4(0.0, 0.0, 0.0, 1.0);
            mat3 invTt = inverse(texTransform);
              
            vec3 lightPos = (lightSourceTransform * vec4(0.0, 0.0, 0.0, 1.0)).xyz;
          
            float D = 1.6666666666666667;
            vec3 cameraPos = vec3(0., 0., 0.);
//            cameraPos = mat3(model3DTransform) * cameraPos;
            mat4 m = inverse(model3DTransform);
            cameraPos = (m * vec4(cameraPos, 1.)).xyz;
            vec3 dir = normalize(vec3(pos.x*D, pos.y*D, -1.0));
            dir = normalize(mat3(m) * dir);
        
            vec3 origin = cameraPos;
//            float angle = 0.0;
            vec3 inters = getIntersectionD(origin, dir, radius, count, roundness, angle);
            //vec3 inters = rayMarch(origin, dir, 1.0, radius, count, roundness, angle);
        
            float k = inters.x;
            //if (k>0.0) return vec4(1.0-inters.z, inters.y/100.0, k * 0.1, 1.0); // debug
        
            float ratio = sourceDim.x/sourceDim.y;
            blend = blend*0.5;
            float width = ratio*(1.0-blend);
            float height = 1.0-blend;
            float bWidth = width - ratio*blend;
            float bHeight = height - blend;
        
            if (k>0.0) {
        
                vec3 intersection = origin + k*dir;
        
                float R = 0.5;
                float r = R*radius*2.0;
                float x = atan(intersection.x, intersection.z) / PI * width;
                float a = sqrt(intersection.x*intersection.x + intersection.z*intersection.z) - R;
                float y = atan(a, -intersection.y) / PI * height;
        
                vec4 col;
                if (blend == 0.0) col = __source__(tf(invTt, vec2(x, y)));
                else {
                    vec2 u00 = tf(invTt, vec2(x, y));
                    vec2 u10 = tf(invTt, vec2(x-sign(x)*(ratio+bWidth), y));
                    vec2 u01 = tf(invTt, vec2(x, y-sign(y)*(1.0+bHeight)));
                    vec2 u11 = tf(invTt, vec2(x-sign(x)*(ratio+bWidth), y-sign(y)*(1.0+bHeight)));
                    col = mix(
                        mix(__source__(u00), __source__(u10), smoothstep(0.0, 2.0*blend*ratio, abs(x)-bWidth)),
                        mix(__source__(u01), __source__(u11), smoothstep(0.0, 2.0*blend*ratio, abs(x)-bWidth)),
                        smoothstep(0.0, 2.0*blend, abs(y)-bHeight)
                    );
                }
        
                float dist = length(origin-intersection);
                float fog = getFog(dist, colorFog.a);
                vec3 normal = getNormal(intersection, radius, count, roundness, angle);
                vec3 lightDir = normalize(intersection-lightPos);
                vec3 colorWithLight = col.rgb * (ambientColor.rgb + max(0.0, dot(normal, lightDir))*sourceColor.rgb);
                if (specular>0.0) {
                    vec3 reflectDir = reflect(dir, normal);
                    float kSpec = 10.0 * specular * pow(max(0.0, dot(-lightDir, reflectDir)), 9.0);
                    colorWithLight.rgb += sourceColor.rgb * kSpec;
                }
                return vec4(mix(colorWithLight.rgb, colorFog.rgb, fog), col.a);
            }
            else {
                vec4 col = vec4(0.0, 0.0, 0.0, 1.0); //background(dir);
                if (backgroundStyle==0) {
    vec3 _o_n = normalize(dir);
    float _o_alpha = atan(_o_n.z, _o_n.x);
    float _o_beta = asin(_o_n.y);
    float _o_ratio = sourceDim.x/sourceDim.y;
    float _o_nX = 2.0;
    float _o_nY = 1.0;
    col = __source__(vec2(-_o_alpha/PI*0.5*_o_nX, 0.5+_o_nY*_o_beta/PI));
}
else if (backgroundStyle==1) {
    vec2 _o_pos = vec2(-(dir).x/(dir).z , -(dir).y/(dir).z)*1.0 ;
    float _o_m = max(abs(_o_pos.x), abs(_o_pos.y));
    float _o_darken = 4.0/max(4.0, _o_m);
    col = __source__(_o_pos)*vec4(_o_darken, _o_darken, _o_darken, 1.0);
}
else if (backgroundStyle==2) {
    float _o_ratio = sourceDim.y/sourceDim.x;
    float _o_X = 0.5;
    float _o_Y = 0.5;
    if (abs((dir).y)>abs((dir).z)*_o_ratio && abs((dir).y)>abs((dir).x)*_o_ratio) {
        _o_X += -(dir).x/(dir).y*0.5;
        _o_Y += -(dir).z/(dir).y*0.5;
    }
    else if (abs((dir).x)<abs((dir).z)) {
        _o_X += (dir).x/abs((dir).z)*_o_ratio*0.5 * -sign((dir).z);
        _o_Y += (dir).y/abs((dir).z)*0.5;
    }
    else {
        _o_X += (dir).z/abs((dir).x)*_o_ratio*0.5 * -sign((dir).x);
        _o_Y += (dir).y/abs((dir).x)*0.5;
    }
    col = __source__(vec2(_o_X, _o_Y));
}
else if (backgroundStyle==3) {
    col = vec4((dir)*0.5+0.5, 1.0);
}
else if (backgroundStyle==4) {
    col = vec4(0.0, 0.0, 0.0, 1.0);
}
else {
    col = vec4(0.0);
}
                float dist = 2.0;
                float fog = clamp(getFog(dist, colorFog.a), 0.0, 1.0);
                return vec4(mix(col.rgb, colorFog.rgb, fog), col.a);
            }
        }

void main() {
    fragColor = torusMap((inverse(u_viewTransform) * vec3(((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), 1.0)).xy, ((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), u_radius, u_angle, u_count, u_roundness, u_blend, u_colorFog, u_sourceColor, u_ambientColor, u_sourceDim, u_backgroundStyle, u_specular, u_model3DTransform, u_texTransform, u_lightSourceTransform);
}
