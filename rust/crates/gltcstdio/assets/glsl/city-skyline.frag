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
#define u_source_specified (int(U[4].x))
#define u_outDim (U[5].xy)
#define u_color1 (U[6])
#define u_color2 (U[7])
#define u_color3 (U[8])
#define u_color4 (U[9])
#define u_count (int(U[10].x))
#define u_randomSeed (U[11].x)
#define u_blur (U[12].x)
#define u_height (U[13].x)
#define u_reflectivity (U[14].x)
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



















































































































































































































































































































































































vec4 blend(int mode, vec4 a, vec4 b) {
    vec3 aa = a.rgb;
    vec3 bb = b.rgb;
    vec3 cc;
    { int _sw_sel = int(mode);
if (_sw_sel == int(1)) { cc = aa + bb; }
else if (_sw_sel == int(2)) { cc = aa * bb; }
else if (_sw_sel == int(3)) { cc = aa - bb; }
else if (_sw_sel == int(4)) { cc = abs(aa - bb); }
else if (_sw_sel == int(5)) { cc = aa / bb; }
else if (_sw_sel == int(10)) { return max(a, b); }
else if (_sw_sel == int(11)) { return min(a, b); }
else { return b; }
}
    return vec4(cc, mix(a.a, b.a, 0.5));
}

vec4 blend(vec4 a, vec4 b) {
    return vec4(mix(vec3(a), vec3(b), b.a), max(a.a, b.a));
}

float eqTriangleDist(vec2 p, float r) {
    vec2 n = vec2(-0.8660254, 0.5);
    p.y = abs(p.y);
    float d = dot(p, n);
    if (d>0.0) {
        p -= 2.0*d*n;
    }
    //p.y = abs(p.y);
    float Y = r*0.8660254;
    return sign(p.x-r) * length(p-vec2(r, clamp(p.y, -Y, Y)));
}

float lineDist(vec2 p, vec2 a, vec2 b) {
    vec2 pa = p-a;
    vec2 ba = b-a;
    float t = clamp(dot(pa, ba)/dot(ba, ba), 0.0, 1.0);
    return length(pa - ba*t);
}

float catDist(vec2 u) {
    float c = 100000.0;
    u += vec2(-0.015, 0.03);
    float hr = 0.005;
    c = min(c, length(u)-hr); // head
    vec2 earL = vec2(0.003, -0.0035);
    vec2 earR = vec2(-0.003, -0.0035);
    c = min(c, eqTriangleDist(-(u+earL), 0.002));
    c = min(c, eqTriangleDist(u+earR, 0.002));
    u.y += 0.0125;
    float br = 0.01;
    c = min(c, length(u*vec2(1.3+u.y*15.0, 1.0))-br); // body
    u += 0.007;
    float tr = 0.0015;
    c = min(c, lineDist(u, vec2(-hr, 0.0), vec2(br, 0.0))-tr); // tail
    return c;
}

vec2 rand2rel(vec2 co) {
    float x = fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
    float y = fract(sin(dot(vec2(x, co.x) ,vec2(12.9898,78.233))) * 43758.5453);
    return vec2(x, y)-vec2(0.5, 0.5);
}

float getHeight(float i, float height) {
    vec2 rnd = rand2rel(vec2(i, i)) + 0.5;
    float h = 1.0+rnd.x*10.0;
    float growth = smoothstep(0.5, 1.0, pow(rnd.y, 10.0-9.0*+height));
    float boost = 1.0+2.0*smoothstep(0.9, 1.0, rnd.x*rnd.y);
    h += height*growth*boost*25.0;
    return h;
}

float mergeRect(float a, float dist, float blur) {
    return max(smoothstep(blur, 0.0, dist), a);
}

