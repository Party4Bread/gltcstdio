const float SKY = 0.;
const float WATER = 10.;
const float SHALLOWWATER = 11.;
const float GROUND = 21.;
const float CLOUD = 22.;
const float RINGS = 50.;

#define HH 0.175

mat4 rotX(float ang) {
    return mat4(1.0, 0.0, 0.0, 0.0,
                0.0, cos(ang), sin(ang), 0.0,
                0.0, sin(ang), -cos(ang), 0.0,
                0.0, 0.0, 0.0, 1.0);

}


mat4 rotY(float ang) {
    return mat4(cos(ang), 0.0, sin(ang), 0.0,
                0.0, 1.0, 0.0, 0.0,
                sin(ang), 0.0, -cos(ang), 0.0,
                0.0, 0.0, 0.0, 1.0);

}


mat4 rotZ(float ang) {
    return mat4(cos(ang), sin(ang), 0.0, 0.0,
                sin(ang), -cos(ang), 0.0, 0.0,
                0.0, 0.0, 1.0, 0.0,
                0.0, 0.0, 0.0, 1.0);

}

vec2 minMat(vec2 a, vec2 b) {
    return a.x<b.x ? a : b;
}
        
vec2 minMat3(vec2 a, vec2 b, vec2 c) {
    return minMat(a, minMat(b, c));
}

vec3 pow3(vec3 v, float e) {
    return vec3(pow(v.x, e), pow(v.y, e), pow(v.z, e));
}

vec2 planet1(vec3 p) {
    //vec3 q = p + H * pow3(sin(p* vec3(20.4, 19.3, 44.4)), 2.);
    vec3 pp = (mat3(rotX(0.5*cos(dot(p, vec3(.75))))) * mat3(rotY(0.5*sin(dot(p, vec3(.2))))) * p)
         + 0.21*sin(p* vec3(20.4+15.*sin(p.z+p.y*2.), 19.3, 24.4));
    float alpha = atan(pp.y, pp.x);
    float beta = atan(pp.z, length(pp.xy));
    float main = mix(cos(alpha*5.), -0.5, smoothstep(0.8, 0.9, abs(p.z)));
    vec3 q = p * (1. + HH * main);
    return minMat(vec2(length(q) - 1., GROUND), vec2(length(p) - 1., WATER));
}

vec2 planet2(vec3 p) {
    float lp = length(p);
    if (lp>1.+HH*2. || lp<1.0) return vec2(length(lp) - 1., WATER);

    //float main = perlinRelNoise3(p*2.55);
    float main1 = 0.05 + perlinRelNoise3(p*1.56) + 0.5*perlinRelNoise3(p*4.79) + 0.25*perlinRelNoise3(p*10.3);
    float main2 = main1  + 0.125*perlinRelNoise3(p*21.0);//+ 0.0625*perlinRelNoise3(p*53.0);
    float main = main2;
    //float main = 0.05 + perlinRelNoise3(p*1.55) + 0.5*perlinRelNoise3(p*4.78);// + 0.25*perlinRelNoise3(p*10.0) + 0.125*perlinRelNoise3(p*22.0);
    vec3 q = p * (1. + HH * main);
    //return minMat(vec2(length(q) - 1., GROUND), vec2(length(lp) - 1., main>0.0625 ? WATER : SHALLOWWATER));
    return minMat(vec2(length(q) - 1., GROUND), vec2(length(lp) - 1., WATER + clamp(main1, 0., 1.)));
}

vec2 clouds(vec3 p) {
    float altitude1 = 1.1;
    float altitude2 = 1.2;
    float thickness1 = min(0.02, -0.03+0.04*sin(dot(p, vec3(7.*sin(1.5*p.x), 8.3, 17.4)))*sin(dot(p, vec3(6.*sin(2.*p.y), 4.3, 6.4))));
    float thickness2 = min(0.02, -0.03+0.04*sin(dot(p, vec3(2.*cos(1.25*p.x), 3.3, 5.4)))*sin(dot(p, vec3(4.*cos(2.*p.y), 3.3, 5.4))));
    return vec2(min(abs(length(p)-altitude1) - thickness1, abs(length(p)-altitude2) - thickness2), CLOUD);
}

vec2 clouds2(vec3 p) {
    float altitude1 = 1.1;
    float altitude2 = 1.2;
    float thickness1 = min(0.5, -0.03+0.2*perlinRelNoise3(0.1*iTime+p*2.));
    float thickness2 = min(0.5, -0.03+0.1*perlinRelNoise3(0.1*iTime+5.+p*2.));
    return vec2(min(abs(length(p)-altitude1) - thickness1, abs(length(p)-altitude2) - thickness2), CLOUD);
}

