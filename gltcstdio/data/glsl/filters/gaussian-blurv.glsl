vec4 blur(vec2 uv, vec2 outPos, float radius) {
    float pixel = 2.0 / u_SourceDim.y;
    float sizing = radius/(80.0*pixel);
    if (sizing>1.0) pixel *= sizing;
    float baseLod = log(sizing);
    vec4 total = texture(u_Source, vec2(u_SourceTransform * vec3(uv, 1.0)));
    total *= total;
    float div = 1.0;
    float d = pixel;
    float step = pixel;
    float lod = baseLod;
    float gInv = 1.0;
    while (d<radius) {
        vec2 u1 = uv-vec2(0.0, d);
        vec2 u2 = uv+vec2(0.0, d);
        float g = gaussian(d/radius);
        vec4 col1 = texture(u_Source, vec2(u_SourceTransform * vec3(u1, 1.0)), lod);
        vec4 col2 = texture(u_Source, vec2(u_SourceTransform * vec3(u2, 1.0)), lod);
        total += (col1*col1 + col2*col2);
        div += 2.0;
        gInv = 1.0/g;
        step = pixel*gInv;
        lod = baseLod + log(gInv);
        d+=step;
    }
    return sqrt(total/div);
}