float rand21alt(vec2 u) {
    return rand2rel(u).x*2.0; //(2.0*fract((fract(u.x*113.237+10.4343+u.y)+23.773+10.565*u.y-u.x)*434.4438))-1.0;
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

float rectDist(vec2 p, float width, float height) {
    p = abs(p);
    return length(p-vec2(clamp(p.x, 0.0, width/2.0), clamp(p.y, 0.0, height/2.0)));
}

vec4 layer(vec2 u, vec4 color, vec4 windowColor, vec4 columnColor, float blur, float ht, float seed, float lights, float columns) {
    float a = smoothstep(blur, 0.0, u.y);
    vec2 id = floor(u);
    float height = getHeight(id.x, ht);
    float height1 = getHeight(id.x-1.0, ht);
    float height2 = getHeight(id.x+1.0, ht);
    vec2 v = fract(u);
    vec4 col = color;
    vec2 rnd = rand2relSeeded(id.xx*0.11, seed)*2.0;
    float occupied = sign(rnd.x+lights)*rnd.x*rnd.x*lights;

    float lightColumn = 0.0;

    if (u.y>0.0 && u.y<height/2.0) { // windows
        vec2 wRatio = vec2(5.0, 3.0);
        vec2 v = (u-vec2(0.0, height/2.0)+0.5)*wRatio;
        vec2 id = floor(v+0.5);
        float windowSize = 0.3-blur;
        float rndW = abs(rand21alt(id));
        if (id.y>-height/2.0*3.0+3.0 && abs(rndW)<occupied*1.0*lights) {
            float catDistance = fract(rndW*10.0)>0.99 ? 3.0*catDist((v-id)/wRatio) : 10000.0;
            //float blDist = fract(rndW*rndW)>0.2 ? 3.0*blindsDist((v-id)/wRatio, 8.0-fract(rndW*30.0)*15.0) : 10000.0;
            float windowLight = smoothstep(blur*3.0, 0.0, max(-catDistance, rectDist(v-id, windowSize, windowSize)));
            col = mix(col, windowColor, clamp(windowLight, 0.0, 1.0));
        }
    }
    else if (height<2.0 && u.y>height/2.0 && abs(rnd.y)>1.0-columns) { // column
        lightColumn = 20.0/(10.0+max(0.0, u.y-height))*0.5*smoothstep(0.5, 0.3, abs(u.x-floor(u.x)-0.5));
    }

    a = max(smoothstep(blur, 0.0, rectDist(u-vec2(id.x+0.5, 0.0), 1.0, height)), a);
    a = max(smoothstep(blur, 0.0, rectDist(u-vec2(id.x-0.5, 0.0), 1.0, height1)), a);
    a = max(smoothstep(blur, 0.0, rectDist(u-vec2(id.x+1.5, 0.0), 1.0, height2)), a);

    if (height>11.0) { // antenna
        if (rnd.y<0.3) {
            a = mergeRect(a, rectDist(u-vec2(id.x+0.5, 0.0), 0.125-blur, height+4.0), blur);
            if (rnd.x>0.9) {
                a = max(smoothstep(blur, 0.0, catDist(u-vec2(id.x+0.5+(rnd.y*0.04), (height+4.0)/2.0+0.051))), a);
                //a = max(smoothstep(0.5, 0.1, length(u-vec2(id.x+0.5, (height+4.0)/2.0))), a);
            }
        }
        else if (rnd.y<0.45) {
            a = mergeRect(a, rectDist(u-vec2(id.x+0.75, 0.0), 0.125-blur, height+3.0), blur);
            a = mergeRect(a, rectDist(u-vec2(id.x+0.25, 0.0), 0.125-blur, height+3.0), blur);
        }
    }

    //col.rg = abs(rand2relSeeded(id.xx*0.11, seed)+0.5);

    return vec4(col.rgb, a) + 2.5*lightColumn*columnColor;//vec4(columnColor.rgb, lightColumn);
}

vec4 mergeColor(vec4 bkg, vec4 front) {
    return vec4(mix(bkg.rgb, front.rgb, front.a + (1.0-bkg.a)*(1.0-front.a)), max(bkg.a, front.a));
}

float rand11(float x) {
    return rand2rel(vec2(x, x)).x*2.0; //(2.0*fract((fract(x*172.237-271.4143)+23.773)*434.74438))-1.0;
}

float stars(vec2 u, float seed) {
    u *= 100.0;
    vec2 id = floor(u);
    vec2 rnd = rand2relSeeded(id, seed);
    float r = abs(rnd.x+rnd.y);
    vec2 delta = rnd*0.35;
    float radius = pow(r, 30.0)*0.5;
    return radius<=0.0 ? 0.0 : smoothstep(radius, 0.0, length(u-id-0.5+delta));
}

vec4 citySkyline(vec2 uv, vec2 outPos, int source_specified, vec4 color1, vec4 color2, vec4 color3, vec4 color4, int count, float randomSeed, float blur, float height, float reflectivity, mat3 modelTransform) {
    uv = -uv;

    float lights = (sin((randomSeed-12.0)*0.3)*0.6+0.4);
    lights = max(0., lights);
    lights *= lights;
    
    float columns = (sin((randomSeed-12.0)*0.7)*0.8+0.2);
    columns = max(0., columns);
    columns *= columns;
            
    blur = max(0.0001, blur)*0.2;
    
    vec4 sunColor = color1;
    vec4 buildingColor = color2;
    vec4 skyColor = color3;
    vec4 windowColor = color4;
    vec4 warmSkyColor = mix(sunColor, skyColor, 0.5);
    float panningSpeed = 8.0;

    // Normalized pixel coordinates (from 0 to 1)
    float Y = 0.0;
    mat3 inverseModelTransform = inverse(modelTransform);
    vec2 panning = vec2(inverseModelTransform[2][0], inverseModelTransform[2][1])*1.0;
    float cameraScale = length(vec2(inverseModelTransform[0][0], inverseModelTransform[0][1]));

    float reflected = 0.0;
    float reflectY = -(Y+panning.y*panningSpeed)/4.0/cameraScale;
    if (uv.y<reflectY) {
        uv.y = 2.0*reflectY - uv.y;
        reflected = 1.0-reflectivity*0.01;
    }

    vec4 bkg = mix(warmSkyColor, skyColor, clamp(uv.y*2.0-0.25, 0.0, 1.0));
    float skyDamp = smoothstep(0.3, 0.05, (bkg.r+bkg.g+bkg.b)*0.333);
    float cloudDamp = 1.0;

    bkg = mix(bkg, windowColor*2.0, stars(uv, randomSeed)*skyDamp*cloudDamp);

    float sunDist = smoothstep(0.275+blur*0.2, 0.275-blur*0.2, length(uv));
    bkg = mix(bkg, sunColor, sunDist*cloudDamp);

    uv*=cameraScale;

    vec4 color = bkg;


    float N = float(count);
    for(float i=N; i>0.0; --i) {
        float layerRatio = N==1.0?0.0:(i-1.0)/(N-1.0);
        vec4 building = mix(buildingColor, warmSkyColor, layerRatio);
        vec4 window = mix(windowColor, warmSkyColor, layerRatio);
        vec4 column = vec4(mix(windowColor, warmSkyColor, layerRatio*0.3).rgb, max(0.0, 0.6-layerRatio));
        float scale = 2.0+2.0*i;
        float offset = 415.24*rand11(i);
        color = blend(color, layer(
        uv*scale + vec2(offset, Y) + panning*panningSpeed, //vec2(offset+panning.x*panningSpeed, Y+panning.y*panningSpeed),
        building,
        window,
        column,
        blur, 
        height,
        randomSeed,
        lights,
        columns));
    }

    vec4 outColor = mix(color, buildingColor, reflected);
    if (source_specified==1) return mergeColor(__source__(outPos), outColor);
    else return outColor;
}

void main() {
    fragColor = citySkyline((inverse(u_viewTransform) * vec3(((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), 1.0)).xy, ((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), u_source_specified, u_color1, u_color2, u_color3, u_color4, u_count, u_randomSeed, u_blur, u_height, u_reflectivity, u_modelTransform);
}
