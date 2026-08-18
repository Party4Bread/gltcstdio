#define MAXHEIGHT 0.75

#define RADIUS 0.1

float multiSine(float x, int n, float kf, float power) {
    float y = 0.;
    float k = 1.;
    float f = 1.;
    float totalK = 0.;
    for(int i=0; i<n; ++i) {
        //y += sin(x*f+1.) * k;
        //y += 2.*abs(abs(sin(x*f+1.))-0.5) * k;
        y += k * (0.75-abs(sin(x*f+1.)-0.5)) / 0.75;
        totalK += k;
        k *= 0.35;
        f *= kf;
    }
    return pow(abs(y / totalK), power) * sign(y);
}

vec4 tree4(vec2 uv, float id, float treePattern, vec4 treeColor, mat3 treeTransform) {
    float rnd = hash11(id);
    float angle = (rnd - 0.5)*0.15;
    //if (abs(angle)>0.05) return vec4(0.);
    float treeProb = sin(id*0.25);
//    if (fract(rnd*11.1)>0.25+0.5*sign(treeProb)*pow(treeProb, 3.)) return vec4(0.);
    if (fract(rnd*11.1)>0.25+0.5*treeProb*treeProb*treeProb) return vec4(0.);
    //mat2 rot = rotation2(angle);
    mat2 rot = rotation2(angle) * (1.05+6.*angle);
    uv = rot * uv;
    
    if (fract(rnd*10.0)<0.015) { // decorate tree
        if (length(uv-vec2(0.1, 0.80)) < 0.07) return vec4(0.9, 0.8, 0.04, 1.);
        if (length(uv-vec2(-0.1, 1.20)) < 0.07) return vec4(0.9, 0.8, 0.04, 1.);
        if (length(uv-vec2(0.1, 1.70)) < 0.07) return vec4(0.9, 0.8, 0.04, 1.);
        if (length(uv-vec2(-0.1, 2.00)) < 0.07) return vec4(0.9, 0.8, 0.04, 1.);
        if (length(uv-vec2(-0.2, 0.70)) < 0.07) return vec4(0.9, 0.1, 0.04, 1.);
        if (length(uv-vec2(0.2, 1.30)) < 0.07) return vec4(0.9, 0.1, 0.04, 1.);
        if (length(uv-vec2(0.05, 2.30)) < 0.07) return vec4(0.9, 0.1, 0.04, 1.);
        if (length(uv-vec2(-0.2, 1.50)) < 0.07) return vec4(0.9, 0.1, 0.04, 1.);
        if (length(uv-vec2(0.35, 0.45)) < 0.07) return vec4(0.9, 0.1, 0.04, 1.);
        if (sdStar5(uv-vec2(0., 2.75), 0.25, 0.45) < 0.) return vec4(0.9, 0.8, 0.04, 1.);
    }
    
    float d = 0.;
    if (d<0.0) return vec4(0.5, 0.25, 0.15, 1.0);
    d = min(d, sdTriangleIsosceles(vec2(uv.x, -uv.y+2.0), vec2(0.5, 1.5))-0.05 );
    d = min(d, sdTriangleIsosceles(vec2(uv.x, -uv.y+2.3), vec2(0.5, 1.5)*0.75)-0.05 );
    d = min(d, sdTriangleIsosceles(vec2(uv.x, -uv.y+2.6), vec2(0.5, 1.5)*0.5)-0.05 );
    
    //if (d<0.0) return vec4(0.9, 0.9, 0.9, 1.0);
    if (d<0.0) {
        float dShade = min(d, sdTriangleIsosceles(vec2(uv.x, -uv.y+1.85), vec2(0.5, 1.5)*1.0)-0.05 );
        vec4 col = vec4(0.1, 0.6, 0.3, 1.0);
        if (treePattern>1.0) {
            float colTransition = min(treePattern-1.0, 1.0);
            vec4 otherCol = mergeColor(col, vec4(treeColor.rgb, treeColor.a*colTransition));
            float intensity = max(0., treePattern-2.0) * 0.1;
            float shape = abs(mod((treePattern-1.0)*2., 2.)-1.)*2.-1.;
            vec2 u = tf(inverse(treeTransform), uv*4.);
            col = mix(col, otherCol, floor(mod(u.y + triangleToSquareWave(u.x, shape)*intensity, 2.0)));
        }
        return vec4(col.rgb * mix(0.8, 1.0, smoothstep(mix(-0.125, -0.25, min(1.0, treePattern)), 0.0, dShade)), col.a);
    }
    d = sdRectangle(uv-vec2(0., 0.0), vec2(0.1, 0.7));
    if (d<0.0) return mix(vec4(0.5, 0.25, 0.15, 1.0), vec4(0.25, 0.125, 0.075, 1.0), smoothstep(0.0, 0.5, uv.y));

    else return vec4(0.);
}

