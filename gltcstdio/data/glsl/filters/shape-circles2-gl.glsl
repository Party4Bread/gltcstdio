float response(float d, float thickness, float blur) {
    return  pow(smoothstep(thickness, thickness+blur, d), 0.3);
}

float distToSegment(vec2 p, vec2 a, vec2 b) {
    vec2 ab = b-a;
    float abLen = length(ab);
    if (abLen==0.0) return length(p-a);
    vec2 abNorm = ab/abLen;
    vec2 ap = p-a;
    float abProj = dot(ap, abNorm);
    if (abProj>=0.0 && abProj<=abLen) {
        return abs(dot(ap, vec2(abNorm.y, -abNorm.x)));
    }
    else {
        return min(length(ap), length(p-b));
    }
}

float distToArc(vec2 p, vec2 center, float radius, float angBegin, float angEnd) {
    vec2 centerToP = p-center;
    float angle = atan(centerToP.y, centerToP.x);
    if (angle>=angBegin && angle<=angEnd) {
        return abs(length(p-center)-radius);
    }
    else {
        vec2 a = center + radius*vec2(cos(angBegin), sin(angBegin));
        vec2 b = center + radius*vec2(cos(angEnd), sin(angEnd));
        return min(length(p-a), length(p-b));
    }
}

float distToRadialTicks(vec2 p, vec2 center, int n, float r1, float r2, float angBegin, float angEnd, float varia, float randomSeed) {
    float d = 1e10;
    vec2 centerToP = p-center;
    float ang = atan(centerToP.y, centerToP.x);
    float dAng = (angEnd-angBegin)/float(n);
    float nd = floor(ang/dAng);

    if (varia!=0.0) {
        if (ang<-PI+dAng/2.0 && mod(float(n), 2.0)==1.0) nd = floor((ang+2.0*PI)/dAng);
        float dr = varia * rand2relSeeded(vec2(float(nd), float(nd)), randomSeed).x;
        r2 = max(r1, r2+dr);
    }

    vec2 dir = vec2(cos((nd+0.5)*dAng), sin((nd+0.5)*dAng));
    d = min(d, distToSegment(p, center+r1*dir, center+r2*dir));

    return d;
}

float distToPiePiece(vec2 p, vec2 center, int n, float r1, float r2, float angBegin, float angEnd) {
    float d = min(
        distToArc(p, center, r1, angBegin, angEnd),
        distToArc(p, center, r2, angBegin, angEnd)
    );
    vec2 centerToP = p-center;
    float ang = atan(centerToP.y, centerToP.x);
    float dAng = (angEnd-angBegin)/float(n);
    float nd = floor(ang/dAng);

    vec2 dir = vec2(cos((nd+0.5)*dAng), sin((nd+0.5)*dAng));
    d = min(d, distToSegment(p, center+r1*dir, center+r2*dir));

    return d;
}

float distToPolyPiece(vec2 p, vec2 center, int n, float r1, float r2, float angBegin, float angEnd) {
    float d = 1e10;
    vec2 centerToP = p-center;
    float ang = atan(centerToP.y, centerToP.x);
    float dAng = (angEnd-angBegin)/float(n);
    float nd = floor(ang/dAng);

    float a1 = nd*dAng;
    vec2 dir1 = vec2(cos(a1), sin(a1));

    float a2 = nd*dAng+dAng;
    vec2 dir2 = vec2(cos(a2), sin(a2));

    d = min(d, distToSegment(p, center+r1*dir1, center+r2*dir1));
    d = min(d, distToSegment(p, center+r1*dir2, center+r2*dir2));
    d = min(d, distToSegment(p, center+r2*dir1, center+r2*dir2));
    d = min(d, distToSegment(p, center+r1*dir1, center+r1*dir2));

    return d;
}

