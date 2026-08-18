float sparc(vec2 u, float power) {
    float len = length(u);
    //return 1./len;
    return 1./pow(len, power);
}

float trail(vec2 p, vec2 a, vec2 b, float power) {
    vec2 ba = b-a;
    float h = length(ba);
    float cosa = ba.x/h;
    float sina = ba.y/h;
    vec2 u = mat2(sina, cosa, -cosa, sina) * (p-a);
    float bigR = 0.05;
    float smallR = 0.01;
    float len = h==0.0 ? length(p-b) : sdUnevenCapsule(u, 0.01, 0.05, h) + bigR;
    return 1./pow(len, power);
}

float explosion(vec2 u, int n, float id, float time, float blend, float power) {
    float total = 0.;
    for(int i=0; i<n; ++i) {
        vec2 rnd = hash12(1. + id + float(i));
        float angle = rnd.x * PI2;
        float speed = pow(rnd.y, 0.35);
        vec2 pos = speed * time * vec2(cos(angle), sin(angle));

        float decay = smoothstep(15.0, 5.0, time);
        float lum = sparc(u-pos, power) * decay;

        //total = mix(total + max(0., (1.0-total)) * lum, total + lum, blend);
        total = pow(pow(total, blend) + pow(lum, blend), 1./blend);
    }
    return total;
}

float explosionT(vec2 u, int n, float id, float time, float deltaT, float blend, float power) {
    float total = 0.;
    for(int i=0; i<n; ++i) {
        vec2 rnd = hash12(1. + id + float(i));
        float angle = rnd.x * PI2;
        vec2 speed = pow(rnd.y, 0.35) * vec2(cos(angle), sin(angle));
        vec2 posA = speed * max(0.0, time-deltaT);
        vec2 posB = speed * time;
        float decay = smoothstep(20.0, 5.0, time);
        float lum = max(0., trail(u, posA, posB, power) * decay);

        //total = mix(total + max(0., (1.0-total)) * lum, total + lum, blend);
        total = pow(pow(total, blend) + pow(lum, blend), 1./blend);
    }
    return total;
}

vec4 fireworks(vec2 uv, vec2 outPos, vec2 sourceDim, int mode, int explosions, int particles, float intensity, float power, float spread, float blend, float randomSeed, vec4 color, float colorVariability, mat3 modelTransform) {                   
    vec4 inc = __source__(uv);

    vec2 u = tf(inverse(modelTransform), uv);

    float time = randomSeed;

    float CYCLE = 20.0;
    vec3 outCol = vec3(0.);
    //float g = sparc(uv);
    float sliceDuration = CYCLE/float(explosions);
    float timeSlice = floor(time/sliceDuration);
    
    for(int e=0; e<explosions; ++e) {
        float explosionId = timeSlice-float(e);
        float startTime = explosionId * sliceDuration;
        float eTime = time - startTime; 
        vec2 center = (hash12(explosionId)-0.5) * 20.0 * spread;
        
        float g;
        if (mode==0) g = explosion(u-center, particles, float(particles) *explosionId, eTime, blend, power);
        else if (mode==1) g = explosionT(u-center, particles, float(particles) *explosionId, eTime, .5, blend, power);
        else if (mode==2) g = explosionT(u-center, particles, float(particles) *explosionId, eTime, 1.3, blend, power);
        else if (mode==3) g = explosionT(u-center, particles, float(particles) *explosionId, eTime, 3.0, blend, power);
        
        vec3 col = color.rgb + (hash13(explosionId*10.)-0.5)*colorVariability;
        outCol += intensity * g * col;
    }

    return spilloverChannels(mergeColor(inc, vec4(outCol, min(1.0, luma(outCol)))));
    //return spilloverChannels(inc + vec4(outCol, 1.));
}
