float hmggl_height(float intensity, vec4 color) {
    return intensity*0.04* ((color.r + color.g + color.b)/3.0 - 0.5);
}

vec4 heightMapGlitchyGl(vec2 pos, vec2 outPos,
            int sourceBkg_specified, int sourceElevation_specified,
            float intensity, int count,
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

            float fResolution = float(count);
            float ballSize = 2.0/fResolution;
            maxZ += ballSize;
            float surfaceHeight = 2.0;

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

            int maxIter = 500;
            float minK = ballSize/4.0;
            vec3 step = minK*dir;

            while (intersected<1.0 && k<=k2 && maxIter>0) {
                vec4 hColor = heightMap ? __sourceElevation__(p.xy) : __source__(p.xy);
                float h = hmggl_height(intensity, hColor);

                if (h > p.z) {
                    outColor = __source__(p.xy);
                    intersected = 1.0;
                }

                k += minK;
                p += step;
                --maxIter;
            }

            return mix(color, vec4(outColor.rgb, color.a), outColor.a);
        }
