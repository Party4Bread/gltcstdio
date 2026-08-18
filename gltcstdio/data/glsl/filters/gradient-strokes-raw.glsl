vec2 perturbate(vec2 p, vec2 dir, float variability) {
    if (variability==0.0) return p;
    float M = variability<0.0 ? 1.0 : 5.0;
    float len = length(dir);
    vec2 ort = vec2(dir.y, -dir.x);
    float x = dot(p, dir) / (len*len) * M;
    float y = dot(p, ort) / (len*len);
    p += variability*0.4*dir*sin(1.0*x+21.54)*cos(5.0*y+5245.24);
    p += variability*0.2*dir*sin(3.0*x+0.21)*cos(15.0*y+0.575);
    p += variability*0.1*dir*sin(10.0*x-1.)*cos(50.0*y+1.255);
    p += variability*0.2*ort*sin(1.2*x+21.4)*cos(4.52*y+525.24);
    p += variability*0.1*ort*sin(3.4*x+0.1)*cos(17.0*y+0.75);
    p += variability*0.05*ort*sin(10.7*x-1.)*cos(47.7*y+1.25);
    return p;
}

vec2 getStroke(vec2 p, vec2 c, vec2 dir, float thickness, float variability) {
    if (dir.x==0.0 && dir.y==0.0) return vec2(0.0, 0.0);
    vec2 d = normalize(dir);
    //p = mat2(d, vec2(-d.y, d.x))*(p-c);
    float len = length(dir);
    p = perturbate(p, dir, variability);
    p = mat2(vec2(d.x, -d.y), d.yx)*(p-c);
    //p = (p-c);
    float l = length(vec2(max(0.0, abs(p.x)-len), p.y));
    float k = clamp((p.x+len)/(2.*len), 0.0, 1.0);
    return vec2(l<thickness ? 1.0 : 0.0, k);
}

vec2 response(vec2 u) {
    if (u.x==0.0 && u.y==0.0) return u;
    float len = length(u);
    len = 1.0;
    vec2 n = normalize(u);
    return len*n;
}

vec4 gradientStrokes(vec2 pos, vec2 outPos, float gradient, int size, float thickness, float variability, float angle, vec4 colorBkg, vec4 color2, vec4 color3, int gradientMap_specified, mat3 modelTransform) {
    float strokeIntensity = 0.0;
    mat3 inverseModelTransform = inverse(modelTransform);
    float resolution = length(inverseModelTransform[0].xy);
    vec2 sp = floor(pos*resolution+0.5)/resolution - fract(inverseModelTransform[2].xy)/resolution;
    float delta = 0.02;
    float step = 1.0/resolution;
    vec4 curColor = vec4(0.0, 0.0, 0.0, 1.0);
    float n = 0.;
    float ang = angle + PI_2;
    mat2 rot = rotation2(ang);
    float N = float(size);
    for(float j=-N; j<=N; ++j) {
        for (float i=-N; i<=N; ++i) {
//            vec2 pp = (u_InverseModelTransform * vec3(sp + vec2(i, j)*step, 1.0)).xy;
            vec2 pp = sp + vec2(i, j)*step;
            
            vec2 d = vec2(delta, 0.0);
            float sample00 = luma((gradientMap_specified==0 ? __source__(pp+d.xy) : __gradientMap__(pp+d.xy)).rgb);
            float sample01 = luma((gradientMap_specified==0 ? __source__(pp-d.xy) : __gradientMap__(pp-d.xy)).rgb);
            float sample10 = luma((gradientMap_specified==0 ? __source__(pp+d.yx) : __gradientMap__(pp+d.yx)).rgb);
            float sample11 = luma((gradientMap_specified==0 ? __source__(pp-d.yx) : __gradientMap__(pp-d.yx)).rgb);
            vec2 grad = vec2(
                (sample00-sample01)/(delta*2.0),
                (sample10-sample11)/(delta*2.0) ) * delta/2.0;
            //vec2 grad = getGradient(pp, delta)*delta/2.0;
            
            vec2 g = rot * (response(grad) /resolution/2.0 * N);
            //            vec2 st = getStroke(pos, pp, vec2(g.x, g.y), u_Thickness*0.01/resolution);
            vec2 st = getStroke(pos, pp, g, thickness/resolution, variability);
            if (st.x>0.) { // source of problem - for some reason the correct values get overriten => count tracing?
                ++n;
                strokeIntensity = max(strokeIntensity, st.x);
                //                vec4 color = vec4(st.x, st.y, n*0.1, 1.0);
                //                vec4 color = vec4(vec3(n*0.1), 1.0);
                float kGrad = (st.y-0.5)*gradient + 0.5;
                //                vec4 color = mix(color2, color3, kGrad);
                float alpha = mix(color2.a, color3.a, st.y);
                vec4 color = vec4(mix(color2.rgb, color3.rgb, mix(st.y, kGrad, min(color2.a, color3.a))), alpha);
                if (color.a<1.0) {
                    vec4 bkgCol = mix(__source__(pp-g*.5*gradient), __source__(pp+g*.5*gradient), 0.5);
                    color = vec4(mix(bkgCol.rgb, color.rgb, color.a), bkgCol.a);
                }
                if (luma(color.rgb) >= luma(curColor.rgb)) curColor = color;
                //                curColor.rgb += color.rgb;
            }
        }
    }

    vec4 bkgCol = __source__(pos);
    curColor = mix(colorBkg, curColor, strokeIntensity);
    curColor = vec4(mix(bkgCol.rgb, curColor.rgb, curColor.a), mix(bkgCol.a, curColor.a, curColor.a));
    return curColor;
}
