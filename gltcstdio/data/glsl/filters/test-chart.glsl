vec4 testChart(vec2 pos, vec2 outPos, mat3 modelTransform, vec4 color1, vec4 color2) {
    vec2 u = (inverse(modelTransform) * vec3(pos, 1.0)).xy;
    if (u.x<0.) {
        if (u.y<0.) {
            vec2 uv = (u+0.5) * 2.0;
            float d = length(uv);
            if (d>1.0) return color1;
            else return mod(floor(d*6.0), 2.0)==0.0 ? color1: color2;
        }
        else {
            vec2 uv = u;//(u+vec2(0.5, 0.0));
            return hslToRgb(vec4(uv.x*360., 1.0, uv.y, 1.0));
        }
    }
    else {
        if (u.y<0.) {
            vec2 uv = abs(u); //(u+vec2(-0.5, 0.5)) * 0.5;
            float d = uv.x + uv.y;
            float g = (sin(d*d*25.0)+1.0)*0.5;
            return vec4(g, g, g, 1.0);
        }
        else {
            vec2 uv = u;//(pos+vec2(-0.5, 0.5)) * 0.5;
            return mod(floor(uv.x*6.0)+floor(uv.y*6.0), 2.0)==0.0 ? color1: color2;
        }
    }
    return mix(color1, color2, mod(floor(u.x), 2.0));
}
