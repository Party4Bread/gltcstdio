vec4 moire(vec2 uv, vec2 outPos, int source_specified, float intensity1, float intensity2, float intensity3, float intensity4, float intensity5, vec4 color1, vec4 color2, float thickness, mat3 viewTransform) {
    vec2 u = uv;
    float scale = 1./length(vec2(viewTransform[0][0], viewTransform[0][1]));
    float t = (1.0-thickness)*5000.0/scale;
    //float pixel = 2.0/u_Tex0Dim.y;
    u = floor(u*t+0.5)/t;

    float k1 = intensity1*intensity1;
    float k2 = intensity2*intensity2;
    float k3 = intensity3*intensity3;
    float k4 = intensity4*intensity4;
    float k5 = intensity5*intensity5;
    float d = u.y*u.x*k1
        + length(u)*k2
        + u.y*u.y*k3
        + u.x*u.x*k4
        + u.y*k5;
    float f = fract(d)*2.0;

    vec4 outColor = f<=1.0 ? color1 : color2;
    if (source_specified==1) return mergeColor(__source__(outPos), outColor);
    else return outColor;
}
