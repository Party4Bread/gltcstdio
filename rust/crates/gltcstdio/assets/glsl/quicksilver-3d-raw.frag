#version 450
layout(location = 0) in vec2 v_uv;
layout(location = 0) out vec4 fragColor;

layout(binding = 0, std140) uniform Params {
    vec4 U[28];
};
layout(binding = 1) uniform sampler samp;
layout(binding = 2) uniform texture2D t_source;
layout(binding = 3) uniform texture2D t_sourceBkg;
layout(binding = 4) uniform texture2D t_sourceElevation;

#define u_source sampler2D(t_source, samp)
#define u_sourceBkg sampler2D(t_sourceBkg, samp)
#define u_sourceElevation sampler2D(t_sourceElevation, samp)
#define u_worldAspect (U[0].x)
#define u_viewTransform (mat3(U[1].xyz, U[2].xyz, U[3].xyz))
#define u_sourceDim (U[4].xy)
#define u_sourceBkgDim (U[5].xy)
#define u_sourceBkg_specified (int(U[6].x))
#define u_sourceElevation_specified (int(U[7].x))
#define u_outDim (U[8].xy)
#define u_intensity (U[9].x)
#define u_model3DTransform (mat4(U[10], U[11], U[12], U[13]))
#define u_lightSourceTransform (mat4(U[14], U[15], U[16], U[17]))
#define u_colorScheme (U[18].x)
#define u_backgroundMode (int(U[19].x))
#define u_sourceColor (U[20])
#define u_ambientColor (U[21])
#define u_colorFog (U[22])
#define u_normalSmoothing (U[23].x)
#define u_surfaceSmoothness (U[24].x)
#define u_specular (U[25].x)
#define u_shadows (U[26].x)
#define u_gamma (U[27].x)

#define __source__texelFetch__(c) texelFetch(u_source, (c), 0)
#define __source__(p) texture(u_source, (vec2((p).x / u_worldAspect, (p).y) / 2.0 + 0.5))
#define __sourceBkg__texelFetch__(c) texelFetch(u_sourceBkg, (c), 0)
#define __sourceBkg__(p) texture(u_sourceBkg, (vec2((p).x / u_worldAspect, (p).y) / 2.0 + 0.5))
#define __sourceElevation__texelFetch__(c) texelFetch(u_sourceElevation, (c), 0)
#define __sourceElevation__(p) texture(u_sourceElevation, (vec2((p).x / u_worldAspect, (p).y) / 2.0 + 0.5))




// gltcstdio GLSL support library.
// Every function below was verified to compile against GL 3.3.
// Prototypes precede bodies so intra-library call order is irrelevant.

#define INF 1e20
#define PI 3.141592653589793
#define PI2 6.283185307179586
#define PI4 12.566370614359172
#define PI_2 1.5707963267948966
#define PI_3 1.0471975511965976
#define PI2_3 2.0943951023931953
#define SQRT3 1.7320508075688772
#define SQRT3_2 0.8660254037844386
#define SQRT3_6 0.288675134594813
#define SQRT2 1.4142135623730951
#define SQRT2_2 0.7071067811865476
#define THIRD 0.33333333333
#define TWO_THIRDS 0.666666666667

struct HexTile {
    vec2 center;
    vec2 pos;
    float angle;    
    float centerDist;
    float borderDist;
};
struct CairoTile {
    vec2 center;
    float borderDist;
};
struct TriangleTile {
    bool up;
    vec2 center;
    vec2 pos;
    float angle;    
    float centerDist;
    float borderDist;
};
struct Tile {
    float centerDist;
    vec2 tileId;
    float borderDist;
    vec2 center;
    vec2 borderNormal;
    float secondCenterDist;
    vec2 secondTileId;    
    float thirdCenterDist;
};

// ---- prototypes ----










































































































































































































// ---- bodies ----



















        























































































// allow vec4's




































































































































































































































































































































































vec4 applyLighting(vec4 baseColor, vec4 reflectColor, float fromSource, float specular, vec4 ambientColor, vec4 sourceColor, float gamma) {
    vec3 sumRGB = ambientColor.rgb + sourceColor.rgb + vec3(1.0);
    float maxLum = max(max(sumRGB.r, sumRGB.g), sumRGB.b);
    if (maxLum == 0.0) return vec4(0.0, 0.0, 0.0, 1.0);

    vec3 color = (reflectColor.rgb + baseColor.rgb * ambientColor.rgb + baseColor.rgb * sourceColor.rgb * fromSource + sourceColor.rgb * specular) / maxLum;

    float lum = (color.r + color.g + color.b) / 3.0;
    if (lum > 0.0 && gamma != 0.0) {
        float gammaCorrectedLum = pow(lum, pow(1.02, -gamma * 100.0));
        color = color * gammaCorrectedLum / lum;
    }

    return clamp(vec4(color, baseColor.a), 0.0, 1.0);
}

