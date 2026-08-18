vec2 distort9(vec2 pos, vec4 rect, vec2 splits, float intensity, float seed) {
    vec2 rnd = rand2relSeeded(splits, seed+122.1);
    float dx = rect.z-rect.x;
    float dy = rect.w-rect.y;
    if (dx>dy) return pos + vec2(sign(rnd.x)*dx/dy*intensity*0.0005, 0.0);
    else       return pos + vec2(0.0, sign(rnd.y)*dy/dx*intensity*0.0005);
}

float withBias(float x, float b) {
    float s = sign(b);
    float ab = abs(b);
    return pow(x+0.5, pow(2.0, -s*ab)) - 0.5;
}

float rounded(float x, float prec) {
    return floor(x/prec+0.5)*prec;
}

bool inWindow(vec2 p, vec2 wc, vec2 wax, vec2 wpp, float winA, float winB) {
    return abs(dot(p-wc,wax))<=winA && abs(dot(p-wc,wpp))<=winB;
}

vec2 windowSliceX(float Y, vec2 wc, vec2 wax, float winA, float winB) {
    float ax=wax.x, ay=wax.y, dy=Y-wc.y;
    float lo=-1e30, hi=1e30;
    if (abs(ax)>1e-6) { float a=wc.x+(-winA-ay*dy)/ax, b=wc.x+(winA-ay*dy)/ax; lo=max(lo,min(a,b)); hi=min(hi,max(a,b)); }
    else if (abs(ay*dy)>winA) return vec2(1e30,-1e30);
    if (abs(ay)>1e-6) { float a=wc.x+(ax*dy-winB)/ay, b=wc.x+(ax*dy+winB)/ay; lo=max(lo,min(a,b)); hi=min(hi,max(a,b)); }
    else if (abs(ax*dy)>winB) return vec2(1e30,-1e30);
    return vec2(lo,hi);
}

vec2 windowSliceY(float X, vec2 wc, vec2 wax, float winA, float winB) {
    float ax=wax.x, ay=wax.y, dx=X-wc.x;
    float lo=-1e30, hi=1e30;
    if (abs(ay)>1e-6) { float a=wc.y+(-winA-ax*dx)/ay, b=wc.y+(winA-ax*dx)/ay; lo=max(lo,min(a,b)); hi=min(hi,max(a,b)); }
    else if (abs(ax*dx)>winA) return vec2(1e30,-1e30);
    if (abs(ax)>1e-6) { float a=wc.y+(ay*dx-winB)/ax, b=wc.y+(ay*dx+winB)/ax; lo=max(lo,min(a,b)); hi=min(hi,max(a,b)); }
    else if (abs(ay*dx)>winB) return vec2(1e30,-1e30);
    return vec2(lo,hi);
}

