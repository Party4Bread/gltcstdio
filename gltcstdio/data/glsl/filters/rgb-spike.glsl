vec2 getOffsetPos(mat3 transform, vec2 pos, float k, float power) {
    mat2 tScaleRot = mat2(transform[0].xy, transform[1].xy); //mat2(transform);
    vec2 u = tScaleRot*vec2(1.0, 0.0);
    vec2 v = tScaleRot*vec2(0.0, 1.0);
    vec2 nu = normalize(u);
    vec2 nv = normalize(v);
    vec2 t = vec2(transform[2][0], transform[2][1])*k;
    float tu = dot(nu, t);
    float tv = dot(nv, t);
    float scale = length(u);

    float pu = dot(nu, pos);
    if (pu<=tu-scale || pu>=tu+scale) return pos;
    float kk = pow((1.0 + cos((pu-tu)/scale*PI))/2.0, pow(1.07, -power*100.));

    return pos - nv * kk*tv;
}

vec4 rgbSpike(vec2 pos, vec2 outPos, int mode, float power, mat3 modelTransform, mat3 redTransform, mat3 greenTransform, mat3 blueTransform) {
            vec4 col = __source__(pos);
            float k = 1.0;
            
            mat3 rmt = modelTransform;
            mat3 gmt = modelTransform;
            mat3 bmt = modelTransform;
            
            if (mode==1) {
                vec2 dir = normalize(modelTransform[1].xy);
                vec2 itr = modelTransform[2].xy - 2. * dir * dot(dir, modelTransform[2].xy);
//                gmt = mat3(mat2(modelTransform));//mat3(1.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 1.0);
                gmt = mat3(modelTransform[0], modelTransform[1], vec3(0., 0., 1.));
                rmt = mat3(modelTransform[0], modelTransform[1], vec3(itr, 1.0));           
            }
            else if (mode==2) {
                //gmt = mat3(mat2(modelTransform));
                gmt = mat3(modelTransform[0], modelTransform[1], vec3(0., 0., 1.));
                rmt = mat3(modelTransform[0], modelTransform[1], vec3(-modelTransform[2].xy, 1.0));
            }
            
            vec4 red = __source__(getOffsetPos(rmt*redTransform, pos, k, power));
            vec4 green = __source__(getOffsetPos(gmt*greenTransform, pos, k, power));
            vec4 blue = __source__(getOffsetPos(bmt*blueTransform, pos, k, power));
            vec4 outColor =  vec4(red.r, green.g, blue.b, (red.a+green.a+blue.a)/3.0);
            return outColor;
        }
