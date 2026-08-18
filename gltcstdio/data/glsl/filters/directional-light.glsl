vec4 alphaBlend(vec4 a, vec4 b) {
    float sumA = a.a + b.a;
    if (sumA==0.0) return a;
    float k1 = a.a/sumA;
    float k2 = b.a/sumA;
    vec4 outc = k1*a + k2*b;
    outc.a = 1.0 - (1.0-a.a) * (1.0-b.a);
    return outc;
}

vec4 directionalLight(vec2 uv, vec2 outPos, vec2 sourceDim, float intensity, float lightAngle, float blur, vec4 color, float variability, float colorVariability, mat3 modelTransform) {                   
    vec4 inc = __source__(uv);

    vec2 t = tf(inverse(modelTransform), uv);

    float lightDistance = 1.0 + sourceDim.x/sourceDim.y; // XXX parameterize
    float angleSize = lightAngle;

    vec4 baseColor = color;


    float lightX = -lightDistance;
    float lightY = 0.0;
    vec2 light = vec2(lightX, lightY);
    float d = length(light);

    float dx = t.x-lightX;
    float dy = t.y-lightY;
    vec2 delta = vec2(dx, dy);

    vec4 col = vec4(0.);
    bool inLight = false;

    float angle = atan(delta.y, delta.x);

    int N = 1 + int(ceil(variability*5.));
    for(int i = 0; i < N; ++i) {
        float subAngleSize = angleSize/float(N);
        float subPhase = - angleSize/2.0 + subAngleSize/2.0 + subAngleSize*float(i);

        // perturbate
        vec2 var = rand2(vec2(float(N), float(i)));
        subPhase += subAngleSize * var.y*variability;
        float sizeVar = var.x<0.0 ? 1.0 + var.x*variability*0.5 : 1.0 + var.x*variability;
        subAngleSize *= sizeVar;
        float subIntensity = intensity*100.;

        float deltaAngle = angle-subPhase;
        if (deltaAngle < -PI) deltaAngle += 2.0*PI;
        else if (deltaAngle > PI) deltaAngle -= 2.0*PI;

        if (deltaAngle > -subAngleSize/2.0 && deltaAngle <= subAngleSize/2.0) {
            inLight = true;
            vec4 newColor = baseColor;
            float kk = 1.0;
            if (blur > 0.0) {
                float distFromBorder = (subAngleSize/2.0 - abs(deltaAngle)) / subAngleSize * 2.0;
                float blurDist = blur;
                if (distFromBorder < blurDist) {
                    kk = distFromBorder/blurDist;
                }
            }
            if (colorVariability > 0.0) {
                vec4 hsl = rgbToHsl(color);
                hsl[0] = hsl[0] + var.y*colorVariability;
                newColor = hslToRgb(hsl);
            }
            newColor.a = subIntensity*0.01 * kk;
            color = alphaBlend(col, newColor);
        }
    }


    if (inLight) {
        vec4 outc = inc + color*color.a;
        outc.a = 1.0;
        return outc;
    }
    else {
        return inc;
    }
}
