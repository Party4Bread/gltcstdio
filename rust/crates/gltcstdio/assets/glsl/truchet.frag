#version 450
layout(location = 0) in vec2 v_uv;
layout(location = 0) out vec4 fragColor;

layout(binding = 0, std140) uniform Params {
    vec4 U[12];
    ivec4 u_types[16];
};
layout(binding = 1) uniform sampler samp;
layout(binding = 2) uniform texture2D t_source;

#define u_source sampler2D(t_source, samp)
#define u_worldAspect (U[0].x)
#define u_viewTransform (mat3(U[1].xyz, U[2].xyz, U[3].xyz))
#define u_source_specified (int(U[4].x))
#define u_outDim (U[5].xy)
#define u_color1 (U[6])
#define u_color2 (U[7])
#define u_distribution (U[8].x)
#define u_regularity (U[9].x)
#define u_types_size (int(U[10].x))
#define u_levels (int(U[11].x))

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













































































































































































































































































































































































int hash(int a, int b) {
    return (a + b) * (a + b + 1) / 2 + a;
}

int hashmore(int i, int j, float regularity) {
    float x = float(i);
    float y = float(j);
    int h = int(fract(sin(x*12.9898+y*78.233) * (x/(mod(y, 1000.0)+1.0)+458.5453))*1000.0);
    if (regularity==0.0) return h;
    return (mod(float(hash(i,j)), 100.0)>=regularity*100.0) ? h : (i+j)*50;
}

int getLevel(int i, int j, float distribution, float regularity, int levels) {
    float d = distribution;
    float k = pow(100.0/d, 1.0/float(levels));
    float div = pow(2.0, float(levels));
    while (levels>=1) {
        vec2 F = vec2(float(i-(i<0?int(div)-1:0)), float(j-(j<0?int(div)-1:0)))/div;
        int I = int(F.x);
        int J = int(F.y);
	    if (mod(float(hashmore(I+11, J+14, regularity)), 100.0) > d) return levels;
        d /= k;
        div /= 2.0;
        --levels;
    }
    return 0;
}

int getType(int i, int j, int types_size, float regularity) {
    return int(u_types[int(mod(float(hashmore(i, j, regularity)), float(types_size)))].x);
}

vec4 mergeColor(vec4 bkg, vec4 front) {
    return vec4(mix(bkg.rgb, front.rgb, front.a + (1.0-bkg.a)*(1.0-front.a)), max(bkg.a, front.a));
}

bool inWing(vec2 pos, vec2 center, float ox, float oy, float r2) {
    vec2 delta = pos - vec2(center.x+ox, center.y+oy);
    return dot(delta, delta) < r2;
}

int minWing(int wing, vec2 pos, int i, int j, float distribution, float regularity, int levels) {
    int mLevel = getLevel(i, j, distribution, regularity, levels);
    int W = wing;
    //for(int level = wing-1; level>=mLevel; --level) {
    for(int level = mLevel; level<W; ++level) {
        float len = 1.0;
        float halflen = len/2.0;
        float exp = pow(2.0, float(level));
        vec2 center = vec2(floor(float(i)/exp) + halflen, floor(float(j)/exp) + halflen);
        float radius = len/3.0;
		vec2 ppos = pos / exp; //float(1<<level);

        if (max(abs(ppos.x-center.x), abs(ppos.y-center.y)) <= halflen+radius) {

            //float radius2 = radius*radius;
            vec2 rel = ppos-center;
            vec2 wingc = sign(rel)*halflen;
            if (wingc.x!=0.0 && wingc.y!=0.0) {
                vec2 delta = rel-wingc;
                //wing = dot(delta, delta) < radius2 ? level :wing;
                if (length(delta) < radius) return level;
            }
            /*wing = (inWing(ppos, center, -halflen, -halflen, radius2)
                || inWing(ppos, center, -halflen, halflen, radius2)
                || inWing(ppos, center, halflen, -halflen, radius2)
                || inWing(ppos, center, halflen, halflen, radius2) ) ? level : wing;*/

            /*wing = ((length(ppos - (center+vec2(-halflen, -halflen))) < radius)
    || (length(ppos - (center+vec2(-halflen, halflen))) < radius)
    || (length(ppos - (center+vec2(halflen, -halflen))) < radius)
    || (length(ppos - (center+vec2(halflen, halflen))) < radius) ) ? level : wing;*/
            /*
            if (length(ppos - (center+vec2(-halflen, -halflen))) < radius) return level;
            else if (length(ppos - (center+vec2(-halflen, halflen))) < radius) return level;
            else if (length(ppos - (center+vec2(halflen, -halflen))) < radius) return level;
            else if (length(ppos - (center+vec2(halflen, halflen))) < radius) return level;*/
       	}
    }

    return wing;
}