vec4 starLayer(vec2 uv) {
    float N = 1.0;
    vec2 id = round(uv);
    //vec4 col = vec4(0.);
    float total = 0.;
    for(float x = -N; x<=N; ++x) {
        for(float y = -N; y<=N; ++y) {
            vec2 starId = vec2(id.x+x, id.y+y);
            vec2 rnd = hash22b(starId);
            vec2 starCenter = starId + (rnd-.5)*2.;
            float r = pow(fract((rnd.x + rnd.y)*10.), 15.) * 0.15+0.00001;
            //col = mergeColor(col, smoothstep(r*1.5, r*0.5, length(uv-starCenter)) *vec4(1.));
            total += smoothstep(r*1.5, r*0.5, length(uv-starCenter));
        }
    }
    return vec4(1., 1., 1., total); //col;
}

vec4 shootingStarLayer(vec2 uv, float time) {
    float k = 0.;
    float N = 5.0;
    for(float i=0.; i<N; ++i) {
        vec2 rnd = hash12(i);
        float radius = (1. + fract(rnd.x*10.0)) * 350.;
        float strength = 0.2 + fract(rnd.x*23.32);
        vec2 point = (rnd-0.5)*40. + vec2(0., 0.);
        vec2 dir = normalize(point);
        vec2 center = point - dir*radius;
        //if (length(uv)<1.0) return vec4(0., 1., 1., 0.5);
        //if (length(center-uv)<0.8) return vec4(1., 1., 0., 0.5);
        //if (length(point-uv)<0.8) return vec4(1., 0., 0., 0.5);
        //if (abs(length(uv-center)-radius)<0.1) return vec4(1., 1., 1., 0.15);
        float startAngle = fract(rnd.y*10.)*6.28;
        float angle = startAngle + time*1.;
        vec2 pos = center + radius * vec2(cos(angle), sin(angle));
        dir = normalize(pos-center);
        vec2 trailUv = mat2(1., 0., 0., -1.) * inverse(mat2(dir, vec2(-dir.y, dir.x))) * (uv-pos);
        
        k += 0.05/pow(length(trailUv), 2.) * strength;
        float trailD = sdUnevenCapsule(trailUv, 0.5, 0.005, 15.0);
        /*if (trailD<0.) k += 1.; else*/ 
        k += 1./pow(trailD+1.5, 3.) * strength;
    }
    return vec4(1., 1., 1., k);
}

vec4 sky(vec2 uv) {
    float y = clamp(uv.y*0.5+0.5, 0., 1.0);
    return vec4(y*0.1, y*0.4, y, 1.0);
}

vec3 mixHSL(vec3 a, vec3 b, float k) {
    vec4 step =  vec4(360., 0., 0., 0.);
    vec4 hslA = rgbToHsl(vec4(a, 1.));
    vec4 hslB = rgbToHsl(vec4(b, 1.));
    if (abs(hslA.x+360.-hslB.x)<abs(hslA.x-hslB.x)) {
        return hslToRgb(mix(hslA+step, hslB, k)).rgb;
    }
    if (abs(hslB.x+360.-hslA.x)<abs(hslA.x-hslB.x)) {
        return hslToRgb(mix(hslA, hslB+step, k)).rgb;
    }
    return hslToRgb(mix(hslA, hslB, k)).rgb;
}

