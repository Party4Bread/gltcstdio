vec4 cubeMap2Gl(vec2 pos, vec2 outPos, mat4 model3DTransform, mat3 texTransform, vec2 sourceDim) {
    // The pinch gesture bakes a uniform scale into model3DTransform (the
    // rotation touch client captures it). Scaling the cube is geometrically
    // inert for an environment map, so consume that scale as a view zoom:
    // dividing pos by it narrows / widens the field of view.
    float zoom = length(model3DTransform[0].xyz);
    vec3 dir = normalize(vec3(pos.x / zoom, pos.y / zoom, -1.0));
    mat4 inv = inverse(model3DTransform);
    dir = mat3(inv[0].xyz, inv[1].xyz, inv[2].xyz) * dir;
    float ratio = 1.0;
    float X = 0.5;
    float Y = 0.5;
    if (abs(dir.y) > abs(dir.z) * ratio && abs(dir.y) > abs(dir.x) * ratio) {
        X += -dir.x / dir.y * 0.5;
        Y += -dir.z / dir.y * 0.5;
    }
    else if (abs(dir.x) < abs(dir.z)) {
        X += dir.x / abs(dir.z) * ratio * 0.5 * -sign(dir.z);
        Y += dir.y / abs(dir.z) * 0.5;
    }
    else {
        X += dir.z / abs(dir.x) * ratio * 0.5 * -sign(dir.x);
        Y += dir.y / abs(dir.x) * 0.5;
    }
    // Fit the [0,1] face square into the largest centered square inside the image.
    float ar = sourceDim.x / sourceDim.y;
    float m = min(ar, 1.0);
    vec2 centered = (vec2(X, Y) * 2.0 - 1.0) * m;
    // texTransform is a view onto the source, so apply its inverse to the sample
    // coords: a drag/pinch then moves the image itself the natural way.
    vec2 uv = (inverse(texTransform) * vec3(centered, 1.0)).xy;
    return __source__(uv);
}
