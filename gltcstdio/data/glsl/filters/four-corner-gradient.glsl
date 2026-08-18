vec4 fourCornerGradient(vec2 u, vec2 outPos, int source_specified, vec4 color1, vec4 color2, vec4 color3, vec4 color4) {
    float k1 = length(u-vec2(-1.0, -1.0));
    if (k1==0.0) return color1;

    float k2 = length(u-vec2(-1.0, 1.0));
    if (k2==0.0) return color2;

    float k3 = length(u-vec2(1.0, -1.0));
    if (k3==0.0) return color3;

    float k4 = length(u-vec2(1.0, 1.0));
    if (k4==0.0) return color4;

//    if (u_PosterizeCount<256.0) {
//        k1 = min(floor(k1*u_PosterizeCount) / (u_PosterizeCount-1.0), 1.0);
//        k2 = min(floor(k2*u_PosterizeCount) / (u_PosterizeCount-1.0), 1.0);
//        k3 = min(floor(k3*u_PosterizeCount) / (u_PosterizeCount-1.0), 1.0);
//        k4 = min(floor(k4*u_PosterizeCount) / (u_PosterizeCount-1.0), 1.0);
//    }

    float inv1 = 1.0/k1;
    float inv2 = 1.0/k2;
    float inv3 = 1.0/k3;
    float inv4 = 1.0/k4;
    float tot = inv1 + inv2 + inv3 + inv4;
    inv1 /= tot;
    inv2 /= tot;
    inv3 /= tot;
    inv4 /= tot;

    vec4 outColor = color1*inv1 + color2*inv2 + color3*inv3 + color4*inv4;
    if (source_specified==1) return mergeColor(__source__(outPos), outColor);
    else return outColor;
}
