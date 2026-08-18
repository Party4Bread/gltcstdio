#version 450
layout(location = 0) in vec2 v_uv;
layout(location = 0) out vec4 fragColor;

layout(binding = 0, std140) uniform Params {
    vec4 U[33];
};
layout(binding = 1) uniform sampler samp;
layout(binding = 2) uniform texture2D t_source;
layout(binding = 3) uniform texture2D t_legacy_1;

#define u_source sampler2D(t_source, samp)
#define iChannel0 sampler2D(t_legacy_1, samp)
#define u_worldAspect (U[0].x)
#define u_viewTransform (mat3(U[1].xyz, U[2].xyz, U[3].xyz))
#define u_sourceDim (U[4].xy)
#define u_outDim (U[5].xy)
#define iResolution (U[6].xy)
#define u_model3DTransform (mat4(U[7], U[8], U[9], U[10]))
#define u_lightSourceTransform (mat4(U[11], U[12], U[13], U[14]))
#define u_bkgTransform (mat4(U[15], U[16], U[17], U[18]))
#define u_camera3DTransform (mat4(U[19], U[20], U[21], U[22]))
#define u_colorMaterial (U[23])
#define u_refractionIndex (U[24].x)
#define u_fresnelStrength (U[25].x)
#define u_chromaticAberration (U[26].x)
#define u_colorFog (U[27])
#define u_sourceColor (U[28])
#define u_ambientColor (U[29])
#define u_specular (U[30].x)
#define u_backgroundStyle (int(U[31].x))
#define u_roundness (U[32].x)

#define __source__texelFetch__(c) texelFetch(u_source, (c), 0)
#define __source__(p) textureLod(u_source, (vec2((p).x / u_worldAspect, (p).y) / 2.0 + 0.5), 0.0)




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












































































































































































































































































































































            























    





vec3 getRay(vec2 uv, vec3 camera, vec3 target, float focalDist) {
    vec3 camZ = normalize(target-camera);
    vec3 camX = normalize(cross(vec3(0.,1.,0.), camZ));
    vec3 camY = cross(camZ,camX);
    return normalize(camZ*focalDist + uv.x*camX + uv.y*camY);
}

float sdBox( vec3 p, vec3 b ) {
  vec3 q = abs(p) - b;
  return length(max(q,0.0)) + min(max(q.x,max(q.y,q.z)),0.0);
}

float sdOctahedron(vec3 p, float s) {
    p = abs(p);
    float m = p.x+p.y+p.z-s;
    vec3 q;
    if (3.*p.x < m) q = p.xyz;
    else if (3.*p.y < m) q = p.yzx;
    else if (3.*p.z < m) q = p.zxy;
    else return m*0.57735027;
    float k = clamp(0.5*(q.z-q.y+s),0.0,s); 
    return length(vec3(q.x,q.y-s+k,q.z-k)); 
}

float sdf(vec3 p, float roundness) {
    return min(sdBox(p, vec3(.25)), sdOctahedron(p, 0.5)) - roundness*0.25;
}

vec3 normal(vec3 p, float roundness) {
    float d = 0.0001;
    float s = sdf(p,roundness);
    return normalize(vec3(
        (s-sdf(vec3(p.x-d, p.y, p.z),roundness))/d,
        (s-sdf(vec3(p.x, p.y-d, p.z),roundness))/d,
        (s-sdf(vec3(p.x, p.y, p.z-d),roundness))/d
        ));
}

