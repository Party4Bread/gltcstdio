vec4 splitCombine(vec2 pos, vec2 outPos, float dithering, float waviness, mat3 axisTransform, mat3 viewTransform1, mat3 viewTransform2) {
    mat3 inverseAxisTransform = inverse(axisTransform);
    vec2 u = tf(inverseAxisTransform, pos); 
    float scale = length(axisTransform[0].xy);
    
    u.x += waviness * sin(u.y*5.); 
    u.x += dithering * sin(u.x*50.);
    float d = u.x * scale;
                    
    vec4 color = (d<0.0) ? __source1__(tf(inverse(viewTransform1), pos)) : __source2__(tf(inverse(viewTransform2), pos));               
    return /*vec4(0.5+0.5*k, 1., 1., 1.) */ color;
}