vec3 interpolateCol3(float k0, vec3 col0, float k1, vec3 col1, float k2, vec3 col2, float k) {
    if (k<k1) return mix(col0, col1, (k-k0)/(k1-k0));
    return mix(col1, col2, (k-k1)/(k2-k1));
}

vec3 interpolateCol4(float k0, vec3 col0, float k1, vec3 col1, float k2, vec3 col2, float k3, vec3 col3, float k) {
    if (k<k1) return mix(col0, col1, (k-k0)/(k1-k0));
    if (k<k2) return mix(col1, col2, (k-k1)/(k2-k1));
    return mix(col2, col3, (k-k2)/(k3-k2));
}

vec3 interpolateCol5(float k0, vec3 col0, float k1, vec3 col1, float k2, vec3 col2, float k3, vec3 col3, float k4, vec3 col4, float k) {
    if (k<k1) return mix(col0, col1, (k-k0)/(k1-k0));
    if (k<k2) return mix(col1, col2, (k-k1)/(k2-k1));
    if (k<k3) return mix(col2, col3, (k-k2)/(k3-k2));
    return mix(col3, col4, (k-k3)/(k4-k3));
}

vec3 interpolateCol5b(float k0, vec3 col0, float k1, vec3 col1, float k2, vec3 col2, float k3, vec3 col3, float k4, vec3 col4, float k) {
    if (k<k1) return mixHSL(col0, col1, (k-k0)/(k1-k0));
    if (k<k2) return mixHSL(col1, col2, (k-k1)/(k2-k1));
    if (k<k3) return mixHSL(col2, col3, (k-k2)/(k3-k2));
    return mixHSL(col3, col4, (k-k3)/(k4-k3));
}

#define MAXHEIGHT 0.75

#define RADIUS 0.1

mat3 getLighting(float time) {
    float angle = time;
    vec2 moonPos = vec2(MAXHEIGHT, MAXHEIGHT) * vec2(sin(angle), -cos(angle));
    vec2 sunPos = -moonPos;
    vec3 lightAtSun = interpolateCol5(
        -MAXHEIGHT, vec3(0.1, 0.4, 1.0), //vec3(0.2, 0.8, 1.0),
        -MAXHEIGHT*0.3, vec3(1.0, 0.9, 0.2),
        MAXHEIGHT*0.1, vec3(0.5, 0.1, 0.0),
        MAXHEIGHT*0.2, vec3(0.1, 0.4, 1.0)*0.1,
        MAXHEIGHT, vec3(.0),
        sunPos.y);
    vec3 lightAtTop = interpolateCol5(
        -MAXHEIGHT, vec3(0.1, 0.4, 1.0),
        -MAXHEIGHT*0.3, vec3(0.3, 0.1, 0.8),
        MAXHEIGHT*0.1, vec3(0.3, 0.1, 0.8),
        MAXHEIGHT*0.2, vec3(0.1, 0.4, 1.0)*0.1,
        MAXHEIGHT, vec3(0.),
        sunPos.y);
    float phaseOffset = (fract(time*0.015) - 0.5) * (RADIUS * 4.6);
    return mat3(lightAtSun, lightAtTop, vec3(sunPos, phaseOffset));
}

