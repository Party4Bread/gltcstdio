float hmpgl_height(float intensity, vec4 color) {
    return intensity*0.04* ((color.r + color.g + color.b)/3.0 - 0.5);
}

float hmpgl_round(float x) { return floor(x+0.5); }

vec3 hmpgl_cubeIntersection(vec3 center, float radius, vec3 origin, vec3 dir) {
    vec3 relOrigin = origin-center;
    float kOut = INF;
    float kIn = 0.0;
    if (dir.x!=0.0) {
        float k1 = -(relOrigin.x-radius)/dir.x;
        float k2 = -(relOrigin.x+radius)/dir.x;
        kIn = max(kIn, min(k1, k2));
        kOut = min(kOut, max(k1, k2));
    }
    else if (abs(relOrigin.x)>radius) return vec3(INF);

    if (dir.y!=0.0) {
        float k1 = -(relOrigin.y-radius)/dir.y;
        float k2 = -(relOrigin.y+radius)/dir.y;
        kIn = max(kIn, min(k1, k2));
        kOut = min(kOut, max(k1, k2));
    }
    else if (abs(relOrigin.y)>radius) return vec3(INF);

    if (dir.z!=0.0) {
        float k1 = -(relOrigin.z-radius)/dir.z;
        float k2 = -(relOrigin.z+radius)/dir.z;
        kIn = max(kIn, min(k1, k2));
        kOut = min(kOut, max(k1, k2));
    }
    else if (abs(relOrigin.z)>radius) return vec3(INF);

    float k = kIn>0.0 ? kIn : kOut;
    if (k<=0.0 || kOut<kIn) return vec3(INF);
    return origin + k*dir;
}

vec3 hmpgl_trailIntersection(vec3 center, float radius, float extraTrail, vec3 origin, vec3 dir) {
    vec3 relOrigin = origin-center;
    float kOut = INF;
    float kIn = 0.0;
    if (dir.x!=0.0) {
        float k1 = -(relOrigin.x-radius)/dir.x;
        float k2 = -(relOrigin.x+radius)/dir.x;
        kIn = max(kIn, min(k1, k2));
        kOut = min(kOut, max(k1, k2));
    }
    else if (abs(relOrigin.x)>radius) return vec3(INF);

    if (dir.y!=0.0) {
        float k1 = -(relOrigin.y-radius)/dir.y;
        float k2 = -(relOrigin.y+radius)/dir.y;
        kIn = max(kIn, min(k1, k2));
        kOut = min(kOut, max(k1, k2));
    }
    else if (abs(relOrigin.y)>radius) return vec3(INF);

    if (dir.z!=0.0) {
        float k1 = -(relOrigin.z+radius)/dir.z;
        float k2 = -(relOrigin.z+(radius+extraTrail))/dir.z;
        kIn = max(kIn, min(k1, k2));
        kOut = min(kOut, max(k1, k2));
    }
    else if (abs(relOrigin.z)>radius) return vec3(INF);

    float k = kIn>0.0 ? kIn : kOut;
    if (k<=0.0 || kOut<kIn) return vec3(INF);
    return origin + k*dir;
}

vec3 hmpgl_getCubeNormal(vec3 center, vec3 intersection) {
    vec3 d = intersection-center;
    if (abs(d.x)>abs(d.y) && abs(d.x)>abs(d.z)) {
        return vec3(sign(d.x), 0.0, 0.0);
    }
    else if (abs(d.y)>abs(d.z)) {
        return vec3(sign(d.y));
    }
    else {
        return vec3(sign(d.z));
    }
}

