float getProgress(vec2 cc, float phasing, int mode) {
    int mm = mode%10;
    if (mm==0) return cc.x;
    else if (mm==1) return length(cc);
    else if (mm==2) return -phasing+length(cc);
    else if (mm==3) return phasing-length(cc);
    else if (mm==4) return phasing-length(cc*vec2(2.0, 0.5));
    else if (mm==5) return phasing * cos(cc.x/phasing*PI);
    else if (mm==6) return 0.5*phasing * (cos(cc.x/phasing*PI)+1.);
    else if (mm==7) return 0.5*phasing * (cos(length(cc)/phasing*PI)+1.);
    else if (mm==8) return 0.25*phasing * (cos(cc.x/phasing*PI)+1.)* (cos(cc.y/phasing*PI)+1.);
    else if (mm==9) return perlinNoise(cc/phasing) * phasing;
    else return phasing;
}

float getGlobalScaling(float progress, float phasing, int mode) {
    if (mode<10) {
        return 1. / smoothstep(phasing, 0., progress);
    }
    else {
        return 1.;
    }
}

float getBaseAngle(vec2 cc, float phasing, int mode) {
    int mm = mode%100;
    if (mm==20) return (cc.x+cc.y)/phasing*PI;
    else return 0.;
}

vec2 getBaseTranslate(vec2 cc, float phasing, int mode) {
    int mm = mode%100;
    if (mm==21) return vec2(0., cos((cc.x+cc.y)/phasing*PI));
    else return vec2(0.);
}

vec4 disintegrate(vec2 uv, vec2 outPos, vec2 outDim, int mode, int sourceBkg_specified, vec4 colorBkg, float regularity, float len, float power, float translateVar, float scaleVar, float angleVar, float shadows, float minimum, float threshold, mat3 modelTransform, float randomSeed) {
            vec2 u = (inverse(modelTransform) * vec3(uv, 1.)).xy;
            float phasing = len;
            float variability = 1. - regularity;
            float pixel = 2.0/outDim.y / length(modelTransform[0].xy);
            
            // progression
            float minProgress = minimum;
            float maxProgress = threshold;
        
            vec2 cell = floor(u);
            float N = ceil(pow(10.0, scaleVar*0.5)*.75 + translateVar);
            //vec4 color = vec4(.5, .5, .5, .1);
            vec4 color = mergeColor(sourceBkg_specified==1 ? __sourceBkg__(uv) : __source__(uv), colorBkg);
            //vec4 color = vec4(0., 0., 0., .1);
            for(float i=-N; i<=N; ++i) {
                for(float j=-N; j<=N; ++j) {
                    vec2 cc = cell + vec2(i, j);
                    vec2 rnd = rand2relSeeded(cc, randomSeed);
                    vec2 rnd2 = sineSurfaceRand2Seeded(.2+cc*0.75, randomSeed*2.); //rand2relSeeded(vec2(cc.y), randomSeed*2.);
        
                    float progress = getProgress(cc, phasing, mode) + phasing*(variability*rnd2.x+variability*variability*rnd.x);
                    progress = pow(abs(progress)/phasing, 1./power) * phasing * sign(progress);
                    progress = max(progress, phasing*minProgress);
                    if (progress>phasing*maxProgress) progress = phasing;
                    float globalScaling = getGlobalScaling(progress, phasing, mode);
        
                    float intensity = smoothstep(0., phasing, progress); //pow(smoothstep(0., phasing, progress), 1./power);
                    float cScale = pow(10.0, rnd.x*0.5*intensity*scaleVar*2.) * globalScaling;
                    float cAngle = getBaseAngle(cc, phasing, mode) + rnd.y*PI*intensity * angleVar;
                    vec2 cTr = getBaseTranslate(cc, phasing, mode) + rnd*intensity * translateVar*4.;
                    mat3 locTr = mat3(cScale*cos(cAngle), -cScale*sin(cAngle), 0.,
                                      cScale*sin(cAngle), cScale*cos(cAngle), 0.,
                                      cTr.x,  cTr.y, 1.);

                    vec2 relU = (locTr*vec3((u-cc)-.5, 1.)).xy;
                    float d = sdRectangle(relU, vec2(.5));
                    float trIntens = abs(log(cScale)) + 0.5*smoothstep(0.0, 0.5, abs(cAngle)) + length(cTr);


                    float shadowLen = shadows * trIntens;
//                    if (d<0.) color = __source__(tf(modelTransform, cc+relU+.5));
//                    else if (d<shadowLen) color.rgb*=smoothstep(0., shadowLen, d);

                    if (trIntens==0.0) {
                        if (d<0.) color = __source__(tf(modelTransform, cc+relU+.5));
                        else if (d<shadowLen) color.rgb*=smoothstep(0., shadowLen, d);
                    }           
                    else color = mix(
                        (d>0. && d<shadowLen) ? color*vec4(vec3(smoothstep(0., shadowLen, d)), 1.) : color, 
                        __source__(tf(modelTransform, cc+relU+.5)), 
                        smoothstep(pixel*.75, -pixel*.75, d) );

//                    color = mix(
//                        (d>0. && d<shadowLen) ? color*vec4(vec3(smoothstep(0., shadowLen, d)), 1.) : color, 
//                        __source__(tf(modelTransform, cc+relU+.5)), 
//                        smoothstep(pixel*.75, -pixel*.75, d) );
                }
            }
        
            return color;
        }