vec4 skyWithMoon(vec2 uv, float time) {
    float y = clamp(uv.y*0.5+0.5, 0., 1.0);

    //float phaseOffset = (fract(time*1.1/*0.015*/) - 0.5) * (RADIUS * 4.6);

    mat3 lighting = getLighting(time);
    vec3 lightAtSun = lighting[0];
    vec3 lightAtTop = lighting[1];
    vec2 sunPos = lighting[2].xy;
    float phaseOffset = lighting[2].z;
    vec2 moonPos = -sunPos;

    float dMoon = length(uv-moonPos) - RADIUS;
    float dShadow = length(uv-(moonPos+vec2(phaseOffset, 0.0)))-RADIUS;
    float dd = max(dMoon, -dShadow);
    if (dd<0.) return vec4(1.);
    float kMoonPower = 1.0-min(1.0, abs(phaseOffset)/(2.*RADIUS));
    vec4 moonGlowCol = vec4(0.5, 0.7, 1., 1.) * (1.0-0.8*kMoonPower);

    float dSun = length(uv-sunPos) - RADIUS;
    if (dSun<0.) return vec4(1.);
    vec4 sunGlowCol = vec4(1.0, 1.0, 0.8, 1.);

    float dy = uv.y-sunPos.y;
//if (abs(dy)<0.01) return vec4(1.0);// else return vec4(vec3(-dy), 1.);
    //vec4 baseSky = vec4(mix(lightAtSun, lightAtTop, -(uv.y-sunPos.y)*0.25), 1.0); //vec4(y*0.1, y*0.4, y, 1.0);
    vec4 baseSky = vec4(mix(lightAtSun, lightAtTop, -dy), 1.0);
    //vec4 baseSky = vec4(mix(vec3(0., 1., 0.), vec3(0.), -dy), 1.0);
//return baseSky;
    //if (dMoon<0.) return baseSky + moonGlowCol;//mix(baseSky, moonGlowCol, 1.0);
    if (dMoon<0.) return mix(vec4(1.), baseSky + moonGlowCol, clamp(-dShadow/0.005, 0., 1.));//mix(baseSky, moonGlowCol, 1.0);
    //if (length(uv-moonPos)<0.) return vec4(1.);
    float moonPower = mix(2.0, 12.0, kMoonPower);
    float sunPower = mix(13., 3., smoothstep(-MAXHEIGHT*0.7, -MAXHEIGHT, sunPos.y));

    vec2 starUv = (rotation2(time*0.5)*(uv-vec2(0., -0.75))+vec2(0., -0.75))*50.;
    float kNight = smoothstep(-MAXHEIGHT*0.35, MAXHEIGHT*0.3, sunPos.y);
    baseSky = mergeColor(baseSky, starLayer(starUv) * vec4(vec3(1.), kNight));
    baseSky = mergeColor(baseSky, shootingStarLayer(starUv, time) * kNight);

    vec4 withMoon = baseSky + mix(baseSky, moonGlowCol, 1./pow((dMoon+1.)*1.00, moonPower)) * smoothstep(-MAXHEIGHT*0.2, -MAXHEIGHT*0.5, moonPos.y);
    vec4 withSun = mix(withMoon, sunGlowCol, 1./pow((dSun+1.)*1.00, sunPower));
    return withSun;

    //else return mix(baseSky, vec4(0.8, 0.9, 1., 1.), 1./pow((d+1.)*1.00, 2.));
}

vec4 rabbit(vec2 v, float id) {
    //vec4 mainCol = vec4(0.8, 0.65, 0.5, 1.);
    vec4 mainCol = vec4(0.95, 0.93, 0.9, 1.);
    v.y += -0.08;
    float d;
    vec2 uv;
    

    uv = v - vec2(0.03, 0.2);
    // eyes
    vec2 u = vec2(abs(uv.x)-0.055, uv.y-0.0);
    if (length(u)-0.0125 < 0.0) return vec4(0.2, 0.2, 0.2, 1.);
    
    // nose
    u = uv - vec2(0., -0.06);
    if (sdTriangleIsosceles(u, vec2(0.010, 0.010))-0.005 < 0.0) return vec4(0.2, 0.2, 0.2, 1.);
    
    
    // head
    d = length(uv*vec2(1., 1.1))-0.1;
    if (d<0.) return mainCol;
    u = vec2(abs(uv.x)-0.06, uv.y+0.02);
    if (length(u)-0.06 < 0.0) return mainCol;
    d = length(uv*vec2(1., 3.)+vec2(0., 0.22))-0.1;
    if (d<0.) return vec4(mainCol.rgb*0.8, 1.);
       
    // ears
    uv = vec2(abs(uv.x)-0.07, uv.y-0.13);
    uv *= rotation2(-0.3);
    d = sdVesica(uv, 0.18, 0.15);
    if (d<0.) return vec4(mainCol.rgb*vec3(1., 0.9, 0.9), 1.);
    d = sdVesica(uv, 0.2, 0.15);
    if (d<0.) return vec4(mainCol.rgb*0.8, 1.);

    // body
    uv = v;
    d = min(length(uv*vec2(0.8, 1.))-0.13, length(uv-vec2(0.03, 0.08)*vec2(1.0, 0.8))-0.13);
    if (d<0.) return mainCol;
    d = length(uv+vec2(0.15, 0.05))-0.05;
    if (d<0.) return vec4(mainCol.rgb*0.95, 1.);


    else return vec4(0.);
}

