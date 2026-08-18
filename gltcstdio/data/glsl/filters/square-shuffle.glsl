vec4 squareShuffle(vec2 uv, vec2 outPos, float intensity, float angle, float randomSeed, mat3 modelTransform) {
    vec2 u = tf(inverse(modelTransform), uv);
    
    vec2 indices = floor(u);
    vec2 d = u-indices;

    if (angle != 0.0) {
        float cosPhase = cos(angle);
        float sinPhase = sin(angle);
        vec2 ri = vec2(floor(indices.x*cosPhase - indices.y*sinPhase + 0.5),
                           floor(indices.x*sinPhase + indices.y*cosPhase + 0.5));
        indices = ri;
    }

    if (intensity != 0.0) {
        vec2 rnd = rand2relSeeded(indices, randomSeed)*20.0;
        float probability = fract(rnd).x;
        if (intensity > probability) {
            vec2 delta = ceil(rnd); //vec2(ceil(rnd.x), round(rnd.y));
            indices += delta;
        }
    }

    u = indices + d;

    vec2 coord = tf(modelTransform, u);

    return __source__(coord);
}
