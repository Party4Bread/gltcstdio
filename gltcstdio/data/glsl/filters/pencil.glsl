vec4 pencil(vec2 uv, vec2 outPos, vec4 color1, vec4 color2, float power, mat3 modelTransform) {
    vec4 bkg = __source__(uv);
    float delta = 0.005;
    vec2 step = vec2(delta/2., 0.);
    
    vec2 grad = vec2( // might be smart to use a mip-map
        luma(__source__(uv+step).rgb) - luma(__source__(uv-step).rgb) ,
        luma(__source__(uv+step.yx).rgb) - luma(__source__(uv-step.yx).rgb) );
        
    vec2 dir = tf(inverse(modelTransform), grad);
    
    vec2 u = uv * dir * 3.0;
    //float k = perlinNoise(length(grad) * tf(inverse(modelTransform),uv)*100.);
    //float k = pow(length(grad), power);
    float k = perlinNoise(tf(inverse(modelTransform),uv)*100. * pow(length(grad), power));
            
    vec4 col = mix(color2, color1, k);
    return mergeColor(bkg, col); 
    
}
