vec4 whirl(vec2 pos, vec2 outPos, mat3 modelTransform, float intensity, float unwind, vec4 highFreqColor) {
    mat3 inverseModelTransform = inverse(modelTransform);
    vec2 u = tf(inverseModelTransform, pos);

    float d = length(u);

    if (d>=1.0) {
        return __source__(pos);
    }
    else {
        float bal = unwind;
        if (bal != 0.5) {
            if (bal==1.0 || d < bal) {
                float ratio2 = d/bal;
                d = 0.5 * ratio2;
            }
            else {
                float ratio2 = (d-bal)/(1.0-bal);
                d = 0.5 * (1.0-ratio2);
            }
        }
        
        float dangle = intensity * 10. * (1.0-cos(d*2.0*PI));
        float ca = cos(dangle);
        float sa = sin(dangle);
        vec2 rotated = vec2(ca*u.x - sa*u.y, ca*u.y + sa*u.x);

        float darken = 0.0;
        if (highFreqColor.a!=0.0) {
            float d = length(rotated*vec2(min(1.5, 1.00+abs(intensity*3.0)), 1.0));
            float sHeight = highFreqColor.a*4.0;
            float sSlope = 1.0+highFreqColor.a*3.0;
            darken = clamp(sHeight-d*sSlope, 0.0, 1.0);
//            darken *= u_Shadows*0.01;
        }
        vec2 coord = tf(modelTransform, rotated);
        vec4 col = __source__(coord);
        
        return mix(col, vec4(highFreqColor.rgb, col.a), darken);
    }
}
