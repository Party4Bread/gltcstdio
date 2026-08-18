vec4 cathodidRay(vec2 pos, vec2 outPos, float intensity, float balance, mat3 modelTransform) {
    vec2 u = (inverse(modelTransform) * vec3(pos, 1.0)).xy;

    float k = mod(u.y+2.0, 2.0)*0.5;

    vec4 color = __source__(pos);
    float intens = 1.0 - intensity;
    float base = pow(10.0, intens*20.0);
    k = balance + 0.5*pow(base, k)/(base/10.0);

    vec3 outCol = color.rgb*vec3(k, k, k);
    return vec4(clamp(0.0, 1.0, outCol.r), clamp(0.0, 1.0, outCol.g),clamp(0.0, 1.0, outCol.b), color.a);     
}