bool in2ThirdCircle(float cx, float cy, vec2 u) {
 	return length(vec2(cx, cy)-u)<=0.33333333 ;
}

bool inThirdCircle(float cx, float cy, vec2 u) {
 	return length(vec2(cx, cy)-u)<=0.16666666 ;
}

bool inThirds(float d) {    
    return d>=THIRD && d<=TWO_THIRDS;
}

bool truchetTile(vec2 u, int type) {
    if (type==1) return inThirds(length(vec2(0.0, 1.0) - u)) || inThirds(length(vec2(1.0, 0.0) - u));
   	//else if (type==2) return inThirds(u.x) || inThirds(u.y);
   	else if (type==2) return !in2ThirdCircle(0.0, 0.0, u) && !in2ThirdCircle(1.0, 0.0, u) && !in2ThirdCircle(0.0, 1.0, u) && !in2ThirdCircle(1.0, 1.0, u);
    else if (type==3) return inThirdCircle(0.0, 0.5, u) || inThirdCircle(1.0, 0.5, u) || inThirdCircle(0.5, 0.0, u) || inThirdCircle(0.5, 1.0, u);
    else return inThirds(length(u)) || inThirds(length(vec2(1.0, 1.0) - u));
}

vec4 multiLevelTruchet(vec2 pos, vec2 outPos, int source_specified, vec4 color1, vec4 color2, float distribution, float regularity, int types_size, int levels) {
//if (0==0) return vec4(1., 0., 0., 1.); // causes crash on android!
    vec2 ipos = floor(pos);
    int i = int(ipos.x);
    int j = int(ipos.y);

    int level = getLevel(i, j, distribution, regularity, levels);
    int exp = int(pow(2.0, float(level)));
    int I = (i-(i<0?exp-1:0))/exp;
    int J = (j-(j<0?exp-1:0))/exp;
    int type = getType(I, J, types_size, regularity);
    float scaling = pow(2.0, float(level)); //float(1 << level);
    bool negative = (level - (level/2)*2 == 1); //level%2==1;

    vec2 scPos = pos/scaling;
    vec2 relPos = fract(scPos);

    float k = truchetTile(relPos, type) ? 1.0 : 0.0;
    if (negative) k = 1.0-k;

    // test wing
    int wing = level;
    if (level>=1 && max(abs(relPos.x-0.5), abs(relPos.y-0.5)) > 0.333333) {
        int N = int(pow(2.0, float(level-1))); //(1 << (level-1));
        for(int jj=j-N; jj<=j+N; ++jj) {
            for(int ii=i-N; ii<=i+N; ++ii) {
                wing = minWing(wing, pos, ii, jj, distribution, regularity, levels);
            }
        }
        if (wing<level) {
            k = (wing - (wing/2)*2)==0 ? 0.0 : 1.0; //k = wing%2==0 ? 0.0 : 1.0;
        }

    }

    vec4 outColor = mix(color1, color2, k);
    if (source_specified==1) return mergeColor(__source__(outPos), outColor);
    else return outColor;    
}

void main() {
    fragColor = multiLevelTruchet((inverse(u_viewTransform) * vec3(((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), 1.0)).xy, ((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), u_source_specified, u_color1, u_color2, u_distribution, u_regularity, u_types_size, u_levels);
}
