float ssdSquareAngle(vec2 u) {
    float ax = abs(u.x);
    float ay = abs(u.y);
    float d = max(ax, ay);
    if (d < 0.0001) return 0.0;

    vec2 n = u / d;
    float p;
    if (n.x >= abs(n.y)) {
        p = n.y + 1.0;
    } else if (n.y > abs(n.x)) {
        p = 2.0 + (1.0 - n.x);
    } else if (n.x <= -abs(n.y)) {
        p = 4.0 + (1.0 - n.y);
    } else {
        p = 6.0 + (n.x + 1.0);
    }
    return p / 8.0 * PI2;
}

vec2 ssdSquareToCart(float d, float angle) {
    float p = mod(angle / PI2 * 8.0, 8.0);
    vec2 n;
    if (p < 2.0) {
        n = vec2(1.0, p - 1.0);
    } else if (p < 4.0) {
        n = vec2(1.0 - (p - 2.0), 1.0);
    } else if (p < 6.0) {
        n = vec2(-1.0, 1.0 - (p - 4.0));
    } else {
        n = vec2(-1.0 + (p - 6.0), -1.0);
    }
    return n * d;
}

vec4 squareSpiralDroste(vec2 uv, vec2 outPos, vec2 sourceDim, float intensity, float distortion, float shapeAspectRatio, float thickness, float shadows, vec4 colorShadow, vec4 colorBorder, mat3 texTransform) {
    vec2 u = uv * vec2(1.0 / shapeAspectRatio, 1.0);

    float d = max(abs(u.x), abs(u.y));

    float p = intensity > 0.0 ? 1.0/(1.0+intensity*10.0) : 1.0+pow(-intensity*100.0, 0.75);

    float angle = ssdSquareAngle(u);

    float widthAngle = PI/4.0;

    angle = mod(angle, PI2);

    float scale360 = intensity*intensity * 0.1;
    float a = angle/PI2;
    float s = pow(scale360, a);
    float dd = log(d*s) / log(scale360);
    float ddd = mod(dd, 1.0);
    if (ddd<thickness) return colorBorder;
    float coord_d = mix(ddd, exp(ddd)/exp(1.0), 1.0-distortion);
    vec2 coord = ssdSquareToCart(coord_d, angle) * vec2(shapeAspectRatio, 1.0);

    float winding = dd-ddd - a;
    vec2 scoord = coord * vec2(1.0 / shapeAspectRatio, 1.0) - shadows*vec2(1.0, 1.0) * mix(1.0, pow(scale360, -winding), shadows*0.1);
    float ds = max(abs(scoord.x), abs(scoord.y));
    float shadowing = 1.0 - (ds>1.0 ? mix(1.0, max(0.0, 6.0-5.0*ds), 0.5+shadows*0.5): 1.0);

    return mix(__source__(tf(inverse(texTransform), coord)), colorShadow, shadowing);
}
