vec4 halo(vec2 uv, vec2 outPos, float intensity, float dampening, float blend, float dispersion, float fadeThickness, float frequency, float thickness, float variability, mat3 modelTransform, mat3 dampeningTransform) {
    vec2 u = tf(inverse(modelTransform), uv);
    
    float lum = intensity;
    frequency = pow(1.05, frequency);
    
    vec2 v = u;
    float angle = atan(v.y, v.x);
    float len = length(v);
    //float qvar = sin(angle*300.0 * (1.5+sin(angle*3.0)));
    float qvar = sin(angle*frequency * (1.5+sin(angle*3.0))) 
        * sin(angle*frequency*0.88 * (1.5+sin(angle*7.0))) 
        * sin(angle*frequency*0.81 * (1.5+sin(angle*11.0)));
    float expand = 1.0 + qvar * variability * (0.3+0.25*(1.0+sin(angle*5.0))* (1.0+sin(angle*14.0)));
    len = (len - (1.0-thickness*.5)) * expand + (1.0-thickness*.5);

    float d = len;
    float dr = len * (1.0+dispersion);
    float kr = smoothstep(1.0-thickness, 1.0-thickness+fadeThickness, dr) * smoothstep(1.0, 1.0-fadeThickness, dr);    
    float dg = len;
    float kg = smoothstep(1.0-thickness, 1.0-thickness+fadeThickness, dg) * smoothstep(1.0, 1.0-fadeThickness, dg);     
    float db = len * (1.0-dispersion);
    float kb = smoothstep(1.0-thickness, 1.0-thickness+fadeThickness, db) * smoothstep(1.0, 1.0-fadeThickness, db);    
    vec3 halo =  vec3(kr, kg, kb);
            

    // dampen
    d = length(tf(inverse(dampeningTransform), u));
    float dampen = 1.0 - dampening * smoothstep(1.0, 0.5, d);
    
    halo *= dampen;

    vec4 col = vec4(lum*halo, 1.0);           
    vec4 bkgCol = __source__(uv);
    float k1 = blend;
    float k2 = 1.-blend;
    vec4 outCol = mix(bkgCol, bkgCol+col, k2+k1*min(lum*k2*10., 1.));
    return outCol;
}
