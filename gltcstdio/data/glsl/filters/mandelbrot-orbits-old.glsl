float orbit(vec2 z, float orbitSize, mat3 t, int type) {
	//return 1.0/(abs(length(z) - 1.0));
    vec2 tz = tf(t, z);
    if (type==0) return length(tz);
    else if (type==1) return abs(length(tz) - orbitSize);
	else if (type==2)  return abs(tz.y);
    else return abs(max(abs(tz.x), abs(tz.y)) - orbitSize); 
}

float pointOrbit(vec2 z, vec2 a) {
	return length(z-a);
}

vec4 mandelbrotOrbits(vec2 pos, vec2 outPos, int mode, mat3 modelTransform, mat3 offsetTransform, mat3 transformRed, mat3 transformGreen, mat3 transformBlue, int iterations, float orbitSize, float julianess, float power) {
            float cj = cos(julianess * PI*0.5);
            float sj = sin(julianess * PI*0.5);
            
            mat3 invModelTransform = inverse(modelTransform);
            mat3 tR = inverse(transformRed);
            mat3 tG = inverse(transformGreen);
            mat3 tB = inverse(transformBlue); 
            int modeR = mode & 3;
            int modeG = (mode/4) & 3;
            int modeB = (mode/16) & 3;
            
            vec2 uv = tf(invModelTransform, pos);
            vec2 t = cj*uv + sj*offsetTransform[2].xy;
            vec2 z0 = sj*uv + cj*offsetTransform[2].xy;
            
            vec2 z = z0;
        
            vec2 prev = t;
        
            int iter = 0;
            float d2 = 0.0;
            bool outside = true;
            
            float distR = INF;
            float distG = INF;
            float distB = INF;       
            
        
            if (power == 2.0) {
                while (iter < iterations) {
                    ++iter;
                    prev = z;
                    z.x = prev.x*prev.x - prev.y*prev.y + t.x;
                    z.y = 2.0*prev.x*prev.y + t.y;
                    d2 = dot(z, z);
                    
                    distR = min(distR, orbit(z, orbitSize, tR, modeR));
                    distG = min(distG, orbit(z, orbitSize, tG, modeG));
                    distB = min(distB, orbit(z, orbitSize, tB, modeB));
                    
//                    distR = min(distR, pointOrbit(z, -transformRed[2].xy) * length(transformRed[0]));
//                    distG = min(distG, pointOrbit(z, -transformGreen[2].xy) * length(transformGreen[0]));
//                    distB = min(distB, pointOrbit(z, -transformBlue[2].xy) * length(transformBlue[0]));
                    
                    if (d2 > 400000000.0) {
                        outside = false;
                        break;
                    }
                }
            }
            else if (power == 3.0) {
                while (iter < iterations) {
                    ++iter;
                    prev = z;
                    z.x = prev.x*prev.x*prev.x - 3.0*prev.y*prev.y*prev.x + t.x;
                    z.y = -prev.y*prev.y*prev.y + 3.0*prev.x*prev.x*prev.y + t.y;
                    d2 = dot(z, z);
                    
                    distR = min(distR, pointOrbit(z, -transformRed[2].xy) * length(transformRed[0]));
                    distG = min(distG, pointOrbit(z, -transformGreen[2].xy) * length(transformGreen[0]));
                    distB = min(distB, pointOrbit(z, -transformBlue[2].xy) * length(transformBlue[0]));
                    
                    if (d2 > 400000000.0) {
                        outside = false;
                        break;
                    }
                }
            }
            else {
                float d = length(z);
        
                while (iter < iterations) {
                    ++iter;
                    prev = z;
                    float angle = atan(prev.y, prev.x);
                    //if (angle<0.0) angle+=M_2PI;
        
                    float dp = pow(d, power);
                    z.x = dp*cos(power*angle) + t.x;
                    z.y = dp*sin(power*angle) + t.y;
        
                    distR = min(distR, pointOrbit(z, -transformRed[2].xy) * length(transformRed[0]));
                    distG = min(distG, pointOrbit(z, -transformGreen[2].xy) * length(transformGreen[0]));
                    distB = min(distB, pointOrbit(z, -transformBlue[2].xy) * length(transformBlue[0]));
                    
                    d = length(z);
                    if (d > 20000.0) {
                        outside = false;
                        break;
                    }
                }
        
                d2 = d*d;
            }
        
        
            float angle = 0.0;
            float d = sqrt(d2);
            float ty = 1.0 + float(iter) - log(log(d))/log(power);
            float grey = (1.0/ty);
            return vec4(distR, distG, distB, 1.0);
        }
