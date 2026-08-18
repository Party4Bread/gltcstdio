vec4 rockSalt(vec2 pos, vec2 outPos, float intensity, int iterations, float shapeAspectRatio, float distortion, mat3 modelTransform) {
    mat3 inverseModelTransform = inverse(modelTransform);
    vec2 u = tf(inverseModelTransform, pos);

    float tileWidth = 2.0;
    float tileHeight = 2.0 * shapeAspectRatio;

    vec2 tileSize = vec2(length(vec2(modelTransform[0][0], modelTransform[1][0])) * tileWidth,
                         length(vec2(modelTransform[0][1], modelTransform[1][1])) * tileHeight );

    intensity = intensity * 0.1;
    float s = 1.0 + intensity;

    vec2 tileCenter;
    vec2 p;

    for(int i=0; i<iterations; ++i) {
        float row = floor(u.y/tileHeight);
        float column = floor(u.x/tileWidth);

        tileCenter = vec2((column+0.5) * tileWidth, (row+0.5) * tileHeight);

        vec2 v = u - tileCenter;

        p = (modelTransform * vec3(v*s + tileCenter, 1.0)).xy;

        vec2 r;
        bool borderX = false;
        bool borderY = false;
        if (distortion > 0.0) {
            float d = distortion;
            r = v / vec2(tileWidth, tileHeight) + vec2(0.5, 0.5);

            if (r.x < d/2.0) {
                r.x = 2.0*r.x/d;
                borderX = true;
                p.x -= tileSize.x*(1.0-r.x)/(0.5+r.x);
            }
            else if (r.x > 1.0-d/2.0) {
                r.x = 2.0*(1.0-r.x)/d;
                borderX = true;
                p.x += tileSize.x*(1.0-r.x)/(0.5+r.x);
            }

            if (r.y < d/2.0) {
                r.y = 2.0*r.y/d;
                borderY = true;
                p.y -= tileSize.y*(1.0-r.y)/(0.5+r.y);
            }
            else if (r.y > 1.0-d/2.0) {
                r.y = 2.0*(1.0-r.y)/d;
                borderY = true;
                p.y += tileSize.y*(1.0-r.y)/(0.5+r.y);
            }
        }
        u = (inverseModelTransform * vec3(p, 1.0)).xy;//p;
    }

    vec4 outColor = __source__(p);
   
    return outColor;           
}
