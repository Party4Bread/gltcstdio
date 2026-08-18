vec4 getColor2(vec3 pos) {
    return vec4(hash33(pos)*2., 0.);
}

vec4 getColor3(vec3 pos) {
    return vec4(mod(pos, 10.)*0.25, 0.);
}

vec4 getColor3b(vec3 pos, float N) {
    vec3 rgb = pos.rgb;
    return vec4(mod(rgb, N)*2.5/N, 0.);
}

vec4 getColor3c(vec3 pos) {
    float N = 3.01;
    vec3 rgb = pos.gbr;
    return vec4(mod(rgb, N)*2.5/N, 0.);
}

vec4 getColor2b(vec3 pos) {
    vec3 rnd = hash33(pos);
    if (fract(rnd.x*12.55)>0.2) return vec4(0.);
    return vec4(rnd*5., 0.);
}

vec4 getColor4(vec3 pos) {
    if (mod(dot(pos, pos.zxy), 4.)>=1.) return vec4(0.);
    //return mod(pos, 6.);
    return vec4(vec3(1.) * 4., 0.);
}

vec4 getColor5(vec3 pos) {
    vec3 v = mod(pos.xyz*pos.zxy, 5.);
    if (v.x*v.y*v.z<=1.) {
        float N =10.00;
        vec3 rgb = pos.gbr;
        return vec4(mod(rgb, N)*2.5/N, 0.);
    }
    else return vec4(vec3(0.), 0.);
}

vec4 getColor5b(vec3 pos) {
    vec3 v = mod(pos.xyz, 14.);
    if (v.x*v.y*v.z<=1.) return vec4(vec3(1.)*7., 0.);
    else return vec4(vec3(0.), 0.);
}

vec4 getColor6(vec3 pos) {
    pos.y = -pos.y;
    float xRoad = mod(pos.x, 15.0);
    float roadLightH = 1.;
    if (pos.z==1.) {
        if (pos.y==1. && mod(pos.x, 4.)==2.) return vec4(vec3(1., 1., 1.)*2., 0.);
    }
    if (pos.z==2.) {
        if (pos.y>=0. && pos.y<=3. && mod(pos.x, 7.)==3.) return vec4(vec3(0.8, 0.9, 1.)*2.3, 0.);
    }
    if (xRoad<4.0 && pos.y<=roadLightH) {
        if (pos.y==0.) {
            float rnd = hash31(pos);
            if (rnd<0.75) {
                if (xRoad==1.) return vec4(vec3(1., 0.1, 0.1)*2.*(rnd+0.75), 0.);
                else if (xRoad==2.) return vec4(vec3(1., 1., 0.5)*2.*(rnd+0.75), 0.);
            }
            //return vec3(0.);
        }
        if (pos.y==roadLightH && (xRoad==0. || xRoad==3. )) {
            return vec4(vec3(1., 1., 1.)*2., 0.);
        }
        return vec4(vec3(0.), 0.);
    }
    if (pos.y>=0. && pos.y<=12. && pos.z>=4.) { // buildings
        vec2 xz = vec2(pos.x, pos.z)*0.2;
        xz += sin(pos.xz);
        xz = floor(xz);
        float rnd = hash21(xz);
        float h = rnd*40. - 28.;
        h = h*h*h /50.;
        if (pos.y<=h && hash31(pos)<0.6) {
            vec3 rnd2 = hash33(pos);
            float k = rnd2.b;
            if (k<0.2) return vec4(0.);
            vec3 baseWindowColor = k<0.3 ? vec3(0.9, 0.6, 0.3) : k<0.75 ? vec3(1., 1., 0.5) : k<0.95 ? vec3(1.) : vec3(0.9, 1.0, 1.2);
            return vec4(baseWindowColor*8.+rnd2*1.5, 0.);
        }
    }
    if (pos.y>=4. && pos.y<=30.) { // construction lights
        float rnd = hash31(mod(pos.xyz*pos.yzx, 5.1));
        if (rnd*pos.y<0.04) {
            vec3 rnd = hash33(pos);
            return vec4(vec3(1., 0.1, 0.1)*5. + rnd, 0.);
        }
    }
    return vec4(vec3(0.), 0.);
}

vec4 getColor7(vec3 pos, float N) {
    N *= 2.;
    vec3 id = floor((pos+N)/(N*2.));
    if (id.z<1.) return vec4(0.);
    vec3 color = hash33(id);
    //vec3 color = mod(id, 5.)*2.5/5. + vec3(0.1);
    pos = mod(pos+N, N*2.)-N;
    float d = length(pos - vec3(0., 0., 0.));
    return vec4(color * vec3(smoothstep(10., 0., d) * 150./pow(max(d, 1.), 1.)), 0.);
    //return vec4(vec3(smoothstep(10., 9., d) * 3.), 0.);
}

