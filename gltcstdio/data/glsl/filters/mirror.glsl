vec4 mirror(vec2 pos, vec2 outPos, vec2 sourceDim, int mode, float border, vec4 borderColor, int borderType, mat3 modelTransform, mat3 axisTransform) {
    float inRatio = sourceDim.x/sourceDim.y;
    vec2 axisNormal = normalize(mat2(axisTransform) * vec2(1.0, 0.0));
    vec2 axisPoint = (axisTransform * vec3(0.0, 0.0, 1.0)).xy;

    mat3 translate;
    if (mode==1) translate = mat3(1.0, 0.0, 0.0, 0.0, 1.0, 0.0, inRatio, 0.0, 1.0);
    else if (mode==2) translate = mat3(1.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 1.0, 1.0);
    else translate = mat3(1.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 1.0);

    float d;
    vec2 pos2;

    if (mode==3) {
        // Point symmetry - 180° rotation around center point
        vec2 center = axisPoint;
        pos2 = 2.0*center - pos;
        // Use axis normal to determine dividing line (allows rotation control)
        d = dot(pos - center, axisNormal);
    } else {
        // Line symmetry (modes 0, 1, 2)
        d = dot(pos-axisPoint, axisNormal);
        pos2 = pos - 2.0*d*axisNormal;
    }

    vec2 t1 = tf(inverse(modelTransform * translate), pos);
    vec2 t2 = tf(inverse(modelTransform * translate), pos2);
    float k = d<=0.0 ? 0.0 : 1.0;
    if (borderType==1) {
        if (abs(d)<border*0.1) {
            k = (d+(border*0.1)) / (border*0.2);
        }
    }
    vec4 mirColor = mix(__source__(t1), __source__(t2), k);

    vec4 bordColor = vec4(0., 0., 0., 0.);
    if (borderType==100) {
        if (abs(d)<border*0.1) bordColor = borderColor;
    }
    else if (borderType==101) {
        if (abs(d)<border*0.1) {
            k = 1.0 - abs(d) / (border*0.1);
            bordColor = vec4(borderColor.rgb, borderColor.a * k);
        }
    }

    return mergeColor(mirColor, bordColor);
}
