vec2 distort(vec2 pos, vec2 a, vec2 b, vec2 splits, vec4 rect, float intensity, float seed, int mode) {
    vec2 c = (a+b)/2.0;
    if (mode<=1) {
        vec2 p = c + (pos-c)*pow(1.05, intensity);
        return p;
    }
    else if (mode==2) {
        vec2 rnd = rand2relSeeded(splits, seed+122.1);
        return pos + vec2(rnd.x*intensity*0.02, 0.0);
    }
    else if (mode==3) {
        vec2 rnd = rand2relSeeded(splits, seed+122.1);
        return pos + vec2(0.0, rnd.y*intensity*0.02);
    }
    else if (mode==4) {
        vec2 rnd = rand2relSeeded(splits, seed+122.1);
        if (abs(rnd.x)>abs(rnd.y)) {
            return pos + vec2(rnd.x*intensity*0.02, 0.0);
        }
        else {
            return pos + vec2(0.0, rnd.y*intensity*0.02);
        }
    }
    else if (mode==5) {
        vec2 rnd = rand2relSeeded(splits, seed+122.1);
        if (rect.z-rect.x>rect.w-rect.y) {
            return pos + vec2(rnd.x*intensity*0.02, 0.0);
        }
        else {
            return pos + vec2(0.0, rnd.y*intensity*0.02);
        }
    }
    else if (mode==6) {
        vec2 delta = (pos-c);
        return c -delta*pow(1.05, intensity);
    }
    else if (mode<=8) {
        vec2 rnd = rand2relSeeded(splits, seed+122.1);
        float dx = rect.z-rect.x;
        float dy = rect.w-rect.y;
        if (dx>dy) {
            return pos + vec2(sign(rnd.x)*dx*intensity*0.02, 0.0);
        }
        else {
            return pos + vec2(0.0, sign(rnd.y)*dy*intensity*0.02);
        }
    }
    else if (mode==9) {
        vec2 rnd = rand2relSeeded(splits, seed+122.1);
        float dx = rect.z-rect.x;
        float dy = rect.w-rect.y;
        if (dx>dy) {
            return pos + vec2(sign(rnd.x)*dx/dy*intensity*0.0005, 0.0);
        }
        else {
            return pos + vec2(0.0, sign(rnd.y)*dy/dx*intensity*0.0005);
        }
    }
    else {
        vec2 p = c + mat2(cos(intensity*0.1), sin(intensity*0.1), -sin(intensity*0.1), cos(intensity*0.1))*(pos-c);
        return p;
    }
}

float rounded(float x, float prec) {
    return floor(x/prec+0.5)*prec;
}

float withBias(float x, float b) {
    float s = sign(b);
    float ab = abs(b);
    //return pow(x+0.5, pow(2.0, -s * min(ab, sqrt(ab)))) - 0.5;
    return pow(x+0.5, pow(2.0, -s*ab)) - 0.5;
}

vec4 dichotomicBreak(vec2 uv, vec2 outPos, vec2 sourceDim, float intensity, int iterations, float variability, float randomSeed, vec4 color, float thickness, int mode, mat3 modelTransform) {
    //intensity = sign(intensity)*intensity*intensity*0.01;

    vec2 bias = (modelTransform*vec3(0.0, 0.0, 1.0)).xy;
    float scale = 1.0/length(vec2(modelTransform[0][0], modelTransform[0][1]));

    float ratio = rounded(sourceDim.x/sourceDim.y, 0.01); // preview coherence
    float pixel = 2.0/sourceDim.y;
    vec2 p = uv;

    bool border = false;
    vec4 rect;
    float rndStep = 1.0;
    if (mode==1 || mode==8 || mode==9) rndStep = 0.0;
    float regularity = 1.0-variability;
    
    for(int j=0; j<iterations; ++j) {
        rect = vec4(-ratio, -1.0, ratio, 1.0);

        bool horSplit = true;
        vec2 splits = vec2(0.0, 0.0); // preview coherence

        float sPos = 0.0; // position in 1D split space
        float sscale = 0.5;
        float inverter = 0.0;

        for (float i=0.0; i+sPos<scale; ++i) {
            vec2 rnd = rand2relSeeded(splits, randomSeed+122.1+rndStep*float(j));
            vec2 size = rect.zw-rect.xy;
            if (size.x<pixel || size.y<pixel) break;

            if (rnd.x+0.5<regularity*2.0) horSplit = size.y>size.x;
            float variability = 1.0-max(0.0, (regularity*2.0-1.0));

            if (horSplit) {
                float Y = mix(rect.y, rect.w, variability*withBias(rnd.y, bias.y)+0.5);
                if (abs(Y-p.y)<thickness*0.1) { border = true; break; }
                if (p.y<Y) { rect.w = Y; ++splits.y; sPos += inverter*sscale; } else { rect.y = Y; splits.y += 100.0; sPos += (1.0-inverter)*sscale; }
            }
            else {
                float X = mix(rect.x, rect.z, variability*withBias(rnd.x, bias.x)+0.5);
                if (abs(X-p.x)<thickness*0.1) { border = true; break; }
                if (p.x<X) { rect.z = X; ++splits.x; sPos += inverter*sscale; } else { rect.x = X; splits.x += 100.0; sPos += (1.0-inverter)*sscale; }
            }
            horSplit = !horSplit;
            inverter = 1.0-inverter;
            sscale *= 0.5;
            bias *= 0.5;
        }
        if (border) break;
        p = distort(p, rect.xy, rect.zw, splits, rect, intensity, randomSeed, mode);
    }
    vec4 col = __source__(uv);

    vec4 outCol = border ? vec4(mix(col.rgb, color.rgb, color.a), col.a) : __source__(p);
    return outCol;
}
