float hash0(vec2 p) {
    vec2 a = fract(-145.3277*p.xy);
    vec2 b = a + dot(a, a+vec2(-4.434, 43.3371));
	return fract(b.x*b.y);
}

float hash1(vec2 p, float randomSeed) {
//    vec2 a = fract((u_Seed-145.3277)*p.xy);
//    vec2 b = a + dot(a, a+123.3371);
//	return fract(b.x*b.y);
    vec2 a = fract((randomSeed-145.3277)*p.xy);
    vec2 b = a + dot(a, a+vec2(-4.434, 43.3371));
	return fract(b.x*b.y);
}

float hashRep(vec2 p, float randomSeed) {
    vec2 a = fract(vec2(15.3*(p.x+randomSeed), 60.15*(p.y-randomSeed+333.3)+10.1));
    vec2 b = a + 1.0*dot(a.yx, a+100.0+randomSeed);
	return fract(b.x*b.y);
}

float hashMoireCurve(vec2 p, float randomSeed) {
    vec2 a = (10.11+20.0*sin(randomSeed*vec2(0.1, 0.166)))*(p+5000.0+randomSeed);
    vec2 b = a*0.001 + dot(a*0.001, a*0.001);
	return clamp(0.5+sin(p.x*b.x*0.001)*sin(p.y*b.y*0.001), 0.0, 1.0);
}

float hashBanding(vec2 p, float randomSeed) {
    p += 5000.0;
    float k = 10.11+randomSeed;
    vec2 a = fract(k*p)*k;
    a = fract(k*a)*k;
    vec2 b = a + 0.0*dot(a, a);
	return abs(sin(p.x*b.x*0.001)*sin(p.y*b.y*0.001));
}

float hash(vec2 p, float randomSeed) {
    return hash1(p, randomSeed);
}

float noise0(vec2 p, float randomSeed) {
    vec2 s = vec2(1.0, 0.0);
    vec2 f = floor(p);
    vec2 d = p-f;
    float h00 = hash(f, randomSeed);
    float h10 = hash(f+s, randomSeed);
    float h01 = hash(f+s.yx, randomSeed);
    float h11 = hash(f+s.xx, randomSeed);

	return mix(mix(h00, h10, d.x), mix(h01, h11, d.x), d.y);
}

float noise1(vec2 p, float randomSeed) {
    vec2 s = vec2(1.0, 0.0);
    vec2 f = floor(p);
    vec2 d = p-f;
    float h00 = hash1(f, randomSeed);
    float h10 = hash1(f+s, randomSeed);
    float h01 = hash1(f+s.yx, randomSeed);
    float h11 = hash1(f+s.xx, randomSeed);

	return mix(mix(h00, h10, smoothstep(0.0, 1.0, d.x)), mix(h01, h11, smoothstep(0.0, 1.0, d.x)), smoothstep(0.0, 1.0, d.y));
}

float noiseRep(vec2 p, float randomSeed) {
    vec2 s = vec2(1.0, 0.0);
    vec2 f = floor(p);
    vec2 d = p-f;
    float h00 = hashRep(f, randomSeed);
    float h10 = hashRep(f+s, randomSeed);
    float h01 = hashRep(f+s.yx, randomSeed);
    float h11 = hashRep(f+s.xx, randomSeed);

	return mix(mix(h00, h10, smoothstep(0.0, 1.0, d.x)), mix(h01, h11, smoothstep(0.0, 1.0, d.x)), smoothstep(0.0, 1.0, d.y));
}

float noiseMoireCurve(vec2 p, float randomSeed) {
    vec2 s = vec2(1.0, 0.0);
    vec2 f = floor(p);
    vec2 d = p-f;
    float h00 = hashMoireCurve(f, randomSeed);
    float h10 = hashMoireCurve(f+s, randomSeed);
    float h01 = hashMoireCurve(f+s.yx, randomSeed);
    float h11 = hashMoireCurve(f+s.xx, randomSeed);

	return mix(mix(h00, h10, smoothstep(0.0, 1.0, d.x)), mix(h01, h11, smoothstep(0.0, 1.0, d.x)), smoothstep(0.0, 1.0, d.y));
}

float noiseBanding(vec2 p, float randomSeed) {
    vec2 s = vec2(1.0, 0.0);
    vec2 f = floor(p);
    vec2 d = p-f;
    float h00 = hashBanding(f, randomSeed);
    float h10 = hashBanding(f+s, randomSeed);
    float h01 = hashBanding(f+s.yx, randomSeed);
    float h11 = hashBanding(f+s.xx, randomSeed);

	return mix(mix(h00, h10, smoothstep(0.0, 1.0, d.x)), mix(h01, h11, smoothstep(0.0, 1.0, d.x)), smoothstep(0.0, 1.0, d.y));
}

