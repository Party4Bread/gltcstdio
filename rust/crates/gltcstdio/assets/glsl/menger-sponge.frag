#version 450
layout(location = 0) in vec2 v_uv;
layout(location = 0) out vec4 fragColor;

layout(binding = 0, std140) uniform Params {
    vec4 U[41];
    vec4 u_params[11];
};
layout(binding = 1) uniform sampler samp;
layout(binding = 2) uniform texture2D t_source;
layout(binding = 3) uniform texture2D t_sourceBkg;

#define u_source sampler2D(t_source, samp)
#define u_sourceBkg sampler2D(t_sourceBkg, samp)
#define u_worldAspect (U[0].x)
#define u_viewTransform (mat3(U[1].xyz, U[2].xyz, U[3].xyz))
#define u_sourceDim (U[4].xy)
#define u_sourceBkgDim (U[5].xy)
#define u_sourceBkg_specified (int(U[6].x))
#define u_outDim (U[7].xy)
#define u_iterations (int(U[8].x))
#define u_model3DTransform (mat4(U[9], U[10], U[11], U[12]))
#define u_camera3DTransform (mat4(U[13], U[14], U[15], U[16]))
#define u_lightSourceTransform (mat4(U[17], U[18], U[19], U[20]))
#define u_internal3DTransform (mat4(U[21], U[22], U[23], U[24]))
#define u_mode (int(U[25].x))
#define u_internalIter (int(U[26].x))
#define u_colorScheme (U[27].x)
#define u_thickness (U[28].x)
#define u_variability (U[29].x)
#define u_randomSeed (U[30].x)
#define u_colorSource (U[31])
#define u_colorAmbient (U[32])
#define u_colorFog (U[33])
#define u_colorGlow (U[34])
#define u_backgroundStyle (U[35].x)
#define u_backgroundMode (int(U[36].x))
#define u_specular (U[37].x)
#define u_glow (U[38].x)
#define u_fog (U[39].x)
#define u_gamma (U[40].x)

#define __source__texelFetch__(c) texelFetch(u_source, (c), 0)
#define __source__(p) texture(u_source, __mirror_wrap__(vec2((p).x / u_worldAspect, (p).y) / 2.0 + 0.5))
#define __sourceBkg__texelFetch__(c) texelFetch(u_sourceBkg, (c), 0)
#define __sourceBkg__(p) texture(u_sourceBkg, __mirror_wrap__(vec2((p).x / u_worldAspect, (p).y) / 2.0 + 0.5))




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

















































































































































































































































































































































#define MAX_ITER 200

#define ERR .00005

























// hue rotation about the grey (1,1,1) axis — vivid, luminance-preserving




            


vec2 __mirror_wrap__(vec2 c) {
    return 1.0 - abs(mod(c, 2.0) - 1.0);
}

float getVar(float x, float variability) {
    if (variability>=0.0) return x;
    else return fract(x*3.0);
}

float sawWave2Pi(float x) {
    return abs(mod(0.5-x*0.3183098861, 2.0)-1.) * 2. - 1.;
}