vec4 heightMapPixelsGl(vec2 pos, vec2 outPos,
            int sourceBkg_specified, int sourceElevation_specified,
            float intensity, int rezolution, float thickness,
            vec4 sourceColor, vec4 ambientColor, float colorScheme,
            float specular,
            vec2 sourceDim, vec2 sourceElevationDim,
            mat4 model3DTransform) {

            vec4 backgroundColor = vec4(0.0, 0.0, 0.0, 1.0);
            float D = 1.0;
            vec3 cameraPos = vec3(0., 0., 0.);
            mat4 m = inverse(model3DTransform);
            cameraPos = (m * vec4(cameraPos, 1.)).xyz;
            vec3 dir = vec3(pos.x*D, pos.y*D, -1.0);
            dir = normalize(mat3(m) * dir);

            bool heightMap = sourceElevation_specified==1;
            float maxZ = abs(intensity)*0.02;
            float ratio = heightMap ? (sourceElevationDim.x/sourceElevationDim.y) : (sourceDim.x/sourceDim.y);
            float dk = heightMap ? 2.0/sourceElevationDim.y : 2.0/sourceDim.y;
            vec3 step = dir * dk;

            float fResolution = float(rezolution);
            float ballSize = 2.0/fResolution;
            maxZ += ballSize;
            float surfaceWidth = hmpgl_round((2.0*ratio)/ballSize)*ballSize;
            float surfaceHeight = 2.0;

            float k1 = 0.0;
            float k2 = 100000000.0;

            if (dir.x!=0.0) {
                float s = sign(dir.x);
                float k3 = (-s*surfaceWidth/2.0-cameraPos.x)/dir.x;
                float k4 = (s*surfaceWidth/2.0-cameraPos.x)/dir.x;
                k1 = max(k1, k3);
                k2 = min(k2, k4);
            }

            if (dir.y!=0.0) {
                float s = sign(dir.y);
                float k3 = (-s-cameraPos.y)/dir.y;
                float k4 = (s-cameraPos.y)/dir.y;
                k1 = max(k1, k3);
                k2 = min(k2, k4);
            }

            float maxZ2 = maxZ+0.0001;
            if (dir.z!=0.0) {
                float s = sign(dir.z);
                float k3 = (-s*maxZ2-cameraPos.z)/dir.z;
                float k4 = (s*maxZ2-cameraPos.z)/dir.z;
                k1 = max(k1, k3);
                k2 = min(k2, k4);
            }

            if (k1>k2) return sourceBkg_specified==1 ? __sourceBkg__(outPos) : vec4(0.0, 0.0, 0.0, 1.0);

            float k = k1;
            vec3 p = cameraPos + k*dir;

            vec4 color = sourceBkg_specified==1 ? __sourceBkg__(outPos) : vec4(0.0, 0.0, 0.0, 1.0);
            float intersected = 0.0;
            vec4 outColor = vec4(0.0, 0.0, 0.0, 0.0);
            vec2 nextLines = sign(dir.xy)*ballSize/2.0;
            float trailSize = thickness*0.04;

            int maxIter = 1000;
            while (intersected<1.0 && k<=k2 && maxIter>0) {
                float indexX = (p.x+surfaceWidth/2.0)/ballSize;
                float indexY = (p.y+surfaceHeight/2.0)/ballSize;
                float fX = fract(indexX);
                float fY = fract(indexY);
                vec3 sphereCenter;

                if (fX>0.9999 && dir.x>0.0) sphereCenter.x = (ceil(indexX)+0.5)*ballSize;
                else if (fX<0.0001 && dir.x<0.0) sphereCenter.x = (floor(indexX)-0.5)*ballSize;
                else
                sphereCenter.x = (floor(indexX)+0.5)*ballSize;
                sphereCenter.x -= surfaceWidth/2.0;

                if (fY>0.9999 && dir.y>0.0) sphereCenter.y = (ceil(indexY)+0.5)*ballSize;
                else if (fY<0.0001 && dir.y<0.0) sphereCenter.y = (floor(indexY)-0.5)*ballSize;
                else
                sphereCenter.y = (floor(indexY)+0.5)*ballSize;
                sphereCenter.y -= surfaceHeight/2.0;

                vec4 hColor = heightMap ? __sourceElevation__(sphereCenter.xy) : __source__(sphereCenter.xy);
                float h = hmpgl_height(intensity, hColor);
                sphereCenter.z = h;

                if (abs(sphereCenter.x)<surfaceWidth/2.0 && abs(sphereCenter.y)<surfaceHeight/2.0) {
                    vec3 intersection = hmpgl_cubeIntersection(sphereCenter, ballSize/2.0, cameraPos, dir);
                    float trailAlpha = 1.0;
                    if (intersection.x >= 1e19) {
                        intersection = hmpgl_trailIntersection(sphereCenter, ballSize/2.0, trailSize, cameraPos, dir);
                        if (intersection.x < 1e19) {
                            trailAlpha = 1.0/(1.0+1.0*(h-ballSize/2.0-intersection.z)/trailSize);
                        }
                    }

                    if (intersection.x < 1e19) {
                        vec4 col;
                        if (colorScheme==0.0) col = __source__(sphereCenter.xy);
                        else if (colorScheme==100.0) col = __source__(intersection.xy);
                        else col = mix(__source__(sphereCenter.xy), __source__(intersection.xy), colorScheme*0.01);

                        col.a *= trailAlpha;
                        vec4 sampled = col * vec4(ambientColor.rgb*2.0, ambientColor.a);
                        if (length(sourceColor.rgb)!=0.0) {
                            vec3 normal = hmpgl_getCubeNormal(sphereCenter, intersection);

                            if (length(normal)>0.0) {
                                float alpha = sampled.a;
                                normal = normalize(normal);
                                vec3 lightDir = normalize(vec3(1.0, 1.0, 1.0));
                                sampled += col*vec4(sourceColor.rgb*2.0, 1.0) * clamp(dot(lightDir, normal), 0.0, 1.0);

                                if (specular!=0.0) {
                                    vec3 reflectLightDir = reflect(lightDir, normal);
                                    vec4 specularColor = sourceColor * (specular<25.0?specular*0.04:1.0) * pow(clamp(dot(dir, reflectLightDir), 0.0, 1.0), 10.0-specular*0.1);
                                    sampled = sampled + specularColor;
                                }
                                sampled.a = alpha;
                            }
                        }

                        outColor = intersected==0.0
                            ? sampled
                            : vec4(mix(outColor.rgb, sampled.rgb, intersected/(intersected+sampled.a)), outColor.a+(1.0-outColor.a)*sampled.a);
                        intersected += sampled.a;
                    }
                }

                vec2 next = sphereCenter.xy + nextLines;
                vec2 deltaK = (next-p.xy)/dir.xy;
                float minK = min(deltaK.x, deltaK.y);
                k += minK;
                p += minK*dir;
                --maxIter;
            }

            vec4 result = mix(color, vec4(outColor.rgb, color.a), outColor.a);
            return clamp(result, 0.0, 1.0);
        }
