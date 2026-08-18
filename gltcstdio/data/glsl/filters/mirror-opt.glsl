vec4 mirrorOpt(vec2 pos, vec2 outPos, vec2 sourceDim, mat3 modelTransform, mat3 axisTransform) {
    float inRatio = sourceDim.x/sourceDim.y;
    vec2 axisNormal = normalize(mat2(axisTransform) * vec2(1.0, 0.0));               
    vec2 axisPoint = (axisTransform * vec3(0.0, 0.0, 1.0)).xy;   
    mat3 translate = mat3(1.0, 0.0, 0.0, 0.0, 1.0, 0.0, inRatio, 0.0, 1.0);
    
    vec2 t = (inverse(modelTransform * translate) * vec3(mirrorPoint(pos, axisPoint, axisNormal), 1.0)).xy;
    return __source__(t);
}
