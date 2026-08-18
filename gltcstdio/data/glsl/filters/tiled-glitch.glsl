vec2 hash42sp(vec4 u, float hashStyle) {
    vec2 r1 = 0.5+0.5*sin(u.z + u.w + u.yx * 55.*sin(u.w + u.xy*15.88));

    vec2 r2 = fract(u.xy * u.yz*11.689 + u.yw);

    vec2 v = abs(fract(u.xy*101.0 + u.zw)-.5);
    //float ar = pow(1.012, fract(v.x+v.y+u.z)-0.5);
    float t = max(v.x, v.y)*(2.+10.*sin(u.z+u.w));
    vec2 r3 = fract(vec2(t, t));

    //vec2 r4 = fract(vec2(u.x*u.y, 3.*sin(u.x*7.)*sin(u.y*520.*sin(u.z+u.w))));
    vec2 r4 = fract((u.xz + u.zy + u.yw)*3.);

    float p = 10.;
    float k1 = pow(0.5+0.5*sin(hashStyle*1.5), p);
    float k2 = pow(0.5+0.5*sin(hashStyle*2.7895), p);
    float k3 = pow(0.5+0.5*cos(hashStyle*1.5), p);
    float k4 = pow(0.5+0.5*cos(hashStyle*2.7895), p);
    float kTotal = k1 + k2 + k3 + k4;

    return (k1*r1 + k2*r2 + k3*r3 + k4*r4) / kTotal;
}

