vec4 pointGradient(vec2 pos, vec2 outPos, int source_specified, int mode, mat3 modelTransform, vec4 colorIn, vec4 colorOut) {
    vec2 u = pos; //(inverse(modelTransform) * vec3(pos, 1.0)).xy;
    float k = 0.0;
    if (mode==0 || mode>=3) k = min(length(u), 1.0);
    if (mode==1 || mode==3) k = (1.-k) * (atan(u.x, u.y)+PI)/PI2;
    if (mode==2 || mode==4) k = (1.-k) * atan(abs(u.x), u.y)/PI;
    
    vec4 outColor = mix(colorIn, colorOut, k);
    if (source_specified==1) return mergeColor(__source__(outPos), outColor);
    else return outColor;
}