vec4 schema3b(vec2 uv, vec2 outPos, vec2 sourceDim, vec2 outDim, float intensity, int iterations, float pixelation, float variability, float randomSeed, vec4 color, float thickness, float aspectRatio, mat3 modelTransform, mat3 windowTransform) {
    float srcRatio = rounded(sourceDim.x/sourceDim.y, 0.01);   // source AR (drives the window)
    float outAR    = rounded(outDim.x/outDim.y, 0.01);         // output AR (drives the subdivision)
    float pixel = 2.0/outDim.y;

    // subdivision controls (same convention as dichotomic-break: modelTransform sets depth+bias)
    vec2 bias = (modelTransform*vec3(0.0, 0.0, 1.0)).xy;
    float scale = 1.0/length(vec2(modelTransform[0][0], modelTransform[0][1]));

    float th = thickness*0.1;
    float bm = 0.001;                                          // on-boundary margin for the window tests

    // --- window geometry: a rotated rectangle in output-uv, showing the source at ITS OWN
    //     aspect ratio (no cover-fit). Half-extent winA along wax, winB along its perpendicular.
    //     The subdivision below carves this out of its OWN cells (splits snap to the window
    //     edges), so the reserved region parts around the rotated window as a cell staircase.
    vec2  wc  = windowTransform[2].xy;
    vec2  wax = normalize(windowTransform[0].xy);              // window local-x axis
    float winA = srcRatio * length(windowTransform[0].xy);     // half-extent along wax (uv)
    float winB =            length(windowTransform[1].xy);     // half-extent perpendicular (uv)
    vec2  wpp = vec2(-wax.y, wax.x);                           // window local-y axis
    vec2  wl  = (inverse(windowTransform) * vec3(uv, 1.0)).xy;  // window-local coords (for sampling)

    // (2) shatter: dichotomic-break (mode 9) over the OUTPUT canvas.
    vec2 p = uv;
    bool border = false;
    vec4 rect;
    float regularity = 1.0-variability;

    for (int j=0; j<iterations; ++j) {
        rect = vec4(-outAR, -1.0, outAR, 1.0);
        bool horSplit = true;
        vec2 splits = vec2(0.0, 0.0);
        float sPos = 0.0;
        float sscale = 0.5;
        float inverter = 0.0;
        vec2 b = bias;

        for (float i=0.0; i+sPos<scale; ++i) {
            vec2 rnd = rand2relSeeded(splits, randomSeed+122.1);   // mode 9 -> rndStep 0
            vec2 size = rect.zw-rect.xy;
            if (size.x<pixel || size.y<pixel) break;

            // don't subdivide inside the window: once the whole cell fits inside it, stop
            // (keeps the interior a single clean block, no inner cells/borders). Only the
            // boundary cells keep splitting -> the staircase carve stays intact.
            if (j==0) {
                vec2 rc = 0.5*(rect.xy+rect.zw), rh = 0.5*size;
                float ax=abs(wax.x), ay=abs(wax.y);
                float uc=dot(rc-wc,wax), vc=dot(rc-wc,wpp);
                // margin so a cell whose side sits exactly on a snapped split (= on the window
                // boundary) still counts as fully inside despite float noise.
                if (abs(uc)+rh.x*ax+rh.y*ay <= winA+0.001 && abs(vc)+rh.x*ay+rh.y*ax <= winB+0.001) break;
            }

            if (rnd.x+0.5<regularity*2.0) horSplit = size.y>size.x;
            float var2 = 1.0-max(0.0, (regularity*2.0-1.0));

            if (horSplit) {
                float Y = mix(rect.y, rect.w, var2*withBias(rnd.y, b.y)+0.5);
                // window carve (undistorted pass): only a split whose segment would actually
                // CUT the window is snapped, onto the window boundary at the cut's own column
                // (nearest boundary value to the random position; splits that miss the window
                // stay fully random -> the original axis-aligned exclusion rule).
                if (j==0) {
                    vec2 sx = windowSliceX(Y, wc, wax, winA, winB);
                    float c0 = max(sx.x, rect.x), c1 = min(sx.y, rect.z);
                    if (c0 < c1) {
                        vec2 sy = windowSliceY(0.5*(c0+c1), wc, wax, winA, winB);
                        bool loNear = abs(Y-sy.x) < abs(sy.y-Y);
                        float Yn = loNear ? sy.x : sy.y;
                        if (!(Yn>rect.y && Yn<rect.w)) Yn = loNear ? sy.y : sy.x;
                        if (Yn>rect.y && Yn<rect.w) Y = Yn;
                    }
                }
                // line-work is suppressed per-pixel: never draw a border pixel whose own point
                // on the split line lies inside the window (bm keeps a split sitting exactly
                // on the boundary counted as inside, so the window isn't framed).
                if (abs(Y-p.y)<th && !(j==0 && inWindow(vec2(p.x, Y), wc, wax, wpp, winA+bm, winB+bm))) { border = true; break; }
                if (p.y<Y) { rect.w = Y; ++splits.y; sPos += inverter*sscale; } else { rect.y = Y; splits.y += 100.0; sPos += (1.0-inverter)*sscale; }
            }
            else {
                float X = mix(rect.x, rect.z, var2*withBias(rnd.x, b.x)+0.5);
                if (j==0) {
                    vec2 sy = windowSliceY(X, wc, wax, winA, winB);
                    float c0 = max(sy.x, rect.y), c1 = min(sy.y, rect.w);
                    if (c0 < c1) {
                        vec2 sx = windowSliceX(0.5*(c0+c1), wc, wax, winA, winB);
                        bool loNear = abs(X-sx.x) < abs(sx.y-X);
                        float Xn = loNear ? sx.x : sx.y;
                        if (!(Xn>rect.x && Xn<rect.z)) Xn = loNear ? sx.y : sx.x;
                        if (Xn>rect.x && Xn<rect.z) X = Xn;
                    }
                }
                if (abs(X-p.x)<th && !(j==0 && inWindow(vec2(X, p.y), wc, wax, wpp, winA+bm, winB+bm))) { border = true; break; }
                if (p.x<X) { rect.z = X; ++splits.x; sPos += inverter*sscale; } else { rect.x = X; splits.x += 100.0; sPos += (1.0-inverter)*sscale; }
            }
            horSplit = !horSplit;
            inverter = 1.0-inverter;
            sscale *= 0.5;
            b *= 0.5;
        }
        if (border) break;
        // the undistorted cell that carved the window: if its centre is inside the window,
        // this is a reserved cell -> clean source (clamped past the true edge, so the steps
        // read as a stepped edge). Otherwise fall through to the shatter's distortion.
        if (j==0) {
            vec2 cc = 0.5*(rect.xy+rect.zw);
            if (abs(dot(cc-wc,wax))<=winA && abs(dot(cc-wc,wpp))<=winB)
                return __source__(clamp(wl, vec2(-srcRatio, -1.0), vec2(srcRatio, 1.0)));
        }
        p = distort9(p, rect, splits, intensity, randomSeed);
    }

    // (3) pixelate the sample coordinate (folds the `pixelate` stage in), then sample.
    vec2 ps = p;
    if (pixelation>1e-4) ps = floor(p/pixelation+0.5)*pixelation;

    if (border) {
        vec4 col = __source__(uv);
        return vec4(mix(col.rgb, color.rgb, color.a), col.a);
    }
    return __source__(ps);
}
