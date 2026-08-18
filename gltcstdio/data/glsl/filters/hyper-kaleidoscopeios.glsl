vec2 invert(vec2 p, vec2 c, float r) {
    vec2 v = p-c;
    float l = length(p-c);
    return c + v*r*r/(l*l);
}

vec2 invert(vec2 pts[12], vec2 c, float r, int p)[12] {
    vec2 outPts[12];
    for(int i=0; i<p; ++i) {
        outPts[int(i)] = invert(pts[i], c, r);
    }
    return outPts;
}

vec3 getCircle(vec2 a, vec2 b, vec2 c) {
    float x12 = a.x - b.x; 
    float x13 = a.x - c.x; 
  
    float x31 = c.x - a.x; 
    float x21 = b.x - a.x; 
  
    float y12 = a.y - b.y; 
    float y13 = a.y - c.y; 
  
    float y31 = c.y - a.y; 
    float y21 = b.y - a.y; 
  
  
    float sx13 = pow(a.x, 2.) - pow(c.x, 2.); 
  
    float sy13 = pow(a.y, 2.) - pow(c.y, 2.); 
  
    float sx21 = pow(b.x, 2.) - pow(a.x, 2.); 
    float sy21 = pow(b.y, 2.) - pow(a.y, 2.); 
  
    float f = ((sx13) * (x12) 
             + (sy13) * (x12) 
             + (sx21) * (x13) 
             + (sy21) * (x13)) 
            / (2. * ((y31) * (x12) - (y21) * (x13))); 
    float g = ((sx13) * (y12) 
             + (sy13) * (y12) 
             + (sx21) * (y13) 
             + (sy21) * (y13)) 
            / (2. * ((x31) * (y12) - (x21) * (y13))); 
 
    vec2 center = vec2(-g, -f);
    return vec3(center, length(a-center));
}

vec3 getCircleForArc(vec2 a, vec2 b) {
    return getCircle(a, b, invert(a, vec2(0.0, 0.0), 1.0));
}

bool inInitial(float p, float d, vec2 u) {
    float ang = 3.14159265*2.0/p;
    for(float i=0.0; i<p; ++i) {
        vec2 a = d*vec2(cos(ang*i), sin(ang*i));
        vec2 b = d*vec2(cos(ang*(i+1.0)), sin(ang*(i+1.0)));
        vec3 c = getCircleForArc(a, b);
        if (length(c.xy-u)<c.z) return false;
    }
    return true;
}

vec2 makeInitial(float d, float offset, int p)[12] {
    vec2 pts[12];
    float ang = 3.14159265*2.0/float(p);
    for(float i=0.0; i<float(p); ++i) {
        pts[int(i)] = d*vec2(cos(ang*i+offset), sin(ang*i+offset));
    }
    return pts;
}

bool inPolygon(vec2 pts[12], vec2 u, int p) {
    for(float i=0.0; i<float(p); ++i) {
        vec2 a = pts[int(i)];
        vec2 b = pts[int(mod(i+1., float(p)))];
        vec3 c = getCircleForArc(a, b);
        if (length(c.xy-u)<c.z) return false;
    }
    return true;
}

bool inStraightPolygon(vec2 pts[12], vec2 u, int p) {
    float s = 0.0;
    for(float i=0.0; i<float(p); ++i) {
        vec2 a = pts[int(i)];
        vec2 b = pts[int(mod(i+1., float(p)))];
        vec2 delta = normalize(b-a);
        float newS = dot(vec2(-delta.y, delta.x), u-a);
        if (sign(s)*sign(newS)<0.0) return false;
        if (newS!=0.0) s = newS;
    }
    return true;
}

bool inTriangle(vec2 pts[3], vec2 u) {
    float s = 0.03;
    for(float i=0.0; i<3.; ++i) {
        vec2 a = pts[int(i)];
        vec2 b = pts[int(mod(i+1., 3.))];
        vec2 delta = normalize(b-a);
        float newS = dot(vec2(-delta.y, delta.x), u-a);
        if (sign(s)*sign(newS)<0.0) return false;
        if (newS!=0.0) s = newS;
    }
    return true;
}

bool nearPolygonVertex(vec2 pts[12], vec2 u, float d, int p) {
    for(float i=0.0; i<float(p); ++i) {
        if (length(pts[int(i)]-u)<d) return true;
    }
    return false;
}

bool nearPolygonCircles(vec2 pts[12], vec2 u, int p) {
    for(float i=0.0; i<float(p); ++i) {
        vec2 a = pts[int(i)];
        vec2 b = pts[int(mod(i+1., float(p)))];
        vec3 c = getCircleForArc(a, b);
        if (abs(length(c.xy-u)-c.z)<0.004) return true;
    }
    return false;
}

vec2 hyReflect(vec2 pts[12], vec3 circle, int p)[12]  {
    vec2 outPts[12];
    for(float i=0.0; i<float(p); ++i) {
        outPts[int(i)] = invert(pts[int(i)], circle.xy, circle.z);
    }
    return outPts;
}

vec2 hyReflect(vec2 pts[12], int i, int p)[12]  {
    vec2 a = pts[i];
    vec2 b = pts[int(mod(float(i+1), float(p)))];
    return hyReflect(pts, getCircleForArc(a, b), p);
}

vec2 polyCenter(vec2 pts[12], int p) {
    vec2 total = vec2(0.0);
    for(float i=0.0; i<float(p); ++i) {
        total += pts[int(i)];
    }
    return total/float(p);
}

float getInitD(float p, float q) {
    float pi = 3.14159265;
    return sqrt((tan(pi*.5 - pi/q) - tan(pi/p)) / (tan(pi*.5 - pi/q) + tan(pi/p)));
}

