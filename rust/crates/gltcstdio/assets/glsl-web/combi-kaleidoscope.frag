#version 450
layout(location = 0) in vec2 v_uv;
layout(location = 0) out vec4 fragColor;

layout(binding = 0, std140) uniform Params {
    vec4 U[25];
};
layout(binding = 1) uniform sampler samp;
layout(binding = 2) uniform texture2D t_source1;
layout(binding = 3) uniform texture2D t_source2;

#define u_source1 sampler2D(t_source1, samp)
#define u_source2 sampler2D(t_source2, samp)
#define u_worldAspect (U[0].x)
#define u_viewTransform (mat3(U[1].xyz, U[2].xyz, U[3].xyz))
#define u_source2_specified (int(U[4].x))
#define u_outDim (U[5].xy)
#define u_spikeCount (int(U[6].x))
#define u_border (U[7].x)
#define u_shadows (U[8].x)
#define u_borderColor (U[9])
#define u_colorShadow (U[10])
#define u_blend (U[11].x)
#define u_transformPairing (int(U[12].x))
#define u_shape (U[13].x)
#define u_modelTransform (mat3(U[14].xyz, U[15].xyz, U[16].xyz))
#define u_modelTransform2 (mat3(U[17].xyz, U[18].xyz, U[19].xyz))
#define u_borderTransform (mat3(U[20].xyz, U[21].xyz, U[22].xyz))
#define u_offset (U[23].x)
#define u_stretch (U[24].x)

#define __source1__texelFetch__(c) texelFetch(u_source1, (c), 0)
#define __source1__(p) textureLod(u_source1, __mirror_wrap__(vec2((p).x / u_worldAspect, (p).y) / 2.0 + 0.5), 0.0)
#define __source2__texelFetch__(c) texelFetch(u_source2, (c), 0)
#define __source2__(p) textureLod(u_source2, __mirror_wrap__(vec2((p).x / u_worldAspect, (p).y) / 2.0 + 0.5), 0.0)




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

vec4 mergeColor(vec4 bkg, vec4 front) {
    return vec4(mix(bkg.rgb, front.rgb, front.a + (1.0-bkg.a)*(1.0-front.a)), max(bkg.a, front.a));
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

float sdVesica(vec2 u, float r, float d) {
    u = abs(u);
    float b = sqrt(r*r - d*d);
    return ((u.y - b)*d > u.x*b) ? length(u - vec2(0.0,b)) : length(u - vec2(-d,0.0))-r;
}

float shapeSdf(vec2 u, int spikeCount, float shape) {
    spikeCount = max(3, spikeCount);
    
    float k = fract(shape);
    float radius = 0.66666;
    float starMul = 0.9/radius;
    if (shape<1.0) {
        float d1 = length(u) - radius;
        float d2 = sdStar(vec2(u.x, -u.y)*starMul, spikeCount, 1.0, 2.0);
        return mix(d1, d2, k);
    } 
    else if (shape<2.0) {
        float kk = k*0.75;
        float m = 2.0 + kk*kk*(float(spikeCount)-2.0);
        return sdStar(vec2(u.x, -u.y)*starMul, spikeCount, 1.0, m);
    }
    else if (shape<3.0) {
        float m = 2.0 + 0.75*0.75* (float(spikeCount)-2.0);
        float d1 = sdStar(vec2(u.x, -u.y)*starMul, spikeCount, 1.0, m);
        float d2 = sdVesica(u*0.75, radius, radius*0.5);
        return mix(d1, d2, k);
    }
    else {
        k = shape - 3.;
        float d1 = sdVesica(u*0.75, radius, radius*0.5);;
        float d2 = length(u) - radius;
        return mix(d1, d2, k);
    
    }
}

vec2 tf(mat3 m, vec2 u) {
    return (m * vec3(u, 1.)).xy;
}

vec4 combiKaleidoscope(vec2 uv, vec2 outPos, int source2_specified, int spikeCount,
    float border, float shadows, vec4 borderColor, vec4 colorShadow, float blend,
    int transformPairing,
    float shape, mat3 modelTransform, mat3 modelTransform2, mat3 borderTransform, float offset, float stretch) {
    
    vec2 u = uv;
    float a = abs(atan(u.x, u.y));
    float period = PI2 / float(spikeCount);
    float halfPeriod = period * 0.5;
    float index = floor(a/period);
    a = mod(a, period);
    if (a>halfPeriod) {
        a = period - a;
        a = mix(offset*(index+1.0), halfPeriod+offset*(index+1.0), a/halfPeriod);
    }
    else {
        a = mix(offset*index, halfPeriod+offset*(index+1.0), a/halfPeriod);
    }
    
    vec2 bu = tf(inverse(borderTransform), u);
    float dist = shapeSdf(bu, spikeCount, shape);
    bool inside = dist<0.0;
   
    vec4 outColor;            
    float d = length(u);
    u = d*vec2(cos(a), sin(a));
    
    vec2 u1 = (inverse(modelTransform) * vec3(u, 1.0)).xy  * pow(2., -stretch*max(0., d));
    mat3 transform2 = transformPairing==0 ? modelTransform2 : modelTransform*modelTransform2;
    vec2 u2 = (inverse(transform2) * vec3(u, 1.0)).xy  * pow(2., -stretch*max(0., d));
        
    if (blend==0.0) {
        outColor = inside ? __source1__(u1) : (source2_specified!=1) ? __source1__(u2) : __source2__(u2);
    }
    else {
        vec4 c1 = __source1__(u1);
        vec4 c2 = (source2_specified!=1) ? __source1__(u2) : __source2__(u2);
        float bk = smoothstep(-blend, blend, dist);
        outColor = mix(c1, c2, bk);
    }

    float adist = abs(dist);
    if (adist < border*0.1) outColor = mergeColor(outColor, borderColor);
    else if (adist<abs(shadows)) {
        float ds = (shadows<0.0 && inside && dist>shadows) || (shadows>0.0 && !inside && dist<shadows) ? abs(dist)/abs(shadows) : 1.0;
        
        outColor = mergeColor(outColor, vec4(colorShadow.rgb, colorShadow.a * 0.8f * smoothstep(1.0, 0.0, ds)));
    }

    return outColor;
}

void main() {
    fragColor = combiKaleidoscope((inverse(u_viewTransform) * vec3(((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), 1.0)).xy, ((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), u_source2_specified, u_spikeCount, u_border, u_shadows, u_borderColor, u_colorShadow, u_blend, u_transformPairing, u_shape, u_modelTransform, u_modelTransform2, u_borderTransform, u_offset, u_stretch);
}
