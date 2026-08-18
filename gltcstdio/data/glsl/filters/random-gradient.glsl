vec3 rgRand3(vec2 v) {
    float x = fract(sin(dot(v.xy, vec2(12.9898, 78.233))) * 43758.5453);
    float y = fract(sin(dot(vec2(x, v.x), vec2(12.9898, 78.233))) * 43758.5453);
    float z = fract(sin(dot(vec2(y, v.y), vec2(12.9898, 78.233))) * 43758.5453);
    return vec3(x, y, z);
}

float rgVaryNoiseSmoothly(float noise, float k) {
    float phase = acos(2.0*noise - 1.0);
    float freq = fract(noise*16.0) + 0.5;
    return (1.0 + cos(phase + freq*k)) * 0.5;
}

vec3 rgVaryVec3NoiseSmoothly(vec3 n, float k) {
    return vec3(rgVaryNoiseSmoothly(n.x, k), rgVaryNoiseSmoothly(n.y, k), rgVaryNoiseSmoothly(n.z, k));
}

vec3 rgRand3relSeeded(vec2 co, float seed) {
    return rgVaryVec3NoiseSmoothly(rgRand3(co), seed) - 0.5;
}

vec3 rgInterpolatedRand3Seeded(vec2 v, float seed) {
    float sfractY = smoothstep(0.0, 1.0, fract(v.y));
    return mix(
        mix(rgRand3relSeeded(floor(v), seed), rgRand3relSeeded(vec2(floor(v.x), ceil(v.y)), seed), sfractY),
        mix(rgRand3relSeeded(vec2(ceil(v.x), floor(v.y)), seed), rgRand3relSeeded(ceil(v), seed), sfractY),
        smoothstep(0.0, 1.0, fract(v.x)));
}

vec4 randomGradient(vec2 pos, vec2 outPos, vec4 color1, float colorVariability, float randomSeed) {
    vec3 rndCol = rgInterpolatedRand3Seeded(vec2(0.0, pos.y), randomSeed) * colorVariability + color1.rgb;
    return vec4(rndCol, 1.0);
}