vec2 clouds3(vec3 p) {
    int N = 6;
    float d = 1e6;
    for(int i=0; i<N; ++i) {
        vec3 rnd = hash33(vec3(float(i-13)));
        mat4 t = rotX((rnd.y-0.5)*2.0) *rotZ(rnd.x*6.28) ;
        vec3 q = (t * vec4(p, 1.)).xyz;
        float l1 = 0.05+rnd.y*0.05;
        float a1 = 1.02 + 0.05*floor(rnd.z*3.);
        //float delta = (rnd.x-0.5) * 4. * l1;
        float delta = pow(rnd.x, 0.2) * 2. * l1;
        float l2 = 0.05+rnd.z*0.05;
        float d2 = sdSegment3(q, vec3(-l1, a1, 0.), vec3(l1, a1, 0.));
        d2 = min(d2, sdSegment3(q, vec3(delta-l2, a1, l1*0.9), vec3(delta+l2, a1, l1*0.9)));
        d2 = d2 - 0.10;
        d2 = max(d2, abs(length(q)-a1)-0.00);
        d = min(d, d2);
    }
    d = d - 0.01;
    return vec2(d, CLOUD);
}

vec2 noclouds(vec3 p) {
    return vec2(10000., CLOUD);
}

vec2 rings(vec3 p) {
    float thickness = 0.008;
    float width = 0.2;
    float R = 1.8;
    float r = thickness;
    float a = abs(sqrt(p.x*p.x + p.y*p.y) - R);
    vec2 q = vec2(a, p.z);
    vec2 c1 = vec2(min(a, width), 0.);
    return vec2((length(q-c1) - r), RINGS);
}

vec2 sdf(vec3 p) {
    //return planet2(p);
    return minMat3(planet2(p), rings(p), noclouds(p));
    //return minMat(planet2(p), clouds3(p));
}


bool isWater(float material) { return material>=WATER && material<=SHALLOWWATER; }

vec3 getNormal(vec3 p) {
    float d = 0.0001;
    float d2 = d*2.0;
    return normalize(vec3(
        (sdf(vec3(p.x-d, p.y, p.z)).x-sdf(vec3(p.x+d, p.y, p.z)).x)/d2,
        (sdf(vec3(p.x, p.y-d, p.z)).x-sdf(vec3(p.x, p.y+d, p.z)).x)/d2,
        (sdf(vec3(p.x, p.y, p.z-d)).x-sdf(vec3(p.x, p.y, p.z+d)).x)/d2
        ));
}


#define MAX_STEPS 1000
#define MAX_DIST 100.0

vec3 getRay(vec2 uv, vec3 camera, vec3 target, float focalDist) {
    vec3 camZ = normalize(target-camera);
    vec3 camX = normalize(cross(vec3(0.,1.,0.), camZ));
    vec3 camY = cross(camZ,camX);
    return normalize(camZ*focalDist + uv.x*camX + uv.y*camY);
}

struct Intersection {
    vec3 p;
    float material;
    vec4 diffCol;
    float minD;
};

vec3 groundColor(vec3 p) {
    vec3 col = mix(vec3(0.15, 0.5, 0.15), vec3(0.55, 0.44, 0.39), smoothstep(0.05, 0.35, perlinRelNoise3(p*5.22)));

    float d = (length(p) - 1.) / HH;
    if (d<0.1) col = mix(vec3(0.9, 0.8, 0.35), col, smoothstep(0.05, 0.06, d));
    else if (d>0.1) col = mix(col, vec3(1.), smoothstep(0.45, 0.5, d));

    float pole = smoothstep(0.8, 0.9, abs(p.z));
    col = mix(col, vec3(1.), pole);

    return col;
}

vec3 ringsColor(vec3 p) {
    float d = length(p);
    //vec3 col = vec3(0.6, 0.5, 0.35) * (1.5 + 0.3 * pow(sin(d*5.+sin(d*40.0)), 3.));
    vec3 col = vec3(0.5, 0.6, 0.7) * (1.5 + 0.3 * pow(sin(d*5.+sin(d*40.0)), 3.));
    return col;
}

vec4 getDiffusion(vec4 diffCol, vec3 p, float dist, vec3 lightDir) {

    float c = 1.5*smoothstep(1.5, 1.08, length(p));
    float illum = pow(max(0., 0.35+dot(p, lightDir)), 0.35);
    vec3 base = vec3(0.2, 0.75, 1.5) * illum;
    //vec4 col = vec4(base, c* illum);
    vec4 col = vec4(base, c * dist * (.5+.5* illum));

    return vec4(mix(diffCol.rgb, col.rgb, col.a), mix(diffCol.a, 1.0, col.a));
}