vec4 snowman(vec2 v, float id) {
    //vec4 mainCol = vec4(0.8, 0.65, 0.5, 1.);
    vec4 mainCol = vec4(0.9, 0.9, 0.9, 1.);
    v.y += -0.18-1.05;
    float d;
    vec2 uv, u;
    
    uv = v;

    // foreground arm    
    u = rotation2(-0.4) * (uv - vec2(0.39, -0.30));
    d = sdRectangle(u, vec2(0.2, 0.03));
    if (d<0.) return vec4(0.5, 0.3, 0.05, 1.); 
    u = rotation2(-0.8) * (uv - vec2(0.60, -0.15));
    d = sdRectangle(u, vec2(0.12, 0.025));
    if (d<0.) return vec4(0.5, 0.3, 0.05, 1.); 
    u = rotation2(-0.2) * (uv - vec2(0.68, -0.20));
    d = sdRectangle(u, vec2(0.15, 0.027));
    if (d<0.) return vec4(0.5, 0.3, 0.05, 1.); 


    // eyes
    u = vec2(abs(uv.x+0.1)-0.12, uv.y-0.05);
    if (length(u)-0.04 < 0.0) return vec4(0.2, 0.2, 0.2, 1.);
    
    // nose
    u = rotation2(1.0) * (uv+vec2(0.35, 0.2));
    if (sdTriangleIsosceles(u, vec2(0.040, 0.320))-0.01 < 0.0) return vec4(0.7, 0.4, 0.1, 1.);
    
    d = length(uv)-0.35;
    if (d<0.) return vec4(mainCol.rgb, 1.);
    
    uv.y += 0.45;
    
    // buttons
    u = vec2(uv.x+0.2, uv.y-0.1);
    if (length(u)-0.04 < 0.0) return vec4(0.2, 0.2, 0.2, 1.);
    u = vec2(uv.x+0.215, uv.y+0.05);
    if (length(u)-0.04 < 0.0) return vec4(0.2, 0.2, 0.2, 1.);
    u = vec2(uv.x+0.2, uv.y+0.2);
    if (length(u)-0.04 < 0.0) return vec4(0.2, 0.2, 0.2, 1.);
   
    d = length(uv)-0.4;
    if (d<0.) {
        d = length(uv-vec2(0., 0.4))-0.35;
        //if (d<0.) return vec4(mainCol.rgb*0.9, 1.);
        return vec4(mainCol.rgb, 1.);
    }
    
    uv.y += 0.525;
    d = length(uv)-0.5;
    if (d<0.) {
        d = length(uv-vec2(0., 0.4))-0.4;
        //if (d<0.) return vec4(mainCol.rgb*0.9, 1.);
        return vec4(mainCol.rgb, 1.);
    }

    uv.y -= 0.9;
    // hat
    
    u = rotation2(-2.7) * (uv - vec2(0.2, 0.68));
    d = sdTriangleIsosceles(u, vec2(0.18, 0.42))-0.0;
    if (d<0.) return vec4(0.8, 0.1, 0.1, 1.); 

    // foreground arm  
    uv.x = -uv.x;
    u = rotation2(-0.4) * (uv - vec2(0.39, -0.30));
    d = sdRectangle(u, vec2(0.2, 0.03));
    if (d<0.) return vec4(0.5, 0.3, 0.05, 1.); 
    u = rotation2(-0.8) * (uv - vec2(0.60, -0.15));
    d = sdRectangle(u, vec2(0.12, 0.025));
    if (d<0.) return vec4(0.5, 0.3, 0.05, 1.); 
    u = rotation2(-0.2) * (uv - vec2(0.68, -0.20));
    d = sdRectangle(u, vec2(0.15, 0.027));
    if (d<0.) return vec4(0.5, 0.3, 0.05, 1.); 
    
    return vec4(0.);
}

