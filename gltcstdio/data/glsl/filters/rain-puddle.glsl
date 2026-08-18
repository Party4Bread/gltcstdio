float ripple_(vec2 center, float radius, float time, float fullCycle, vec2 u) {
    u -= center;
    float d = length(u) / radius;
    float dim = radius * 0.1;
    float dampCenter = 0.0+time*0.3;
    float dampRadius = dim*1.5 * (1.0+time*0.5);
    float dampX = (d-dampCenter) / dampRadius;
    float damp = (abs(dampX)>1.) ? 0.0 : (cos(dampX*3.1415)+1.)*0.5;
    float timeDamp = pow(0.01, time/fullCycle) * smoothstep(fullCycle, fullCycle*0.5, time);
    return cos(d/dim*3.1415*2. - time*20.) * damp * timeDamp;
}

float ripples_(float maxDist, int count, float radiusVariability, float time, float fullCycle, vec2 u) {
    float total = 0.;
    float timeSlice = floor(time/fullCycle * float(count));
    for(int i=0; i<=count; ++i) {
        float id = timeSlice - float(i);
        vec2 h =  hash12(id);
        float radius = max(0.1, 1.0 + radiusVariability*(fract(h.x*41.)-0.5)*2.0);
        vec2 center = (h-0.5)*maxDist*2.;
        float localTime = time - float(id)/float(count)*fullCycle;
        total += ripple_(center, radius, localTime, fullCycle, u);
    }
    return total;
}

vec2 ripplesNormal(float maxDist, int count, float radiusVariability, float time, float fullCycle, vec2 u) {
    float ri = ripples_(maxDist, count, radiusVariability, time, fullCycle, u);
    float delta = 0.0001;
    float riX = ripples_(maxDist, count, radiusVariability, time, fullCycle, u+vec2(delta, 0.));
    float riY = ripples_(maxDist, count, radiusVariability, time, fullCycle, u+vec2(0.0, delta));
    return vec2((riX-ri)/delta, (riY-ri)/delta);
}

vec4 rainPuddle(vec2 uv, vec2 outPos, int mode, float spacing, float intensity, int count, float radiusVariability, float time, float lighting, float specular, mat3 modelTransform) {
    mat3 t = inverse(modelTransform);
    vec2 u = tf(t, uv);
    vec4 col;
    
    vec2 ripplesN = ripplesNormal(spacing, count, radiusVariability, time*1., 4., u);
    vec3 n = normalize(vec3(ripplesN, 1.));
    
    if (mode==2) {
        col = vec4(vec3((ripples_(spacing, count, radiusVariability, time*1., 4., u)+1.)*0.5) , 1.);
    }
    else if (mode==1) {
        col = vec4(n.x, n.y, n.z, 1.);
    }
    else {
        vec2 duv = tf(modelTransform, u + ripplesN*intensity * 0.02);
        col = __source__(duv);
    }
    
    float lum = dot(n, normalize(vec3(1., 1., 0.))) * lighting;
    float spec = pow(max(0.0, dot(n, normalize(vec3(u.x, u.y, 1.)))), 9.) * 2. * specular;
    lum += spec;
   
    col += vec4(lum, lum, lum, 1.); 
    return col;
}
