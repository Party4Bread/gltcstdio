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
#define u_source_specified (int(U[4].x))
#define u_outDim (U[5].xy)
#define u_modelTransform (mat3(U[6].xyz, U[7].xyz, U[8].xyz))
#define u_color1 (U[9])
#define u_color2 (U[10])
#define u_randomSeed (U[11].x)
#define u_regularity (U[12].x)
#define u_thickness (U[13].x)
#define u_roundness (U[14].x)

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


















































































































































































































































































































































float hash21(vec2 p) {
    vec2 a = fract(-45.3277*p.xy);
    vec2 b = a + dot(a, a+123.3371);
	return fract(b.x*b.y);  
}

float hash4(vec2 id, vec2 id2, float regularity, vec4 vecSeed) {
    vec2 ida = min(id, id2);
    vec2 idb = max(id, id2);
	float a = fract(dot(ida+23.23, idb.yx*10.2232) + (((ida.x==id.x && ida.y==id.y) || (ida.x==id2.x && ida.y==id2.y)) ? 123.32 : -123.55));
    float b = fract(a + ida.x*232.23 - idb.y*777.77);
    float irreg = fract(a*5.22 + b + a*b*23.77 + 99.9);
    float reg = fract(dot(vec4(ida, idb), vecSeed));//ida.x*vec+ida.y*0.2 + idb.x*0.3+idb.y*0.5);
    return mix(irreg, reg, regularity);
}

vec4 mergeColor(vec4 bkg, vec4 front) {
    return vec4(mix(bkg.rgb, front.rgb, front.a + (1.0-bkg.a)*(1.0-front.a)), max(bkg.a, front.a));
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

float sdDisk(vec2 u, float r) {
    return length(u)-r;
}

float sdSegment(vec2 u, vec2 a, vec2 b) {
    vec2 ua = u-a;
    vec2 ba = b-a;
    float h = clamp(dot(ua, ba)/dot(ba, ba), 0., 1.);
    return length(ua - ba*h);
}

vec4 circuit(vec2 pos, vec2 outPos, mat3 modelTransform, int source_specified, vec4 color1, vec4 color2, float randomSeed, float regularity, float thickness, float roundness) {
    vec2 uv = pos;

    vec4 vecSeed = vec4(rand2relSeeded(vec2(0.0, 0.0), randomSeed-8.0), rand2relSeeded(vec2(0.5212, 10.0), randomSeed-8.0));
    vec2 rnd = rand2relSeeded(vec2(1.0, 2.0), (randomSeed-8.0)*0.3);
    float density = 0.55 + rnd.x*0.6;
    float diagonals = (1.0-pow(rnd.y+0.5, 10.0))*0.5;

    float D = 1e9;
    for(float Y=-1.0; Y<=1.0; ++Y) {
        for(float X=-1.0; X<=1.0; ++X) {

            vec2 id = floor(uv)+vec2(X, Y);
    		vec2 u = uv-id-0.5;
            float d = 1e9;
            int count = 0;
            vec2 first, second;
            for(float y=-1.0; y<=1.0; ++y) {
                for(float x=-1.0; x<=1.0; ++x) {
                    if (x!=0.0 || y!=0.0) {
                        //bool on = hash41(id, id+vec2(x, y)) < 0.65-0.24*(abs(x)+abs(y));
                        //bool on = hash4(id, id+vec2(x, y), u_Regularity*0.01, vecSeed) < 0.65-0.32*(abs(x)+abs(y));
                        bool on = hash4(id, id+vec2(x, y), regularity, vecSeed) < density*(1.0-diagonals*(abs(x)+abs(y)));
                        //bool on = hash4(id, id+vec2(x, y)) < 0.4-0.24*(abs(x));
                        //bool on = hash4(id, id+vec2(x, y)) < 0.5;
                        if (count==0) first = vec2(x, y);
                        else if (count==1) second = vec2(x, y);
                        if (on) {
                            ++count;
                            d = min(d, sdSegment(u, vec2(0.0), 0.5*vec2(x, y)));
                        }
                    }
                }
            }
            if (count==1) {
                float l = length(u);
                float cr = rnd.x+0.25>regularity ? 0.25*roundness*ceil(hash21(id)*2.0)/2.0 : 0.25*roundness;
                if (l<cr) d = abs(sdDisk(u, cr));
                else d = min(d, abs(sdDisk(u, cr)));
            }
            else if (count==2 && dot(first, second)==0.0) {
                float cr = 0.5*roundness;
                vec2 c = cr*(first+second);
                //if (abs(u.x)<cr && abs(u.y)<cr) {
                //if (dot(u, first)<cr && dot(u, second)<cr) {
                if (dot(u-c, -first)>=0.0 && dot(u-c, -second)>=0.0) {
                    float radius = sdSegment(c, vec2(0.0, 0.0), first);
                    d = abs(sdDisk(u-c, radius));
                }
            }

            D = min(D, d);
        }
    }

   	//g = smoothstep(0.05, 0.045, d);
   	float thick = 0.15*thickness;
   	float k = smoothstep(thick, thick-0.005, D);

    vec4 outColor = mix(color1, color2, k);
    if (source_specified==1) return mergeColor(__source__(outPos), outColor);
    else return outColor;
}

void main() {
    fragColor = circuit((inverse(u_viewTransform) * vec3(((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), 1.0)).xy, ((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), u_modelTransform, u_source_specified, u_color1, u_color2, u_randomSeed, u_regularity, u_thickness, u_roundness);
}
