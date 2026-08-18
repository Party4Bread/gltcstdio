vec4 pixelateVariable(vec2 pos, vec2 outPos, mat3 modelTransform, float regularity, float balance) {
    mat3 invModelTransform = inverse(modelTransform);
    vec4 sampledColor;
    vec2 uu;
    float scale = 1.0;
    for(int i=0; i<5; ++i) {
        mat3 sM = mat3(scale, 0.0, 0.0, 0.0, scale, 0.0, 0.0, 0.0, 1.0);
        mat3 isM = mat3(1./scale, 0.0, 0.0, 0.0, 1./scale, 0.0, 0.0, 0.0, 1.0);
        vec2 v = tf(isM*invModelTransform, pos);
        vec2 pix = round(v);
        vec2 u = tf(modelTransform*sM, pix);
        
        
        sampledColor = __source__(u);
        float scale2 = regularity==0.0 ? 0.0000001 : regularity*2.*scale;
        
        mat3 sM2 = mat3(scale2, 0.0, 0.0, 0.0, scale2, 0.0, 0.0, 0.0, 1.0);
        mat3 isM2 = mat3(1./scale2, 0.0, 0.0, 0.0, 1./scale2, 0.0, 0.0, 0.0, 1.0);
        v = tf(isM2*invModelTransform, pos);
        pix = round(v);
        u = tf(modelTransform*sM2, pix);
        
        float total = 0.0;
        for(int j=-1; j<=1; ++j) {
            for(int i=-1; i<=1; ++i) {
                vec4 other = __source__(u + scale*0.5*vec2(float(i), float(j)));
                total += length(sampledColor.rgb - other.rgb);
            }
        }
        float dist = total/8.0;
        if (dist >= (0.5 + balance*0.5) * 1.717) break;
        
        scale *= 2.;
    }

    return sampledColor;

}
