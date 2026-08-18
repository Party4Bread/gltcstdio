vec2 getIndexRange(float y, float scale, float height, float variability) {
    float z = scale;
    float regularity = 0.25/(variability+1e-6);
    float amp = (0.1 + 0.1 / regularity) / z;
    float k = 0.1+height;
    float y1 = y + 1.0-amp;
    float y2 = y + 1.0+amp;
    return vec2(floor(y1/k), ceil(y2/k));
}

float wave(float i, float x, float scale, float phase, float height, float variability) {
    float z = scale;
    float regularity = 0.25/(variability+1e-6);
    float p = phase*i + sin(i*1.5)*10.0 / regularity;
    float freq = (6.0 + 0.0009*sin(i*4.) / regularity) * z;
    float amp = (0.1 + 0.1*sin(i*10.15) / regularity) / z;
    float k = 0.1+height;
    return  i*k - 1.0 + amp*sin(freq*x + p);
}

vec3 getColor(float k, vec3 base, float variability) {
    return base + variability * vec3(cos(k*10.0), sin(k*7.4), sin(k*14.0+1.0));
}

vec4 genWaves(vec2 uv, vec2 outPos, vec4 color, float colorVariability, float randomSeed, float variability, mat3 modelTransform) {
    float yinv = -1.0; // set to 1.0 to flip Y
    float N = 24.0;
    mat3 m = inverse(modelTransform);
    float scale = length(m[0].xy);
    float phase = m[2].x;
    float height = -yinv * m[2].y*0.05;
    float Y = yinv*uv.y;
    vec2 range = getIndexRange(Y, scale, height, variability);

    int step = 0;
    for(float i=range.x; i<=range.y; ++i) {
        if (Y < wave(i, uv.x, scale, phase, height, variability*variability)) {
            return vec4(getColor(6.89 + randomSeed*0.1 + 0.1*colorVariability*i /*+ uv.x*0.08*/, color.rgb, .5*colorVariability), color.a);
        }
        if ((step++) > 100) break;
    }

    return color;
}
