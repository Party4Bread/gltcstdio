vec4 pixelate(vec2 uv, vec2 outPos, mat3 modelTransform, float pixelAspectRatio) {
    vec2 u = (inverse(modelTransform) * vec3(uv, 1.0)).xy;
    vec2 pixDim = pixelAspectRatio>=1.0 ? vec2(pixelAspectRatio, 1.0) : vec2(1.0, 1.0/pixelAspectRatio);
    vec2 pix = floor(u/pixDim+0.5) * pixDim; //floor(u+0.5);
    vec2 v = (modelTransform * vec3(pix.xy, 1.0)).xy;
    return __source__(v);
}