vec3 boxMap(vec3 dir, vec2 sourceBkgDim) {
    float ratio = sourceBkgDim.y / sourceBkgDim.x;
    float X = 0.5;
    float Y = 0.5;

    if (abs(dir.y) > abs(dir.z) * ratio && abs(dir.y) > abs(dir.x) * ratio) {
        X += -dir.x / dir.y * 0.5;
        Y += -dir.z / dir.y * 0.5;
    } else if (abs(dir.x) < abs(dir.z)) {
        X += dir.x / abs(dir.z) * ratio * 0.5 * -sign(dir.z);
        Y += dir.y / abs(dir.z) * 0.5;
    } else {
        X += dir.z / abs(dir.x) * ratio * 0.5 * -sign(dir.x);
        Y += dir.y / abs(dir.x) * 0.5;
    }
    return vec3(X, Y, 1.0);
}

vec3 planeMap(vec3 dir, vec2 sourceBkgDim) {
    float ratio = sourceBkgDim.x / sourceBkgDim.y;
    vec2 planePos = vec2(-dir.x/dir.z * ratio, -dir.y/dir.z) * 0.5 + vec2(0.5, 0.5);
    float m = max(abs(planePos.x - 0.5), abs(planePos.y - 0.5)) * 2.0;
    float darken = 1.0 / max(1.0, m);
    return vec3(planePos, darken);
}

vec3 sphereMap(vec3 dir, vec2 sourceBkgDim) {
    vec3 n = normalize(dir);
    float alpha = atan(n.x, n.z);
    float beta = asin(n.y);
    float nX = 1.0;
    float nY = 1.0;
    return vec3(-alpha/3.14159265359 * nX, 0.5 + nY * beta/3.14159265359, 1.0);
}

vec3 backgroundDirect(vec3 dir, vec2 outPos, vec2 sourceBkgDim, int backgroundMode) {
    if (backgroundMode == 1) return planeMap(dir, sourceBkgDim);
    else if (backgroundMode == 2) return boxMap(dir, sourceBkgDim);
    else if (backgroundMode == 3) return vec3(outPos, 1.0);
    else return sphereMap(dir, sourceBkgDim);
}

vec3 backgroundForReflection(vec3 dir, vec2 sourceBkgDim, int backgroundMode) {
    if (backgroundMode == 1) return planeMap(dir, sourceBkgDim);
    else if (backgroundMode == 2) return boxMap(dir, sourceBkgDim);
    else return sphereMap(dir, sourceBkgDim);
}

float height(float intensity, vec4 color) {
    return intensity*0.04* ((color.r + color.g + color.b)/3.0 - 0.5);
}

