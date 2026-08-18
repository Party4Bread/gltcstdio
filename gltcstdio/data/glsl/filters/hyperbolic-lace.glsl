#define MAX_TRACE_STEPS 100

#define MIN_TRACE_DIST 0.1

#define MAX_TRACE_DIST 100.0

#define PRECISION 0.0001

#define AA 2

#define MAX_REFLECTIONS  500

#define CHECKER1  vec3(0., 0., 0.05)

#define CHECKER2  vec3(0.2)

#define MATERIAL  vec3(10, 0.3, 0.2)

#define FUNDCOL   vec3(.3, 1, 8)

#define INFI -1.

#define LighteningFactor 8.

float dihedral(float x) { 
    return x == INFI ? 1. : cos(PI / x); 
}

float distABCD(vec3 p, vec3 A, vec3 B, vec4 C, vec3 D) {
    float dA = abs(dot(p, A));
    float dB = abs(dot(p, B));
    float dD = abs(dot(p, D));
    float dC = abs(length(p - C.xyz) - C.w);
    return min(dA, min(dB, min(dC, dD)));
}

bool try_reflect(inout vec3 p, vec3 n, inout int count) {
    float k = dot(p, n);
    // if we are already inside, do nothing and return true
    if (k >= 0.0)
    	return true;

    p -= 2.0 * k * n;
    count += 1;
    return false;
}

bool try_reflect(inout vec3 p, vec4 sphere, inout int count, inout float orb) {
    vec3 cen = sphere.xyz;
    float r = sphere.w;
    vec3 q = p - cen;
    float d2 = dot(q, q);
    if (d2 == 0.0)
    	return true;
    float k = (r * r) / d2;
    if (k < 1.0)
    	return true;
    p = k * q + cen;
    count += 1;
    orb *= k;
    return false;
}

float sdSphere(vec3 p, float radius) { 
    return length(p) - radius; 
}

float sdPlane(vec3 p, float offset) { 
    return -(p.y - offset); 
}

vec3 planeToSphere(vec2 p) {
    float pp = dot(p, p);
    vec3 q = vec3(2.0 * p, pp - 1.0).xzy / (1.0 + pp);
    return vec3(q.x, -q.y, q.z);
}          
// vec3 planeToSphere(vec2 p) {
//     float pp = dot(p, p);
//     return vec3(2.0 * p, pp - 1.0).xzy / (1.0 + pp);
// }

vec2 sphereToPlane(vec3 p, vec3 c) {
    vec3 delta = normalize(p-c);
    float dy = delta.y+1.;
    if (dy==0.0) return vec2(0.0);
    return 1. * (delta.xz) / dy + c.xz;
}

bool iterateSpherePoint(inout vec3 p, inout int count, vec3 A, vec3 B, vec4 C, vec3 D, inout float orb, int iterations) {
    bool inA, inB, inC, inD;
    for(int iter=0; iter<iterations; iter++)
    {
        inA = try_reflect(p, A, count);
        inB = try_reflect(p, B, count);
        inC = try_reflect(p, C, count, orb);
        inD = try_reflect(p, D, count);
        p =  normalize(p);  // avoid floating error accumulation
        if (inA && inB && inC && inD)
            return true;
    }
    return false;
}

vec4 chooseColor(bool found, int count, float orb, vec4 color1, vec4 color2, vec4 color3, float glow, int iterations)
{
    vec4 col;
    if (found) {
        /*if (count == 0) return vec4(FUNDCOL, 1.);
        else */if (count >= 300) col = color3;
        else
            col = (count % 2 == 0) ? color1 : color2;
    }
    else
        col = color3;

//    float t =  float(count) / float(iterations); // multiply this by eg. 4 for more glow - divide by AA² if we keep it
    float t =  4. * float(count) / float(AA*AA) / float(iterations); // multiply this by eg. 4 for more glow - divide by AA² if we keep it
    col.rgb = mix(color3.rgb*glow, col.rgb, 1. - t * smoothstep(0., 1., log(orb) / 32.));
    return col;
}

vec2 rot2d(vec2 p, float a) { 
    return p * cos(a) + vec2(-p.y, p.x) * sin(a); 
}

vec2 sdf(vec3 p, float modelControl) {
    float d1 = sdSphere(p, 1.0);
    float d2 = sdPlane(p, 1.0);
    float id = (d1 < d2) ? 0.: 1.;
    return vec2(min(d1, d2), id);
}