float sdBox( vec3 p, vec3 b ) {
  vec3 q = abs(p) - b;
  return length(max(q,0.0)) + min(max(q.x,max(q.y,q.z)),0.0);
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

float sdTorusSp(vec3 p, vec2 t) {
  vec2 q = vec2(length(p.xz)-t.x,p.y);
  return length(q)-t.y;
}

vec2 getDistAndGlow(vec3 q, int mode, vec4 colorGlow, float thickness, float variability, float randomSeed, vec3 clamper, int iterations, mat4 fractMat, float glowParams[5], int internalIter) {
    vec3 p = q;
 
	float d;
    int shapeMode = mode / 64;
    int shape0 = shapeMode%4;
	if (shape0==0) d = sdBox(p, vec3(1.0, 1.0, 1.0));
	else if (shape0==1) d = length(p)-1.0;
	else if (shape0==2) d = 2.0*sdPyramid(-p*0.5+vec3(0.0, 0.5, 0.0), 1.0);
	else  d = sdTorusSp(p.xzy, vec2(1.0, 0.33));
    shapeMode = shapeMode / 4;

 	if (d>(colorGlow.a>0.0 ? 1.0 : 0.1)) return vec2(d, 0.0);
    float mul = 1.0;
    vec3 reflectNormal = normalize(vec3(-1.0, 1.0, 0.0));

    vec3 offset = vec3(thickness*2., 0.0, 0.0);
    float glowVal = 0.0;
    //int rotN = int(pow(2.0, abs(phase)/PI_2));

    int j = variability<0.0 ? 2 : 1;
    float lowR = variability<0.0 ? 0.1 : 0.0;
    float highR = variability<0.0 ? 0.5 : 0.6;
    float freq1 = 1.0;
    float freq2 = 0.3;
    for(int i=0; i<iterations-1; ++i) {
        if (j==3) j = 0;
        float var = getVar(q[i], variability);

        float dr = 0.1+0.1*sawWave2Pi(randomSeed * freq1);
        float paramix = 0.4 + 0.15*sawWave2Pi(-0.4605539919293922 + randomSeed * freq2);
        float r = clamp(abs(paramix + (i>0 ? dr*variability*var : 0.0)), lowR, highR);
        freq1 *= 1.52;
        freq2 *= 1.42;
        
        vec3 qq = p;

        vec3 size = vec3(1.05, r, r);
        if (i>0) size += clamp(q[i]*variability*clamper*5.0, -1.0, 1.0);
       	offset[j] += clamp(q[i]*variability*dr*(r*15.0), 0.0, 1.0);

	    p = abs(p);

        if (p.y>p.x) p = p - 2.0*dot(reflectNormal, (p-reflectNormal*0.0))*reflectNormal;
        if (p.z>p.x) p = p - 2.0*dot(reflectNormal.xzy, p)*reflectNormal.xzy;

        float d2;
        bool addOrSub = mode%2==0;
        float signD = addOrSub ? -1.0 : 1.0;
        if (shapeMode%2==0) d2 = addOrSub ? -mul*sdBox(p-offset, 1.0*size) : mul*sdBox(p-offset, 1.5*vec3(1.0, r, r));
        else d2 = addOrSub ? -mul*(length(p-offset)-1.0*r) : mul*(length(p-offset)-1.5*r);
        shapeMode /= 2;
        mode /= 2;
        
        if (i<5) glowVal = max(glowVal, 0.01*mul*glowParams[i]/abs(d+signD*d2));
        

        d = max(d, d2);

        if (i<internalIter /*&& phase!=0.0*/) {
        	p = (fractMat*vec4(p, 1.0)).xyz;
        }
        p = (fract((p+r)/(2.0*r))*2.0*r - r)/r;
        mul *= r;
    }

	return vec2(d, glowVal);
}

float getDist(vec3 q, int mode, vec4 colorGlow, float thickness, float variability, float randomSeed, vec3 clamper, int iterations, mat4 fractMat, float glowParams[5], int internalIter) {
    return getDistAndGlow(q, mode, colorGlow, thickness, variability, randomSeed, clamper, iterations, fractMat, glowParams, internalIter).x;
}

vec3 getNormal(vec3 p, int mode, vec4 colorGlow, float thickness, float variability, float randomSeed, vec3 clamper, int iterations, mat4 fractMat, float glowParams[5], int internalIter) {
    float d = 0.0001;
    float d2 = d*2.0;
    return normalize(vec3(
        (getDist(vec3(p.x-d, p.y, p.z), mode, colorGlow, thickness, variability, randomSeed, clamper, iterations, fractMat, glowParams, internalIter)-getDist(vec3(p.x+d, p.y, p.z), mode, colorGlow, thickness, variability, randomSeed, clamper, iterations, fractMat, glowParams, internalIter))/d2,
        (getDist(vec3(p.x, p.y-d, p.z), mode, colorGlow, thickness, variability, randomSeed, clamper, iterations, fractMat, glowParams, internalIter)-getDist(vec3(p.x, p.y+d, p.z), mode, colorGlow, thickness, variability, randomSeed, clamper, iterations, fractMat, glowParams, internalIter))/d2,
        (getDist(vec3(p.x, p.y, p.z-d), mode, colorGlow, thickness, variability, randomSeed, clamper, iterations, fractMat, glowParams, internalIter)-getDist(vec3(p.x, p.y, p.z+d), mode, colorGlow, thickness, variability, randomSeed, clamper, iterations, fractMat, glowParams, internalIter))/d2
        ));
}

vec3 getRay(vec2 uv, vec3 camera, vec3 target, float focalDist) {
    vec3 camZ = normalize(target-camera);
    vec3 camX = normalize(cross(vec3(0.,1.,0.), camZ));
    vec3 camY = cross(camZ,camX);
    return normalize(camZ*focalDist + uv.x*camX + uv.y*camY);
}

float hash3(vec3 u) {
    float k = (dot(u.xy, -u.yz)*644.2834-dot(u.zx, u.xy)*3184.43);
    float l = fract((u.x*u.z*20.01-33.110*u.y*u.x*k+23.32*u.z*u.y+u.x*2.11-u.y*33.454+u.z+k));
    return fract(45.4518*dot(vec3(k, u.xy), vec3(u.zy, l)));
}

vec3 hueRotate(vec3 c, float a) {
    vec3 k = vec3(0.57735027);
    float cosA = cos(a);
    return c*cosA + cross(k, c)*sin(a) + k*dot(k, c)*(1.0 - cosA);
}

float max3(vec3 u) { 
    return max(u.x, max(u.y, u.z));
}

mat3 rayMarch(vec3 origin, vec3 dir, int mode, vec4 colorGlow, float thickness, float variability, float randomSeed, vec3 clamper, int iterations, mat4 fractMat, float glowParams[5], int internalIter) {
	float d = 0.0;
    int i = 0;
    vec3 current = origin;
    float glow = 0.0;
    while (i<MAX_ITER) {
        vec2 distGlow = getDistAndGlow(current, mode, colorGlow, thickness, variability, randomSeed, clamper, iterations, fractMat, glowParams, internalIter);
        float dist = distGlow.x;
        glow = max(glow, distGlow.y);
        if (dist<ERR) break;
        current += dist*dir*0.8;
    	++i;
    }
    if (i>=MAX_ITER) return mat3(vec3(INF), vec3(glow, i, 0.0), vec3(0.0));
    else return mat3(current, vec3(glow, i, 0.0), vec3(0.0));
}

float upStayDown(float x, float a, float b) {
    float c = a+b;
    float d = b-a;
    return clamp(1.0+d*0.5 - abs(x-c*0.5), 0.0, 1.0);
}

        vec4 mengerSponge(vec2 uv, vec2 outPos, int iterations, mat4 model3DTransform, mat4 camera3DTransform, mat4 lightSourceTransform, mat4 internal3DTransform, vec2 sourceDim, vec2 sourceBkgDim, int sourceBkg_specified, int mode, int internalIter, float colorScheme, float thickness, float variability, float randomSeed, vec4 colorSource, vec4 colorAmbient, vec4 colorFog, vec4 colorGlow, float backgroundStyle, int backgroundMode, float specular, float glow, float fog, float gamma) {
            
float D = 1.0;
//vec3 camera = vec3(0., 0., D);
            vec3 camera = vec3(0., 0., 0.);
            camera = ((camera3DTransform) * vec4(camera, 1.)).xyz;

            vec3 target = vec3(0.);
            vec3 camDir = getRay(uv, camera, target, 1.); // no longer used
            
            vec3 lightPos = (lightSourceTransform * vec4(0.0, 0.0, 0.0, 1.0)).xyz;
            mat4 invModelTransform = inverse(model3DTransform);
            mat3 model3DTransform3 = mat3(model3DTransform);
            camera = (invModelTransform * vec4(camera, 1.)).xyz;
            vec3 dir = normalize(vec3(uv.x*D, uv.y*D, -1.0));
            dir = mat3(camera3DTransform) * dir;
            camDir = normalize(mat3(invModelTransform) * dir);

            vec3 cameraPos = camera;
            dir = camDir;
            vec3 origin = cameraPos;

            mat4 fractMat;
            if (internalIter>0) fractMat = inverse(internal3DTransform);
                                                                
            randomSeed -= 0.52;;
        
            vec3 col;
            float COLOR_SCHEMES = 3.0;
            float csRaw = colorScheme;
            colorScheme = colorScheme*(COLOR_SCHEMES-1.0);
            float glowK = glow * 13.0;
            float glowParams[5];
            if (glowK>12.0) {
                float k = glowK - 12.0;
                glowParams[0] = k;
                glowParams[1] = k * 0.5;
                glowParams[2] = k * 0.25;
                glowParams[3] = k * 0.125;
                glowParams[4] = k * 0.06125;
            }
            else if (glowK>4.0) {
                glowParams[0] = upStayDown(glowK, 5.0, 6.0);
                glowParams[1] = upStayDown(glowK, 6.0, 7.0);
                glowParams[2] = upStayDown(glowK, 9.0, 10.0);
                glowParams[3] = upStayDown(glowK, 10.0, 11.0);
                glowParams[4] = upStayDown(glowK, 5.0, 6.0);
            }
            else {
                glowParams[0] = 0.;
                glowParams[1] = 0.;
                glowParams[2] = 0.;
                glowParams[3] = 0.;
                glowParams[4] = 0.;
            }
                
            vec3 clamper = vec3(
                0.1+0.1*sawWave2Pi(randomSeed * 0.76),
                0.1+0.1*sawWave2Pi(randomSeed * 1.1552),
                0.1+0.1*sawWave2Pi(randomSeed * 1.7559) );

        
            mat3 intersectionGlow = rayMarch(origin, dir, mode, colorGlow, thickness, variability, randomSeed, clamper, iterations, fractMat, glowParams, internalIter);
            vec3 intersection = intersectionGlow[0];
            float glowI = intersectionGlow[1].x;
            float glowIterations = intersectionGlow[1].y;
         
            if (intersection.x!=INF) {
                vec3 normal = -getNormal(intersection, mode, colorGlow, thickness, variability, randomSeed, clamper, iterations, fractMat, glowParams, internalIter);
                vec3 lightDir = normalize(lightPos - intersection);
                
                float illum = clamp(dot(normal, lightDir), 0.0, 1.0);
        
                // get color
                if (csRaw < 0.0) {
                    // negative schemes: geometry-derived vivid color (photo-independent)
                    // anchors: 0.0 position | -0.25/-0.5/-0.75 hue-rotated normals | -1.0 depth palette
                    vec3 nc = normal*0.5+0.5;
                    vec3 posCol = abs(intersection.zxy);
                    vec3 cN1 = hueRotate(nc, 2.0943951);
                    vec3 cN2 = hueRotate(nc, 4.1887902);
                    float depth = length(origin - intersection);
                    vec3 depthCol = 0.5 + 0.5*cos(6.2831853*(0.7*depth + vec3(0.0, 0.3333, 0.6667)));
                    float s = -csRaw;
                    if (s < 0.25)      col = mix(posCol, nc, s*4.0);
                    else if (s < 0.5)  col = mix(nc, cN1, (s-0.25)*4.0);
                    else if (s < 0.75) col = mix(cN1, cN2, (s-0.5)*4.0);
                    else               col = mix(cN2, depthCol, (s-0.75)*4.0);
                }
                else if (colorScheme<=1.0) {
                    vec3 col1 = abs(intersection.zxy);
                    vec2 pos2 = vec2(0.0, max3(abs(intersection)*2.0-1.0));
                    vec3 col2 = __source__(pos2).rgb;
//                    col = mix(0.1, 1.0, illum) * mix(col1, col2, colorScheme);
                    col = mix(col1, col2, colorScheme);
                }
                else {
                    vec3 tu = abs(normal.x)>=abs(normal.y) ? normalize(vec3(normal.z, 0.0, -normal.x)) : normalize(vec3(0.0, -normal.z, normal.y));
                    vec3 tv = cross(normal, tu);
                    vec2 pos1 = vec2(0.0, max3(abs(intersection)*2.0-1.0));
                    vec3 col1 = __source__(pos1).rgb;
                    vec2 pos2 = vec2(dot(tu, intersection)+normal.x*2.0, dot(tv, intersection)+normal.y*2.0);
                    vec3 col2 = __source__(pos2).rgb;
                    //col = mix(0.1, 1.0, illum) * mix(col1, col2, colorScheme-1.0);
                    col = mix(col1, col2, colorScheme-1.0);
                }
        
                float light = 1.0;
        
                if ((colorSource.a!=0.0 && (colorSource.r!=0.0 || colorSource.g!=0.0 || colorSource.b!=0.0)) || specular!=0.0) {
                    light = rayMarch(intersection+lightDir*0.01, lightDir, mode, colorGlow, thickness, variability, randomSeed, clamper, iterations, fractMat, glowParams, internalIter)[0].x==INF ? 1.0 : 0.0;
                    col = colorAmbient.rgb*col + light*illum*colorSource.rgb*col;
                }
                else {
                    col = colorAmbient.rgb*col;
                }
        
                float spec = light*clamp(max(specular*0.01-0.5, 0.0) + dot(normalize(reflect(dir, normal)), lightDir), 0.0, 1.0);
                col += specular*colorSource.rgb*0.04*pow(spec, 20.0-specular*0.1);
            }
            else {
                // BACKGROUND
                float BKG_STYLES = 5.0;
                float bkgStyle = backgroundStyle*(BKG_STYLES-1.0);
                vec4 bkgCol; //background(dir).rgb
                if (bkgStyle<=2.0) {
                    bool hasBkg = sourceBkg_specified==1;
                    if (backgroundMode==1) { // planes
                        vec2 sDim = hasBkg ? sourceBkgDim : sourceDim;
                        // NB: no manual aspect scaling on x — __source__/__sourceBkg__ already
                        // normalize x by the source ratio (input space is [-ratio,ratio]x[-1,1]).
                        // The old `* sDim.y/sDim.x` double-compensated (x squished by ratio^2 →
                        // thinner image + horizontal OOB for non-1:1 backgrounds). Matches the
                        // Perspective effect, which samples the raw projected coord.
                        vec2 pos = vec2(-dir.x/dir.z, -dir.y/dir.z);
                        float m = max(abs(pos.x), abs(pos.y));
                        float darken = 4.0/max(4.0, m);
                        bkgCol = (hasBkg ? __sourceBkg__(pos) : __source__(pos)) * vec4(darken, darken, darken, 1.0);
                    }
                    else if (backgroundMode==2) { // box
                        vec2 sDim = hasBkg ? sourceBkgDim : sourceDim;
                        float ratio = sDim.y/sDim.x;
                        float X = 0.5;
                        float Y = 0.5;
                        if (abs(dir.y)>abs(dir.z)*ratio && abs(dir.y)>abs(dir.x)*ratio) {
                            X += -dir.x/dir.y*0.5;
                            Y += -dir.z/dir.y*0.5;
                        }
                        else if (abs(dir.x)<abs(dir.z)) {
                            X += dir.x/abs(dir.z)*ratio*0.5 * -sign(dir.z);
                            Y += dir.y/abs(dir.z)*0.5;
                        }
                        else {
                            X += dir.z/abs(dir.x)*ratio*0.5 * -sign(dir.x);
                            Y += dir.y/abs(dir.x)*0.5;
                        }
                        vec2 pos = vec2(X, Y)*2.-1.;
                        // Cancel __source__/__sourceBkg__'s x/ratio normalization: the box math
                        // produces x in Pap's [-1,1] fill space, but the sampler expects
                        // [-ratio,ratio]. Same double-compensation fix as planes mode above.
                        pos.x *= sDim.x/sDim.y;
                        bkgCol = hasBkg ? __sourceBkg__(pos) : __source__(pos);
                    }
                    else { // sphere
                        vec3 n = normalize(dir);
                        float alpha = atan(n.z, n.x);
                        float beta = asin(n.y);
                        float nX = 2.0;
                        float nY = 1.0;
                        vec2 sDim = hasBkg ? sourceBkgDim : sourceDim;
                        vec2 pos = vec2(-alpha/PI*0.5*nX, 0.5+nY*beta/PI)*2.-1.;
                        // Cancel __source__/__sourceBkg__'s x/ratio normalization so azimuth maps
                        // to texture x AR-independently (equirect), same double-compensation fix
                        // as planes/box. (The separate nX=2 still assumes a 2:1 panorama.)
                        pos.x *= sDim.x/sDim.y;
                        bkgCol = hasBkg ? __sourceBkg__(pos) : __source__(pos);
                    }
                }
                vec3 lightDir = normalize(lightPos-cameraPos);
                if (bkgStyle<=1.0) {
                    float lightProx = dot(lightDir, dir);
                    col = bkgCol.rgb + bkgStyle*0.2*pow((lightProx+1.0)/1.95, 100.0)*colorSource.rgb;
                }
                else if (bkgStyle<=2.0) {
                    float lightProx = dot(lightDir, dir);
                    vec3 colImg = bkgCol.rgb + 0.2*pow((lightProx+1.0)/1.95, 100.0)*colorSource.rgb;
                    vec3 colSpectrum = abs(dir) + pow((dot(lightDir, dir)+1.0)/1.95, 50.0);
                    col = mix(colImg, colSpectrum, bkgStyle-1.0);
                }
                else if (bkgStyle<=3.0) {
                    vec3 colSpectrum = abs(dir) + pow((dot(lightDir, dir)+1.0)/1.95, 50.0);
    
                    float lightProx = dot(lightDir, dir);
                    vec3 colDay = mix(vec3(0.03, 0.12, 0.82), vec3(0.2, 0.4, 1.0), (lightProx+1.0)/2.0) + 0.2*pow((lightProx+1.0)/1.95, 100.0)*colorSource.rgb;
    
                    col =  mix(colSpectrum, colDay, bkgStyle-2.0);
                }
                else {
                    float lightProx = dot(lightDir, dir);
                    vec3 colDay = mix(vec3(0.0, 0.14, 0.85), vec3(0.2, 0.4, 1.0), (lightProx+1.0)/2.0) + 0.2*pow((lightProx+1.0)/1.95, 100.0)*colorSource.rgb;
    
                    float R = 40.0;
                    vec3 center = floor(dir*R+0.5)/R;
                    float mag = pow(hash3(center), 10.0)*40.0;
                    float stars1 = smoothstep(0.3, 1.0, mag*0.00000001/pow(length(center-dir), 2.5));
                    R = 400.0;
                    center = floor(dir*R+0.5)/R;
                    mag = pow(hash3(center), 100.0)*4.0;
                    float stars2 = smoothstep(0.3, 1.0, mag*0.00000001/pow(length(center-dir), 2.5));
                    float mainStar = pow(max(0.0, lightProx)*1.001, 1000.0);
                    vec3 colNight = vec3(0.0) + stars1 + stars2 + mainStar*colorSource.rgb;
    
                    col =  mix(colDay, colNight, bkgStyle-3.0);
                }
                
            }
        
            col += glowI*colorGlow.a*colorGlow.rgb;
        
            // GLOW
            if (intersection.x!=INF && glowK>0.0 && glowK<4.0) {
                float glow0 = upStayDown(glowK, 1.0, 2.0);
                float glow1 = upStayDown(glowK, 2.0, 3.0);
                col = mix(col, max(vec3(0.0), 1.5-glowIterations*0.1*(1.0-colorGlow.rgb*0.5)), glow0*colorGlow.a);
                col = mix(col, colorGlow.rgb*vec3(glowIterations)*0.01, glow1*colorGlow.a);
            }
        
            // FOG
            if (fog!=0.0) {
                fog *= 100.;
                float near = fog<10.0 ? 1e10/pow(fog, 10.0) : 100.0/(fog*fog); ///(u_Fog+1e-10);
                float far = near*10.0;
                col = mix(col, colorFog.rgb, smoothstep(near, far, length(origin-intersection.xyz)));
            }
        
            col = pow(col, vec3(1.0-gamma));
        
            return vec4(col,1.0);       
        }

void main() {
    fragColor = mengerSponge((inverse(u_viewTransform) * vec3(((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), 1.0)).xy, ((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), u_iterations, u_model3DTransform, u_camera3DTransform, u_lightSourceTransform, u_internal3DTransform, u_sourceDim, u_sourceBkgDim, u_sourceBkg_specified, u_mode, u_internalIter, u_colorScheme, u_thickness, u_variability, u_randomSeed, u_colorSource, u_colorAmbient, u_colorFog, u_colorGlow, u_backgroundStyle, u_backgroundMode, u_specular, u_glow, u_fog, u_gamma);
}