struct LevelParams {
    mat3 transform;
    mat3 inverseTransform;
    float startScale;
    float subLevels;
    float subThreshold;
    int modeMap[4];
    float coverage;
    float streakInterpolateCoverage;
    int streakSubLevels;
    float streakVerticality;
    float seed;
    float hashStyle;
};

        vec4 multiGlitch(vec2 pos, vec2 outPos, vec2 sourceDim, int mode, 
                        float coverage, float randomSeed, float randomType, int levels, float threshold, int streakLevels, float streakBalance, float streakCoverage,
                        int  overMode, float overRandomSeed, float overRandomType, int overLevels, float overThreshold, float overCoverage, float overStreakCoverage, int overStreakLevels, float overStreakBalance, mat3 overTransform, 
                        mat3 tileTransform1, mat3 tileTransform2, mat3 tileTransform3, mat3 tileTransform4, 
                        mat3 modelTransform) {                       
        
            LevelParams params;
            vec4 col = __source__(pos);
            vec4 outCol = vec4(0., 0., 0., 1.);

            if (coverage>0.0 || streakCoverage>0.0) {
                mat3 inverseModelTransform = inverse(modelTransform);
                float startScale = length(inverseModelTransform[0].xy); 

                int modeMap[4];
                if (mode<16) {
                    for(int i=0; i<4; ++i) modeMap[i] = mode;
                }
                else { 
                    mode -= 16;
                    modeMap[0] = mode & 15;
                    mode /= 16;
                    modeMap[1] = mode & 15;
                    mode /= 16;
                    modeMap[2] = mode & 15;
                    mode /= 16;
                    modeMap[3] = mode & 15;
                }
                params.transform = inverseModelTransform;
                params.inverseTransform = modelTransform;
                params.startScale = startScale;
                params.subLevels = float(levels);
                params.subThreshold = threshold;
                params.modeMap[0] = modeMap[0];
                params.modeMap[1] = modeMap[1];
                params.modeMap[2] = modeMap[2];
                params.modeMap[3] = modeMap[3];
                params.coverage = coverage;
                params.streakInterpolateCoverage = streakCoverage;
                params.streakSubLevels = streakLevels;
                params.streakVerticality = (streakBalance+1.)*.5;
                params.seed = randomSeed;
                params.hashStyle = randomType;
//                params = LevelParams(
//                    inverseModelTransform,
//                    modelTransform,
//                    startScale,
//                    float(levels),
//                    threshold,
//                    modeMap,
//                    coverage,
//                    streakCoverage,
//                    streakLevels,
//                    (streakBalance+1.)*.5,
//                    randomSeed, 
//                    randomType);
                {
        vec2 _uv = pos;
        LevelParams _params = params;
        vec4 _srcCol = col;
        
        float startScale = _params.startScale;
        float subLevels = _params.subLevels;
        float subThreshold = _params.subThreshold;
        float streakInterpolateCoverage = _params.streakInterpolateCoverage;
        int streakSubLevels = _params.streakSubLevels;
        float streakVerticality = _params.streakVerticality;
        float seed = _params.seed;
        float hashStyle = _params.hashStyle;
        mat3 currentTransform = _params.transform;
        mat3 inverseCurrentTransform = _params.inverseTransform;

        vec2 v;
        vec2 relId;
        vec2 rnd;
        int streakLevel = 1;
        for(float i = 0.; i<float(streakSubLevels); ++i) {
            if (i!=0.0) {
            //currentTransform *= mat3(2., 0., 0., 0., 2., 0., 0., 0., 1.); // parallax version
                currentTransform = mat3(2., 0., 0., 0., 2., 0., 0., 0., 1.) * currentTransform;
                inverseCurrentTransform = inverseCurrentTransform * mat3(0.5, 0., 0., 0., 0.5, 0., 0., 0., 1.);
            }
            relId = floor(tf(currentTransform, _uv));
            rnd = hash42sp(vec4(relId*0.08845, i, seed), hashStyle);
            if (/*i==subLevels-1. ||*/ rnd.x>subThreshold) {
                break;
            }
            ++streakLevel;
        }
        //id = tf(inverseCurrentTransform, relId);

        if (rnd.y<=streakInterpolateCoverage /*&& streakLevel <= streakSubLevels*/) {
            vec2 uu1, uu2;
            float k;
            v = tf(currentTransform, _uv) - relId;
            if (fract(rnd.y*13.323)<streakVerticality) {
                k = v.y;
                uu1 = tf(inverseCurrentTransform, relId + vec2(v.x, -0.0001));
                uu2 = tf(inverseCurrentTransform, relId + vec2(v.x, +0.9999));
            }
            else {
                k = v.x;
                uu1 = tf(inverseCurrentTransform, relId + vec2(-0.0001, v.y));
                uu2 = tf(inverseCurrentTransform, relId + vec2(0.9999, v.y));
            }
            vec4 src1 = __source__(uu1);
            vec4 src2 = __source__(uu2);                
            {
        vec2 _uv = uu1;
        
        float startScale = _params.startScale;
        float subLevels = _params.subLevels;
        float subThreshold = _params.subThreshold;
        //int[] modeMap = _params.modeMap;
        float seed = _params.seed;
        float hashStyle = _params.hashStyle;
        float coverage = _params.coverage;
    
        mat3 currentTransform = _params.transform;
        mat3 inverseCurrentTransform = _params.inverseTransform;
        float scale = startScale;
        vec2 v;
        vec2 id;
        vec2 relId;
        vec2 rnd;
        for(float i = 0.; i<subLevels; ++i) {
            if (i!=0.) {
                //currentTransform *= mat3(2., 0., 0., 0., 2., 0., 0., 0., 1.); // parallax version
                currentTransform = mat3(2., 0., 0., 0., 2., 0., 0., 0., 1.) * currentTransform;
                inverseCurrentTransform = inverseCurrentTransform * mat3(0.5, 0., 0., 0., 0.5, 0., 0., 0., 1.);     
            }
            relId = floor(tf(currentTransform, _uv));
            rnd = hash42sp(vec4(relId*0.13137, i, seed), hashStyle);
            if (i==subLevels-1. || rnd.x>subThreshold) {
                break;
            }
    
            scale *= 2.;
        }
        id = tf(inverseCurrentTransform, relId);
        
        vec3 col;
        int modeIndex = int(floor(rnd.y*4.0));
        int mode = _params.modeMap[modeIndex];
        
        mat3 tileTransform;
        if (modeIndex==0) tileTransform = tileTransform1;
        else if (modeIndex==1) tileTransform = tileTransform2;
        else if (modeIndex==2) tileTransform = tileTransform3;
        else tileTransform = tileTransform4;
        mat3 inverseTileTransform = inverse(tileTransform);
        
        v = tf(currentTransform, _uv) - relId -.5;
        outCol = vec4(0.);
        if (fract(rnd.x*6.222+rnd.y*8.233) <= coverage) {  
            if (mode==0) { // noise
                vec2 w = inverseTileTransform[0].xy;
                w = floor(vec2(dot(w, vec2(20.)), dot(w, vec2(20., -20.))));
                vec2 pixId = relId + 1.23 * (floor(v * w) + floor((length(tileTransform[0].xy)*5.*inverseTileTransform[2].xy) * w));
                outCol = __source__(hash22(pixId));
            }
            else if (mode==1) { // square non interpolated
                v = vec2(0., max(abs(v.x), abs(v.y)));
                vec2 vv = tf(inverseCurrentTransform, relId + (tf(inverseTileTransform, v) + 0.5));
                outCol = __source__(vv);
            }
            else if (mode==2) { // circle interpolated
                float size = 0.5 + inverseTileTransform[2].y;
                float d = length(v);
                float ang = atan(v.y, v.x);
                if (d<=size) {
                    float spikeCount = 4.;
                    float anglePeriod = PI2/spikeCount;
                    float a1 = floor(ang/anglePeriod)*anglePeriod;
                    float a2 = a1 + anglePeriod;
                    float k = (ang-a1) / anglePeriod;
                    float ds = d * 10.0 * length(inverseTileTransform[0].xy); // tile parameter
                    vec2 center = relId + 0.5;
                    vec2 u1 = tf(inverseCurrentTransform, center+ds*vec2(cos(a1), sin(a1)) + inverseTileTransform[2].x);
                    vec2 u2 = tf(inverseCurrentTransform, center+ds*vec2(cos(a2), sin(a2)) + inverseTileTransform[2].x);
                    vec4 col1 = __source__(u1);
                    vec4 col2 = __source__(u2);
                    outCol = mix(col1, col2, k);
                }    
            }
            else if (mode==3) { // square interpolated
                bool vert = abs(v.y)>abs(v.x);
                float a = vert ? v.y : v.x;
                vec2 u1 = vert ? vec2(-a, a) : vec2(a, -a);
                vec2 u2 = vec2(a, a);
                float k = (v.x+v.y) / (2.*a);
                u1 = tf(inverseCurrentTransform, relId + (tf(inverseTileTransform, u1) + 0.5));
                u2 = tf(inverseCurrentTransform, relId + (tf(inverseTileTransform, u2) + 0.5));
                vec4 col1 = __source__(u1);
                vec4 col2 = __source__(u2);
                outCol = mix(col1, col2, k);
            }
            else if (mode==4) { // leaf
                float size = 0.5;
                float ang = atan(inverseTileTransform[0].y, inverseTileTransform[0].x);
                float orientation = ang<0.0 ? sign(mod(relId.x+relId.y, 2.)-0.5) : 1.;
                if (rnd.y > abs(ang)/PI) orientation = -orientation;
    //            float orientation = (rnd.y-.5);
                float p = orientation*v.x*v.y < 0. ? 40. : 2.5;
                float d = p>30. ? max(abs(v.x), abs(v.y)) : pow(pow(abs(v.x), p) + pow(abs(v.y), p), 1./p);
                v = vec2(0., d);
                if (v.y<=size) {
                    vec2 vv = tf(inverseCurrentTransform, relId + (tf(inverseTileTransform, v) + 0.5));
                    outCol = __source__(vv);
                }
            }        
            else if (mode<=6) { // circles and squares
                float scale = length(inverseTileTransform[0].xy);
                bool invert = scale < 1.0;
                if (invert) scale = 1./scale;
                float ds  = fract(scale);
                float N = max(floor(scale), 1.);
                vec2 w = fract((v + 0.5)*N) - 0.5;
                vec2 center = floor((v + 0.5)*N)/N * 2. - 1.0 + 1.0/N;
                float ang = atan(inverseTileTransform[0].y, inverseTileTransform[0].x);
                float keepX = 1.0;
                float keepY = 1.0;
                if (ang>0.0) keepX = 1.0 - ang/PI;
                else keepY = 1.0 + ang/PI;
                bool hide = abs(center.x)>keepX || abs(center.y)>keepY;
                
                float size = mix(0.5, 0.15, ds);
                bool outside = (mode==6 && length(w)>size) || (mode==5 && (abs(w.x)>size || abs(w.y)>size));
                if (!(hide || outside)) {
                    outCol = __source__(id + inverseTileTransform[2].xy);
                }
                else if (invert) {
                    outCol = __source__(id);
                }
            }
            else if (mode==7) { // bw checkerboard
                vec2 w = inverseTileTransform[0].xy;
                w = floor(vec2(dot(w, vec2(16.)), dot(w, vec2(16., -16.))));
                
                float minScale = startScale * 2.0 * pow(2., floor(2.*inverseTileTransform[2].y));
                float maxScale = max(minScale, startScale * 4.0 * pow(2., floor(2.*inverseTileTransform[2].x)));
                float scale2 = clamp(scale, minScale, maxScale);
                float invScaleRatio = scale2/scale;
                mat3 tr = mat3(invScaleRatio, 0., 0., 0., invScaleRatio, 0., 0., 0., 1.) * currentTransform;
                v = tf(tr, _uv) - .5;
    
                vec2 pixId = floor(v * w);
                float k = mod(pixId.x + pixId.y, 2.);
                outCol = vec4(vec3(k), 1.);
            }
            else if (mode==8) { // bw 45° hatch
                float Xn = 8. /* length(inverseTileTransform[0].xy)*/;
                float scale2 = startScale * 4.;//min(max(scale, startScale * 4.), startScale * 4.);
                //float scale2 = scale;
                float invScaleRatio = scale2/scale;
                mat3 tr = mat3(invScaleRatio, 0., 0., 0., invScaleRatio, 0., 0., 0., 1.) * currentTransform;
                v = tf(tr, _uv) - .5;
                float piN = PI/16.;
                float ang = floor(atan(inverseTileTransform[0].y, inverseTileTransform[0].x)/piN)*piN;
                v = (rotation2(ang)*v) * length(inverseTileTransform[0].xy) + 2.*inverseTileTransform[2].xy;
                float k = mod(floor((v.x+v.y*sign(rnd.y-.5))*Xn), 2.);
                outCol = vec4(vec3(k), 1.);
            }
            else if (mode==9) { // compact disk effect
                float N = floor(1000. * pow(0.25, length(inverseTileTransform[2].xy)));// could be a parameter
                //float N = 32. * startScale / scale;// doesn't really work (angles need to be rounded differently) but could interesting to get right
                float offset = PI*.5 + PI/N + atan(inverseTileTransform[1].y, inverseTileTransform[1].x);
                float ang = atan(v.y, v.x);
                ang = round((ang-offset)/PI2*N) / N*PI2 + offset;
                float dist = length(inverseTileTransform[0].xy) * 0.5 / max(abs(cos(ang)), abs(sin(ang))); // could be a parameter
                //float dist = 0.3; // could be a parameter
                v = dist * vec2(cos(ang), sin(ang));
                vec2 u = tf(inverseCurrentTransform, relId + (v + 0.5));
                outCol = __source__(u);
            }
            else if (mode==10) { // hsl
                float s = length(inverseTileTransform[0].xy)*0.05;
                v += 0.5;
                float N = 16.;
                float ang = floor(atan(inverseTileTransform[0].y, inverseTileTransform[0].x)/PI*N)*PI/N;
                v = rotation2(ang) * v;
                vec4 rgb = hslToRgb(vec4((v.x+inverseTileTransform[2].x*length(tileTransform[0].xy))*360., 1., v.y+inverseTileTransform[2].y*length(tileTransform[0].xy), 1.));
                //vec4 rgb = clamp(vec4(hsl2rgb(vec3((v.x+inverseTileTransform[2].x*length(tileTransform[0].xy)), 1., v.y+inverseTileTransform[2].y*length(tileTransform[0].xy))), 1.), 0., 1.);
                vec4 inc = __source__(_uv);
                float dist = length(inc.rgb - rgb.rgb);
                float k = 1.0 - smoothstep(0.0, 1.7, dist) * s;
                rgb = mix(inc, rgb, k);
                             
                outCol = rgb;
            }
    //        else if (mode==11) { // hsl adaptive
    //            float colorScaling = 0.5 * length(inverseTileTransform[0].xy); // could be a parameter
    //            vec4 inc = __source__(id);
    //            vec4 hslInc = rgbToHsl(inc);
    //            v += 0.5;
    //            float saturation = hslInc.y; // or 1.0
    //            vec4 rgb = hslToRgb(vec4(hslInc.x + v.x*360.*colorScaling, saturation, hslInc.z + v.y*colorScaling, 1.));
    //            outCol = rgb;
    //        }
            else if (mode==11) { 
                float N = round(4. * abs(inverseTileTransform[0].x));
                vec2 center = vec2(0., floor((v.y + 0.5)*N)/N * 2. - 1.0 + 1.0/N)*.5;
                vec2 dv = abs(v - center);
                if (dv.x < 0.45 && dv.y < 0.4/N) {
                    float s = inverseTileTransform[2].x + 1.0;
                    vec2 u1 = tf(inverseCurrentTransform, relId + (s*vec2(0., -0.5) + 0.5));
                    vec2 u2 = tf(inverseCurrentTransform, relId + (s*vec2(0., 0.5) + 0.5));
                    outCol = mix(__source__(u1), __source__(u2), center.y + 0.5);
                }
            }
            else if (mode==12) { // scale
                v *= vec2(2., 2.);
                v = tf(inverseTileTransform, v);
                outCol = __source__(tf(inverseCurrentTransform, relId + (v + 0.5)));
            }
            else if (mode==13) { // halftone lines
                float lum = luma(__source__(_uv).rgb);
                v = tf(inverseTileTransform, v*vec2(8., 8.));
                float y = abs(mod(v.y+1.0, 2.) - 1.0);
                float k = lum>y ? 1.0 : 0.0;
                outCol = vec4(vec3(k), 1.);
            }
            else if (mode==14) { // red green gradient
                float lum = luma(__source__(id).rgb);
                float contrast = length(tileTransform[0].xy);
                outCol = vec4(v+.5, 0.5 + contrast*(lum-0.5), 1.);
            }
            else if (mode==15) {     
                vec2 center = sign(rnd-0.5) * 0.5;
                vec2 dv = v - center;
                float N = floor(16.0 * length(inverseTileTransform[0].xy));
                float angOffset = 0.0;
                float ang = atan(dv.y, dv.x) + angOffset;
                float k = abs(mod(ang/PI*N*2., 2.0) - 1.0);
                float kCol = atan(inverseTileTransform[0].y, inverseTileTransform[0].x)/PI;
                float lum = 0.;
                for(int i =0; i<5; ++i) {
                    vec2 w = tf(inverseCurrentTransform, relId + (0.1+0.15*float(i))*vec2(cos(ang), sin(ang)));
                    lum += luma(__source__(w).rgb);            
                }
                lum /= 5.;
                k = lum>k ? 1.0 : 0.0;
                if (kCol==0.0) {
                    outCol = vec4(vec3(k), 1.);
                }
    //            else if (kCol>0.0) {
    //                vec4 col1 = __source__(id + vec2(inverseTileTransform[2].x, 0.));
    //                vec4 col2 = __source__(id + 1.0 + vec2(0.0, inverseTileTransform[2].y));
    //                if (luma(col1.rgb)>luma(col2.rgb)) k = 1. - k;
    //                vec4 outCol1 = vec4(vec3(k), 1.);
    //                vec4 outCol2 = mix(col1, col2, k);
    //                outCol = mix(outCol1, outCol2, kCol);
    //            }
    //            else {
    //                vec4 col1 = __source__(vec2(inverseTileTransform[2].x, 0.));
    //                vec4 col2 = __source__(vec2(0.0, inverseTileTransform[2].y));
    //                if (luma(col1.rgb)>luma(col2.rgb)) k = 1. - k;
    //                vec4 outCol1 = vec4(vec3(k), 1.);
    //                vec4 outCol2 = mix(col1, col2, k);
    //                outCol = mix(outCol1, outCol2, abs(kCol));
    //            }
                else {
                    vec2 u1 = vec2(inverseTileTransform[2].x, 0.);
                    vec2 u2 = vec2(0.0, inverseTileTransform[2].y);
                    if (kCol>0.0) {
                        u1 += id;
                        u2 += id + 1.;
                    }
                    vec4 col1 = __source__(u1);
                    vec4 col2 = __source__(u2);
                    if (luma(col1.rgb)>luma(col2.rgb)) k = 1. - k;
                    vec4 outCol1 = vec4(vec3(k), 1.);
                    vec4 outCol2 = mix(col1, col2, k);
                    outCol = mix(outCol1, outCol2, abs(kCol));
                }
            }
        }
    
    };
            vec4 col1 = mergeColor(src1, outCol);
            {
        vec2 _uv = uu2;
        
        float startScale = _params.startScale;
        float subLevels = _params.subLevels;
        float subThreshold = _params.subThreshold;
        //int[] modeMap = _params.modeMap;
        float seed = _params.seed;
        float hashStyle = _params.hashStyle;
        float coverage = _params.coverage;
    
        mat3 currentTransform = _params.transform;
        mat3 inverseCurrentTransform = _params.inverseTransform;
        float scale = startScale;
        vec2 v;
        vec2 id;
        vec2 relId;
        vec2 rnd;
        for(float i = 0.; i<subLevels; ++i) {
            if (i!=0.) {
                //currentTransform *= mat3(2., 0., 0., 0., 2., 0., 0., 0., 1.); // parallax version
                currentTransform = mat3(2., 0., 0., 0., 2., 0., 0., 0., 1.) * currentTransform;
                inverseCurrentTransform = inverseCurrentTransform * mat3(0.5, 0., 0., 0., 0.5, 0., 0., 0., 1.);     
            }
            relId = floor(tf(currentTransform, _uv));
            rnd = hash42sp(vec4(relId*0.13137, i, seed), hashStyle);
            if (i==subLevels-1. || rnd.x>subThreshold) {
                break;
            }
    
            scale *= 2.;
        }
        id = tf(inverseCurrentTransform, relId);
        
        vec3 col;
        int modeIndex = int(floor(rnd.y*4.0));
        int mode = _params.modeMap[modeIndex];
        
        mat3 tileTransform;
        if (modeIndex==0) tileTransform = tileTransform1;
        else if (modeIndex==1) tileTransform = tileTransform2;
        else if (modeIndex==2) tileTransform = tileTransform3;
        else tileTransform = tileTransform4;
        mat3 inverseTileTransform = inverse(tileTransform);
        
        v = tf(currentTransform, _uv) - relId -.5;
        outCol = vec4(0.);
        if (fract(rnd.x*6.222+rnd.y*8.233) <= coverage) {  
            if (mode==0) { // noise
                vec2 w = inverseTileTransform[0].xy;
                w = floor(vec2(dot(w, vec2(20.)), dot(w, vec2(20., -20.))));
                vec2 pixId = relId + 1.23 * (floor(v * w) + floor((length(tileTransform[0].xy)*5.*inverseTileTransform[2].xy) * w));
                outCol = __source__(hash22(pixId));
            }
            else if (mode==1) { // square non interpolated
                v = vec2(0., max(abs(v.x), abs(v.y)));
                vec2 vv = tf(inverseCurrentTransform, relId + (tf(inverseTileTransform, v) + 0.5));
                outCol = __source__(vv);
            }
            else if (mode==2) { // circle interpolated
                float size = 0.5 + inverseTileTransform[2].y;
                float d = length(v);
                float ang = atan(v.y, v.x);
                if (d<=size) {
                    float spikeCount = 4.;
                    float anglePeriod = PI2/spikeCount;
                    float a1 = floor(ang/anglePeriod)*anglePeriod;
                    float a2 = a1 + anglePeriod;
                    float k = (ang-a1) / anglePeriod;
                    float ds = d * 10.0 * length(inverseTileTransform[0].xy); // tile parameter
                    vec2 center = relId + 0.5;
                    vec2 u1 = tf(inverseCurrentTransform, center+ds*vec2(cos(a1), sin(a1)) + inverseTileTransform[2].x);
                    vec2 u2 = tf(inverseCurrentTransform, center+ds*vec2(cos(a2), sin(a2)) + inverseTileTransform[2].x);
                    vec4 col1 = __source__(u1);
                    vec4 col2 = __source__(u2);
                    outCol = mix(col1, col2, k);
                }    
            }
            else if (mode==3) { // square interpolated
                bool vert = abs(v.y)>abs(v.x);
                float a = vert ? v.y : v.x;
                vec2 u1 = vert ? vec2(-a, a) : vec2(a, -a);
                vec2 u2 = vec2(a, a);
                float k = (v.x+v.y) / (2.*a);
                u1 = tf(inverseCurrentTransform, relId + (tf(inverseTileTransform, u1) + 0.5));
                u2 = tf(inverseCurrentTransform, relId + (tf(inverseTileTransform, u2) + 0.5));
                vec4 col1 = __source__(u1);
                vec4 col2 = __source__(u2);
                outCol = mix(col1, col2, k);
            }
            else if (mode==4) { // leaf
                float size = 0.5;
                float ang = atan(inverseTileTransform[0].y, inverseTileTransform[0].x);
                float orientation = ang<0.0 ? sign(mod(relId.x+relId.y, 2.)-0.5) : 1.;
                if (rnd.y > abs(ang)/PI) orientation = -orientation;
    //            float orientation = (rnd.y-.5);
                float p = orientation*v.x*v.y < 0. ? 40. : 2.5;
                float d = p>30. ? max(abs(v.x), abs(v.y)) : pow(pow(abs(v.x), p) + pow(abs(v.y), p), 1./p);
                v = vec2(0., d);
                if (v.y<=size) {
                    vec2 vv = tf(inverseCurrentTransform, relId + (tf(inverseTileTransform, v) + 0.5));
                    outCol = __source__(vv);
                }
            }        
            else if (mode<=6) { // circles and squares
                float scale = length(inverseTileTransform[0].xy);
                bool invert = scale < 1.0;
                if (invert) scale = 1./scale;
                float ds  = fract(scale);
                float N = max(floor(scale), 1.);
                vec2 w = fract((v + 0.5)*N) - 0.5;
                vec2 center = floor((v + 0.5)*N)/N * 2. - 1.0 + 1.0/N;
                float ang = atan(inverseTileTransform[0].y, inverseTileTransform[0].x);
                float keepX = 1.0;
                float keepY = 1.0;
                if (ang>0.0) keepX = 1.0 - ang/PI;
                else keepY = 1.0 + ang/PI;
                bool hide = abs(center.x)>keepX || abs(center.y)>keepY;
                
                float size = mix(0.5, 0.15, ds);
                bool outside = (mode==6 && length(w)>size) || (mode==5 && (abs(w.x)>size || abs(w.y)>size));
                if (!(hide || outside)) {
                    outCol = __source__(id + inverseTileTransform[2].xy);
                }
                else if (invert) {
                    outCol = __source__(id);
                }
            }
            else if (mode==7) { // bw checkerboard
                vec2 w = inverseTileTransform[0].xy;
                w = floor(vec2(dot(w, vec2(16.)), dot(w, vec2(16., -16.))));
                
                float minScale = startScale * 2.0 * pow(2., floor(2.*inverseTileTransform[2].y));
                float maxScale = max(minScale, startScale * 4.0 * pow(2., floor(2.*inverseTileTransform[2].x)));
                float scale2 = clamp(scale, minScale, maxScale);
                float invScaleRatio = scale2/scale;
                mat3 tr = mat3(invScaleRatio, 0., 0., 0., invScaleRatio, 0., 0., 0., 1.) * currentTransform;
                v = tf(tr, _uv) - .5;
    
                vec2 pixId = floor(v * w);
                float k = mod(pixId.x + pixId.y, 2.);
                outCol = vec4(vec3(k), 1.);
            }
            else if (mode==8) { // bw 45° hatch
                float Xn = 8. /* length(inverseTileTransform[0].xy)*/;
                float scale2 = startScale * 4.;//min(max(scale, startScale * 4.), startScale * 4.);
                //float scale2 = scale;
                float invScaleRatio = scale2/scale;
                mat3 tr = mat3(invScaleRatio, 0., 0., 0., invScaleRatio, 0., 0., 0., 1.) * currentTransform;
                v = tf(tr, _uv) - .5;
                float piN = PI/16.;
                float ang = floor(atan(inverseTileTransform[0].y, inverseTileTransform[0].x)/piN)*piN;
                v = (rotation2(ang)*v) * length(inverseTileTransform[0].xy) + 2.*inverseTileTransform[2].xy;
                float k = mod(floor((v.x+v.y*sign(rnd.y-.5))*Xn), 2.);
                outCol = vec4(vec3(k), 1.);
            }
            else if (mode==9) { // compact disk effect
                float N = floor(1000. * pow(0.25, length(inverseTileTransform[2].xy)));// could be a parameter
                //float N = 32. * startScale / scale;// doesn't really work (angles need to be rounded differently) but could interesting to get right
                float offset = PI*.5 + PI/N + atan(inverseTileTransform[1].y, inverseTileTransform[1].x);
                float ang = atan(v.y, v.x);
                ang = round((ang-offset)/PI2*N) / N*PI2 + offset;
                float dist = length(inverseTileTransform[0].xy) * 0.5 / max(abs(cos(ang)), abs(sin(ang))); // could be a parameter
                //float dist = 0.3; // could be a parameter
                v = dist * vec2(cos(ang), sin(ang));
                vec2 u = tf(inverseCurrentTransform, relId + (v + 0.5));
                outCol = __source__(u);
            }
            else if (mode==10) { // hsl
                float s = length(inverseTileTransform[0].xy)*0.05;
                v += 0.5;
                float N = 16.;
                float ang = floor(atan(inverseTileTransform[0].y, inverseTileTransform[0].x)/PI*N)*PI/N;
                v = rotation2(ang) * v;
                vec4 rgb = hslToRgb(vec4((v.x+inverseTileTransform[2].x*length(tileTransform[0].xy))*360., 1., v.y+inverseTileTransform[2].y*length(tileTransform[0].xy), 1.));
                //vec4 rgb = clamp(vec4(hsl2rgb(vec3((v.x+inverseTileTransform[2].x*length(tileTransform[0].xy)), 1., v.y+inverseTileTransform[2].y*length(tileTransform[0].xy))), 1.), 0., 1.);
                vec4 inc = __source__(_uv);
                float dist = length(inc.rgb - rgb.rgb);
                float k = 1.0 - smoothstep(0.0, 1.7, dist) * s;
                rgb = mix(inc, rgb, k);
                             
                outCol = rgb;
            }
    //        else if (mode==11) { // hsl adaptive
    //            float colorScaling = 0.5 * length(inverseTileTransform[0].xy); // could be a parameter
    //            vec4 inc = __source__(id);
    //            vec4 hslInc = rgbToHsl(inc);
    //            v += 0.5;
    //            float saturation = hslInc.y; // or 1.0
    //            vec4 rgb = hslToRgb(vec4(hslInc.x + v.x*360.*colorScaling, saturation, hslInc.z + v.y*colorScaling, 1.));
    //            outCol = rgb;
    //        }
            else if (mode==11) { 
                float N = round(4. * abs(inverseTileTransform[0].x));
                vec2 center = vec2(0., floor((v.y + 0.5)*N)/N * 2. - 1.0 + 1.0/N)*.5;
                vec2 dv = abs(v - center);
                if (dv.x < 0.45 && dv.y < 0.4/N) {
                    float s = inverseTileTransform[2].x + 1.0;
                    vec2 u1 = tf(inverseCurrentTransform, relId + (s*vec2(0., -0.5) + 0.5));
                    vec2 u2 = tf(inverseCurrentTransform, relId + (s*vec2(0., 0.5) + 0.5));
                    outCol = mix(__source__(u1), __source__(u2), center.y + 0.5);
                }
            }
            else if (mode==12) { // scale
                v *= vec2(2., 2.);
                v = tf(inverseTileTransform, v);
                outCol = __source__(tf(inverseCurrentTransform, relId + (v + 0.5)));
            }
            else if (mode==13) { // halftone lines
                float lum = luma(__source__(_uv).rgb);
                v = tf(inverseTileTransform, v*vec2(8., 8.));
                float y = abs(mod(v.y+1.0, 2.) - 1.0);
                float k = lum>y ? 1.0 : 0.0;
                outCol = vec4(vec3(k), 1.);
            }
            else if (mode==14) { // red green gradient
                float lum = luma(__source__(id).rgb);
                float contrast = length(tileTransform[0].xy);
                outCol = vec4(v+.5, 0.5 + contrast*(lum-0.5), 1.);
            }
            else if (mode==15) {     
                vec2 center = sign(rnd-0.5) * 0.5;
                vec2 dv = v - center;
                float N = floor(16.0 * length(inverseTileTransform[0].xy));
                float angOffset = 0.0;
                float ang = atan(dv.y, dv.x) + angOffset;
                float k = abs(mod(ang/PI*N*2., 2.0) - 1.0);
                float kCol = atan(inverseTileTransform[0].y, inverseTileTransform[0].x)/PI;
                float lum = 0.;
                for(int i =0; i<5; ++i) {
                    vec2 w = tf(inverseCurrentTransform, relId + (0.1+0.15*float(i))*vec2(cos(ang), sin(ang)));
                    lum += luma(__source__(w).rgb);            
                }
                lum /= 5.;
                k = lum>k ? 1.0 : 0.0;
                if (kCol==0.0) {
                    outCol = vec4(vec3(k), 1.);
                }
    //            else if (kCol>0.0) {
    //                vec4 col1 = __source__(id + vec2(inverseTileTransform[2].x, 0.));
    //                vec4 col2 = __source__(id + 1.0 + vec2(0.0, inverseTileTransform[2].y));
    //                if (luma(col1.rgb)>luma(col2.rgb)) k = 1. - k;
    //                vec4 outCol1 = vec4(vec3(k), 1.);
    //                vec4 outCol2 = mix(col1, col2, k);
    //                outCol = mix(outCol1, outCol2, kCol);
    //            }
    //            else {
    //                vec4 col1 = __source__(vec2(inverseTileTransform[2].x, 0.));
    //                vec4 col2 = __source__(vec2(0.0, inverseTileTransform[2].y));
    //                if (luma(col1.rgb)>luma(col2.rgb)) k = 1. - k;
    //                vec4 outCol1 = vec4(vec3(k), 1.);
    //                vec4 outCol2 = mix(col1, col2, k);
    //                outCol = mix(outCol1, outCol2, abs(kCol));
    //            }
                else {
                    vec2 u1 = vec2(inverseTileTransform[2].x, 0.);
                    vec2 u2 = vec2(0.0, inverseTileTransform[2].y);
                    if (kCol>0.0) {
                        u1 += id;
                        u2 += id + 1.;
                    }
                    vec4 col1 = __source__(u1);
                    vec4 col2 = __source__(u2);
                    if (luma(col1.rgb)>luma(col2.rgb)) k = 1. - k;
                    vec4 outCol1 = vec4(vec3(k), 1.);
                    vec4 outCol2 = mix(col1, col2, k);
                    outCol = mix(outCol1, outCol2, abs(kCol));
                }
            }
        }
    
    };
            vec4 col2 = mergeColor(src2, outCol);
            outCol = vec4(mix(col1.rgb, col2.rgb, k), 1.);
        }
        else {
            {
        vec2 _uv = _uv;
        
        float startScale = _params.startScale;
        float subLevels = _params.subLevels;
        float subThreshold = _params.subThreshold;
        //int[] modeMap = _params.modeMap;
        float seed = _params.seed;
        float hashStyle = _params.hashStyle;
        float coverage = _params.coverage;
    
        mat3 currentTransform = _params.transform;
        mat3 inverseCurrentTransform = _params.inverseTransform;
        float scale = startScale;
        vec2 v;
        vec2 id;
        vec2 relId;
        vec2 rnd;
        for(float i = 0.; i<subLevels; ++i) {
            if (i!=0.) {
                //currentTransform *= mat3(2., 0., 0., 0., 2., 0., 0., 0., 1.); // parallax version
                currentTransform = mat3(2., 0., 0., 0., 2., 0., 0., 0., 1.) * currentTransform;
                inverseCurrentTransform = inverseCurrentTransform * mat3(0.5, 0., 0., 0., 0.5, 0., 0., 0., 1.);     
            }
            relId = floor(tf(currentTransform, _uv));
            rnd = hash42sp(vec4(relId*0.13137, i, seed), hashStyle);
            if (i==subLevels-1. || rnd.x>subThreshold) {
                break;
            }
    
            scale *= 2.;
        }
        id = tf(inverseCurrentTransform, relId);
        
        vec3 col;
        int modeIndex = int(floor(rnd.y*4.0));
        int mode = _params.modeMap[modeIndex];
        
        mat3 tileTransform;
        if (modeIndex==0) tileTransform = tileTransform1;
        else if (modeIndex==1) tileTransform = tileTransform2;
        else if (modeIndex==2) tileTransform = tileTransform3;
        else tileTransform = tileTransform4;
        mat3 inverseTileTransform = inverse(tileTransform);
        
        v = tf(currentTransform, _uv) - relId -.5;
        outCol = vec4(0.);
        if (fract(rnd.x*6.222+rnd.y*8.233) <= coverage) {  
            if (mode==0) { // noise
                vec2 w = inverseTileTransform[0].xy;
                w = floor(vec2(dot(w, vec2(20.)), dot(w, vec2(20., -20.))));
                vec2 pixId = relId + 1.23 * (floor(v * w) + floor((length(tileTransform[0].xy)*5.*inverseTileTransform[2].xy) * w));
                outCol = __source__(hash22(pixId));
            }
            else if (mode==1) { // square non interpolated
                v = vec2(0., max(abs(v.x), abs(v.y)));
                vec2 vv = tf(inverseCurrentTransform, relId + (tf(inverseTileTransform, v) + 0.5));
                outCol = __source__(vv);
            }
            else if (mode==2) { // circle interpolated
                float size = 0.5 + inverseTileTransform[2].y;
                float d = length(v);
                float ang = atan(v.y, v.x);
                if (d<=size) {
                    float spikeCount = 4.;
                    float anglePeriod = PI2/spikeCount;
                    float a1 = floor(ang/anglePeriod)*anglePeriod;
                    float a2 = a1 + anglePeriod;
                    float k = (ang-a1) / anglePeriod;
                    float ds = d * 10.0 * length(inverseTileTransform[0].xy); // tile parameter
                    vec2 center = relId + 0.5;
                    vec2 u1 = tf(inverseCurrentTransform, center+ds*vec2(cos(a1), sin(a1)) + inverseTileTransform[2].x);
                    vec2 u2 = tf(inverseCurrentTransform, center+ds*vec2(cos(a2), sin(a2)) + inverseTileTransform[2].x);
                    vec4 col1 = __source__(u1);
                    vec4 col2 = __source__(u2);
                    outCol = mix(col1, col2, k);
                }    
            }
            else if (mode==3) { // square interpolated
                bool vert = abs(v.y)>abs(v.x);
                float a = vert ? v.y : v.x;
                vec2 u1 = vert ? vec2(-a, a) : vec2(a, -a);
                vec2 u2 = vec2(a, a);
                float k = (v.x+v.y) / (2.*a);
                u1 = tf(inverseCurrentTransform, relId + (tf(inverseTileTransform, u1) + 0.5));
                u2 = tf(inverseCurrentTransform, relId + (tf(inverseTileTransform, u2) + 0.5));
                vec4 col1 = __source__(u1);
                vec4 col2 = __source__(u2);
                outCol = mix(col1, col2, k);
            }
            else if (mode==4) { // leaf
                float size = 0.5;
                float ang = atan(inverseTileTransform[0].y, inverseTileTransform[0].x);
                float orientation = ang<0.0 ? sign(mod(relId.x+relId.y, 2.)-0.5) : 1.;
                if (rnd.y > abs(ang)/PI) orientation = -orientation;
    //            float orientation = (rnd.y-.5);
                float p = orientation*v.x*v.y < 0. ? 40. : 2.5;
                float d = p>30. ? max(abs(v.x), abs(v.y)) : pow(pow(abs(v.x), p) + pow(abs(v.y), p), 1./p);
                v = vec2(0., d);
                if (v.y<=size) {
                    vec2 vv = tf(inverseCurrentTransform, relId + (tf(inverseTileTransform, v) + 0.5));
                    outCol = __source__(vv);
                }
            }        
            else if (mode<=6) { // circles and squares
                float scale = length(inverseTileTransform[0].xy);
                bool invert = scale < 1.0;
                if (invert) scale = 1./scale;
                float ds  = fract(scale);
                float N = max(floor(scale), 1.);
                vec2 w = fract((v + 0.5)*N) - 0.5;
                vec2 center = floor((v + 0.5)*N)/N * 2. - 1.0 + 1.0/N;
                float ang = atan(inverseTileTransform[0].y, inverseTileTransform[0].x);
                float keepX = 1.0;
                float keepY = 1.0;
                if (ang>0.0) keepX = 1.0 - ang/PI;
                else keepY = 1.0 + ang/PI;
                bool hide = abs(center.x)>keepX || abs(center.y)>keepY;
                
                float size = mix(0.5, 0.15, ds);
                bool outside = (mode==6 && length(w)>size) || (mode==5 && (abs(w.x)>size || abs(w.y)>size));
                if (!(hide || outside)) {
                    outCol = __source__(id + inverseTileTransform[2].xy);
                }
                else if (invert) {
                    outCol = __source__(id);
                }
            }
            else if (mode==7) { // bw checkerboard
                vec2 w = inverseTileTransform[0].xy;
                w = floor(vec2(dot(w, vec2(16.)), dot(w, vec2(16., -16.))));
                
                float minScale = startScale * 2.0 * pow(2., floor(2.*inverseTileTransform[2].y));
                float maxScale = max(minScale, startScale * 4.0 * pow(2., floor(2.*inverseTileTransform[2].x)));
                float scale2 = clamp(scale, minScale, maxScale);
                float invScaleRatio = scale2/scale;
                mat3 tr = mat3(invScaleRatio, 0., 0., 0., invScaleRatio, 0., 0., 0., 1.) * currentTransform;
                v = tf(tr, _uv) - .5;
    
                vec2 pixId = floor(v * w);
                float k = mod(pixId.x + pixId.y, 2.);
                outCol = vec4(vec3(k), 1.);
            }
            else if (mode==8) { // bw 45° hatch
                float Xn = 8. /* length(inverseTileTransform[0].xy)*/;
                float scale2 = startScale * 4.;//min(max(scale, startScale * 4.), startScale * 4.);
                //float scale2 = scale;
                float invScaleRatio = scale2/scale;
                mat3 tr = mat3(invScaleRatio, 0., 0., 0., invScaleRatio, 0., 0., 0., 1.) * currentTransform;
                v = tf(tr, _uv) - .5;
                float piN = PI/16.;
                float ang = floor(atan(inverseTileTransform[0].y, inverseTileTransform[0].x)/piN)*piN;
                v = (rotation2(ang)*v) * length(inverseTileTransform[0].xy) + 2.*inverseTileTransform[2].xy;
                float k = mod(floor((v.x+v.y*sign(rnd.y-.5))*Xn), 2.);
                outCol = vec4(vec3(k), 1.);
            }
            else if (mode==9) { // compact disk effect
                float N = floor(1000. * pow(0.25, length(inverseTileTransform[2].xy)));// could be a parameter
                //float N = 32. * startScale / scale;// doesn't really work (angles need to be rounded differently) but could interesting to get right
                float offset = PI*.5 + PI/N + atan(inverseTileTransform[1].y, inverseTileTransform[1].x);
                float ang = atan(v.y, v.x);
                ang = round((ang-offset)/PI2*N) / N*PI2 + offset;
                float dist = length(inverseTileTransform[0].xy) * 0.5 / max(abs(cos(ang)), abs(sin(ang))); // could be a parameter
                //float dist = 0.3; // could be a parameter
                v = dist * vec2(cos(ang), sin(ang));
                vec2 u = tf(inverseCurrentTransform, relId + (v + 0.5));
                outCol = __source__(u);
            }
            else if (mode==10) { // hsl
                float s = length(inverseTileTransform[0].xy)*0.05;
                v += 0.5;
                float N = 16.;
                float ang = floor(atan(inverseTileTransform[0].y, inverseTileTransform[0].x)/PI*N)*PI/N;
                v = rotation2(ang) * v;
                vec4 rgb = hslToRgb(vec4((v.x+inverseTileTransform[2].x*length(tileTransform[0].xy))*360., 1., v.y+inverseTileTransform[2].y*length(tileTransform[0].xy), 1.));
                //vec4 rgb = clamp(vec4(hsl2rgb(vec3((v.x+inverseTileTransform[2].x*length(tileTransform[0].xy)), 1., v.y+inverseTileTransform[2].y*length(tileTransform[0].xy))), 1.), 0., 1.);
                vec4 inc = __source__(_uv);
                float dist = length(inc.rgb - rgb.rgb);
                float k = 1.0 - smoothstep(0.0, 1.7, dist) * s;
                rgb = mix(inc, rgb, k);
                             
                outCol = rgb;
            }
    //        else if (mode==11) { // hsl adaptive
    //            float colorScaling = 0.5 * length(inverseTileTransform[0].xy); // could be a parameter
    //            vec4 inc = __source__(id);
    //            vec4 hslInc = rgbToHsl(inc);
    //            v += 0.5;
    //            float saturation = hslInc.y; // or 1.0
    //            vec4 rgb = hslToRgb(vec4(hslInc.x + v.x*360.*colorScaling, saturation, hslInc.z + v.y*colorScaling, 1.));
    //            outCol = rgb;
    //        }
            else if (mode==11) { 
                float N = round(4. * abs(inverseTileTransform[0].x));
                vec2 center = vec2(0., floor((v.y + 0.5)*N)/N * 2. - 1.0 + 1.0/N)*.5;
                vec2 dv = abs(v - center);
                if (dv.x < 0.45 && dv.y < 0.4/N) {
                    float s = inverseTileTransform[2].x + 1.0;
                    vec2 u1 = tf(inverseCurrentTransform, relId + (s*vec2(0., -0.5) + 0.5));
                    vec2 u2 = tf(inverseCurrentTransform, relId + (s*vec2(0., 0.5) + 0.5));
                    outCol = mix(__source__(u1), __source__(u2), center.y + 0.5);
                }
            }
            else if (mode==12) { // scale
                v *= vec2(2., 2.);
                v = tf(inverseTileTransform, v);
                outCol = __source__(tf(inverseCurrentTransform, relId + (v + 0.5)));
            }
            else if (mode==13) { // halftone lines
                float lum = luma(__source__(_uv).rgb);
                v = tf(inverseTileTransform, v*vec2(8., 8.));
                float y = abs(mod(v.y+1.0, 2.) - 1.0);
                float k = lum>y ? 1.0 : 0.0;
                outCol = vec4(vec3(k), 1.);
            }
            else if (mode==14) { // red green gradient
                float lum = luma(__source__(id).rgb);
                float contrast = length(tileTransform[0].xy);
                outCol = vec4(v+.5, 0.5 + contrast*(lum-0.5), 1.);
            }
            else if (mode==15) {     
                vec2 center = sign(rnd-0.5) * 0.5;
                vec2 dv = v - center;
                float N = floor(16.0 * length(inverseTileTransform[0].xy));
                float angOffset = 0.0;
                float ang = atan(dv.y, dv.x) + angOffset;
                float k = abs(mod(ang/PI*N*2., 2.0) - 1.0);
                float kCol = atan(inverseTileTransform[0].y, inverseTileTransform[0].x)/PI;
                float lum = 0.;
                for(int i =0; i<5; ++i) {
                    vec2 w = tf(inverseCurrentTransform, relId + (0.1+0.15*float(i))*vec2(cos(ang), sin(ang)));
                    lum += luma(__source__(w).rgb);            
                }
                lum /= 5.;
                k = lum>k ? 1.0 : 0.0;
                if (kCol==0.0) {
                    outCol = vec4(vec3(k), 1.);
                }
    //            else if (kCol>0.0) {
    //                vec4 col1 = __source__(id + vec2(inverseTileTransform[2].x, 0.));
    //                vec4 col2 = __source__(id + 1.0 + vec2(0.0, inverseTileTransform[2].y));
    //                if (luma(col1.rgb)>luma(col2.rgb)) k = 1. - k;
    //                vec4 outCol1 = vec4(vec3(k), 1.);
    //                vec4 outCol2 = mix(col1, col2, k);
    //                outCol = mix(outCol1, outCol2, kCol);
    //            }
    //            else {
    //                vec4 col1 = __source__(vec2(inverseTileTransform[2].x, 0.));
    //                vec4 col2 = __source__(vec2(0.0, inverseTileTransform[2].y));
    //                if (luma(col1.rgb)>luma(col2.rgb)) k = 1. - k;
    //                vec4 outCol1 = vec4(vec3(k), 1.);
    //                vec4 outCol2 = mix(col1, col2, k);
    //                outCol = mix(outCol1, outCol2, abs(kCol));
    //            }
                else {
                    vec2 u1 = vec2(inverseTileTransform[2].x, 0.);
                    vec2 u2 = vec2(0.0, inverseTileTransform[2].y);
                    if (kCol>0.0) {
                        u1 += id;
                        u2 += id + 1.;
                    }
                    vec4 col1 = __source__(u1);
                    vec4 col2 = __source__(u2);
                    if (luma(col1.rgb)>luma(col2.rgb)) k = 1. - k;
                    vec4 outCol1 = vec4(vec3(k), 1.);
                    vec4 outCol2 = mix(col1, col2, k);
                    outCol = mix(outCol1, outCol2, abs(kCol));
                }
            }
        }
    
    };
        }
    }
                col = mergeColor(col, outCol);
            }
                      
                    overTransform = modelTransform * overTransform; 
            mat3 inverseUnderTransform = inverse(overTransform);
            float startScale = length(inverseUnderTransform[0].xy); 
            
            int modeMap[4];
            if (overMode<16) {
              for(int i=0; i<4; ++i) modeMap[i] = overMode;
            }
            else { 
                overMode -= 16;
                modeMap[0] = overMode & 15;
                overMode /= 16;
                modeMap[1] = overMode & 15;
                overMode /= 16;
                modeMap[2] = overMode & 15;
                overMode /= 16;
                modeMap[3] = overMode & 15;
            }
            params = LevelParams(
                inverseUnderTransform,
                overTransform,
                startScale,
                float(overLevels),
                overThreshold,
                modeMap,
                overCoverage,
                overStreakCoverage,
                overStreakLevels,
                (overStreakBalance+1.)*.5,
                overRandomSeed, 
                overRandomType);
            {
    vec2 _uv = pos;
    LevelParams _params = params;
    vec4 _srcCol = vec4(0.);
    
    float startScale = _params.startScale;
    float subLevels = _params.subLevels;
    float subThreshold = _params.subThreshold;
    float streakInterpolateCoverage = _params.streakInterpolateCoverage;
    int streakSubLevels = _params.streakSubLevels;
    float streakVerticality = _params.streakVerticality;
    float seed = _params.seed;
    float hashStyle = _params.hashStyle;
    mat3 currentTransform = _params.transform;
    mat3 inverseCurrentTransform = _params.inverseTransform;

    vec2 v;
    vec2 relId;
    vec2 rnd;
    int streakLevel = 1;
    for(float i = 0.; i<float(streakSubLevels); ++i) {
        if (i!=0.0) {
        //currentTransform *= mat3(2., 0., 0., 0., 2., 0., 0., 0., 1.); // parallax version
            currentTransform = mat3(2., 0., 0., 0., 2., 0., 0., 0., 1.) * currentTransform;
            inverseCurrentTransform = inverseCurrentTransform * mat3(0.5, 0., 0., 0., 0.5, 0., 0., 0., 1.);
        }
        relId = floor(tf(currentTransform, _uv));
        rnd = hash42sp(vec4(relId*0.08845, i, seed), hashStyle);
        if (/*i==subLevels-1. ||*/ rnd.x>subThreshold) {
            break;
        }
        ++streakLevel;
    }
    //id = tf(inverseCurrentTransform, relId);

    if (rnd.y<=streakInterpolateCoverage /*&& streakLevel <= streakSubLevels*/) {
        vec2 uu1, uu2;
        float k;
        v = tf(currentTransform, _uv) - relId;
        if (fract(rnd.y*13.323)<streakVerticality) {
            k = v.y;
            uu1 = tf(inverseCurrentTransform, relId + vec2(v.x, -0.0001));
            uu2 = tf(inverseCurrentTransform, relId + vec2(v.x, +0.9999));
        }
        else {
            k = v.x;
            uu1 = tf(inverseCurrentTransform, relId + vec2(-0.0001, v.y));
            uu2 = tf(inverseCurrentTransform, relId + vec2(0.9999, v.y));
        }
        vec4 src1 = __source__(uu1);
        vec4 src2 = __source__(uu2);                
        {
    vec2 _uv = uu1;
    
    float startScale = _params.startScale;
    float subLevels = _params.subLevels;
    float subThreshold = _params.subThreshold;
    //int[] modeMap = _params.modeMap;
    float seed = _params.seed;
    float hashStyle = _params.hashStyle;
    float coverage = _params.coverage;

    mat3 currentTransform = _params.transform;
    mat3 inverseCurrentTransform = _params.inverseTransform;
    float scale = startScale;
    vec2 v;
    vec2 id;
    vec2 relId;
    vec2 rnd;
    for(float i = 0.; i<subLevels; ++i) {
        if (i!=0.) {
            //currentTransform *= mat3(2., 0., 0., 0., 2., 0., 0., 0., 1.); // parallax version
            currentTransform = mat3(2., 0., 0., 0., 2., 0., 0., 0., 1.) * currentTransform;
            inverseCurrentTransform = inverseCurrentTransform * mat3(0.5, 0., 0., 0., 0.5, 0., 0., 0., 1.);     
        }
        relId = floor(tf(currentTransform, _uv));
        rnd = hash42sp(vec4(relId*0.13137, i, seed), hashStyle);
        if (i==subLevels-1. || rnd.x>subThreshold) {
            break;
        }

        scale *= 2.;
    }
    id = tf(inverseCurrentTransform, relId);
    
    vec3 col;
    int modeIndex = int(floor(rnd.y*4.0));
    int mode = _params.modeMap[modeIndex];
    
    mat3 tileTransform;
    if (modeIndex==0) tileTransform = tileTransform1;
    else if (modeIndex==1) tileTransform = tileTransform2;
    else if (modeIndex==2) tileTransform = tileTransform3;
    else tileTransform = tileTransform4;
    mat3 inverseTileTransform = inverse(tileTransform);
    
    v = tf(currentTransform, _uv) - relId -.5;
    outCol = vec4(0.);
    if (fract(rnd.x*6.222+rnd.y*8.233) <= coverage) {  
        if (mode==0) { // noise
            vec2 w = inverseTileTransform[0].xy;
            w = floor(vec2(dot(w, vec2(20.)), dot(w, vec2(20., -20.))));
            vec2 pixId = relId + 1.23 * (floor(v * w) + floor((length(tileTransform[0].xy)*5.*inverseTileTransform[2].xy) * w));
            outCol = __source__(hash22(pixId));
        }
        else if (mode==1) { // square non interpolated
            v = vec2(0., max(abs(v.x), abs(v.y)));
            vec2 vv = tf(inverseCurrentTransform, relId + (tf(inverseTileTransform, v) + 0.5));
            outCol = __source__(vv);
        }
        else if (mode==2) { // circle interpolated
            float size = 0.5 + inverseTileTransform[2].y;
            float d = length(v);
            float ang = atan(v.y, v.x);
            if (d<=size) {
                float spikeCount = 4.;
                float anglePeriod = PI2/spikeCount;
                float a1 = floor(ang/anglePeriod)*anglePeriod;
                float a2 = a1 + anglePeriod;
                float k = (ang-a1) / anglePeriod;
                float ds = d * 10.0 * length(inverseTileTransform[0].xy); // tile parameter
                vec2 center = relId + 0.5;
                vec2 u1 = tf(inverseCurrentTransform, center+ds*vec2(cos(a1), sin(a1)) + inverseTileTransform[2].x);
                vec2 u2 = tf(inverseCurrentTransform, center+ds*vec2(cos(a2), sin(a2)) + inverseTileTransform[2].x);
                vec4 col1 = __source__(u1);
                vec4 col2 = __source__(u2);
                outCol = mix(col1, col2, k);
            }    
        }
        else if (mode==3) { // square interpolated
            bool vert = abs(v.y)>abs(v.x);
            float a = vert ? v.y : v.x;
            vec2 u1 = vert ? vec2(-a, a) : vec2(a, -a);
            vec2 u2 = vec2(a, a);
            float k = (v.x+v.y) / (2.*a);
            u1 = tf(inverseCurrentTransform, relId + (tf(inverseTileTransform, u1) + 0.5));
            u2 = tf(inverseCurrentTransform, relId + (tf(inverseTileTransform, u2) + 0.5));
            vec4 col1 = __source__(u1);
            vec4 col2 = __source__(u2);
            outCol = mix(col1, col2, k);
        }
        else if (mode==4) { // leaf
            float size = 0.5;
            float ang = atan(inverseTileTransform[0].y, inverseTileTransform[0].x);
            float orientation = ang<0.0 ? sign(mod(relId.x+relId.y, 2.)-0.5) : 1.;
            if (rnd.y > abs(ang)/PI) orientation = -orientation;
//            float orientation = (rnd.y-.5);
            float p = orientation*v.x*v.y < 0. ? 40. : 2.5;
            float d = p>30. ? max(abs(v.x), abs(v.y)) : pow(pow(abs(v.x), p) + pow(abs(v.y), p), 1./p);
            v = vec2(0., d);
            if (v.y<=size) {
                vec2 vv = tf(inverseCurrentTransform, relId + (tf(inverseTileTransform, v) + 0.5));
                outCol = __source__(vv);
            }
        }        
        else if (mode<=6) { // circles and squares
            float scale = length(inverseTileTransform[0].xy);
            bool invert = scale < 1.0;
            if (invert) scale = 1./scale;
            float ds  = fract(scale);
            float N = max(floor(scale), 1.);
            vec2 w = fract((v + 0.5)*N) - 0.5;
            vec2 center = floor((v + 0.5)*N)/N * 2. - 1.0 + 1.0/N;
            float ang = atan(inverseTileTransform[0].y, inverseTileTransform[0].x);
            float keepX = 1.0;
            float keepY = 1.0;
            if (ang>0.0) keepX = 1.0 - ang/PI;
            else keepY = 1.0 + ang/PI;
            bool hide = abs(center.x)>keepX || abs(center.y)>keepY;
            
            float size = mix(0.5, 0.15, ds);
            bool outside = (mode==6 && length(w)>size) || (mode==5 && (abs(w.x)>size || abs(w.y)>size));
            if (!(hide || outside)) {
                outCol = __source__(id + inverseTileTransform[2].xy);
            }
            else if (invert) {
                outCol = __source__(id);
            }
        }
        else if (mode==7) { // bw checkerboard
            vec2 w = inverseTileTransform[0].xy;
            w = floor(vec2(dot(w, vec2(16.)), dot(w, vec2(16., -16.))));
            
            float minScale = startScale * 2.0 * pow(2., floor(2.*inverseTileTransform[2].y));
            float maxScale = max(minScale, startScale * 4.0 * pow(2., floor(2.*inverseTileTransform[2].x)));
            float scale2 = clamp(scale, minScale, maxScale);
            float invScaleRatio = scale2/scale;
            mat3 tr = mat3(invScaleRatio, 0., 0., 0., invScaleRatio, 0., 0., 0., 1.) * currentTransform;
            v = tf(tr, _uv) - .5;

            vec2 pixId = floor(v * w);
            float k = mod(pixId.x + pixId.y, 2.);
            outCol = vec4(vec3(k), 1.);
        }
        else if (mode==8) { // bw 45° hatch
            float Xn = 8. /* length(inverseTileTransform[0].xy)*/;
            float scale2 = startScale * 4.;//min(max(scale, startScale * 4.), startScale * 4.);
            //float scale2 = scale;
            float invScaleRatio = scale2/scale;
            mat3 tr = mat3(invScaleRatio, 0., 0., 0., invScaleRatio, 0., 0., 0., 1.) * currentTransform;
            v = tf(tr, _uv) - .5;
            float piN = PI/16.;
            float ang = floor(atan(inverseTileTransform[0].y, inverseTileTransform[0].x)/piN)*piN;
            v = (rotation2(ang)*v) * length(inverseTileTransform[0].xy) + 2.*inverseTileTransform[2].xy;
            float k = mod(floor((v.x+v.y*sign(rnd.y-.5))*Xn), 2.);
            outCol = vec4(vec3(k), 1.);
        }
        else if (mode==9) { // compact disk effect
            float N = floor(1000. * pow(0.25, length(inverseTileTransform[2].xy)));// could be a parameter
            //float N = 32. * startScale / scale;// doesn't really work (angles need to be rounded differently) but could interesting to get right
            float offset = PI*.5 + PI/N + atan(inverseTileTransform[1].y, inverseTileTransform[1].x);
            float ang = atan(v.y, v.x);
            ang = round((ang-offset)/PI2*N) / N*PI2 + offset;
            float dist = length(inverseTileTransform[0].xy) * 0.5 / max(abs(cos(ang)), abs(sin(ang))); // could be a parameter
            //float dist = 0.3; // could be a parameter
            v = dist * vec2(cos(ang), sin(ang));
            vec2 u = tf(inverseCurrentTransform, relId + (v + 0.5));
            outCol = __source__(u);
        }
        else if (mode==10) { // hsl
            float s = length(inverseTileTransform[0].xy)*0.05;
            v += 0.5;
            float N = 16.;
            float ang = floor(atan(inverseTileTransform[0].y, inverseTileTransform[0].x)/PI*N)*PI/N;
            v = rotation2(ang) * v;
            vec4 rgb = hslToRgb(vec4((v.x+inverseTileTransform[2].x*length(tileTransform[0].xy))*360., 1., v.y+inverseTileTransform[2].y*length(tileTransform[0].xy), 1.));
            //vec4 rgb = clamp(vec4(hsl2rgb(vec3((v.x+inverseTileTransform[2].x*length(tileTransform[0].xy)), 1., v.y+inverseTileTransform[2].y*length(tileTransform[0].xy))), 1.), 0., 1.);
            vec4 inc = __source__(_uv);
            float dist = length(inc.rgb - rgb.rgb);
            float k = 1.0 - smoothstep(0.0, 1.7, dist) * s;
            rgb = mix(inc, rgb, k);
                         
            outCol = rgb;
        }
//        else if (mode==11) { // hsl adaptive
//            float colorScaling = 0.5 * length(inverseTileTransform[0].xy); // could be a parameter
//            vec4 inc = __source__(id);
//            vec4 hslInc = rgbToHsl(inc);
//            v += 0.5;
//            float saturation = hslInc.y; // or 1.0
//            vec4 rgb = hslToRgb(vec4(hslInc.x + v.x*360.*colorScaling, saturation, hslInc.z + v.y*colorScaling, 1.));
//            outCol = rgb;
//        }
        else if (mode==11) { 
            float N = round(4. * abs(inverseTileTransform[0].x));
            vec2 center = vec2(0., floor((v.y + 0.5)*N)/N * 2. - 1.0 + 1.0/N)*.5;
            vec2 dv = abs(v - center);
            if (dv.x < 0.45 && dv.y < 0.4/N) {
                float s = inverseTileTransform[2].x + 1.0;
                vec2 u1 = tf(inverseCurrentTransform, relId + (s*vec2(0., -0.5) + 0.5));
                vec2 u2 = tf(inverseCurrentTransform, relId + (s*vec2(0., 0.5) + 0.5));
                outCol = mix(__source__(u1), __source__(u2), center.y + 0.5);
            }
        }
        else if (mode==12) { // scale
            v *= vec2(2., 2.);
            v = tf(inverseTileTransform, v);
            outCol = __source__(tf(inverseCurrentTransform, relId + (v + 0.5)));
        }
        else if (mode==13) { // halftone lines
            float lum = luma(__source__(_uv).rgb);
            v = tf(inverseTileTransform, v*vec2(8., 8.));
            float y = abs(mod(v.y+1.0, 2.) - 1.0);
            float k = lum>y ? 1.0 : 0.0;
            outCol = vec4(vec3(k), 1.);
        }
        else if (mode==14) { // red green gradient
            float lum = luma(__source__(id).rgb);
            float contrast = length(tileTransform[0].xy);
            outCol = vec4(v+.5, 0.5 + contrast*(lum-0.5), 1.);
        }
        else if (mode==15) {     
            vec2 center = sign(rnd-0.5) * 0.5;
            vec2 dv = v - center;
            float N = floor(16.0 * length(inverseTileTransform[0].xy));
            float angOffset = 0.0;
            float ang = atan(dv.y, dv.x) + angOffset;
            float k = abs(mod(ang/PI*N*2., 2.0) - 1.0);
            float kCol = atan(inverseTileTransform[0].y, inverseTileTransform[0].x)/PI;
            float lum = 0.;
            for(int i =0; i<5; ++i) {
                vec2 w = tf(inverseCurrentTransform, relId + (0.1+0.15*float(i))*vec2(cos(ang), sin(ang)));
                lum += luma(__source__(w).rgb);            
            }
            lum /= 5.;
            k = lum>k ? 1.0 : 0.0;
            if (kCol==0.0) {
                outCol = vec4(vec3(k), 1.);
            }
//            else if (kCol>0.0) {
//                vec4 col1 = __source__(id + vec2(inverseTileTransform[2].x, 0.));
//                vec4 col2 = __source__(id + 1.0 + vec2(0.0, inverseTileTransform[2].y));
//                if (luma(col1.rgb)>luma(col2.rgb)) k = 1. - k;
//                vec4 outCol1 = vec4(vec3(k), 1.);
//                vec4 outCol2 = mix(col1, col2, k);
//                outCol = mix(outCol1, outCol2, kCol);
//            }
//            else {
//                vec4 col1 = __source__(vec2(inverseTileTransform[2].x, 0.));
//                vec4 col2 = __source__(vec2(0.0, inverseTileTransform[2].y));
//                if (luma(col1.rgb)>luma(col2.rgb)) k = 1. - k;
//                vec4 outCol1 = vec4(vec3(k), 1.);
//                vec4 outCol2 = mix(col1, col2, k);
//                outCol = mix(outCol1, outCol2, abs(kCol));
//            }
            else {
                vec2 u1 = vec2(inverseTileTransform[2].x, 0.);
                vec2 u2 = vec2(0.0, inverseTileTransform[2].y);
                if (kCol>0.0) {
                    u1 += id;
                    u2 += id + 1.;
                }
                vec4 col1 = __source__(u1);
                vec4 col2 = __source__(u2);
                if (luma(col1.rgb)>luma(col2.rgb)) k = 1. - k;
                vec4 outCol1 = vec4(vec3(k), 1.);
                vec4 outCol2 = mix(col1, col2, k);
                outCol = mix(outCol1, outCol2, abs(kCol));
            }
        }
    }

};
        vec4 col1 = mergeColor(src1, outCol);
        {
    vec2 _uv = uu2;
    
    float startScale = _params.startScale;
    float subLevels = _params.subLevels;
    float subThreshold = _params.subThreshold;
    //int[] modeMap = _params.modeMap;
    float seed = _params.seed;
    float hashStyle = _params.hashStyle;
    float coverage = _params.coverage;

    mat3 currentTransform = _params.transform;
    mat3 inverseCurrentTransform = _params.inverseTransform;
    float scale = startScale;
    vec2 v;
    vec2 id;
    vec2 relId;
    vec2 rnd;
    for(float i = 0.; i<subLevels; ++i) {
        if (i!=0.) {
            //currentTransform *= mat3(2., 0., 0., 0., 2., 0., 0., 0., 1.); // parallax version
            currentTransform = mat3(2., 0., 0., 0., 2., 0., 0., 0., 1.) * currentTransform;
            inverseCurrentTransform = inverseCurrentTransform * mat3(0.5, 0., 0., 0., 0.5, 0., 0., 0., 1.);     
        }
        relId = floor(tf(currentTransform, _uv));
        rnd = hash42sp(vec4(relId*0.13137, i, seed), hashStyle);
        if (i==subLevels-1. || rnd.x>subThreshold) {
            break;
        }

        scale *= 2.;
    }
    id = tf(inverseCurrentTransform, relId);
    
    vec3 col;
    int modeIndex = int(floor(rnd.y*4.0));
    int mode = _params.modeMap[modeIndex];
    
    mat3 tileTransform;
    if (modeIndex==0) tileTransform = tileTransform1;
    else if (modeIndex==1) tileTransform = tileTransform2;
    else if (modeIndex==2) tileTransform = tileTransform3;
    else tileTransform = tileTransform4;
    mat3 inverseTileTransform = inverse(tileTransform);
    
    v = tf(currentTransform, _uv) - relId -.5;
    outCol = vec4(0.);
    if (fract(rnd.x*6.222+rnd.y*8.233) <= coverage) {  
        if (mode==0) { // noise
            vec2 w = inverseTileTransform[0].xy;
            w = floor(vec2(dot(w, vec2(20.)), dot(w, vec2(20., -20.))));
            vec2 pixId = relId + 1.23 * (floor(v * w) + floor((length(tileTransform[0].xy)*5.*inverseTileTransform[2].xy) * w));
            outCol = __source__(hash22(pixId));
        }
        else if (mode==1) { // square non interpolated
            v = vec2(0., max(abs(v.x), abs(v.y)));
            vec2 vv = tf(inverseCurrentTransform, relId + (tf(inverseTileTransform, v) + 0.5));
            outCol = __source__(vv);
        }
        else if (mode==2) { // circle interpolated
            float size = 0.5 + inverseTileTransform[2].y;
            float d = length(v);
            float ang = atan(v.y, v.x);
            if (d<=size) {
                float spikeCount = 4.;
                float anglePeriod = PI2/spikeCount;
                float a1 = floor(ang/anglePeriod)*anglePeriod;
                float a2 = a1 + anglePeriod;
                float k = (ang-a1) / anglePeriod;
                float ds = d * 10.0 * length(inverseTileTransform[0].xy); // tile parameter
                vec2 center = relId + 0.5;
                vec2 u1 = tf(inverseCurrentTransform, center+ds*vec2(cos(a1), sin(a1)) + inverseTileTransform[2].x);
                vec2 u2 = tf(inverseCurrentTransform, center+ds*vec2(cos(a2), sin(a2)) + inverseTileTransform[2].x);
                vec4 col1 = __source__(u1);
                vec4 col2 = __source__(u2);
                outCol = mix(col1, col2, k);
            }    
        }
        else if (mode==3) { // square interpolated
            bool vert = abs(v.y)>abs(v.x);
            float a = vert ? v.y : v.x;
            vec2 u1 = vert ? vec2(-a, a) : vec2(a, -a);
            vec2 u2 = vec2(a, a);
            float k = (v.x+v.y) / (2.*a);
            u1 = tf(inverseCurrentTransform, relId + (tf(inverseTileTransform, u1) + 0.5));
            u2 = tf(inverseCurrentTransform, relId + (tf(inverseTileTransform, u2) + 0.5));
            vec4 col1 = __source__(u1);
            vec4 col2 = __source__(u2);
            outCol = mix(col1, col2, k);
        }
        else if (mode==4) { // leaf
            float size = 0.5;
            float ang = atan(inverseTileTransform[0].y, inverseTileTransform[0].x);
            float orientation = ang<0.0 ? sign(mod(relId.x+relId.y, 2.)-0.5) : 1.;
            if (rnd.y > abs(ang)/PI) orientation = -orientation;
//            float orientation = (rnd.y-.5);
            float p = orientation*v.x*v.y < 0. ? 40. : 2.5;
            float d = p>30. ? max(abs(v.x), abs(v.y)) : pow(pow(abs(v.x), p) + pow(abs(v.y), p), 1./p);
            v = vec2(0., d);
            if (v.y<=size) {
                vec2 vv = tf(inverseCurrentTransform, relId + (tf(inverseTileTransform, v) + 0.5));
                outCol = __source__(vv);
            }
        }        
        else if (mode<=6) { // circles and squares
            float scale = length(inverseTileTransform[0].xy);
            bool invert = scale < 1.0;
            if (invert) scale = 1./scale;
            float ds  = fract(scale);
            float N = max(floor(scale), 1.);
            vec2 w = fract((v + 0.5)*N) - 0.5;
            vec2 center = floor((v + 0.5)*N)/N * 2. - 1.0 + 1.0/N;
            float ang = atan(inverseTileTransform[0].y, inverseTileTransform[0].x);
            float keepX = 1.0;
            float keepY = 1.0;
            if (ang>0.0) keepX = 1.0 - ang/PI;
            else keepY = 1.0 + ang/PI;
            bool hide = abs(center.x)>keepX || abs(center.y)>keepY;
            
            float size = mix(0.5, 0.15, ds);
            bool outside = (mode==6 && length(w)>size) || (mode==5 && (abs(w.x)>size || abs(w.y)>size));
            if (!(hide || outside)) {
                outCol = __source__(id + inverseTileTransform[2].xy);
            }
            else if (invert) {
                outCol = __source__(id);
            }
        }
        else if (mode==7) { // bw checkerboard
            vec2 w = inverseTileTransform[0].xy;
            w = floor(vec2(dot(w, vec2(16.)), dot(w, vec2(16., -16.))));
            
            float minScale = startScale * 2.0 * pow(2., floor(2.*inverseTileTransform[2].y));
            float maxScale = max(minScale, startScale * 4.0 * pow(2., floor(2.*inverseTileTransform[2].x)));
            float scale2 = clamp(scale, minScale, maxScale);
            float invScaleRatio = scale2/scale;
            mat3 tr = mat3(invScaleRatio, 0., 0., 0., invScaleRatio, 0., 0., 0., 1.) * currentTransform;
            v = tf(tr, _uv) - .5;

            vec2 pixId = floor(v * w);
            float k = mod(pixId.x + pixId.y, 2.);
            outCol = vec4(vec3(k), 1.);
        }
        else if (mode==8) { // bw 45° hatch
            float Xn = 8. /* length(inverseTileTransform[0].xy)*/;
            float scale2 = startScale * 4.;//min(max(scale, startScale * 4.), startScale * 4.);
            //float scale2 = scale;
            float invScaleRatio = scale2/scale;
            mat3 tr = mat3(invScaleRatio, 0., 0., 0., invScaleRatio, 0., 0., 0., 1.) * currentTransform;
            v = tf(tr, _uv) - .5;
            float piN = PI/16.;
            float ang = floor(atan(inverseTileTransform[0].y, inverseTileTransform[0].x)/piN)*piN;
            v = (rotation2(ang)*v) * length(inverseTileTransform[0].xy) + 2.*inverseTileTransform[2].xy;
            float k = mod(floor((v.x+v.y*sign(rnd.y-.5))*Xn), 2.);
            outCol = vec4(vec3(k), 1.);
        }
        else if (mode==9) { // compact disk effect
            float N = floor(1000. * pow(0.25, length(inverseTileTransform[2].xy)));// could be a parameter
            //float N = 32. * startScale / scale;// doesn't really work (angles need to be rounded differently) but could interesting to get right
            float offset = PI*.5 + PI/N + atan(inverseTileTransform[1].y, inverseTileTransform[1].x);
            float ang = atan(v.y, v.x);
            ang = round((ang-offset)/PI2*N) / N*PI2 + offset;
            float dist = length(inverseTileTransform[0].xy) * 0.5 / max(abs(cos(ang)), abs(sin(ang))); // could be a parameter
            //float dist = 0.3; // could be a parameter
            v = dist * vec2(cos(ang), sin(ang));
            vec2 u = tf(inverseCurrentTransform, relId + (v + 0.5));
            outCol = __source__(u);
        }
        else if (mode==10) { // hsl
            float s = length(inverseTileTransform[0].xy)*0.05;
            v += 0.5;
            float N = 16.;
            float ang = floor(atan(inverseTileTransform[0].y, inverseTileTransform[0].x)/PI*N)*PI/N;
            v = rotation2(ang) * v;
            vec4 rgb = hslToRgb(vec4((v.x+inverseTileTransform[2].x*length(tileTransform[0].xy))*360., 1., v.y+inverseTileTransform[2].y*length(tileTransform[0].xy), 1.));
            //vec4 rgb = clamp(vec4(hsl2rgb(vec3((v.x+inverseTileTransform[2].x*length(tileTransform[0].xy)), 1., v.y+inverseTileTransform[2].y*length(tileTransform[0].xy))), 1.), 0., 1.);
            vec4 inc = __source__(_uv);
            float dist = length(inc.rgb - rgb.rgb);
            float k = 1.0 - smoothstep(0.0, 1.7, dist) * s;
            rgb = mix(inc, rgb, k);
                         
            outCol = rgb;
        }
//        else if (mode==11) { // hsl adaptive
//            float colorScaling = 0.5 * length(inverseTileTransform[0].xy); // could be a parameter
//            vec4 inc = __source__(id);
//            vec4 hslInc = rgbToHsl(inc);
//            v += 0.5;
//            float saturation = hslInc.y; // or 1.0
//            vec4 rgb = hslToRgb(vec4(hslInc.x + v.x*360.*colorScaling, saturation, hslInc.z + v.y*colorScaling, 1.));
//            outCol = rgb;
//        }
        else if (mode==11) { 
            float N = round(4. * abs(inverseTileTransform[0].x));
            vec2 center = vec2(0., floor((v.y + 0.5)*N)/N * 2. - 1.0 + 1.0/N)*.5;
            vec2 dv = abs(v - center);
            if (dv.x < 0.45 && dv.y < 0.4/N) {
                float s = inverseTileTransform[2].x + 1.0;
                vec2 u1 = tf(inverseCurrentTransform, relId + (s*vec2(0., -0.5) + 0.5));
                vec2 u2 = tf(inverseCurrentTransform, relId + (s*vec2(0., 0.5) + 0.5));
                outCol = mix(__source__(u1), __source__(u2), center.y + 0.5);
            }
        }
        else if (mode==12) { // scale
            v *= vec2(2., 2.);
            v = tf(inverseTileTransform, v);
            outCol = __source__(tf(inverseCurrentTransform, relId + (v + 0.5)));
        }
        else if (mode==13) { // halftone lines
            float lum = luma(__source__(_uv).rgb);
            v = tf(inverseTileTransform, v*vec2(8., 8.));
            float y = abs(mod(v.y+1.0, 2.) - 1.0);
            float k = lum>y ? 1.0 : 0.0;
            outCol = vec4(vec3(k), 1.);
        }
        else if (mode==14) { // red green gradient
            float lum = luma(__source__(id).rgb);
            float contrast = length(tileTransform[0].xy);
            outCol = vec4(v+.5, 0.5 + contrast*(lum-0.5), 1.);
        }
        else if (mode==15) {     
            vec2 center = sign(rnd-0.5) * 0.5;
            vec2 dv = v - center;
            float N = floor(16.0 * length(inverseTileTransform[0].xy));
            float angOffset = 0.0;
            float ang = atan(dv.y, dv.x) + angOffset;
            float k = abs(mod(ang/PI*N*2., 2.0) - 1.0);
            float kCol = atan(inverseTileTransform[0].y, inverseTileTransform[0].x)/PI;
            float lum = 0.;
            for(int i =0; i<5; ++i) {
                vec2 w = tf(inverseCurrentTransform, relId + (0.1+0.15*float(i))*vec2(cos(ang), sin(ang)));
                lum += luma(__source__(w).rgb);            
            }
            lum /= 5.;
            k = lum>k ? 1.0 : 0.0;
            if (kCol==0.0) {
                outCol = vec4(vec3(k), 1.);
            }
//            else if (kCol>0.0) {
//                vec4 col1 = __source__(id + vec2(inverseTileTransform[2].x, 0.));
//                vec4 col2 = __source__(id + 1.0 + vec2(0.0, inverseTileTransform[2].y));
//                if (luma(col1.rgb)>luma(col2.rgb)) k = 1. - k;
//                vec4 outCol1 = vec4(vec3(k), 1.);
//                vec4 outCol2 = mix(col1, col2, k);
//                outCol = mix(outCol1, outCol2, kCol);
//            }
//            else {
//                vec4 col1 = __source__(vec2(inverseTileTransform[2].x, 0.));
//                vec4 col2 = __source__(vec2(0.0, inverseTileTransform[2].y));
//                if (luma(col1.rgb)>luma(col2.rgb)) k = 1. - k;
//                vec4 outCol1 = vec4(vec3(k), 1.);
//                vec4 outCol2 = mix(col1, col2, k);
//                outCol = mix(outCol1, outCol2, abs(kCol));
//            }
            else {
                vec2 u1 = vec2(inverseTileTransform[2].x, 0.);
                vec2 u2 = vec2(0.0, inverseTileTransform[2].y);
                if (kCol>0.0) {
                    u1 += id;
                    u2 += id + 1.;
                }
                vec4 col1 = __source__(u1);
                vec4 col2 = __source__(u2);
                if (luma(col1.rgb)>luma(col2.rgb)) k = 1. - k;
                vec4 outCol1 = vec4(vec3(k), 1.);
                vec4 outCol2 = mix(col1, col2, k);
                outCol = mix(outCol1, outCol2, abs(kCol));
            }
        }
    }

};
        vec4 col2 = mergeColor(src2, outCol);
        outCol = vec4(mix(col1.rgb, col2.rgb, k), 1.);
    }
    else {
        {
    vec2 _uv = _uv;
    
    float startScale = _params.startScale;
    float subLevels = _params.subLevels;
    float subThreshold = _params.subThreshold;
    //int[] modeMap = _params.modeMap;
    float seed = _params.seed;
    float hashStyle = _params.hashStyle;
    float coverage = _params.coverage;

    mat3 currentTransform = _params.transform;
    mat3 inverseCurrentTransform = _params.inverseTransform;
    float scale = startScale;
    vec2 v;
    vec2 id;
    vec2 relId;
    vec2 rnd;
    for(float i = 0.; i<subLevels; ++i) {
        if (i!=0.) {
            //currentTransform *= mat3(2., 0., 0., 0., 2., 0., 0., 0., 1.); // parallax version
            currentTransform = mat3(2., 0., 0., 0., 2., 0., 0., 0., 1.) * currentTransform;
            inverseCurrentTransform = inverseCurrentTransform * mat3(0.5, 0., 0., 0., 0.5, 0., 0., 0., 1.);     
        }
        relId = floor(tf(currentTransform, _uv));
        rnd = hash42sp(vec4(relId*0.13137, i, seed), hashStyle);
        if (i==subLevels-1. || rnd.x>subThreshold) {
            break;
        }

        scale *= 2.;
    }
    id = tf(inverseCurrentTransform, relId);
    
    vec3 col;
    int modeIndex = int(floor(rnd.y*4.0));
    int mode = _params.modeMap[modeIndex];
    
    mat3 tileTransform;
    if (modeIndex==0) tileTransform = tileTransform1;
    else if (modeIndex==1) tileTransform = tileTransform2;
    else if (modeIndex==2) tileTransform = tileTransform3;
    else tileTransform = tileTransform4;
    mat3 inverseTileTransform = inverse(tileTransform);
    
    v = tf(currentTransform, _uv) - relId -.5;
    outCol = vec4(0.);
    if (fract(rnd.x*6.222+rnd.y*8.233) <= coverage) {  
        if (mode==0) { // noise
            vec2 w = inverseTileTransform[0].xy;
            w = floor(vec2(dot(w, vec2(20.)), dot(w, vec2(20., -20.))));
            vec2 pixId = relId + 1.23 * (floor(v * w) + floor((length(tileTransform[0].xy)*5.*inverseTileTransform[2].xy) * w));
            outCol = __source__(hash22(pixId));
        }
        else if (mode==1) { // square non interpolated
            v = vec2(0., max(abs(v.x), abs(v.y)));
            vec2 vv = tf(inverseCurrentTransform, relId + (tf(inverseTileTransform, v) + 0.5));
            outCol = __source__(vv);
        }
        else if (mode==2) { // circle interpolated
            float size = 0.5 + inverseTileTransform[2].y;
            float d = length(v);
            float ang = atan(v.y, v.x);
            if (d<=size) {
                float spikeCount = 4.;
                float anglePeriod = PI2/spikeCount;
                float a1 = floor(ang/anglePeriod)*anglePeriod;
                float a2 = a1 + anglePeriod;
                float k = (ang-a1) / anglePeriod;
                float ds = d * 10.0 * length(inverseTileTransform[0].xy); // tile parameter
                vec2 center = relId + 0.5;
                vec2 u1 = tf(inverseCurrentTransform, center+ds*vec2(cos(a1), sin(a1)) + inverseTileTransform[2].x);
                vec2 u2 = tf(inverseCurrentTransform, center+ds*vec2(cos(a2), sin(a2)) + inverseTileTransform[2].x);
                vec4 col1 = __source__(u1);
                vec4 col2 = __source__(u2);
                outCol = mix(col1, col2, k);
            }    
        }
        else if (mode==3) { // square interpolated
            bool vert = abs(v.y)>abs(v.x);
            float a = vert ? v.y : v.x;
            vec2 u1 = vert ? vec2(-a, a) : vec2(a, -a);
            vec2 u2 = vec2(a, a);
            float k = (v.x+v.y) / (2.*a);
            u1 = tf(inverseCurrentTransform, relId + (tf(inverseTileTransform, u1) + 0.5));
            u2 = tf(inverseCurrentTransform, relId + (tf(inverseTileTransform, u2) + 0.5));
            vec4 col1 = __source__(u1);
            vec4 col2 = __source__(u2);
            outCol = mix(col1, col2, k);
        }
        else if (mode==4) { // leaf
            float size = 0.5;
            float ang = atan(inverseTileTransform[0].y, inverseTileTransform[0].x);
            float orientation = ang<0.0 ? sign(mod(relId.x+relId.y, 2.)-0.5) : 1.;
            if (rnd.y > abs(ang)/PI) orientation = -orientation;
//            float orientation = (rnd.y-.5);
            float p = orientation*v.x*v.y < 0. ? 40. : 2.5;
            float d = p>30. ? max(abs(v.x), abs(v.y)) : pow(pow(abs(v.x), p) + pow(abs(v.y), p), 1./p);
            v = vec2(0., d);
            if (v.y<=size) {
                vec2 vv = tf(inverseCurrentTransform, relId + (tf(inverseTileTransform, v) + 0.5));
                outCol = __source__(vv);
            }
        }        
        else if (mode<=6) { // circles and squares
            float scale = length(inverseTileTransform[0].xy);
            bool invert = scale < 1.0;
            if (invert) scale = 1./scale;
            float ds  = fract(scale);
            float N = max(floor(scale), 1.);
            vec2 w = fract((v + 0.5)*N) - 0.5;
            vec2 center = floor((v + 0.5)*N)/N * 2. - 1.0 + 1.0/N;
            float ang = atan(inverseTileTransform[0].y, inverseTileTransform[0].x);
            float keepX = 1.0;
            float keepY = 1.0;
            if (ang>0.0) keepX = 1.0 - ang/PI;
            else keepY = 1.0 + ang/PI;
            bool hide = abs(center.x)>keepX || abs(center.y)>keepY;
            
            float size = mix(0.5, 0.15, ds);
            bool outside = (mode==6 && length(w)>size) || (mode==5 && (abs(w.x)>size || abs(w.y)>size));
            if (!(hide || outside)) {
                outCol = __source__(id + inverseTileTransform[2].xy);
            }
            else if (invert) {
                outCol = __source__(id);
            }
        }
        else if (mode==7) { // bw checkerboard
            vec2 w = inverseTileTransform[0].xy;
            w = floor(vec2(dot(w, vec2(16.)), dot(w, vec2(16., -16.))));
            
            float minScale = startScale * 2.0 * pow(2., floor(2.*inverseTileTransform[2].y));
            float maxScale = max(minScale, startScale * 4.0 * pow(2., floor(2.*inverseTileTransform[2].x)));
            float scale2 = clamp(scale, minScale, maxScale);
            float invScaleRatio = scale2/scale;
            mat3 tr = mat3(invScaleRatio, 0., 0., 0., invScaleRatio, 0., 0., 0., 1.) * currentTransform;
            v = tf(tr, _uv) - .5;

            vec2 pixId = floor(v * w);
            float k = mod(pixId.x + pixId.y, 2.);
            outCol = vec4(vec3(k), 1.);
        }
        else if (mode==8) { // bw 45° hatch
            float Xn = 8. /* length(inverseTileTransform[0].xy)*/;
            float scale2 = startScale * 4.;//min(max(scale, startScale * 4.), startScale * 4.);
            //float scale2 = scale;
            float invScaleRatio = scale2/scale;
            mat3 tr = mat3(invScaleRatio, 0., 0., 0., invScaleRatio, 0., 0., 0., 1.) * currentTransform;
            v = tf(tr, _uv) - .5;
            float piN = PI/16.;
            float ang = floor(atan(inverseTileTransform[0].y, inverseTileTransform[0].x)/piN)*piN;
            v = (rotation2(ang)*v) * length(inverseTileTransform[0].xy) + 2.*inverseTileTransform[2].xy;
            float k = mod(floor((v.x+v.y*sign(rnd.y-.5))*Xn), 2.);
            outCol = vec4(vec3(k), 1.);
        }
        else if (mode==9) { // compact disk effect
            float N = floor(1000. * pow(0.25, length(inverseTileTransform[2].xy)));// could be a parameter
            //float N = 32. * startScale / scale;// doesn't really work (angles need to be rounded differently) but could interesting to get right
            float offset = PI*.5 + PI/N + atan(inverseTileTransform[1].y, inverseTileTransform[1].x);
            float ang = atan(v.y, v.x);
            ang = round((ang-offset)/PI2*N) / N*PI2 + offset;
            float dist = length(inverseTileTransform[0].xy) * 0.5 / max(abs(cos(ang)), abs(sin(ang))); // could be a parameter
            //float dist = 0.3; // could be a parameter
            v = dist * vec2(cos(ang), sin(ang));
            vec2 u = tf(inverseCurrentTransform, relId + (v + 0.5));
            outCol = __source__(u);
        }
        else if (mode==10) { // hsl
            float s = length(inverseTileTransform[0].xy)*0.05;
            v += 0.5;
            float N = 16.;
            float ang = floor(atan(inverseTileTransform[0].y, inverseTileTransform[0].x)/PI*N)*PI/N;
            v = rotation2(ang) * v;
            vec4 rgb = hslToRgb(vec4((v.x+inverseTileTransform[2].x*length(tileTransform[0].xy))*360., 1., v.y+inverseTileTransform[2].y*length(tileTransform[0].xy), 1.));
            //vec4 rgb = clamp(vec4(hsl2rgb(vec3((v.x+inverseTileTransform[2].x*length(tileTransform[0].xy)), 1., v.y+inverseTileTransform[2].y*length(tileTransform[0].xy))), 1.), 0., 1.);
            vec4 inc = __source__(_uv);
            float dist = length(inc.rgb - rgb.rgb);
            float k = 1.0 - smoothstep(0.0, 1.7, dist) * s;
            rgb = mix(inc, rgb, k);
                         
            outCol = rgb;
        }
//        else if (mode==11) { // hsl adaptive
//            float colorScaling = 0.5 * length(inverseTileTransform[0].xy); // could be a parameter
//            vec4 inc = __source__(id);
//            vec4 hslInc = rgbToHsl(inc);
//            v += 0.5;
//            float saturation = hslInc.y; // or 1.0
//            vec4 rgb = hslToRgb(vec4(hslInc.x + v.x*360.*colorScaling, saturation, hslInc.z + v.y*colorScaling, 1.));
//            outCol = rgb;
//        }
        else if (mode==11) { 
            float N = round(4. * abs(inverseTileTransform[0].x));
            vec2 center = vec2(0., floor((v.y + 0.5)*N)/N * 2. - 1.0 + 1.0/N)*.5;
            vec2 dv = abs(v - center);
            if (dv.x < 0.45 && dv.y < 0.4/N) {
                float s = inverseTileTransform[2].x + 1.0;
                vec2 u1 = tf(inverseCurrentTransform, relId + (s*vec2(0., -0.5) + 0.5));
                vec2 u2 = tf(inverseCurrentTransform, relId + (s*vec2(0., 0.5) + 0.5));
                outCol = mix(__source__(u1), __source__(u2), center.y + 0.5);
            }
        }
        else if (mode==12) { // scale
            v *= vec2(2., 2.);
            v = tf(inverseTileTransform, v);
            outCol = __source__(tf(inverseCurrentTransform, relId + (v + 0.5)));
        }
        else if (mode==13) { // halftone lines
            float lum = luma(__source__(_uv).rgb);
            v = tf(inverseTileTransform, v*vec2(8., 8.));
            float y = abs(mod(v.y+1.0, 2.) - 1.0);
            float k = lum>y ? 1.0 : 0.0;
            outCol = vec4(vec3(k), 1.);
        }
        else if (mode==14) { // red green gradient
            float lum = luma(__source__(id).rgb);
            float contrast = length(tileTransform[0].xy);
            outCol = vec4(v+.5, 0.5 + contrast*(lum-0.5), 1.);
        }
        else if (mode==15) {     
            vec2 center = sign(rnd-0.5) * 0.5;
            vec2 dv = v - center;
            float N = floor(16.0 * length(inverseTileTransform[0].xy));
            float angOffset = 0.0;
            float ang = atan(dv.y, dv.x) + angOffset;
            float k = abs(mod(ang/PI*N*2., 2.0) - 1.0);
            float kCol = atan(inverseTileTransform[0].y, inverseTileTransform[0].x)/PI;
            float lum = 0.;
            for(int i =0; i<5; ++i) {
                vec2 w = tf(inverseCurrentTransform, relId + (0.1+0.15*float(i))*vec2(cos(ang), sin(ang)));
                lum += luma(__source__(w).rgb);            
            }
            lum /= 5.;
            k = lum>k ? 1.0 : 0.0;
            if (kCol==0.0) {
                outCol = vec4(vec3(k), 1.);
            }
//            else if (kCol>0.0) {
//                vec4 col1 = __source__(id + vec2(inverseTileTransform[2].x, 0.));
//                vec4 col2 = __source__(id + 1.0 + vec2(0.0, inverseTileTransform[2].y));
//                if (luma(col1.rgb)>luma(col2.rgb)) k = 1. - k;
//                vec4 outCol1 = vec4(vec3(k), 1.);
//                vec4 outCol2 = mix(col1, col2, k);
//                outCol = mix(outCol1, outCol2, kCol);
//            }
//            else {
//                vec4 col1 = __source__(vec2(inverseTileTransform[2].x, 0.));
//                vec4 col2 = __source__(vec2(0.0, inverseTileTransform[2].y));
//                if (luma(col1.rgb)>luma(col2.rgb)) k = 1. - k;
//                vec4 outCol1 = vec4(vec3(k), 1.);
//                vec4 outCol2 = mix(col1, col2, k);
//                outCol = mix(outCol1, outCol2, abs(kCol));
//            }
            else {
                vec2 u1 = vec2(inverseTileTransform[2].x, 0.);
                vec2 u2 = vec2(0.0, inverseTileTransform[2].y);
                if (kCol>0.0) {
                    u1 += id;
                    u2 += id + 1.;
                }
                vec4 col1 = __source__(u1);
                vec4 col2 = __source__(u2);
                if (luma(col1.rgb)>luma(col2.rgb)) k = 1. - k;
                vec4 outCol1 = vec4(vec3(k), 1.);
                vec4 outCol2 = mix(col1, col2, k);
                outCol = mix(outCol1, outCol2, abs(kCol));
            }
        }
    }

};
    }
}
            col = mergeColor(col, outCol);
                                  
            return col;           
        }
