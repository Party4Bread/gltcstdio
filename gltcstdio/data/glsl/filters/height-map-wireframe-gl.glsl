float height(float intensity, vec4 color) {
    return intensity*0.04* ((color.r + color.g + color.b)/3.0 - 0.5);
}

bool close(float a, float b) {
    return abs(a-b) < 0.00001;
}

float intersectX_hmwgl(vec3 _p, vec3 cameraPos, vec3 cameraDir, float h, float thickness, float glow) {
    float dist = dot(cameraDir, _p-cameraPos);
    float t = thickness*0.01;
    float b = glow*0.1;
    float maxDist = (t+b)*dist;
    maxDist /= abs(normalize(cameraPos.xz-vec2(_p.x, h)).x);
    float proxim = abs(_p.z-h) / maxDist;
    if (proxim>1.0) return 0.0;
    return 1.0 - pow(smoothstep(t/(t+b), 1.0, proxim), 0.5);
}

float intersectY_hmwgl(vec3 _p, vec3 cameraPos, vec3 cameraDir, float h, float thickness, float glow) {
    float dist = dot(cameraDir, _p-cameraPos);
    float t = thickness*0.01;
    float b = glow*0.1;
    float maxDist = (t+b)*dist;
    maxDist /= abs(normalize(cameraPos.yz-vec2(_p.y, h)).x);
    float proxim = abs(_p.z-h) / maxDist;
    if (proxim>1.0) return 0.0;
    return 1.0 - pow(smoothstep(t/(t+b), 1.0, proxim), 0.5);
}

vec4 heightMapWireframeGl(vec2 pos, vec2 outPos,
            float intensity, int rezolution, mat4 model3DTransform, vec2 sourceDim, vec2 sourceElevationDim,
            int sourceBkg_specified, int sourceElevation_specified,
            float thickness, float glow,
            vec4 colorLines
        ) {
            float D = 1.0;
            vec3 cameraPos = vec3(0.0, 0.0, 0.0);
            mat4 m = inverse(model3DTransform);
            cameraPos = (m * vec4(cameraPos, 1.0)).xyz;
            vec3 dir = normalize(vec3(pos.x*D, pos.y*D, -1.0));
            dir = mat3(m) * dir;
            vec3 cameraDir = normalize(vec3(0.0, 0.0, -1.0));
            cameraDir = mat3(m) * cameraDir;

            bool heightMap = sourceElevation_specified==1;

            float maxZ = abs(intensity)*0.02;
            float ratio = heightMap ? (sourceElevationDim.x/sourceElevationDim.y) : (sourceDim.x/sourceDim.y);
            float dk = heightMap ? 2.0/sourceElevationDim.y : 2.0/sourceDim.y;
            vec3 step = dir * dk;

            float k1 = 0.0;
            float k2 = 100000000.0;

            if (dir.x!=0.0) {
                float s = sign(dir.x);
                float k3 = (-s*ratio-cameraPos.x)/dir.x;
                float k4 = (s*ratio-cameraPos.x)/dir.x;
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

            float maxZ2 = maxZ+0.0001; // prevent flickering on edge case
            if (dir.z!=0.0) {
                float s = sign(dir.z);
                float k3 = (-s*maxZ2-cameraPos.z)/dir.z;
                float k4 = (s*maxZ2-cameraPos.z)/dir.z;
                k1 = max(k1, k3);
                k2 = min(k2, k4);
            }

            if (k1>k2) return sourceBkg_specified==1 ? __sourceBkg__(outPos) : __source__(outPos);

            float k = k1;
            vec3 p = cameraPos + k*dir;

            // Pap shader uses u_Count (scalar). We pass rezolution as int — same role.
            float strideX = ratio*2.0/float(rezolution);
            float countY = floor(2.0/strideX + 0.5); // round(2.0/strideX)
            float strideY = 2.0/countY;

            float intersected = 0.0;
            float _h;

            // ----- Y-scanline pass -----
            float yPos = (p.y+1.0)/strideY;
            float yIndex = floor(yPos + 0.5); // round
            if (close(yPos, yIndex)) {
                _h = height(intensity, heightMap ? __sourceElevation__(p.xy) : __source__(p.xy));
                intersected += intersectY_hmwgl(p, cameraPos, cameraDir, _h, thickness, glow);
            }

            if (dir.y!=0.0) {
                float advanceY = (sign(dir.y)>0.0 ? ceil(yPos)-yPos : floor(yPos)-yPos) * strideY;
                float deltaK = advanceY/dir.y;
                k += deltaK;
                p += deltaK*dir;

                float deltaY = sign(dir.y) * strideY;
                deltaK = deltaY/dir.y;
                int maxIter = 1500;
                while (abs(p.y)<=1.0 && k<=k2 && maxIter>0) {
                    _h = height(intensity, heightMap ? __sourceElevation__(p.xy) : __source__(p.xy));
                    intersected += intersectY_hmwgl(p, cameraPos, cameraDir, _h, thickness, glow);
                    if (intersected>=1.0) break;
                    k += deltaK;
                    p += deltaK*dir;
                    --maxIter;
                }
            }

            // ----- X-scanline pass (reset & sweep) -----
            k = k1;
            p = cameraPos + k*dir;

            float xPos = (p.x+1.0)/strideX;
            float xIndex = floor(xPos + 0.5);
            if (close(xPos, xIndex)) {
                _h = height(intensity, heightMap ? __sourceElevation__(p.xy) : __source__(p.xy));
                intersected += intersectX_hmwgl(p, cameraPos, cameraDir, _h, thickness, glow);
            }

            if (dir.x!=0.0) {
                float advanceX = (sign(dir.x)>0.0 ? ceil(xPos)-xPos : floor(xPos)-xPos) * strideX;
                float deltaK = advanceX/dir.x;
                k += deltaK;
                p += deltaK*dir;

                float deltaX = sign(dir.x) * strideX;
                deltaK = deltaX/dir.x;
                int maxIter = 1500;
                while (abs(p.x)<=ratio && k<=k2 && maxIter>0) {
                    _h = height(intensity, heightMap ? __sourceElevation__(p.xy) : __source__(p.xy));
                    intersected += intersectX_hmwgl(p, cameraPos, cameraDir, _h, thickness, glow);
                    if (intersected>=1.0) break;
                    k += deltaK;
                    p += deltaK*dir;
                    --maxIter;
                }
            }

            vec4 wireColor = colorLines;
            return mix(sourceBkg_specified==1 ? __sourceBkg__(outPos) : __source__(outPos), wireColor, clamp(intersected, 0.0, 1.0));
        }