vec3 getNormal(vec3 p)
{
    const vec2 e = vec2(0.001, 0.);
    return normalize(
        vec3(
            sdf(p + e.xyy).x - sdf(p  - e.xyy).x,
            sdf(p + e.yxy).x - sdf(p  - e.yxy).x,
            sdf(p + e.yyx).x - sdf(p  - e.yyx).x
            )
        );
}

vec2 raymarch(in vec3 ro, in vec3 rd, float modelControl)
{
    float t = MIN_TRACE_DIST;
    vec2 h;
    for(int i=0; i<MAX_TRACE_STEPS; i++)
    {
        h = sdf(ro + t * rd, modelControl);
        if (h.x < PRECISION * t)
            return vec2(t, h.y);

        if (t > MAX_TRACE_DIST)
            break;

        t += h.x;
    }
    return vec2(-1.0);
}

float calcOcclusion(vec3 p, vec3 n, float modelControl) {
    float occ = 0.0;
    float sca = 1.0;
    for (int i = 0; i < 5; i++) {
        float h = 0.01 + 0.15 * float(i) / 4.0;
        float d = sdf(p + h * n, modelControl).x;
        occ += (h - d) * sca;
        sca *= 0.75;
    }
    return clamp(1.0 - occ, 0.0, 1.0);
}

float softShadow(vec3 ro, vec3 rd, float tmin, float tmax, float k, float modelControl) {
    float res = 1.0;
    float t = tmin;
    for (int i = 0; i < 12; i++) {
        float h = sdf(ro + rd * t, modelControl).x;
        res = min(res, k * h / t);
        t += clamp(h, 0.01, 0.2);
        if (h < 0.0001 || t > tmax)
            break;
    }
    return clamp(res, 0.0, 1.0);
}

vec4 getColor(vec3 ro, vec3 rd, vec3 pos, vec3 nor, vec3 lp, vec4 basecol, vec4 colorSpecular, float modelControl)
{
    vec4 col = vec4(0.0, 0.0, 0.0, basecol.a);
    vec3 ld = lp - pos;
    float lDist = max(length(ld), .001);
    ld /= lDist;
    float ao = calcOcclusion(pos, nor, modelControl);
    float sh = softShadow(pos+0.001*nor, ld, 0.02, lDist, 32., modelControl);
    float diff = clamp(dot(nor, ld), 0., 1.);
    float atten = 2. / (1. + lDist * lDist * .01);

    float spec = pow(max( dot( reflect(-ld, nor), -rd ), 0.0 ), 32.);
    float fres = clamp(1.0 + dot(rd, nor), 0.0, 1.0);

    col.rgb += basecol.rgb * diff;
    col.rgb += basecol.rgb * colorSpecular.rgb * colorSpecular.a * spec * 4.;
    col.rgb += basecol.rgb * vec3(0.8) * fres * fres * 2.;
    col.rgb *= ao * atten * sh;
    col.rgb += basecol.rgb * clamp(0.8 + 0.2 * nor.y, 0., 1.) * 0.5;
    return col;
}

mat3 sphMat(float theta, float phi)
{
    float cx = cos(theta);
    float cy = cos(phi);
    float sx = sin(theta);
    float sy = sin(phi);
    return mat3(cy, -sy * -sx, -sy * cx,
                0,   cx,  sx,
                sy,  cy * -sx, cy * cx);
}

