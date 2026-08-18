vec4 mandelbrotFeather(vec2 pos, vec2 outPos, int source_specified, mat3 modelTransform, mat3 offsetTransform, int iterations, float dampening, float balance, float julianess, float power, vec4 colorIn, vec4 colorOut) {
            float cj = cos(julianess * PI*0.5);
            float sj = sin(julianess * PI*0.5);
            
            mat3 invModelTransform = inverse(modelTransform);

            vec2 uv = tf(invModelTransform, pos);
            vec2 t = cj*uv + sj*offsetTransform[2].xy;
            vec2 z0 = sj*uv + cj*offsetTransform[2].xy;
            
            vec2 z = z0;
            vec2 w;
            float escape = 0.0;
            //vec2 featherT = featherTransform[2].xy;
            
            vec2 prev = t;
        
            int iter = 0;
            float d2 = 0.0;
                    
            if (power == 2.0) {
                while (iter < iterations) {
                    ++iter;
                    prev = z;
                    z.x = prev.x*prev.x - prev.y*prev.y + t.x;
                    z.y = 2.0*prev.x*prev.y + t.y;
                    d2 = dot(z, z);
                                        
                    w = rotation2(float(iter) * balance*PI2)*z; // float(iter) seems to not have a significant (if any) impact
                    if (w.y > 5.0) {
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
                                        
                    w = rotation2(float(iter) * balance*PI2)*z;
                    if (w.y > 5.0) {
                        break;
                    }
                }
                w = z;
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
                    
                    d = length(z);
                                        
                    w = rotation2(float(iter) * balance*PI2)*z;
                    if (w.y > 5.0) {
                        break;
                    }
                }
                w = z;

                d2 = d*d;
            }  
        
            float angle = 0.0;
            float d = sqrt(d2);
            float ty = 1.0 + float(iter) - log(log(d))/log(power);
            float grey = (1.0/ty);
            vec4 color;
            if (iter==iterations) {
                grey = abs(w.y);
                color = colorIn;
            } //0.0;
//            else grey = -z.y*0.1 + float(iter)/float(iterations);
//            else grey = 3.0/pow(w.y, 0.25) * (1.0-pow(0.9, float(iter)));
            else {
                //grey = 1.0/pow(w.y, 0.25) + (1.0-pow(0.9, float(iter)));

                grey = 1.0/pow(w.y, 0.25) + 0.75*(1.0-pow(0.9, float(iter)));

//                grey = 1.0/pow(w.x, 0.25) + 0.75*(1.0-pow(0.9, float(iter))); // sharper look

                if (dampening>0.0) {
                    float kIter = float(iterations-1-iter)/float(iterations);
                    if (kIter<dampening) grey *= kIter/dampening;
                }

                color = colorOut;
            }
//            else grey = .5 + .5*cos(PI2 * (0.41 + 1.0/z.y + float(iter)/64.));
//            else grey = z.y*0.01;
            
            if (source_specified==0) return vec4(grey*color.rgb*2.0, color.a);
            else return __source__(vec2(0.0, grey*2.-1.0));
        }