vec4 quicksilver3D(vec2 pos, vec2 outPos, float intensity, mat4 model3DTransform, vec2 sourceDim, vec2 sourceBkgDim,
    int sourceBkg_specified, int sourceElevation_specified,
    mat4 lightSourceTransform, float colorScheme, int backgroundMode,
    vec4 sourceColor, vec4 ambientColor, vec4 colorFog,
    float normalSmoothing, float surfaceSmoothness, float specular, float shadows, float gamma) {

    float D = 1.0;
    vec3 cameraPos = vec3(0.0, 0.0, 0.0);
    mat4 m = inverse(model3DTransform);
    cameraPos = (m * vec4(cameraPos, 1.0)).xyz;
    vec3 dir = vec3(pos.x * D, pos.y * D, -1.0);
    dir = normalize(mat3(m) * dir);

    float maxZ = abs(intensity) * 0.02;
    float ratio = sourceDim.x / sourceDim.y;
    float dk = 2.0 / sourceDim.y;
    vec3 step = dir * dk;
    bool heightMap = sourceElevation_specified == 1;

    vec3 lightPos = (lightSourceTransform * vec4(0.0, 0.0, 0.0, 1.0)).xyz;

    float k1 = 0.0;
    float k2 = 100000000.0;

    if (dir.x != 0.0) {
        float s = sign(dir.x);
        float k3 = (-s * ratio - cameraPos.x) / dir.x;
        float k4 = (s * ratio - cameraPos.x) / dir.x;
        k1 = max(k1, k3);
        k2 = min(k2, k4);
    }

    if (dir.y != 0.0) {
        float s = sign(dir.y);
        float k3 = (-s - cameraPos.y) / dir.y;
        float k4 = (s - cameraPos.y) / dir.y;
        k1 = max(k1, k3);
        k2 = min(k2, k4);
    }

    float maxZ2 = maxZ + 0.0001;
    if (dir.z != 0.0) {
        float s = sign(dir.z);
        float k3 = (-s * maxZ2 - cameraPos.z) / dir.z;
        float k4 = (s * maxZ2 - cameraPos.z) / dir.z;
        k1 = max(k1, k3);
        k2 = min(k2, k4);
    }

    vec4 backgroundColor = vec4(0.0, 0.0, 0.0, 1.0);
    if (sourceBkg_specified == 1) {
        vec3 bkgDir = backgroundDirect(dir, outPos, sourceBkgDim, backgroundMode);
        backgroundColor = __sourceBkg__(bkgDir.xy) * vec4(vec3(bkgDir.z), 1.0);
    }

    if (k1 > k2) return backgroundColor;

    float k = k1;
    vec3 p = cameraPos + k * dir;

    vec4 color = backgroundColor;
    float h = 0.0;
    float dz = 0.0;
    float prevDz;
    vec4 prevColor = vec4(0.0, 0.0, 0.0, 1.0);
    float prevH;
    bool stop;

    if (heightMap) {
        do {
            prevDz = dz;
            prevH = h;

            h = height(intensity, __sourceElevation__(p.xy));
            dz = p.z - h;

            p += step;
            k += dk;
            stop = dz == 0.0 || (k != k1 && sign(dz) == -sign(prevDz));
        } while (k <= k2 && !stop);
        vec2 pp = (p - step).xy;
        color = __source__(pp);
        prevColor = __source__(pp - step.xy);
    } else {
        do {
            prevColor = color;
            prevDz = dz;
            prevH = h;

            color = __source__(p.xy);
            h = height(intensity, color);
            dz = p.z - h;

            p += step;
            k += dk;
            stop = dz == 0.0 || (k != k1 && sign(dz) == -sign(prevDz));
        } while (k <= k2 && !stop);
    }

    stop = stop || abs(dz) < dk;

    if (!stop) return backgroundColor;

    float kk = (dz == 0.0 || k1 + dk > k2) ? 1.0 : abs(prevDz) / (abs(dz) + abs(prevDz));
    float hh = mix(prevH, h, kk);

    vec3 lightVec = lightPos - p;
    vec3 lightDir = normalize(lightVec);

    float lighting = 1.0;
    float spec = 0.0;
    float shadowing = sourceColor.r + sourceColor.g + sourceColor.b;

    vec3 intersection = p;
    float N = 1.0 + ceil(normalSmoothing / 20.0);
    float bx = 0.0005 + normalSmoothing * 0.0001;
    float sx = N >= 2.0 ? bx / (N - 1.0) : 0.0;
    float dzdx = 0.0;

    if (!heightMap) {
        for (int i = 0; i < int(N); ++i) {
            float deltaX = bx + float(i) * sx;
            dzdx += (height(intensity, __source__(vec2(intersection.x + deltaX, intersection.y)))
                    - height(intensity, __source__(vec2(intersection.x - deltaX, intersection.y))));
        }
    } else {
        for (int i = 0; i < int(N); ++i) {
            float deltaX = bx + float(i) * sx;
            dzdx += (height(intensity, __sourceElevation__(vec2(intersection.x + deltaX, intersection.y)))
                    - height(intensity, __sourceElevation__(vec2(intersection.x - deltaX, intersection.y))));
        }
    }

    dzdx /= N;
    float deltaX = bx + (N - 1.0) / 2.0 * sx;

    float by = 0.0005 + normalSmoothing * 0.0001;
    float sy = N >= 2.0 ? by / (N - 1.0) : 0.0;
    float dzdy = 0.0;

    if (!heightMap) {
        for (int i = 0; i < int(N); ++i) {
            float deltaY = by + float(i) * sy;
            dzdy += (height(intensity, __source__(vec2(intersection.x, intersection.y + deltaY)))
                   - height(intensity, __source__(vec2(intersection.x, intersection.y - deltaY))));
        }
    } else {
        for (int i = 0; i < int(N); ++i) {
            float deltaY = by + float(i) * sy;
            dzdy += (height(intensity, __sourceElevation__(vec2(intersection.x, intersection.y + deltaY)))
                   - height(intensity, __sourceElevation__(vec2(intersection.x, intersection.y - deltaY))));
        }
    }

    dzdy /= N;
    float deltaY = by + (N - 1.0) / 2.0 * sy;

    vec3 unormal = vec3(-2.0 * deltaY * dzdx, -2.0 * deltaX * dzdy, deltaX * deltaY);
    vec3 normal = (unormal.x == 0.0 && unormal.y == 0.0 && unormal.z == 0.0) ? vec3(0.0, 0.0, 1.0) : normalize(unormal);

    lighting = (dot(lightDir, normal) + 1.0) / 2.0;

    // Compute reflection
    vec3 reflected = reflect(dir, normal);
    vec4 surfaceColor = mix(prevColor, color, kk);
    vec4 reflectiveColor = mix(vec4(1.0, 1.0, 1.0, 1.0), 1.5 * surfaceColor, colorScheme * 0.01);

    vec4 reflectColor = vec4(0.0, 0.0, 0.0, 1.0);
    if (sourceBkg_specified == 1) {
        vec3 refDir = backgroundForReflection(reflected, sourceBkgDim, backgroundMode);
        reflectColor = reflectiveColor * __sourceBkg__(refDir.xy) * vec4(vec3(refDir.z), 1.0);
    }

    if (surfaceSmoothness < 100.0) {
        if (lighting < 0.5) {
            lighting = pow(lighting * 2.0, 100.0 / surfaceSmoothness) / 2.0;
        } else {
            lighting = pow((lighting - 0.5) * 2.0, 0.01 * surfaceSmoothness) / 2.0 + 0.5;
        }
    }

    if (specular != 0.0) {
        vec3 reflectLightDir = reflect(lightDir, normal);
        spec = pow(clamp(dot(dir, reflectLightDir), 0.0, 1.0), 10.0 - specular * 0.1);
    }

    float shad = shadows;
    if (shadowing != 0.0 && shad > 0.0 && intensity != 0.0) {
        p = p - 2.0 * step;
        vec3 lightStep = lightDir * dk;

        k1 = 0.0;
        float k2 = length(lightVec);

        if (lightDir.x != 0.0) {
            float s = sign(lightDir.x);
            float k3 = (-s * ratio - p.x) / lightDir.x;
            float k4 = (s * ratio - p.x) / lightDir.x;
            if (k4 > 0.0) k2 = min(k2, k4);
            if (k3 > 0.0) k2 = min(k2, k3);
        }

        if (lightDir.y != 0.0) {
            float s = sign(lightDir.y);
            float k3 = (-s - p.y) / lightDir.y;
            float k4 = (s - p.y) / lightDir.y;
            if (k4 > 0.0) k2 = min(k2, k4);
            if (k3 > 0.0) k2 = min(k2, k3);
        }

        float maxZ2 = maxZ + 0.0001;
        if (lightDir.z != 0.0) {
            float s = sign(lightDir.z);
            float k3 = (-s * maxZ2 - p.z) / lightDir.z;
            float k4 = (s * maxZ2 - p.z) / lightDir.z;
            if (k4 > 0.0) k2 = min(k2, k4);
            if (k3 > 0.0) k2 = min(k2, k3);
        }

        k = 0.0;
        h = 0.0;
        dz = 0.0;
        stop = false;

        if (heightMap) {
            do {
                prevDz = dz;
                prevH = h;

                h = height(intensity, __sourceElevation__(p.xy));
                dz = p.z - h;

                p += lightStep;
                k += dk;
                stop = dz == 0.0 || (k != k1 && sign(dz) == -sign(prevDz));
            } while (k <= k2 && !stop);
        } else {
            do {
                prevDz = dz;
                prevH = h;

                h = height(intensity, __source__(p.xy));
                dz = p.z - h;

                p += lightStep;
                k += dk;
                stop = dz == 0.0 || (k != k1 && sign(dz) == -sign(prevDz));
            } while (k <= k2 && !stop);
        }

        if (stop) {
            lighting = min(1.0 - shadows, lighting);
            spec = 0.0;
        }
    }

    color = applyLighting(surfaceColor, reflectColor, lighting, spec, ambientColor, sourceColor, gamma);

    if (colorFog.a != 0.0) {
        float kFog = length(cameraPos - p);
        float nearDist = 2.0 * (1.0 - colorFog.a);
        float farDist = 2.0 * nearDist;
        kFog = smoothstep(nearDist, farDist, kFog);
        color.rgb = mix(color.rgb, colorFog.rgb, kFog);
    }

    return clamp(color, 0.0, 1.0);
}

void main() {
    fragColor = quicksilver3D((inverse(u_viewTransform) * vec3(((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), 1.0)).xy, ((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), u_intensity, u_model3DTransform, u_sourceDim, u_sourceBkgDim, u_sourceBkg_specified, u_sourceElevation_specified, u_lightSourceTransform, u_colorScheme, u_backgroundMode, u_sourceColor, u_ambientColor, u_colorFog, u_normalSmoothing, u_surfaceSmoothness, u_specular, u_shadows, u_gamma);
}
