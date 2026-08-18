vec4 linearRipples(vec2 pos, vec2 outPos, float intensity, float perspective, mat3 modelTransform) {
    mat3 invModelTransform = inverse(modelTransform);
    vec2 u = (invModelTransform * vec3(pos, 1.0)).xy;

    float d = u.y;

    if (d < 0.0) {
        return __source__(pos);
    }

    float radius = 0.5;

    float p = perspective * radius;
    float pd = perspective==0.0 ? 0.0 : perspective >= 10000.0 ? d : (p*d)/(p+d);

    float dilation = intensity * radius*0.5 * sin(pd * PI*100.0/radius);
//    float sx = x - sa*dilation;
//    float sy = y + ca*dilation;

    vec2 coord = (modelTransform * vec3(u.x, u.y + dilation, 1.0)).xy;
    return __source__(coord);
}