float distToDisjointPiePieces(vec2 p, vec2 center, int n, float r1, float r2, float angBegin, float angEnd, float varia, float randomSeed) {
    float d = 1e10;
    vec2 centerToP = p-center;
    float ang = atan(centerToP.y, centerToP.x);
    float dAng = (angEnd-angBegin)/float(n);
//    float eAng = dAng * 0.075;
    float eAng = dAng * 0.1;
    float nd = floor(ang/dAng);

    float a1 = nd*dAng+eAng;
    vec2 dir1 = vec2(cos(a1), sin(a1));

    float a2 = nd*dAng+dAng-eAng;
    vec2 dir2 = vec2(cos(a2), sin(a2));
    if (varia!=0.0) {
        if (ang<-PI+dAng/2.0 && mod(float(n), 2.0)==1.0) nd = floor((ang+2.0*PI)/dAng);
        float dr = varia * rand2relSeeded(vec2(float(nd), float(nd)), randomSeed).x;
        if (varia>0.0) r2 = max(r1, r2+dr);
        else r1 = max(0.0, min(r2, r1+dr));
    }

    d = min(d, distToSegment(p, center+r1*dir1, center+r2*dir1));
    d = min(d, distToSegment(p, center+r1*dir2, center+r2*dir2));
    d = min(d, distToArc(p, center, r1, a1, a2));
    d = min(d, distToArc(p, center, r2, a1, a2));

    return d;
}

vec4 circleGraphics(vec2 uv, vec2 outPos, int count, int mode, float randomSeed, float thickness, vec4 color, float radius, float glow, float variability, mat3 modelTransform) {
    mat3 invModelTransform = inverse(modelTransform);
    vec2 u = tf(invModelTransform, uv);

    float scale = length(invModelTransform[0].xy);

    thickness = pow(thickness, 2.0)* 0.25 * scale;

    float varia = variability;
    int m = mode;//int(mod(float(u_Mode), 4.0));
    float d = 1e10;
    float r2 = 0.5;
    float r1 = r2 * radius;
    if (m==0) d = distToPiePiece(u, vec2(0.0, 0.0), int(count), r1, r2, -PI, PI);
    else if (m==1) d = distToPolyPiece(u, vec2(0.0, 0.0), int(count), r1, r2, -PI, PI);
    else if (m==2) d = distToDisjointPiePieces(u, vec2(0.0, 0.0), int(count), r1, r2, -PI, PI, varia, randomSeed);
    else if (m==3) d = distToRadialTicks(u, vec2(0.0, 0.0), int(count), r1, r2, -PI, PI, varia, randomSeed);
    else {
        int N = int(mod(float(mode), 5.0)+2.0);
        vec2 rnd = rand2relSeeded(vec2(mode, mode), 0.0);
        for(int i=0; i<N; ++i) {
            m = int(mod(4.0*(rnd.y+0.5), 4.0));
            float kv = floor(rnd.y*2.0+0.5)-0.5;
            if (m==0) d = min(d, distToPiePiece(u, vec2(0.0, 0.0), int(count), r1, r2, -PI, PI));
            else if (m==1) d = min(d, distToPolyPiece(u, vec2(0.0, 0.0), int(count), r1, r2, -PI, PI));
            else if (m==2) d = min(d, distToDisjointPiePieces(u, vec2(0.0, 0.0), int(count), r1, r2, -PI, PI, varia*kv, randomSeed));
            else d = min(d, distToRadialTicks(u, vec2(0.0, 0.0), int(count), r1, r2, -PI, PI, varia*kv, randomSeed));
            float scale = 0.5 + 0.9*rnd.x;
            if (scale<0.05) break;
            r1 *= scale;
            r2 *= scale;
            rnd = rand2relSeeded(rnd, 0.0);
        }
    }

    float blur = glow;
    float k = response(d, thickness, blur * 0.2 * scale);
    float gg = 0.025*max(0.0, blur*100.0-50.0) *pow(1.0-k, 10.0); 
    float addK = smoothstep(0.5, 1.0, blur);
    vec4 bkgCol = __source__(uv);
    vec3 shapeRgb = (color.rgb+vec3(gg, gg, gg))*(gg+1.0);
    // k is 0 on the shape and 1 outside it, so coverage is 1-k.
    vec4 overCol = mergeColor(bkgCol, vec4(shapeRgb, color.a*(1.0-k)));
    // Additive branch: weight the shape colour away from a transparent source's
    // meaningless rgb, and let the added light carry its own alpha.
    vec3 addRgb = mix(bkgCol.rgb, shapeRgb, color.a + (1.0-bkgCol.a)*(1.0-color.a));
    vec4 addCol = vec4(addRgb*(1.0-k) + bkgCol.rgb*bkgCol.a, min(1.0, bkgCol.a + color.a*(1.0-k)));
    vec4 outCol = mix(overCol, addCol, addK);

    return outCol;
}