vec4 hills3(vec2 uv, float hillPattern, vec4 hillColor, mat3 hillTransform, float treePattern, vec4 treeColor, mat3 treeTransform) {
    float y = -uv.y;
    float h = perlinOctaveNoise(vec2(uv.x, 0.), 1)-0.5;
    float dx = 0.02;
    float h2 = perlinOctaveNoise(vec2(uv.x+dx, 0.), 1)-0.5;
    float dy = (h2-h)/dx;
    //float hh = h-0.04;
    float hh = min(h-0.04, h + dy*2.);
    if (y < h) {
        vec4 col = vec4(0.9, 0.9, 0.9, 1.0);
        if (hillPattern!=0.) {
            vec4 otherCol = mergeColor(col, hillColor);
            col = mix(col, otherCol, floor(mod(pow(abs(tf(hillTransform, vec2(uv.x, -uv.y)).y-h), hillPattern*2.)*20., 2.0)));
        }
        col.rgb *= mix(1.0, 0.9, smoothstep(h, hh, y));
        return col;
    }
    else {
        if (y-h>0.32) return vec4(0.); // optimization if we're above tree line, return immediately
        
        float X, x, hh, hh2;
        
        // rabbit & snowman
        X = (round(uv.x*5.00) -.0) / 5.;
        if (abs(uv.x-X)<0.06 && abs(y-h)<0.2) {
            //return vec4(1., 0., 0., 1.);
            float rnd = hash11(X);
            float rnd2 = fract(rnd*34.3+0.333);
            if (rnd2<0.025) {
                x = (uv.x-X)*5.;//round(uv.x*8.00) - 0.5;
                hh = perlinOctaveNoise(vec2(X, 0.), 1)-0.5;
                hh2 = perlinOctaveNoise(vec2(X+dx, 0.), 1)-0.5;
                float dy = (hh2-hh)/dx;
                if (abs(dy)<0.15) {
                    vec4 rabbitCol = rabbit(3.*vec2(x, (y-hh)*5.), X);
                    if (rabbitCol.a!=0.) return rabbitCol;
                }
            }
            if (rnd2>0.985) {
                x = (uv.x-X)*5.;//round(uv.x*8.00) - 0.5;
                hh = perlinOctaveNoise(vec2(X, 0.), 1)-0.5;
                vec4 snowmanCol = snowman(5.*vec2(x, (y-hh)*5.), X);
                if (snowmanCol.a!=0.) return snowmanCol;  
            }
        }

        X = (round(uv.x*8.00) -.0) / 8.;
        x = (uv.x-X)*8.;//round(uv.x*8.00) - 0.5;
        hh = perlinOctaveNoise(vec2(X, 0.), 1)-0.5;
        vec4 treeCol = tree4(2.*vec2(x, (y-hh)*8.), X, treePattern, treeColor, treeTransform);
        if (treeCol.a!=0.) return treeCol;

        // more trees
        float delta = 0.0625;
        X = (round((uv.x+delta)*8.00)) / 8.;
        x = ((uv.x+delta)-X)*8.;
        hh = perlinOctaveNoise(vec2(X-delta, 0.), 1)-0.5;
        treeCol = tree4(2.*vec2(x, (y-hh)*8.), X-delta, treePattern, treeColor, treeTransform)*vec4(vec3(0.9), 1.);
        if (treeCol.a!=0.) return treeCol;

        return vec4(0.);
    }
}

