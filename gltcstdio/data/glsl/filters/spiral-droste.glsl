vec4 spiralDroste(vec2 uv, vec2 outPos, vec2 sourceDim, float intensity, float distortion, float thickness, float shadows, vec4 colorShadow, vec4 colorBorder, mat3 texTransform) {
    vec2 u = uv;

    float d = length(u);

    float p = intensity > 0.0 ? 1.0/(1.0+intensity*10.0) : 1.0+pow(-intensity*100.0, 0.75);

    float angle = atan(u.y, u.x); //getVecAngle(u, d);

    float widthAngle = PI/4.0;

    angle = mod(angle, PI2);

    float scale360 = intensity*intensity * 0.1; 
    float a = angle/PI2;
    float s = pow(scale360, a);
    float dd = log(d*s) / log(scale360);
    float ddd = mod(dd, 1.0);
    if (ddd<thickness) return colorBorder;
    vec2 coord = mix(ddd, exp(ddd)/exp(1.0), 1.0-distortion) * vec2(cos(angle), sin(angle));

    //float shadowing = (u_Shadows==0.0 ? 1.0 : (u_Shadows<0.0 ? 1.0/pow(ddd, u_Shadows*0.02) : pow(ddd, u_Shadows*0.02)));

    //float winding = dd-ddd - a;
    //float shadowing = u_Shadows==0.0 ? 1.0 : min(1.0, 1.0 + winding*u_Shadows*0.01);

    float winding = dd-ddd - a;
    vec2 scoord = coord - shadows*vec2(1.0, 1.0) * mix(1.0, pow(scale360, -winding), shadows*0.1);
    float ds = length(scoord);
    float shadowing = 1.0 - (ds>1.0 ? mix(1.0, max(0.0, 6.0-5.0*ds), 0.5+shadows*0.5): 1.0);

    return mix(__source__(tf(inverse(texTransform), coord)), colorShadow, shadowing); // * vec4(vec3(shadowing), 1.0);
}
