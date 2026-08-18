vec4 marble(vec2 pos, vec2 outPos, mat3 modelTransform, int iterations, float intensity) {
    vec2 t = (inverse(modelTransform) * vec3(pos, 1.0)).xy;

    if (intensity != 0.0) {
        pos = fractalValueNoiseDisplace(pos, t, iterations, intensity*2.0);
    }

    return __source__(pos);
}