vec4 mountains4(vec2 uv, float kf, float mountainPattern, float mountainDetail, vec4 mountainColor, mat3 mountainTransform) {
    float y = -uv.y;
    if (y>1.0) return vec4(0.); // optim
    int N = 6;
    float msd = multiSine(uv.x, N, kf, 2.);
    float h = 0.75 * msd + 0.002*(perlinOctaveNoise(vec2(uv.x, 0.), 1)-0.5) + 0.2;
    float dx = 0.02;
    float msd2 = multiSine(uv.x+dx, N, kf, 2.);
    float dy = (msd2-msd)/dx;
    float snowloss;
    if (mountainDetail<=1.0) {
        snowloss = pow(0.5, h*10.) - mix(0., 0.1, mountainDetail) * (1. + mix(dy, abs(dy), 0.45));
    }
    else if (mountainDetail<=2.0) {
        snowloss = (pow(0.5, h*10.) - 0.1 - 0.1*mix(dy, abs(dy), 0.45)) + mix(0., 1., mountainDetail-1.0) * smoothstep(0.0, 0.5, y)*(perlinOctaveNoise(uv*15.0, 2)-0.5);
    }
    else if (mountainDetail<=3.0) {
        snowloss = (pow(0.5, h*10.) - mix(0.1, 0.0, mountainDetail-2.) * (1. + mix(dy, abs(dy), 0.45))) + mix(1., 0., mountainDetail-2.0) * smoothstep(0.0, 0.5, y)*(perlinOctaveNoise(uv*15.0, 2)-0.5);
    }
    //float snowloss = pow(0.5, h*10.) - 0.1 - 0.1*mix(dy, abs(dy), 0.45);
    //float snowloss = (pow(0.5, h*10.) - 0.1 - 0.1*mix(dy, abs(dy), 0.45)) + 0.5*smoothstep(0.0, 0.5, y)*(perlinOctaveNoise(uv*15.0, 2)-0.5);
    //float snowloss = -h*0.1*mix(dy, abs(dy), 0.45) + 1.5*abs(h*h)*(perlinOctaveNoise(uv*15.0, 3)-0.5);
    //float snowloss = -h*0.1*mix(dy, abs(dy), 0.45) + 0.65*(perlinOctaveNoise(uv*vec2(20.0, 10.), 2)-0.5);
    //float snowloss = pow(0.5, h*10.) - 0.1*mix(dy, abs(dy), 0.0);
    float h2 = h + snowloss;
    vec4 col;
    if (y > h) col = vec4(0.);
    else if (y<h2) col = vec4(0.9, 0.9, 0.9, 1.0);
    else col = vec4(0.5, 0.5, 0.5, 1.0);//vec4(0.1, 0.6, 0.3, 1.0);
    if (mountainPattern!=0.0 && y<=h) {
        float colTransition = min(mountainPattern, 1.0);
        vec4 otherCol = mergeColor(col, vec4(mountainColor.rgb, mountainColor.a*colTransition));
        float intensity = max(0., mountainPattern-2.0) * 0.1;
        float shape = abs(mod((mountainPattern-1.0)*2., 2.)-1.)*2.-1.;
        vec2 u = tf(inverse(mountainTransform), (uv+vec2(0., h * smoothstep(2., 1., mountainPattern)))*20.);
        col = mix(col, otherCol, floor(mod(u.y + triangleToSquareWave(u.x, shape)*intensity, 2.0)));
    }
    return col;
}

vec4 getColorAtLayer(vec4 col, float z, float time) {
    //vec4 lightedCol = col * vec4(0.1, 0.4, 1.0, 1.0);
    vec4 lightedCol = col * vec4(0.2, 0.5, 1.0, 1.0);
    vec4 haze = vec4(0.0, 0.02, 0.04, col.a);
    return mix(haze, lightedCol, pow(0.9, z));
}

