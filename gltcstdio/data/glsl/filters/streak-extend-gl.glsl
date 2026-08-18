vec4 streakExpand(vec2 uv, vec2 outPos, float len, float shadows, mat3 modelTransform) {
    mat3 inverseModelTransform = inverse(modelTransform);
    vec2 u = tf(inverseModelTransform, uv);

    float lightness = 1.0;
    vec4 col = __source__(uv);
    vec4 outColor = col;
    if (u.y>0.0) {
        float scale = length(inverseModelTransform[0].xy);
        if (abs(u.x)<1.0) {
            float step = scale*len;
            u.y = len==0.0? 0.0 : mod(u.y /*+ step*0.5*/, step);
            vec2 p = tf(modelTransform, u);
            outColor = __source__(p);
        }
        else if (shadows>0.0) {
            float dx = (abs(u.x)-1.0) / scale;
            float dy = abs(u.y) / scale;
            float maxDx = 0.25;
            float maxDy = 1.0;
//            if (dy<maxD) dx *= dy/maxD; //extends shadow horizontally
            if (dy<maxDy) dx += (maxDy-dy)/maxDy*shadows*maxDx;
            lightness = 1.0 - clamp(0.0, 1.0, shadows*maxDx-dx)/maxDx;
            if (lightness>1.0) lightness=1.0;
            outColor = col*vec4(lightness, lightness, lightness, 1.0);
        }
    }
    return outColor;
}
