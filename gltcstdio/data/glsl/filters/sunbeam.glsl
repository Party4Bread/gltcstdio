vec4 sunbeam(vec2 uv, vec2 outPos, float intensity, float dampening, float normalization, vec4 color, mat3 modelTransform) {                   
    vec4 inc = __source__(uv);

    vec2 pos = (modelTransform * vec3(0.0, 0.0, 1.0)).xy;
    float radius = length(modelTransform[0].xy);
    float strongRadius = radius * (1.0 - dampening*dampening);
    float step = 0.01; // up from 0.001 in Chroma Lab: this seems both better looking and faster!
    vec2 dir = normalize(uv-pos);
    float k = 1.0;
    float dist = length(pos-uv);
    for(float d = 0.0; d<min(radius, dist); d+=step) {
        vec2 p = pos + dir*d;
        float damp = smoothstep(strongRadius*0.25, strongRadius, d);
        float v = mix(1.0, luma(__source__(p).rgb), damp);
        //k += 0.001*v;
        k = min(k, max(0.0, v*v));
        //k = min(k, pow(max(0.0, v-d), 2.0));
        //k = min(k, max(0.0, v-d));
    }
    k = k*intensity*10.0;
    vec3 light = k*color.rgb;

    float value = (inc.r+inc.g+inc.b)/3.0;
    /*float reduce = mix(1.0, smoothstep(1.0, 0.0, value), u_Normalize*0.01);
    return inc + reduce*vec4(light, 0.0);*/
    //float reduce = mix(1.0, 1.0/(1.0+k*u_Color1.a), u_Normalize*0.1);
    float alpha = mix(smoothstep(1.0, 0.0, value), 1.0, color.a);
    float reduce = mix(1.0, 1.0/(1.0+intensity*10.0), normalization);
    //return (inc + vec4(light, 0.0))*vec4(vec3(reduce), 1.0);
    //return vec4(vec3(k), 1.0);
    return vec4((inc.rgb+alpha*light)*reduce, inc.a);
}