vec4 getColorAtLayer2(vec4 col, float z, mat3 lighting) {
    vec3 lightAtSun = lighting[0];
    vec3 lightAtTop = lighting[1];
    vec2 sunPos = lighting[2].xy;
    vec3 midColor = mix(lightAtSun, lightAtTop, 0.5);
    float phaseOffset = lighting[2].z;
    float kMoonPower = 1.0-min(1.0, abs(phaseOffset)/(2.*RADIUS));

    float sunPower = smoothstep(-MAXHEIGHT*0.4, -MAXHEIGHT, sunPos.y);
    midColor = mix(midColor, 1.08*vec3(1.0, 1.0, 1.2), smoothstep(-MAXHEIGHT*0.4, -MAXHEIGHT, sunPos.y));
    //if (sunPower<=0.) midColor = mix(midColor, vec3(0.2, 0.5, 1.0), max(0., 1.-kMoonPower));
    //if (sunPos.y>0.) midColor = mix(midColor, vec3(0.4, 0.62, 1.0), smoothstep(0.0, 0.2, sunPos.y) * max(0., 1.-kMoonPower));
    if (sunPos.y>0.) midColor = mix(midColor, vec3(0.62, 0.78, 1.0), smoothstep(0.0, 0.2, sunPos.y) * pow(mix(0.1, 1., max(0., 1.-kMoonPower)), 0.5));

    z = mix(z, z*0.15, sunPower); // less layer darkening as more sun

    //vec4 lightedCol = col * vec4(0.1, 0.4, 1.0, 1.0);
    //vec4 lightedCol = col * vec4(0.2, 0.5, 1.0, 1.0);
    vec4 lightedCol = col * vec4(midColor, 1.0);
    vec4 haze = vec4(0.0, 0.02, 0.04, col.a);
    return mix(haze, lightedCol, pow(0.9, z));
}

vec4 winterWonderland(vec2 uv, vec2 outPos, float time, mat3 modelTransform,
    vec4 treeColor, float treePattern, mat3 treeTransform,
    vec4 mountainColor, float mountainPattern, float mountainDetail, mat3 mountainTransform,
    vec4 hillColor, float hillPattern, mat3 hillTransform) {
    
    mat3 inverseModelTransform = inverse(modelTransform);
    vec2 delta = 2.5 * tf(inverseModelTransform, vec2(0., 0.));
    float scaling = length(inverseModelTransform[0].xy);
    vec4 col = vec4(0.);
    float t = time * PI / 5.;
    mat3 lighting = getLighting(t);
    //if (col.a==0.0) col = getColorAtLayer2(hills3(uv*0.125*scaling + vec2(11., -0.3)+ delta*1., hillPattern, hillColor, hillTransform, treePattern, treeColor, treeTransform), 1.0, lighting);
    
    if (col.a==0.0) col = getColorAtLayer2(hills3(uv*0.5*scaling + vec2(11., -0.2)+ delta*1., hillPattern, hillColor, hillTransform, treePattern, treeColor, treeTransform), 1.0, lighting);

    if (col.a==0.0) col = getColorAtLayer2(hills3(uv*scaling + delta*.75, hillPattern, hillColor, hillTransform, treePattern, treeColor, treeTransform), 3., lighting);

    if (col.a==0.0) col = getColorAtLayer2(hills3(uv*1.5*scaling + vec2(11., 0.2)+ delta* 0.5, hillPattern, hillColor, hillTransform, treePattern, treeColor, treeTransform), 5.0, lighting);

    if (col.a==0.0) col = getColorAtLayer2(mountains4(uv*scaling + delta* 0.1, 2.823, mountainPattern, mountainDetail, mountainColor, mountainTransform), 7.0, lighting);

    if (col.a==0.0) col = getColorAtLayer2(mountains4(uv*1.5*scaling + vec2(11., 0.2) + delta* 0.075, 2.4754, mountainPattern, mountainDetail, mountainColor, mountainTransform), 10.0, lighting);

    if (col.a==0.0) col = skyWithMoon(uv, t);
    
    return col;
}
