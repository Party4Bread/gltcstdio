float orbit(vec2 z, mat3 t, int type) {
    //return 1.0/(abs(length(z) - 1.0));
    vec2 tz = tf(t, z);
    
    if (type==0) return length(tz);
    else if (type==1) return abs(length(tz) - 5.);
    else if (type==2) return abs(tz.y);
    else if (type==3) return abs(max(abs(tz.x), abs(tz.y)) - 5.); 
    else if (type==4) return sdSegment(tz, vec2(-8.0, 0.0), vec2(8.0, 0.0));
    else if (type==5) return length(fract(tz)-0.5)*5.;
    else return -1.0;
}

void threeOrbits(inout vec3 dist, vec2 z, mat3 t1, mat3 t2, mat3 t3, vec3 modes) {
        dist.x = min(dist.x, orbit(z, t1, int(modes.x)));
        dist.y = min(dist.y, orbit(z, t2, int(modes.y)));
        dist.z = min(dist.z, orbit(z, t3, int(modes.z))); 
}

vec3 getColor(float d, float offset, float channel) {
    float x = mod(d+offset + channel*PI2 + PI, PI2*3.0);
    if (x<PI2) return vec3(-0.5*cos(x)+0.5, 0.0, 0.0);
    else if (x<PI4) return vec3(0.0, -0.5*cos(x-PI2)+0.5, 0.0);
    else return vec3(0.0, 0.0, -0.5*cos(x-PI4)+0.5);
}

vec4 getCombinedColor(vec3 orbDist, float colorPower, float offset, vec4 color) {
        if (orbDist.y<0.0 && orbDist.z<0.0) {
            float dd = pow(orbDist.x, colorPower)+offset;
            float k = 0.5+0.5*cos(dd);
            vec3 rndCol = vec3(sin(dd*3.333), sin(dd*4.3434), sin(dd*3.88434));
            vec3 baseCol = color.rgb;// * cos(dd*6.343771);
            return vec4(mix(rndCol, baseCol, k), color.a);
        }
        else if (orbDist.z<0.0) {
            float dd = pow(orbDist.x, colorPower)+offset;
            float dd2 = pow(orbDist.y, colorPower)+offset;
            float k = 0.5+0.5*cos(dd2);
            vec3 col1 = color.rgb;
            vec3 col2 = vec3(sin(dd*3.333), sin(dd*4.3434), sin(dd*3.88434)); //orbDist.y>=0.0 ? getColor(pow(orbDist.y, colorPower)*orbitSize, offset, 1.0) : vec3(0.);
            return vec4(mix(col2, col1, k), color.a);
        }
        else {
            vec3 col1 = orbDist.x>=0.0 ? getColor(pow(orbDist.x, colorPower), offset, 0.0) : vec3(0.);
            vec3 col2 = orbDist.y>=0.0 ? getColor(pow(orbDist.y, colorPower), offset, 1.0) : vec3(0.);
            vec3 col3 = orbDist.z>=0.0 ? getColor(pow(orbDist.z, colorPower), offset, 2.0) : vec3(0.);
            float similarity = (dot(col1, col2) + dot(col2, col3) + dot(col3, col1))/3.0;
//                vec3 rgb = mix(color.rgb + col1 + col2 + col3, col1 + col2 + col3, similarity);
//                vec3 rgb = mix(mix(color.rgb, col1 + col2 + col3, 0.6), col1 + col2 + col3, similarity);
            vec3 rgb = mix((col1 + col2 + col3)*color.rgb*2.0, col1 + col2 + col3, similarity);
            return vec4(rgb, color.a);
        }    
    }

