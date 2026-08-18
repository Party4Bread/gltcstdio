vec4 radialInterpolate(vec2 pos, vec2 outPos, float thickness, int count, float balance, float len, float angle, mat3 modelTransform) {
    float thickn = thickness;
    float ha = angle/2.0;
    float angleRange = angle/float(count);

    vec2 u = tf(inverse(modelTransform), pos);

    if (angle <= PI2) {

        float halfThickPos = 1.0-thickn/2.0;

        float phase = 0.0;
        vec2 center = vec2(0.0, 0.0);

        for(int i=0; i<int(ceil(len)); ++i) {
            float d = length(u - center);
            if (d>=1.0-thickn && d<=1.0) {

                float da = 0.0;
                if (d > 0.0) {
                    float ang = acos((u.x-center.x)/d);
                    if (u.y-center.y < 0.0) ang = PI2 - ang;

                    ang += phase + PI/2.0 + ha;
                    ang = mod(ang + PI2, PI2);
                    if (ang <= angle) {
                        ang = angle-ang;
                        float index = floor(ang/angle*float(count));
                        float ang1 = phase -ha + angleRange*index;
                        float ang2 = phase -ha + angleRange*(index+1.0);
                        vec2 pos1 = tf(modelTransform, vec2(center.x-d*sin(ang1), center.y-d*cos(ang1)));
                        vec4 col1 = __source__(pos1);
                        vec2 pos2 = tf(modelTransform, vec2(center.x-d*sin(ang2), center.y-d*cos(ang2)));
                        vec4 col2 = __source__(pos2);

                        //return mix(col1, col2, (ang-angleRange*index)/angleRange);
                        float ka = (ang-angleRange*index)/angleRange;
                        return mix(col1, col2, mix(1.0-ka, ka, 0.5+0.5*balance));
                    }
                }
            }

            float endAng = phase -ha + ((mod(float(i), 2.0)==0.0) ? angle : 0.0);
            vec2 posH = vec2(center.x-halfThickPos*sin(endAng), center.y-halfThickPos*cos(endAng));
            center = 2.0*posH - center;
            phase += PI;
        }

//        phase = 0.0;
        float endAng = -ha;
        vec2 posH = vec2(-halfThickPos*sin(endAng), -halfThickPos*cos(endAng));
        center = 2.0*posH;
        phase = PI;

        for(int i=1; i<int(ceil(len)); ++i) {
            float d = length(u - center);
            if (d>=1.0-thickn && d<=1.0) {

                float da = 0.0;
                if (d > 0.0) {
                    float ang = acos((u.x-center.x)/d);
                    if (u.y-center.y < 0.0) ang = PI2 - ang;

                    ang += phase + PI/2.0 + ha;
                    ang = mod(ang + PI2, PI2);
                    if (ang <= angle) {
                        ang = angle-ang;
                        float index = floor(ang/angle*float(count));
                        float ang1 = phase -ha + angleRange*index;
                        float ang2 = phase -ha + angleRange*(index+1.0);
                        vec2 pos1 = tf(modelTransform, vec2(center.x-d*sin(ang1), center.y-d*cos(ang1)));
                        vec4 col1 = __source__(pos1);
                        vec2 pos2 = tf(modelTransform, vec2(center.x-d*sin(ang2), center.y-d*cos(ang2)));
                        vec4 col2 = __source__(pos2);

                        //return mix(col1, col2, (ang-angleRange*index)/angleRange);
                        float ka = (ang-angleRange*index)/angleRange;
                        return mix(col1, col2, mix(1.0-ka, ka, 0.5+0.5*balance));
                    }
                }
            }

            float endAng = phase -ha + ((mod(float(i), 2.0)==1.0) ? angle : 0.0);
            vec2 posH = vec2(center.x-halfThickPos*sin(endAng), center.y-halfThickPos*cos(endAng));
            center = 2.0*posH - center;
//            center += vec2(1.0, 0.0);
            phase += PI;
        }

    }

    return __source__(pos);
}