vec4 getColor1(vec3 pos) {
    pos.y = -pos.y;
    if (pos.y<0. || pos.y>9.) return vec4(vec3(0.), 0.);
    vec3 v = mod(pos, 10.);
    if (v.x*v.y+v.z==0.) return vec4(vec3(1.)*7., 0.);
    if (v.x+v.y*v.z==12.) return vec4(hash33(pos)*15., 0.);
    if (v.x*v.y+v.z==5.) return vec4(vec3(1.)*7., 0.);
    vec3 w = mod(pos*4.1, 10.);
    if (w.x<1. && w.y<1. && w.z<1.) return vec4(hash33(pos)*15., 0.);

    else return vec4(vec3(0.), 0.);
}

vec4 getColorSuperStructure(vec3 pos, float N) {
    float k = abs(N) * 0.01;
    if (hash21(pos.xy)<k || hash21(pos.yz)<k || hash21(pos.zx)<k) return vec4(hash33(vec3(pos.xyz))*8., 0.);
    return vec4(vec3(0.), 0.);
}

vec4 getColorCorridor(vec3 pos, float N) {
    float k = pow(abs(N) * 0.01, 0.5);
    if (hash21(pos.xy)<k) return vec4(hash33(vec3(pos.xyz))*8., 0.);
    else return vec4(vec3(0.), 0.);
}

vec4 getColorPillars(vec3 pos, float N) {
    float k = pow(abs(N) * 0.01, 0.5);
    if (hash21(pos.zx)<k) return vec4(hash33(vec3(pos.xyz))*8., 0.);
    else return vec4(vec3(0.), 0.);
}

vec4 getColorCorridorGradient(vec3 pos, float N) {
    float k = pow(abs(N) * 0.01, 0.5);
    if (hash21(pos.xy)<k) {
        vec3 col = hash23(pos.xy);
        float offset = fract(col.g*55.2) * 10.;
        return vec4(col*8. * fract(pos.z*0.02 + offset), 0.);
    }
    else return vec4(vec3(0.), 0.);
}

vec4 getColorPlanes(vec3 pos, float N) {
    float k = pow(abs(N) * 0.01, 0.5);
    if (hash11(pos.y)<k) return vec4(hash33(vec3(pos.xyz))*8., 0.);
    else return vec4(vec3(0.), 0.);
}

vec4 getColorBoxes(vec3 pos, float N) {
    float k = pow(abs(N) * 0.01, 0.5);
    if (hash11(pos.x)<k || hash11(pos.y)<k) return vec4(hash33(vec3(pos.xyz))*8., 0.);

    else return vec4(vec3(0.), 0.);
}

vec4 getColorBoxesGradient(vec3 pos, float N) {
    float k = pow(abs(N) * 0.01, 0.5);
    if (hash11(pos.x)<k || hash11(pos.y)<k) {
        vec3 col = hash23(pos.xy);
        float offset = fract(col.g*55.2) * 10.;
        return vec4(col*8. * fract(pos.z*0.02 + offset), 0.);    
    }

    else return vec4(vec3(0.), 0.);
}