float perlin(vec2 p) {
    vec2 s = vec2(1.0, 0.0);
    vec2 f = floor(p);
    vec2 d = p-f;
    //return dotGridGradient(f, p);
    float ix0 = smix(dotGridGradient(f, p), dotGridGradient(f+s, p), d.x);
    float ix1 = smix(dotGridGradient(f+s.yx, p), dotGridGradient(f+s.xx, p), d.x);
    return 0.5+smix(ix0, ix1, d.y)*0.5;
}

float sinNoise(vec2 p, float randomSeed) {
    float noiseH = 200.0;
    float index = p.x + floor(p.y*noiseH)/noiseH*10000.0;
    float ind = index+1000.0;// + randomSeed*10.0;
    float base = ((sin(ind*0.1)+0.5*sin(ind*0.2)+0.5*sin(ind*0.5)+0.5*sin(ind*1.0)+0.5*sin(ind*2.5)+0.5*sin(ind*4.0))/7.0+0.5);
    //return 0.3 + 0.5*abs(hash(p, randomSeed));
    return clamp(base + 0.0*abs(hash(p, randomSeed)), 0.0, 1.0);
}

float sinNoise2(vec2 p, float randomSeed) {
    float noiseH = 5.0;
    float j0 = floor(p.y);
    float i0 = floor(p.x/noiseH);// + floor(p.y*noiseH);
    float i1 = i0+1.0;
    float dx = fract(p.x/noiseH);
    float h0 = hash(vec2(i0, j0), randomSeed)*6.28;
    float h1 = hash(vec2(i1, j0), randomSeed)*6.28;
    return sin(mix(h0, h1, dx))*0.5 + 0.5;
}

float perlin4(vec2 p) {
    return (perlin(p)+0.5*perlin(p*2.0)+0.25*perlin(p*4.0)+0.125*perlin(p*8.0))*0.6;
}

float contrast(float x, float c) {
    return 0.5 + (x-0.5)*(1.0+c);
}

float ccontrast(float x, float c) {
    return clamp(0.5 + (x-0.5)*(1.0+c), 0.0, 1.0);
}

vec3 colorSchemeF(vec3 rgb, float k) {
    float grey = (rgb.r+rgb.g+rgb.b)/3.0;
    if (k<0.2) return mix(vec3(rgb.g), vec3(grey), k*5.0);
    if (k<0.4) return mix(vec3(grey), rgb, (k-0.2)*5.0);
    return rgb;
}

float staticNoiseF(vec2 u, float k, float shapeAspectRatio, float randomSeed) {
    float baseScale = 500.0;
    vec2 ar = aRatio(shapeAspectRatio);
    if (k<0.25)  return mix(noise1(u*baseScale*ar, randomSeed), noiseMoireCurve(u*baseScale*ar, randomSeed), k*4.0);
    if (k<0.5)   return mix(noiseMoireCurve(u*baseScale*ar, randomSeed), noiseRep(u*baseScale*ar, randomSeed), (k-0.25)*4.0);
    if (k<0.75)  return mix(noiseRep(u*baseScale*ar, randomSeed), noiseBanding(u*baseScale*ar, randomSeed), (k-0.5)*4.0);
    else		 return mix(noiseBanding(u*baseScale*ar, randomSeed), noise1(u*baseScale*ar, randomSeed), (k-0.75)*4.0);
}

float bc(float x, float brightness, float contrast) {
    float y = x * (brightness+1.0);
    y = (y-0.5)*contrast + 0.5;
    return clamp(y, 0.0, 1.0);
}

vec4 staticNoise(vec2 pos, vec2 outPos, float mode, float intensity, float balance, float coverage, float brightness, float contrast, float colorScheme, float randomSeed, float variability, float shapeAspectRatio, mat3 modelTransform) {
    mat3 invModelTransform = inverse(modelTransform);
    vec2 u = tf(invModelTransform, pos);
    float scale = length(invModelTransform[0].xy);
    mode *= 0.1;
    
    vec4 inCol = __source__(pos);
    float alpha = clamp(coverage + ccontrast(perlin4(u*0.1*vec2(variability*10.0, 100.0)), -5.0), 0.0, 1.0);
    alpha = smoothstep(0.15, 1.0, pow(alpha, 2.0)) * intensity;

    float delta = (colorScheme<0.4 ? 1.0 : colorScheme-0.39)*10.0;
    vec3 rnd = vec3(staticNoiseF(pos, mode, shapeAspectRatio, randomSeed), staticNoiseF(pos+delta, mode, shapeAspectRatio, randomSeed), staticNoiseF(pos-delta, mode, shapeAspectRatio, randomSeed));
    vec3 rgb = vec3(bc(rnd.r, brightness, contrast), bc(rnd.g, brightness, contrast), bc(rnd.b, brightness, contrast));

    vec2 d = (rnd.xy-0.5)*0.5;
    balance = (balance+1.0)/2.0;
    vec4 baseCol = __source__(pos + alpha*d*min(1.0, 2.0*(1.0-balance)));
    vec4 outCol = mix(baseCol, vec4(colorSchemeF(rgb, colorScheme), 1.0), alpha * min(1.0, 2.0*balance));

    return outCol;      
}