float getCloudDensity(vec3 p) {
    float d = length(p);
    return smoothstep(0.1, 0.05, abs(d-1.05)) * smoothstep(0.5, 0.7, perlinNoise3(p*vec3(1.5, 1.5, 3.)*pow(length(p), 3.)));
}

vec4 getDiffusion2(vec4 diffCol, vec3 p, float dist, vec3 lightDir) {

    float c = 1.5*smoothstep(1.5, 1.08, length(p));
    float illum = pow(max(0., 0.35+dot(p, lightDir)), 0.35);
    float cloud = getCloudDensity(p);

    vec3 base = mix(vec3(0.2, 0.75, 1.5) * illum, vec3(illum*.8+.2), cloud);
    c = mix(c, 25., cloud);

    vec4 col = vec4(base, min(c * dist * (.5+.5* illum), 1.));

    return vec4(mix(diffCol.rgb, col.rgb, col.a), mix(diffCol.a, 1.0, col.a));
}

Intersection rayMarch(vec3 p0, vec3 dir, vec3 lightDir) {
    vec2 d = sdf(p0);
    float s = sign(d.x);
    float totalD = 0.0;
    int step = 0;
    vec4 diffCol = vec4(0.);
    float minD = 1e9;
    while (step < MAX_STEPS && d.x<MAX_DIST) {
        float stepD = d.x*0.85;
        totalD += stepD;
        vec3 p = p0 + totalD*dir;

        d = sdf(p);
        minD = min(d.x/totalD, minD);
        diffCol = getDiffusion2(diffCol, p, stepD, lightDir);
        if (diffCol.a>0.95) return Intersection(p, d.y, diffCol, minD);
        if (abs(d.x)<0.0001) return Intersection(p, d.y, diffCol, minD);
        ++step;
    }
    return Intersection(vec3(INF), SKY, diffCol, minD);
}

float getSpecular(float material, vec3 camDir, vec3 normal, vec3 lightDir) {
    vec3 ref = reflect(lightDir, normal);
    float k = 0.;
    if (isWater(material)) k = .9;
    else if (material==GROUND) k = .1;
    else if (material==RINGS) k = .5;
    return pow(max(0., dot(ref, camDir)), 9.) * k;
}

vec4 planet(vec2 uv, vec2 outPos, mat4 model3DTransform, mat4 lightSourceTransform, mat4 camera3DTransform) {
    float D = 0.5;
//vec3 camera = vec3(0., 0., D);
    vec3 camera = vec3(0., 0., 0.);
    camera = ((camera3DTransform) * vec4(camera, 1.)).xyz;

    vec3 target = vec3(0.);
    vec3 camDir = getRay(uv, camera, target, 1.); // no longer used
    
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
    
    vec3 lightPos = (lightSourceTransform * vec4(0.0, 0.0, 0.0, 1.0)).xyz;
    vec3 lightDir = -lightPos;
    vec3 p = camera;

    vec3 col = vec3(0.0);

    Intersection intersection = rayMarch(p, camDir, lightDir);
    vec3 q = intersection.p;
    float material = intersection.material;
    vec3 normal = getNormal(q);
    if (material==SKY) col = vec3(0.1, 0.2, 0.3);
    else if (isWater(material)) col = mix(vec3(0.2, 0.75, 1.0), vec3(0.1, 0.2, 0.8), smoothstep(0.05, 0.4, material-WATER));
    //else if (material==WATER) col = vec3(0.15, 0.3, 1.0);
    //else if (material==SHALLOWWATER) col = vec3(0.3, 0.6, 1.0);
    else if (material==GROUND) col = groundColor(q);
    else if (material==RINGS) col = ringsColor(q);
    else if (material==CLOUD) col = vec3(1.);
    else if (q.x!=INF) col = normal*0.5+0.5;



    float illum = max(0., dot(normal, -lightDir));
    if (q.x!=INF) { // shadows
        vec3 start = q - camDir*0.0005;
        Intersection intersection = rayMarch(start, lightDir, lightDir);
        if (intersection.p.x!=INF) illum = 0.;
        else illum *= clamp(intersection.minD*25., 0., 1.); // penumbra - completely ad-hoc
    }
    col *= (0.15 + 1.*illum);

    vec4 diffCol = intersection.diffCol;
    col = mix(col.rgb, diffCol.rgb, diffCol.a);

    float spec = getSpecular(material, camDir, normal, lightDir);
    col += spec;

    return vec4(col,1.0);
}
