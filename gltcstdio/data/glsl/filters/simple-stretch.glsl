vec4 simpleStretch(vec2 uv, vec2 outPos, float intensity, mat3 modelTransform) {
    mat3 invM = inverse(modelTransform);
    vec2 u = tf(invM, uv);
    float d = length(u);
    float radius = 1.0;
    float maxRadius = length(invM[0].xy) * 0.75;
    float p = 1.1;
    float dilation = pow(2.0, intensity / 20.0);
    if (d >= radius) {
        float a = maxRadius * (dilation - 1.0) * pow(maxRadius - radius, -p);
        dilation = dilation - a * pow(d - radius, p) / d;
    }
    vec2 coord = tf(modelTransform, dilation * u);
    return __source__(coord);
}
