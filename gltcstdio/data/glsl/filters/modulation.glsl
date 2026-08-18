vec2 getStart(vec2 p, vec2 dir, vec2 dim) {
    float kx1 = dir.x==0.0 ? -1.0 : (-dim.x-p.x)/dir.x;
    float kx2 = dir.x==0.0 ? -1.0 : (dim.x-p.x)/dir.x;
    float ky1 = dir.y==0.0 ? -1.0 : (-dim.y-p.y)/dir.y;
    float ky2 = dir.y==0.0 ? -1.0 : (dim.y-p.y)/dir.y;
    float k = kx1;
    if (k<0.0 || kx2>=0.0 && kx2<k) k = kx2;
    if (k<0.0 || ky2>=0.0 && ky2<k) k = ky2;
    if (k<0.0 || ky1>=0.0 && ky1<k) k = ky1;
    return p+k*dir;
}

vec4 modulation(vec2 pos, vec2 outPos, float intensity, float angle, float thickness, float smoothen, float step, vec4 color1, vec4 color2, float contrast, float brightness, float vignetting, float scanlines, vec2 sourceDim) {
    float ratio = sourceDim.x / sourceDim.y;
    //vec2 dir = normalize((u_ModelTransform*vec3(1.0, 0.0, 1.0)).xy);
    vec2 dir = vec2(cos(angle), sin(angle));

    float pixel = 2.0/sourceDim.y;
    step = pixel * 1.0 * step;

    vec2 dim = vec2(ratio, 1.0);
    vec2 p = getStart(pos, -dir, dim);
    float k = 0.0;
    float acc = 0.0;
    float diag = length(dim);

    float radius = thickness*0.02;
    float weight = step*333.33*intensity;
    //int N = int(ceil((length(p-pos)+radius)/step));
    int N = int(min((dim.x+dim.y)*2.01/pixel, ceil((length(p-pos)+radius)/step))); // min to prevent huge N coming from who knows where
    float bestL = 1e10;
    //int N = int(min(ceil((length(p-pos)+radius)/step), 2000.0));
    if (vignetting==0.0 && contrast==0.0 && brightness==0.0 && smoothen==0.0) {
        for (int i=0; i<N; ++i) {
            vec4 c = __source__(p);
            float val = (c.r+c.g+c.b);
            acc += weight*val;
            if (acc>=1.0) {
                vec2 dd = p-pos; bestL = min(bestL, dot(dd, dd)); // squared distance
                acc = 0.0;
            }
            p += step*dir;
        }
        k = smoothstep(radius, 0.0, sqrt(bestL));
    }
    else {
        for (int i=0; i<N; ++i) {
            vec4 c = __source__(p);
            float val = (c.r+c.g+c.b);
            val = (val-0.5)*contrast + 0.5 + brightness;
            if (vignetting!=0.0) {
                float vignette = mix(1.0, smoothstep(1.0, 0.0, length(p)/diag), vignetting);
                val *= vignette;
            }
            acc += weight*val;
            if (acc>=1.0) {
//                vec2 dd = p-pos; bestL = min(bestL, dot(dd, dd)); // squared distance
                bestL = min(bestL, length(p-pos));
                acc = 0.0;
            }

            if (smoothen>0.0) {
                acc = mix(acc, 0.5+0.5*sin(p.x*100.0), smoothen*91. * pixel);
            }

            p += step*dir;
        }
        k = smoothstep(radius, 0.0, bestL);
    }

    vec4 bkgCol = __source__(pos);
    vec4 lineColor = vec4(mix(bkgCol.rgb, color2.rgb, color2.a), bkgCol.a);
    vec4 backColor = vec4(mix(bkgCol.rgb, color1.rgb, color1.a), bkgCol.a);
    vec4 color = mix(backColor, lineColor, clamp(0.0, 1.0, k));

    vec4 outColor = color;//mix(bkgCol, vec4(mix(bkgCol.rgb, color.rgb, color.a), bkgCol.a), 1.0);
    if (scanlines!=0.0) {
        outColor.rgb *= mix(1.0, pow((1.1+sin(pos.y*400.0/ratio))*0.5, 0.4), scanlines);
    }
    
    return outColor;
}