vec3 rayMarch(vec3 p0, vec3 dir, float side, float roundness) {
    float d = sdf(p0,roundness);
    float s = sign(d);
    float totalD = 0.0;
    int step = 0;
    while (step < 1000 && d<100.) {
        totalD += d*side;
        vec3 p = p0 + totalD*dir;
        d = sdf(p,roundness);
        if (abs(d)<0.0001) return p;
        ++step;
    }
    return vec3(INF);
}

        vec4 rayMarcher(vec2 uv, vec2 outPos, mat4 model3DTransform, vec2 sourceDim, mat4 lightSourceTransform, mat4 bkgTransform,
                        mat4 camera3DTransform,
                        vec4 colorMaterial, float refractionIndex, float fresnelStrength,
                        float chromaticAberration, vec4 colorFog,
                        vec4 sourceColor, vec4 ambientColor, float specular, int backgroundStyle, float roundness) {
            float D = 1.0;
//vec3 camera = vec3(0., 0., D);
            vec3 camera = vec3(0., 0., 0.);
            camera = ((camera3DTransform) * vec4(camera, 1.)).xyz;

            vec3 target = vec3(0.);
            vec3 camDir = getRay(uv, camera, target, 1.); // no longer used
            
            vec3 lightPos = (lightSourceTransform * vec4(0.0, 0.0, 0.0, 1.0)).xyz;
            
//mat4 invModelTransform = inverse(model3DTransform);
//mat3 model3DTransform3 = mat3(model3DTransform);
//camera = (invModelTransform * vec4(camera, 1.)).xyz;
//camDir = mat3(invModelTransform) * camDir; 
            
            mat4 invModelTransform = inverse(model3DTransform);
            mat3 model3DTransform3 = mat3(model3DTransform);
            camera = (invModelTransform * vec4(camera, 1.)).xyz;
            vec3 dir = normalize(vec3(uv.x*D, uv.y*D, -1.0));
            dir = mat3(camera3DTransform) * dir;
            camDir = normalize(mat3(invModelTransform) * dir);

            vec4 col = vec4(0., 0., 0., 1.);
            vec4 color = vec4(0., 0., 0., 1.);

            vec3 qIn = rayMarch(camera, camDir, 1.,roundness);
            vec3 reflectDir = camDir;
            vec3 reflectK = vec3(1.);
            float ref = refractionIndex;
            float chromaticAbb = chromaticAberration;
            float absorption = pow(mix(30.0, 1000.0, smoothstep(0.95, 1., colorMaterial.a)), colorMaterial.a);

            if (qIn.x!=INF) {
                vec3 nIn = normal(qIn,roundness);
                float incidence = abs(dot(nIn, camDir));
                float fresnel = pow(1.0-incidence, 6.-fresnelStrength*6.) * smoothstep(0.0, 0.025, fresnelStrength) * smoothstep(0.0, 0.025, fresnelStrength);                

                reflectDir = reflect(camDir, nIn);
                vec3 reflectivity = vec3(1.) - colorMaterial.rgb;
                reflectK = reflectivity;
                vec3 lightDir = normalize(qIn-lightPos);

                if (fresnel!=1.0) {
                    vec3 refractDir;// = refract(camDir, nIn, ref);
                    float k = 1.0 - ref * ref * (1.0 - dot(nIn, camDir) * dot(nIn, camDir));
                    if (k < 0.0)
                        refractDir = vec3(0.0);       // or genDType(0.0)
                    else
                        refractDir = ref * camDir - (ref * dot(nIn, camDir) + sqrt(k)) * nIn;

                    vec3 qOut = rayMarch(qIn-nIn*0.001, refractDir, -1.,roundness);

                    vec3 n = -normal(qOut,roundness);

                    vec3 rDir = refract(refractDir, n, 1./ref-chromaticAbb);
                    vec3 refractDirR = (length(rDir)==0.) ? reflect(refractDir, n) : rDir;

                    vec3 gDir = refract(refractDir, n, 1./ref);
                    vec3 refractDirG = (length(gDir)==0.) ? reflect(refractDir, n) : gDir;

                    vec3 bDir = refract(refractDir, n, 1./ref+chromaticAbb);
                    vec3 refractDirB = (length(bDir)==0.) ? reflect(refractDir, n) : bDir;
                    
                    //col = vec4(bkg(refractDirR).r, bkg(refractDirG).g, bkg(refractDirB).b, 1.);
                    //col = vec4(refractDirR.x*0.5+0.5, refractDirG.y*0.5+0.5, refractDirB.z*0.5+0.5, 1.);
                    vec4 colR, colG, colB;
refractDirR = model3DTransform3 * refractDirR;
refractDirG = model3DTransform3 * refractDirG;
refractDirB = model3DTransform3 * refractDirB;
                    if (backgroundStyle==0) {
    vec3 _o_n = normalize(refractDirR);
    float _o_alpha = atan(_o_n.z, _o_n.x);
    float _o_beta = asin(_o_n.y);
    float _o_ratio = sourceDim.x/sourceDim.y;
    float _o_nX = 2.0;
    float _o_nY = 1.0;
    colR = __source__(vec2(-_o_alpha/PI*0.5*_o_nX, 0.5+_o_nY*_o_beta/PI));
}
else if (backgroundStyle==1) {
    vec2 _o_pos = vec2(-(refractDirR).x/(refractDirR).z , -(refractDirR).y/(refractDirR).z)*1.0 ;
    float _o_m = max(abs(_o_pos.x), abs(_o_pos.y));
    float _o_darken = 4.0/max(4.0, _o_m);
    colR = __source__(_o_pos)*vec4(_o_darken, _o_darken, _o_darken, 1.0);
}
else if (backgroundStyle==2) {
    float _o_ratio = sourceDim.y/sourceDim.x;
    float _o_X = 0.5;
    float _o_Y = 0.5;
    if (abs((refractDirR).y)>abs((refractDirR).z)*_o_ratio && abs((refractDirR).y)>abs((refractDirR).x)*_o_ratio) {
        _o_X += -(refractDirR).x/(refractDirR).y*0.5;
        _o_Y += -(refractDirR).z/(refractDirR).y*0.5;
    }
    else if (abs((refractDirR).x)<abs((refractDirR).z)) {
        _o_X += (refractDirR).x/abs((refractDirR).z)*_o_ratio*0.5 * -sign((refractDirR).z);
        _o_Y += (refractDirR).y/abs((refractDirR).z)*0.5;
    }
    else {
        _o_X += (refractDirR).z/abs((refractDirR).x)*_o_ratio*0.5 * -sign((refractDirR).x);
        _o_Y += (refractDirR).y/abs((refractDirR).x)*0.5;
    }
    colR = __source__(vec2(_o_X, _o_Y));
}
else {
    colR = vec4((refractDirR)*0.5+0.5, 1.0);
}
                    if (backgroundStyle==0) {
    vec3 _o_n = normalize(refractDirG);
    float _o_alpha = atan(_o_n.z, _o_n.x);
    float _o_beta = asin(_o_n.y);
    float _o_ratio = sourceDim.x/sourceDim.y;
    float _o_nX = 2.0;
    float _o_nY = 1.0;
    colG = __source__(vec2(-_o_alpha/PI*0.5*_o_nX, 0.5+_o_nY*_o_beta/PI));
}
else if (backgroundStyle==1) {
    vec2 _o_pos = vec2(-(refractDirG).x/(refractDirG).z , -(refractDirG).y/(refractDirG).z)*1.0 ;
    float _o_m = max(abs(_o_pos.x), abs(_o_pos.y));
    float _o_darken = 4.0/max(4.0, _o_m);
    colG = __source__(_o_pos)*vec4(_o_darken, _o_darken, _o_darken, 1.0);
}
else if (backgroundStyle==2) {
    float _o_ratio = sourceDim.y/sourceDim.x;
    float _o_X = 0.5;
    float _o_Y = 0.5;
    if (abs((refractDirG).y)>abs((refractDirG).z)*_o_ratio && abs((refractDirG).y)>abs((refractDirG).x)*_o_ratio) {
        _o_X += -(refractDirG).x/(refractDirG).y*0.5;
        _o_Y += -(refractDirG).z/(refractDirG).y*0.5;
    }
    else if (abs((refractDirG).x)<abs((refractDirG).z)) {
        _o_X += (refractDirG).x/abs((refractDirG).z)*_o_ratio*0.5 * -sign((refractDirG).z);
        _o_Y += (refractDirG).y/abs((refractDirG).z)*0.5;
    }
    else {
        _o_X += (refractDirG).z/abs((refractDirG).x)*_o_ratio*0.5 * -sign((refractDirG).x);
        _o_Y += (refractDirG).y/abs((refractDirG).x)*0.5;
    }
    colG = __source__(vec2(_o_X, _o_Y));
}
else {
    colG = vec4((refractDirG)*0.5+0.5, 1.0);
}
                    if (backgroundStyle==0) {
    vec3 _o_n = normalize(refractDirB);
    float _o_alpha = atan(_o_n.z, _o_n.x);
    float _o_beta = asin(_o_n.y);
    float _o_ratio = sourceDim.x/sourceDim.y;
    float _o_nX = 2.0;
    float _o_nY = 1.0;
    colB = __source__(vec2(-_o_alpha/PI*0.5*_o_nX, 0.5+_o_nY*_o_beta/PI));
}
else if (backgroundStyle==1) {
    vec2 _o_pos = vec2(-(refractDirB).x/(refractDirB).z , -(refractDirB).y/(refractDirB).z)*1.0 ;
    float _o_m = max(abs(_o_pos.x), abs(_o_pos.y));
    float _o_darken = 4.0/max(4.0, _o_m);
    colB = __source__(_o_pos)*vec4(_o_darken, _o_darken, _o_darken, 1.0);
}
else if (backgroundStyle==2) {
    float _o_ratio = sourceDim.y/sourceDim.x;
    float _o_X = 0.5;
    float _o_Y = 0.5;
    if (abs((refractDirB).y)>abs((refractDirB).z)*_o_ratio && abs((refractDirB).y)>abs((refractDirB).x)*_o_ratio) {
        _o_X += -(refractDirB).x/(refractDirB).y*0.5;
        _o_Y += -(refractDirB).z/(refractDirB).y*0.5;
    }
    else if (abs((refractDirB).x)<abs((refractDirB).z)) {
        _o_X += (refractDirB).x/abs((refractDirB).z)*_o_ratio*0.5 * -sign((refractDirB).z);
        _o_Y += (refractDirB).y/abs((refractDirB).z)*0.5;
    }
    else {
        _o_X += (refractDirB).z/abs((refractDirB).x)*_o_ratio*0.5 * -sign((refractDirB).x);
        _o_Y += (refractDirB).y/abs((refractDirB).x)*0.5;
    }
    colB = __source__(vec2(_o_X, _o_Y));
}
else {
    colB = vec4((refractDirB)*0.5+0.5, 1.0);
}
                    col = vec4(colR.r, colG.g, colB.b, 1.);
                    
                    //float absorbed = min(1.0, absorption * pow(2.0, length(qI n-qOut)));
                    float absorbed = 1.0 - pow(0.5, absorption * length(qIn-qOut));
                    absorbed = mix(0.0, absorbed, smoothstep(0.0, 0.1, colorMaterial.a));
                    
                    color.rgb += colorMaterial.rgb * (1.0-fresnel) * (1.-absorbed) * col.rgb;                    
                    color.rgb += absorbed * colorMaterial.rgb * (ambientColor.rgb + max(0.0, dot(nIn, lightDir))*sourceColor.rgb);
                }

                if (fresnel!=0.0 || specular!=0.0) {
                    vec3 origReflectDir = reflectDir;
                    vec3 qR = rayMarch(qIn+nIn*0.001, reflectDir, 1.,roundness);
                    if (qR.x!=INF) {
                         vec3 n = normal(qR,roundness);
                         reflectDir = reflect(reflectDir, n);
                    }
reflectDir = model3DTransform3 * reflectDir;
                    if (backgroundStyle==0) {
    vec3 _o_n = normalize(reflectDir);
    float _o_alpha = atan(_o_n.z, _o_n.x);
    float _o_beta = asin(_o_n.y);
    float _o_ratio = sourceDim.x/sourceDim.y;
    float _o_nX = 2.0;
    float _o_nY = 1.0;
    col = __source__(vec2(-_o_alpha/PI*0.5*_o_nX, 0.5+_o_nY*_o_beta/PI));
}
else if (backgroundStyle==1) {
    vec2 _o_pos = vec2(-(reflectDir).x/(reflectDir).z , -(reflectDir).y/(reflectDir).z)*1.0 ;
    float _o_m = max(abs(_o_pos.x), abs(_o_pos.y));
    float _o_darken = 4.0/max(4.0, _o_m);
    col = __source__(_o_pos)*vec4(_o_darken, _o_darken, _o_darken, 1.0);
}
else if (backgroundStyle==2) {
    float _o_ratio = sourceDim.y/sourceDim.x;
    float _o_X = 0.5;
    float _o_Y = 0.5;
    if (abs((reflectDir).y)>abs((reflectDir).z)*_o_ratio && abs((reflectDir).y)>abs((reflectDir).x)*_o_ratio) {
        _o_X += -(reflectDir).x/(reflectDir).y*0.5;
        _o_Y += -(reflectDir).z/(reflectDir).y*0.5;
    }
    else if (abs((reflectDir).x)<abs((reflectDir).z)) {
        _o_X += (reflectDir).x/abs((reflectDir).z)*_o_ratio*0.5 * -sign((reflectDir).z);
        _o_Y += (reflectDir).y/abs((reflectDir).z)*0.5;
    }
    else {
        _o_X += (reflectDir).z/abs((reflectDir).x)*_o_ratio*0.5 * -sign((reflectDir).x);
        _o_Y += (reflectDir).y/abs((reflectDir).x)*0.5;
    }
    col = __source__(vec2(_o_X, _o_Y));
}
else {
    col = vec4((reflectDir)*0.5+0.5, 1.0);
}
                    //col = vec4(bkg(reflectDir), 1.);
                    color.rgb += fresnel * col.rgb;
                    
                    // specular
                    float kSpec = 10.0 * specular * pow(max(0.0, dot(lightDir, origReflectDir)), 9.0);
                    color.rgb += sourceColor.rgb * kSpec;
                }
                
                // fog
                if (colorFog.a!=0.0) {
                    float dist = length(camera - qIn);
                    float kFog = 1.0 - pow(0.4, colorFog.a * max(0.0, dist-0.1));
                    color.rgb = mix(color.rgb, colorFog.rgb, kFog);
                }
                
            }
            else {
camDir = mat3(bkgTransform) * model3DTransform3 * camDir;
                if (backgroundStyle==0) {
    vec3 _o_n = normalize(camDir);
    float _o_alpha = atan(_o_n.z, _o_n.x);
    float _o_beta = asin(_o_n.y);
    float _o_ratio = sourceDim.x/sourceDim.y;
    float _o_nX = 2.0;
    float _o_nY = 1.0;
    col = __source__(vec2(-_o_alpha/PI*0.5*_o_nX, 0.5+_o_nY*_o_beta/PI));
}
else if (backgroundStyle==1) {
    vec2 _o_pos = vec2(-(camDir).x/(camDir).z , -(camDir).y/(camDir).z)*1.0 ;
    float _o_m = max(abs(_o_pos.x), abs(_o_pos.y));
    float _o_darken = 4.0/max(4.0, _o_m);
    col = __source__(_o_pos)*vec4(_o_darken, _o_darken, _o_darken, 1.0);
}
else if (backgroundStyle==2) {
    float _o_ratio = sourceDim.y/sourceDim.x;
    float _o_X = 0.5;
    float _o_Y = 0.5;
    if (abs((camDir).y)>abs((camDir).z)*_o_ratio && abs((camDir).y)>abs((camDir).x)*_o_ratio) {
        _o_X += -(camDir).x/(camDir).y*0.5;
        _o_Y += -(camDir).z/(camDir).y*0.5;
    }
    else if (abs((camDir).x)<abs((camDir).z)) {
        _o_X += (camDir).x/abs((camDir).z)*_o_ratio*0.5 * -sign((camDir).z);
        _o_Y += (camDir).y/abs((camDir).z)*0.5;
    }
    else {
        _o_X += (camDir).z/abs((camDir).x)*_o_ratio*0.5 * -sign((camDir).x);
        _o_Y += (camDir).y/abs((camDir).x)*0.5;
    }
    col = __source__(vec2(_o_X, _o_Y));
}
else {
    col = vec4((camDir)*0.5+0.5, 1.0);
}
                if (colorFog.a!=0.0) color.rgb = colorFog.rgb; else color = col;
            }

            return clamp(color, 0.0, 1.0);
        }

void main() {
    fragColor = rayMarcher((inverse(u_viewTransform) * vec3(((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), 1.0)).xy, ((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), u_model3DTransform, u_sourceDim, u_lightSourceTransform, u_bkgTransform, u_camera3DTransform, u_colorMaterial, u_refractionIndex, u_fresnelStrength, u_chromaticAberration, u_colorFog, u_sourceColor, u_ambientColor, u_specular, u_backgroundStyle, u_roundness);
}