vec4 hyperbolicGroupLimit(vec2 uv, vec2 outPos, int iterations, vec4 color1, vec4 color2, vec4 color3, float glow, int paramP, int paramQ, int paramR, 
        float offset, float border, vec4 borderColor, vec4 colorSpecular, float modelControl, int mode,
        mat3 modelTransform, mat3 texTransform,
        mat4 model3DTransform, mat4 lightSourceTransform
) {
        
    vec4 finalcol = vec4(0.);
    int count = 0;
    vec2 m = tf(inverse(modelTransform), vec2(0.0));
    float rx = m.y * PI;
    float ry = -m.x * 2. * PI;
    mat3 mouRot = sphMat(rx, ry);

// ---------------------------------
// initialize the mirrors

    float P = float(paramP), Q = float(paramQ), R = float(paramR);
    float cp = dihedral(P), sp = sqrt(1. - cp*cp);
    float cq = dihedral(Q);
    float cr = dihedral(R);
    vec3 A = vec3(0,  0,   1);
    vec3 B = vec3(0, sp, -cp);
    vec3 D = vec3(1,  0,   0);

    float r = 1.0 / cr;
    float k = r * cq / sp;
    vec3 cen = vec3(1, k, 0);
    vec4 C = vec4(cen, r) / sqrt(dot(cen, cen) - r * r);

// -------------------------------------
// view setttings

//    vec3 camera = vec3(3., 3.2, -3.);
//    vec3 lp = vec3(0.5, 3.0, -0.8); //light position
//    camera.xz = rot2d(camera.xz, 0.3); 
//    vec3 lookat  = vec3(0., -0.5, 0.);
//    vec3 up = vec3(0., 1., 0.);
//    vec3 forward = normalize(lookat - camera);
//    vec3 right = normalize(cross(forward, up));
//    up = normalize(cross(right, forward));
    
    float glowFactor = glow < 0.01 ? glow*100.0 : pow(1000.0, glow);
    
    vec3 lp = (lightSourceTransform * vec4(0.0, 0.0, 0.0, 1.0)).xyz;
    float focalD = 1.0;
    vec3 cameraPos = vec3(0., 0., 0.);
//            cameraPos = mat3(model3DTransform) * cameraPos;
    mat4 inverseModel3DTransform = inverse(model3DTransform);
    cameraPos = (inverseModel3DTransform * vec4(cameraPos, 1.)).xyz;
    vec3 dir = vec3(uv.x*focalD, uv.y*focalD, -1.0);
    dir = normalize(mat3(inverseModel3DTransform) * dir);
    vec3 camera = cameraPos;

    vec3 rd = dir;//normalize(uv.x * right + uv.y * up + 3.0 * forward);
    float orb = 1.0;
    // ---------------------------------
    // hit the scene and get distance, object id

    vec2 res = raymarch(camera, rd, modelControl);
    float t = res.x;
    float id = res.y;
    vec3 pos = camera + t * rd;

    bool found;
    float edist;
    vec4 col;
    // the sphere is hit
if (id == 0.) {
    vec3 nor = pos;
    vec3 hPos = vec3(pos.x, pos.y, pos.z);
    vec3 q = hPos * mouRot;
    found = iterateSpherePoint(q, count, A, B, C, D, orb, iterations);
    edist = distABCD(q, A, B, C, D);
    vec4 basecol = chooseColor(found, count, orb, color1, color2, color3, glowFactor, iterations);
    vec2 texUV = q.xy;
    if (offset!=0.0) {
        texUV += offset * sphereToPlane(pos, vec3(0., 0., 0.));
    }
    basecol = mergeColor(__source__(tf(inverse(texTransform), texUV)), basecol);
    col = getColor(camera, rd, pos, nor, lp, basecol, colorSpecular, modelControl);
}
// the plane is hit
else if (id == 1.) {
    vec3 nor = vec3(0., 1., 0.);
    vec3 q = planeToSphere(pos.xz);
    q = q * mouRot;
    found = iterateSpherePoint(q, count, A, B, C, D, orb, iterations);
    edist = distABCD(q, A, B, C, D);
    vec4 basecol = chooseColor(found, count, orb, color1, color2, color3, glowFactor, iterations);
    vec2 texUV = q.xy;
    if (offset!=0.0) texUV += offset * pos.xz;
    basecol = mergeColor(__source__(tf(inverse(texTransform), texUV)), basecol);
    col = getColor(camera, rd, pos, nor, lp, basecol, colorSpecular, modelControl);
    col.rgb *= .9;
}
else col = vec4(0., 0., 0., 1.); // at infinity                
    
    // draw the arcs
//            col.rgb = mix(col.rgb, vec3(0.), (1.0 - smoothstep(0., 0.1*border, edist))*0.85);
//            col.rgb = mix(col.rgb, vec3(0.), 1.0 - exp(-0.01*t*t));
    if (border!=0.0) col = mix(col, borderColor, (1.0 - smoothstep(0.05*border-0.0025, 0.1*border, edist))*0.85);
    //if (edist>1.0) col.rgb = vec3(0.); // handles the far distance fadeout
    col.rgb = mix(col.rgb, vec3(0.), 1.0 - exp(-0.01*t*t));
    finalcol += col;

// ------------------------------------
// a little post-processing

    finalcol.rgb = mix(finalcol.rgb, 1. - exp(-finalcol.rgb), .35);
    return vec4(sqrt(max(finalcol.rgb, 0.0)), finalcol.a);
}
