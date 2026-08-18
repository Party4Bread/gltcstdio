vec4 tangentCircleStreak(vec2 uv, vec2 outPos, int count, mat3 modelTransform, float offset) {
    vec2 u = (inverse(modelTransform) * vec3(uv, 1.0)).xy;
    float h = dot(u, u)/(2.*u.y);
    //float h = dot(uv, uv)/(2.*uv.y+sin(iTime)*4.);
    vec2 c = vec2(0., h);
    vec2 dv = u-c;
    
    float angle = atan(dv.y, dv.x);
    float N = float(count);
    float au = 2.*PI / N;
    float a0 = (floor(angle/au-offset)+offset) * au;
    float a1 = (ceil(angle/au-offset)+offset) * au;
    float k = (angle-a0)/au;
                
    vec2 uv1 = tf(modelTransform, c + h*vec2(cos(a0), sin(a0)));
    vec2 uv2 = tf(modelTransform, c + h*vec2(cos(a1), sin(a1)));
    vec4 col0 = __source__(uv1);
    vec4 col1 = __source__(uv2);
    vec4 outCol = mix(col0, col1, k);
    
    return outCol;
}