vec3 getOrbitModes(int mode, mat3 t0, inout mat3 t1, inout mat3 t2, inout mat3 t3) {
    vec3 modes = vec3(0., -1., -1.);
    t1 = inverse(t0);
    float baseMode = float(mode/10);
    int subMode = mode%10;
    if (baseMode<=5.0) {
        modes.x = baseMode; 
        if (subMode==1) { modes.y = baseMode; t2 = inverse(rotation3(PI)*t0); }
        else if (subMode==2) { modes.y = baseMode; t2 = inverse(translation3(vec2(0.5, 0.0))*t0); }
        else if (subMode==3) { modes.y = baseMode; t2 = inverse(translation3(vec2(1.0, 0.0))*t0); }
        else {
            modes.y = baseMode; modes.z = baseMode;
            if (subMode==4) { t2 = inverse(rotation3(PI/3.0)*t0); t3 = inverse(rotation3(PI2/3.0)*t0); }
            else if (subMode==5) { t2 = inverse(scaling3(1.5)*t0); t3 = inverse(scaling3(2.25)*t0); }
            else if (subMode==6) { t2 = inverse(translation3(vec2(0.0, 2.0))*t0); t3 = inverse(translation3(vec2(0.0, -2.0))*t0); }
            else if (subMode==7) { t2 = inverse(translation3(0.25*vec2(-SQRT3_2, -1.0))*t0); t3 = inverse(translation3(0.25*vec2(-SQRT3_2, 1.0))*t0); }
            else if (subMode==8) { t2 = inverse(translation3(0.5*vec2(-SQRT3_2, -1.0))*t0); t3 = inverse(translation3(0.5*vec2(-SQRT3_2, 1.0))*t0); }
            else if (subMode==9) { t2 = inverse(scaling3(1.5)*translation3(1.0*vec2(-SQRT3_2, -1.0))*t0); t3 = inverse(scaling3(2.25)*translation3(0.5*vec2(-SQRT3_2, 1.0))*t0); }
        }
    }
    else if (mode==60) { modes.x = 0.0; modes.y = 2.0; t2 = inverse(rotation3(PI)*t0); }
    else if (mode==61) { modes.x = 0.0; modes.y = 1.0; t2 = inverse(rotation3(PI)*t0); }
    else if (mode==62) { modes.x = 0.0; modes.y = 5.0; t2 = inverse(translation3(vec2(2.0, 0.0))*t0); }
    else if (mode==63) { modes.x = 0.0; modes.y = 1.0; t2 = inverse(translation3(vec2(2.0, 0.0))*t0); }
           
    return modes;
}

vec4 mandelbrotC(vec2 pos, vec2 outPos, int source_specified, mat3 modelTransform, mat3 offsetTransform, mat3 texTransform, int iterations, float julianess, float power, float offset, vec4 colorIn, vec4 colorOut) {
    float cj = cos(julianess * PI*0.5);
    float sj = sin(julianess * PI*0.5);

    mat3 invModelTransform = inverse(modelTransform*mat3(vec3(offsetTransform[0].xy, 0.0), vec3(offsetTransform[1].xy, 0.0), vec3(0.0, 0.0, 1.0)));

    vec2 uv = tf(invModelTransform, pos);
    vec2 t = cj*uv + sj*offsetTransform[2].xy;
    vec2 z0 = sj*uv + cj*offsetTransform[2].xy;
    vec2 z = z0;

    vec2 prev = t;
    int iter = 0;
    float d2 = 0.0;
    bool outside = true;

    if (power == 2.0) {
        while (iter < iterations) {
            ++iter;
            prev = z;
            z.x = prev.x*prev.x - prev.y*prev.y + t.x;
            z.y = 2.0*prev.x*prev.y + t.y;
            d2 = dot(z, z);
            if (d2 > 400000000.0) { outside = false; break; }
        }
    }
    else if (power == 3.0) {
        while (iter < iterations) {
            ++iter;
            prev = z;
            z.x = prev.x*prev.x*prev.x - 3.0*prev.y*prev.y*prev.x + t.x;
            z.y = -prev.y*prev.y*prev.y + 3.0*prev.x*prev.x*prev.y + t.y;
            d2 = dot(z, z);
            if (d2 > 400000000.0) { outside = false; break; }
        }
    }
    else {
        float d = length(z);
        while (iter < iterations) {
            ++iter;
            prev = z;
            float angle = atan(prev.y, prev.x);
            float dp = pow(d, power);
            z.x = dp*cos(power*angle) + t.x;
            z.y = dp*sin(power*angle) + t.y;
            d = length(z);
            if (d > 20000.0) { outside = false; break; }
        }
        d2 = d*d;
    }

    float d = sqrt(d2);
    // Branch-cut-free angle via acos(x/|v|). atan2 has a seam on the -x axis that
    // survives through the source sampler when sourceTransform scales the UV,
    // breaking the period-2 mirror wrap that would otherwise hide it.
    float angleT = acos(t.x / max(length(t), 1e-6));
    float angleZ0 = acos(z0.x / max(length(z0), 1e-6));
    float angle = cj*angleT + sj*angleZ0;

    float tx = angle/PI * 2.0 - 1.0;
    float ty = 1.0 + float(iter) - log(log(max(d, 2.718281828)))/log(max(power, 1.0001));
    if (offset != 0.0) ty = pow(max(ty, 0.0001), pow(1.05, -offset));
    vec2 s = vec2(tx, ty);

    vec4 texCol = __source__(tf(inverse(texTransform), s));
    vec4 inoutCol = outside ? colorIn : colorOut;
    return vec4(mix(texCol.rgb, inoutCol.rgb, inoutCol.a), texCol.a);
}
