void constants() {
    #define INF 1e20
}

float orbit(vec2 z, float orbitSize) {
	//return 1.0/(abs(length(z) - 1.0));
	return abs(length(z) - orbitSize);
    /*float d = orbitSize;
    vec2 zz = abs(z-vec2(-0.0, 0.0));
    return min(length(zz-vec2(min(d, zz.x), 0.0)), length(zz-vec2(0.0, min(d, zz.y))));*/ 
}

vec2 gg(vec2 z, vec2 c) {
    //return complexMul(z,c) - 1.0*complexExp(z-c) + c;
    //return ((7.0*z+2.0) - complexMul(5.0*z+2.0, complexExp(vec2(-PI*c.y, PI*c.x)))) * 0.25;
    //return ((7.0*z+2.0) - complexMul(5.0*c+2.0, complexExp(PI*(complexMul(z,c))))) * 0.25;
    return complexMul(z, z) + c;
}

vec4 mandelbrot(vec2 pos, vec2 outPos, mat3 modelTransform, int count, float orbitSize) {
    constants();
    vec3 lookDir = normalize(vec3(pos, 1.0));
    vec2 uv = (inverse(modelTransform) * vec3(pos, 1.0)).xy;
    
    float dist = INF;
    float distx = INF;
    float disty = INF;
    vec2 z = vec2(0.0, 0.0);
   
    float delta = 0.001/length(modelTransform[0].xy);
    vec2 uvx = uv + vec2(delta, 0.0);
    vec2 uvy = uv + vec2(0.0, delta);
    vec2 zx = z;
    vec2 zy = z;
    for(int i = 0; i<count; ++i) {
        z = gg(z, uv);    
        zx = gg(zx, uvx);
        zy = gg(zy, uvy);
        
        dist = min(dist, orbit(z, orbitSize));
        distx = min(distx, orbit(zx, orbitSize));
        disty = min(disty, orbit(zy, orbitSize));
    }
    //float g = i==N ? 1.0 : i/N;
    //g = (1.0-dist*0.05)*0.05;
    float g = dist;
    
    vec3 normal = normalize(vec3((distx-dist)/delta, (disty-dist)/delta, 1.0));
    vec3 sourceDir = normalize(vec3(0.0, 0.5, 1.0));
    float lum = smoothstep(-1.0, 1.0, dot(sourceDir, normal)) * 0.7;
    float specular = dot(lookDir, reflect(sourceDir, normal));
    //lum += 0.7*smoothstep(0.99, 1.0, specular) + 0.2*smoothstep(0.95, 1.0, specular);
    lum += 0.7*pow(smoothstep(0.95, 1.0, specular), 3.0);
    
    return vec4(vec3(lum), 1.0);
}
