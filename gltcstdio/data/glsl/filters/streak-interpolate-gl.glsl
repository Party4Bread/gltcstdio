vec4 streakInterpolate(vec2 uv, vec2 outPos, mat3 modelTransform, vec2 sourceDim, int count, float size, float textureSensitivity) {
    mat3 inverseModelTransform = inverse(modelTransform);
    
    vec2 u = tf(inverseModelTransform, uv);
    float ratio = sourceDim.x/sourceDim.y;
    float scale = length(inverseModelTransform[0].xy);
    float l = size*1.5 * max(1.0, ratio) * scale;
    float b = 0.2 * textureSensitivity * scale;
    float pixel = 2.0/sourceDim.y * scale;

    if (abs(u.x)<l && abs(u.y)<1.0+abs(b)) {
        float ya = -1.0;
        float yb = 1.0;
        if (b!=0.0) {
            vec2 p = vec2(u.x, ya);
            vec2 ip = (modelTransform * vec3(p, 1.0)).xy;
            vec4 c = __source__(ip);
            float value = (c.r+c.g+c.b);
            float threshold = 1.5;
            float dt = threshold * pixel/b;
            float dir = -sign(b * (value-threshold));
            //p.y  += dir*b;
            while (dir!=0.0 && abs(p.y-ya)<abs(b)) {
                p.y += dir*pixel;
                ip = (modelTransform * vec3(p, 1.0)).xy;
                c = __source__(ip);
                value = (c.r+c.g+c.b);
                float newdir = -sign(b * (value-threshold));
                if (dir!=newdir) dir = 0.0;
                threshold -= dir*dt;
            }
            ya = p.y;

            p = vec2(u.x, yb);
            ip = (modelTransform * vec3(p, 1.0)).xy;
            c = __source__(ip);
            value = (c.r+c.g+c.b);
            threshold = 1.5;
            dt = threshold * pixel/b;
            dir = sign(b * (value-threshold));
            //p.y  += dir*b;
            while (dir!=0.0 && abs(p.y-yb)<abs(b)) {
                p.y += dir*pixel;
                ip = (modelTransform * vec3(p, 1.0)).xy;
                c = __source__(ip);
                value = (c.r+c.g+c.b);
                float newdir = sign(b * (value-threshold));
                if (dir!=newdir) dir = 0.0;
                threshold += dir*dt;
            }
            yb = p.y;
        }

//        if (abs(u.y-ya)<pixel*1.7) return vec4(1.0, 0.0, 0.0, 1.0);

        if (u.y>=ya && u.y<=yb) {
            float stride = (yb-ya)/float(count); 
            float y = u.y-ya;//+1.0;
            float y1 = floor(y/stride)*stride + ya;//-1.0;
            float y2 = y1+stride;
            vec2 p1 = (modelTransform * vec3(u.x, y1, 1.0)).xy;
            vec2 p2 = (modelTransform * vec3(u.x, y2, 1.0)).xy;

            return mix(__source__(p1), __source__(p2), (u.y-y1)/stride);
        }
    }
    return __source__(uv);

}