int getClosestEdge0(vec2 pts[12], vec2 u, int p) {
    float minD = 1e9;
    float minI = -1.;
    for(float i=0.0; i<float(p); ++i) {
        vec2 a = pts[int(i)];
        vec2 b = pts[int(mod(i+1., float(p)))];
        float d = length(u-(a+b)*0.5);
        if (d < minD) {
            minD = d;
            minI = i;
        }
    }
    return int(minI);    
}

int getClosestEdge(vec2 pts[12], vec2 u, int p) {
    float minD = -1e9;
    float minI = -1.;
    vec2 c = polyCenter(pts, p);
    for(float i=0.0; i<float(p); ++i) {
        vec2 a = pts[int(i)];
        vec2 b = pts[int(mod(i+1., float(p)))];
        vec2 dir = b-a;
        vec2 ort = vec2(-dir.y, dir.x);
        float dc = dot(ort, c-a);
        float du = dot(ort, u-a);
        float d = -du/dc;
        if (d > minD) {
            minD = d;
            minI = i;
        }
    }
    return int(minI);    
}

vec2 kaleidMap(vec2 pts[12], vec2 u, float offang, int p) {
    vec2 c = polyCenter(pts, p);
    vec2 delta = u-c;
    vec2 triangle[3];
    triangle[0] = c;
    for(float i=0.0; i<float(p); ++i) {
        triangle[1] = pts[int(i)];
        triangle[2] = pts[int(mod(i+1., float(p)))];
        vec2 side1 = triangle[1]-c;
        vec2 side2 = triangle[2]-c;
        float l = (delta.y*side1.x - delta.x*side1.y)/(side1.x*side2.y-side1.y*side2.x);
        float k = (delta.x-l*side2.x)/side1.x;
        if (l>=0.0 && k>=0.0 && l+k<=1.0) {      
            float angle = 3.14159265*2.0/float(p);
            vec2 w = l<k ? vec2(k, l) : vec2(l, k);
            return w.x*vec2(cos(offang), sin(offang)) + w.y*vec2(cos(offang+angle), sin(offang+angle));
        }
    }
    return c+length(delta);
}

vec2 findStraightPolygon(vec2 pts[12], vec2 u, int N, int p) {
    float code = 0.;
    for(int i=0; i<N; ++i) {
        //if (inStraightPolygon(pts, u, p)) return vec2(code, code);//polyCenter(pts, p);
        if (inStraightPolygon(pts, u, p)) return kaleidMap(pts, u, 0., p);//code, code);//polyCenter(pts, p);
        //if (inStraightPolygon(pts, u, p)) return kaleidMap0(pts, u, 0., p);//code, code);//polyCenter(pts, p);
        int edge = getClosestEdge(pts, u, p);
        pts = hyReflect(pts, edge, p);
        code += float(edge)*pow(float(p), float(i));
    }
    return vec2(1e9, 1e9); // not found
}

vec2 circleToSquare(vec2 u) {
    float c = u.x/length(u);
    float s = u.y/length(u);
    return u/max(abs(c), abs(s));
}

vec2 squareToCircle(vec2 u) {
    float c = u.x/length(u);
    float s = u.y/length(u);
    return u*max(abs(c), abs(s));
}

vec4 circleIntersections(vec2 c1, float r1, vec2 c2, float r2) {
    float d = length(c1-c2);
    if (r1+r2<d) return vec4(0.);
    float x = (d*d - r2*r2 + r1*r1)/(2.*d);
    float y = sqrt(r1*r1 - x*x);
    vec2 M = mix(c1, c2, x/d);
    vec2 dir = normalize(c2-c1);
    vec2 n = vec2(-dir.x, dir.y);
    return vec4(M+y*n, M-y*n);
}

vec3 makeDispCircle(vec2 u) {
    float l = length(u*100.);
    float d = 1./l;
    float x = 1. + d;
    float r = sqrt(x*x - 1.);
    return vec3(x*normalize(u), r);
}

vec4 hyKaleidoscope(vec2 uv, vec2 outPos, int p, int q, mat3 viewTransform, mat3 modelTransform, mat3 texTransform, float offset, float thickness) {
    if (length(uv)>1.0) {
        if (length(uv)<1.0+thickness) {
            return vec4(0., 0., 0., 1.);
        }
        else {
            uv = invert(uv/(1.0+thickness), vec2(0.0, 0.0), 1.0);
        }
    }
    
    float initAngle = /*modelTransform[0].x==0.0 && modelTransform[0].y==0.0 ? 0.0 :*/ atan(modelTransform[0].y, modelTransform[0].x);
    vec2 init[12] = makeInitial(getInitD(float(p), float(q)), initAngle, p);
    vec2 B = modelTransform[2].xy;
    if (B.x==0.0 && B.y==0.0) B = vec2(0.00001, 0.00001); // hack to prevent Bi shooting to infinity
    vec2 Bi = invert(B, vec2(0.0, 0.0), 1.0);
    vec2 M = mix(B, Bi, .8);
    vec4 P = circleIntersections(M, length(M), vec2(0.), length(B));
    vec3 circle = makeDispCircle(B);//getCircleForArc(P.xy, P.zw);
    
    init = invert(init, circle.xy, circle.z, p); // move the polygon - tiling may be discontinuous along a line - overall seems better

    vec2 f = findStraightPolygon(init, uv, 30, p) + uv*offset;
    vec3 col;
    if (f.x<1e9) {
        col = vec3(f, 0.5);
    }
    else { 
        col = vec3(0.0);
    }
    vec2 v = tf(inverse(texTransform), f);
    return __source__(v); 
}