vec4 getLayer(float id, vec2 camera, float cameraZ, vec2 uv, int mode, float dampening, inout float lastX, float offset, float distortion, float distortionPower, float distortionScale, float distortionIntensity, float colorPeriod) {
    //vec3 dir = normalize(vec3(uv.x, uv.y, 1.));
    //vec3 cam = vec3(camera, 0.0);
    float z = id + 1.;
    if (z+cameraZ<=0.) return vec4(0.);

    vec2 displace = offset==0.0 ? vec2(0.0) : offset * 2. * hash12(z);
    
    if (distortion==0.) {}
    else if (distortion<=1.0) {
        float scale = distortionScale * pow(z, distortionPower);
        displace += distortion * distortionIntensity * sin(uv * scale); //vec2(sin(uv.x * scale), sin(uv.y * scale));
    }
    else if (distortion<=2.0) {
        float k = distortion-1.;
        float scale = distortionScale * pow(z, distortionPower);
        displace += distortionIntensity * mix(sin(uv * scale), normalize(uv) * cos(uv.x * scale) * cos(uv.y * scale), k);
    }
    else if (distortion<=3.0) {
        float k = distortion-2.;
        float scale = distortionScale * pow(z, distortionPower);   
         displace += distortionIntensity * mix(normalize(uv) * cos(uv.x * scale) * cos(uv.y * scale), normalize(uv) * sin(length(uv * scale)), k);
    }
    else if (distortion<=4.0) {
        float k = distortion-3.;
        float scale = distortionScale * pow(z, distortionPower);   
        displace += distortionIntensity * mix(normalize(uv) * sin(length(uv * scale)), normalize(uv) * cos(length(uv * scale)), k);
    }
    else if (distortion<=5.0) {
        float k = distortion-4.;
        float scale = distortionScale * pow(z, distortionPower);   
        float d = length(uv);
        float a = atan(uv.y, uv.x);
        //float da = 0.5*d*z + a;
        float da = cos(d * scale) + a;
        displace += distortionIntensity * mix(normalize(uv) * cos(length(uv * scale)), d * vec2(cos(da), sin(da)) - uv, k);    
    }
    
    // grid sine
    //vec2 displace += vec2(sin(uv.x*4.1+z), sin(uv.y*4.1+z));
    //vec2 displace += vec2(sin(uv.x*2.1), sin(uv.y*2.1));
    //vec2 displace += vec2(sin(uv.x*5.1/z), sin(uv.y*5.1/z));

    //vec2 displace += /*hash12(z) +*/ 2.5*normalize(uv) * cos(uv.x*10.1*z) * cos(uv.y*10.1*z);
    //vec2 displace += /*hash12(z) +*/ 4.5*normalize(uv) * cos(uv.x*2.1) * cos(uv.y*2.1);
    //vec2 displace += hash12(z) + 2.5*normalize(uv) * sin(uv.x*7.1) * sin(uv.y*7.1);
    //vec2 displace += /*hash12(z) +*/ 1.*normalize(uv) * cos(uv.x*0.1*z) * cos(uv.y*0.1*z);
    //vec2 displace += /*hash12(z) +*/ 2.*normalize(uv) * cos(uv.x*0.1+z) * cos(uv.y*0.1*z);

    // ripple
    //vec2 displace += normalize(uv) * sin(length(uv*2.*z));
    //vec2 displace += normalize(uv) * sin(length(uv*5.));
    //vec2 displace += normalize(uv) * sin(length(uv*10./z));
    //vec2 displace += normalize(uv) * cos(length(uv*5./z));

    /*float d = length(uv);
    float a = atan(uv.y, uv.x);
    //float da = 0.5*d*z + a;
    float da = cos(10.5*d/z) + a;
    displace += d * vec2(cos(da), sin(da)) -uv;
*/

    vec2 intersection = (uv + displace)*(z+cameraZ) + camera;
    vec2 cell = round(intersection);
    if (lastX!=-1e9) {
        if (cell.x!=lastX) return vec4(0.);
    }
    
    vec4 color;
    vec3 pos = vec3(cell, z);
    if (mode==0) color = getColor2(pos); 
    else if (mode==1) color = getColor2b(pos);
    else if (mode==2) color = getColor3b(pos, colorPeriod);
    else if (mode==3) color = getColor3b(pos.gbr, colorPeriod);
    else if (mode==4) color = getColor3b(pos.brg, colorPeriod);
    else if (mode==5) color = getColor7(pos, colorPeriod);
    else if (mode==10) color = getColor1(pos);
    else if (mode==20) color = getColor6(pos);
    else if (mode==100) color = getColorSuperStructure(pos, colorPeriod);
    else if (mode==101) color = getColorPillars(pos, colorPeriod);
    else if (mode==102) color = getColorCorridor(pos, colorPeriod);
    else if (mode==103) color = getColorCorridorGradient(pos, colorPeriod);
    else if (mode==110) color = getColorPlanes(pos, colorPeriod);
    else if (mode==111) color = getColorBoxes(pos, colorPeriod);
    else if (mode==112) color = getColorBoxesGradient(pos, colorPeriod);
    
    if (color.r==0. && color.g==0. && color.b==0.) return color;
    vec2 u = intersection - cell;// - 0.2*(hash32(vec3(cell, z)) - 0.5);
    float r = length(u); 
    //float g = smoothstep(0.35, 0.2, r) * 0.05/r;
    float g = smoothstep(0.5, 0.3, r) * 0.05/r;
    float depthDampening = pow(z, -dampening); //1./z;
    //float depthDampening = pow(z, -0.75);
    if (color.a>0.0) lastX = cell.x;
    return vec4(g * color.rgb * depthDampening, color.a);
    //return vec3(g)*depthDampening;
}

vec4 lightArray(vec2 uv, vec2 outPos, int layerCount, mat3 modelTransform, vec4 color, int mode, float dampening, float offset, float intensity, float distortion, float distortionPower, float distortionScale, float distortionIntensity, float colorPeriod, int source_specified) {
    mat3 inverseModelTransform = inverse(modelTransform);
        
    uv *= 1.;
    float lastX = -1e9;
    vec3 col = vec3(0.);
    float N = float(layerCount);
    float camScale = length(inverseModelTransform[0].xy);
    float cameraZ = log(camScale);
    for(float i=0.; i<N; ++i) {
        vec4 layColor = getLayer(i, inverseModelTransform[2].xy * 2./* / camScale*/, cameraZ, uv, mode, dampening, lastX, offset, distortion, distortionPower, distortionScale, distortionIntensity, colorPeriod);
        col += layColor.rgb;
        //if (layColor.a>0.1) break;
    }
    
    // coloring
    vec4 outCol = vec4(intensity * col, 1.0);
    float lum = outCol.r + outCol.g + outCol.b;
    if (lum>0.) {
        color.rgb *= lum / (color.r + color.g + color.b);
        outCol.rgb = mix(outCol.rgb, color.rgb, color.a);
    }
    
    if (source_specified==1) {
        float blend = clamp(lum, 0., 1.);
        outCol = __source__(uv)+outCol;
        //outCol = mix(__source__(uv)+outCol, outCol, blend); 
    }

    return outCol;
}
