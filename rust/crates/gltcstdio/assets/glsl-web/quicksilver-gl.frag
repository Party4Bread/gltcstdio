#version 450
layout(location = 0) in vec2 v_uv;
layout(location = 0) out vec4 fragColor;

layout(binding = 0, std140) uniform Params {
    vec4 U[23];
};
layout(binding = 1) uniform sampler samp;
layout(binding = 2) uniform texture2D t_source;

#define u_source sampler2D(t_source, samp)
#define u_worldAspect (U[0].x)
#define u_viewTransform (mat3(U[1].xyz, U[2].xyz, U[3].xyz))
#define u_sourceDim (U[4].xy)
#define u_outDim (U[5].xy)
#define u_model3DTransform (mat4(U[6], U[7], U[8], U[9]))
#define u_intensity (U[10].x)
#define u_colorScheme (U[11].x)
#define u_gamma (U[12].x)
#define u_specular (U[13].x)
#define u_surfaceSmoothness (U[14].x)
#define u_normalSmoothing (U[15].x)
#define u_shadows (U[16].x)
#define u_lightDistance (U[17].x)
#define u_lightAngleX (U[18].x)
#define u_lightAngleY (U[19].x)
#define u_sourceColor (U[20])
#define u_ambientColor (U[21])
#define u_backgroundStyle (int(U[22].x))

#define __source__texelFetch__(c) texelFetch(u_source, (c), 0)
#define __source__(p) textureLod(u_source, (vec2((p).x / u_worldAspect, (p).y) / 2.0 + 0.5), 0.0)




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





















































































































































































































































































































































vec4 qsApplyLighting(vec4 baseColor, vec4 reflectColor, float fromSource, float specular,
                     vec4 ambientColor, vec4 sourceColor, float gamma) {
    vec3 sumRGB = ambientColor.rgb + sourceColor.rgb + vec3(1.0);
    float maxLum = max(max(sumRGB.r, sumRGB.g), sumRGB.b);
    if (maxLum == 0.0) return vec4(0.0, 0.0, 0.0, 1.0);
    vec3 color = (reflectColor.rgb + baseColor.rgb * ambientColor.rgb + baseColor.rgb * sourceColor.rgb * fromSource + sourceColor.rgb * specular) / maxLum;
    float lum = (color.r + color.g + color.b) / 3.0;
    if (lum > 0.0 && gamma != 0.0) {
        float gammaCorrectedLum = pow(lum, pow(1.02, -gamma));
        color = color * gammaCorrectedLum / lum;
    }
    return clamp(vec4(color, baseColor.a), 0.0, 1.0);
}

float qsHeight(float intensity, vec4 color) {
    return intensity * 0.04 * ((color.r + color.g + color.b) / 3.0 - 0.5);
}

        vec4 quicksilverGl(vec2 pos, vec2 outPos, mat4 model3DTransform, vec2 sourceDim,
                           float intensity, float colorScheme, float gamma, float specular,
                           float surfaceSmoothness, float normalSmoothing, float shadows,
                           float lightDistance, float lightAngleX, float lightAngleY,
                           vec4 sourceColor, vec4 ambientColor,
                           int backgroundStyle) {
            mat4 invModelTransform = inverse(model3DTransform);
            // lightPos = rotY(lightAngleY) * rotX(lightAngleX) * translate(0,0,distance) * (0,0,0,1)
            float _caX = cos(lightAngleX);
            float _saX = sin(lightAngleX);
            float _caY = cos(lightAngleY);
            float _saY = sin(lightAngleY);
            vec3 lightPos = vec3(
                lightDistance * _caX * _saY,
                -lightDistance * _saX,
                lightDistance * _caX * _caY
            );

            // Pap: intensity = pow(u_Intensity * 0.01, 4.0) * 100.0 (applied in the planar() entry).
            // gltcstdio IntensityRel100 is on a -100..100 scale, same as Pap's slider.
            float intensityScaled = pow(intensity * 0.01, 4.0) * 100.0;
            // Sign of u_Intensity is lost by the pow(…, 4.0); Pap reproduces it via abs(intensity)
            // in maxZ. Keep abs(intensity) in maxZ just like Pap.
            float intensityAbs = abs(intensity);

            float D = 1.0;
            vec3 cameraPos = (invModelTransform * vec4(0.0, 0.0, 0.0, 1.0)).xyz;
            vec3 dir = normalize(mat3(invModelTransform) * vec3(pos.x * D, pos.y * D, -1.0));

            float maxZ = intensityAbs * 0.02;
            float ratio = sourceDim.x / sourceDim.y;
            float dk = 2.0 / sourceDim.y;
            vec3 step = dir * dk;

            float k1 = 0.0;
            float k2 = 1e8;
            if (dir.x != 0.0) {
                float s = sign(dir.x);
                float k3 = (-s * ratio - cameraPos.x) / dir.x;
                float k4 = ( s * ratio - cameraPos.x) / dir.x;
                k1 = max(k1, k3);
                k2 = min(k2, k4);
            }
            if (dir.y != 0.0) {
                float s = sign(dir.y);
                float k3 = (-s - cameraPos.y) / dir.y;
                float k4 = ( s - cameraPos.y) / dir.y;
                k1 = max(k1, k3);
                k2 = min(k2, k4);
            }
            float maxZ2 = maxZ + 0.0001;
            if (dir.z != 0.0) {
                float s = sign(dir.z);
                float k3 = (-s * maxZ2 - cameraPos.z) / dir.z;
                float k4 = ( s * maxZ2 - cameraPos.z) / dir.z;
                k1 = max(k1, k3);
                k2 = min(k2, k4);
            }

            vec4 _bkgMiss = vec4(0.0, 0.0, 0.0, 1.0);
            if (backgroundStyle == 0) {
    vec3 _o_n = normalize(dir);
    float _o_alpha = atan(_o_n.z, _o_n.x);
    float _o_beta = asin(_o_n.y);
    _bkgMiss = __source__(vec2(-_o_alpha / PI * 2.0, 2.0 * _o_beta / PI));
}
else if (backgroundStyle == 1) {
    // Pap planeMap has its own darken factor based on texture coord distance from center
    vec2 _o_pos = vec2(-(dir).x / (dir).z * sourceDim.y / sourceDim.x, -(dir).y / (dir).z);
    float _o_m = max(abs(_o_pos.x), abs(_o_pos.y));
    float _o_darken = 4.0 / max(4.0, _o_m);
    _bkgMiss = __source__(_o_pos) * vec4(_o_darken, _o_darken, _o_darken, 1.0);
}
else if (backgroundStyle == 2) {
    float _o_ratio = sourceDim.y / sourceDim.x;
    float _o_X = 0.5;
    float _o_Y = 0.5;
    if (abs((dir).y) > abs((dir).z) * _o_ratio && abs((dir).y) > abs((dir).x) * _o_ratio) {
        _o_X += -(dir).x / (dir).y * 0.5;
        _o_Y += -(dir).z / (dir).y * 0.5;
    }
    else if (abs((dir).x) < abs((dir).z)) {
        _o_X += (dir).x / abs((dir).z) * _o_ratio * 0.5 * -sign((dir).z);
        _o_Y += (dir).y / abs((dir).z) * 0.5;
    }
    else {
        _o_X += (dir).z / abs((dir).x) * _o_ratio * 0.5 * -sign((dir).x);
        _o_Y += (dir).y / abs((dir).x) * 0.5;
    }
    _bkgMiss = __source__(vec2(_o_X, _o_Y) * 2.0 - 1.0);
}
else {
    _bkgMiss = vec4((dir) * 0.5 + 0.5, 1.0);
}
            if (k1 > k2) return _bkgMiss;

            float k = k1;
            vec3 p = cameraPos + k * dir;
            vec4 color = vec4(0.0, 0.0, 0.0, 1.0);
            vec4 prevColor = color;
            float h = 0.0;
            float prevH = 0.0;
            float dz = 0.0;
            float prevDz = 0.0;
            bool stop = false;

            // Single-source version: heightmap sampled from __source__.
            do {
                prevColor = color;
                prevDz = dz;
                prevH = h;
                color = __source__(p.xy);
                h = qsHeight(intensityScaled, color);
                dz = p.z - h;
                p += step;
                k += dk;
                stop = dz == 0.0 || (k != k1 && sign(dz) == -sign(prevDz));
            } while (k <= k2 && !stop);

            stop = stop || abs(dz) < dk;
            if (!stop) return _bkgMiss;

            float kk = (dz == 0.0 || k1 + dk > k2) ? 1.0 : abs(prevDz) / (abs(dz) + abs(prevDz));
            float hh = mix(prevH, h, kk);

            vec3 lightVec = lightPos - p;
            vec3 lightDir = normalize(lightVec);

            float shadowing = sourceColor.r + sourceColor.g + sourceColor.b;

            // Normal via Pap's multi-tap finite differences (N = 1 + ceil(normalSmoothing/20)).
            vec3 intersection = p;
            float N = 1.0 + ceil(normalSmoothing / 20.0);
            float bx = 0.0005 + normalSmoothing * 0.0001;
            float sx = N >= 2.0 ? bx / (N - 1.0) : 0.0;
            float dzdx = 0.0;
            for (int i = 0; i < int(N); ++i) {
                float deltaX = bx + float(i) * sx;
                dzdx += (qsHeight(intensityScaled, __source__(vec2(intersection.x + deltaX, intersection.y)))
                       - qsHeight(intensityScaled, __source__(vec2(intersection.x - deltaX, intersection.y))));
            }
            dzdx /= N;
            float deltaX = bx + (N - 1.0) / 2.0 * sx;

            float by = 0.0005 + normalSmoothing * 0.0001;
            float sy = N >= 2.0 ? by / (N - 1.0) : 0.0;
            float dzdy = 0.0;
            for (int i = 0; i < int(N); ++i) {
                float deltaY = by + float(i) * sy;
                dzdy += (qsHeight(intensityScaled, __source__(vec2(intersection.x, intersection.y + deltaY)))
                       - qsHeight(intensityScaled, __source__(vec2(intersection.x, intersection.y - deltaY))));
            }
            dzdy /= N;
            float deltaY = by + (N - 1.0) / 2.0 * sy;

            vec3 unormal = vec3(-2.0 * deltaY * dzdx, -2.0 * deltaX * dzdy, deltaX * deltaY);
            vec3 normal = (unormal.x == 0.0 && unormal.y == 0.0 && unormal.z == 0.0) ? vec3(0.0, 0.0, 1.0) : normalize(unormal);

            float lighting = (dot(lightDir, normal) + 1.0) / 2.0;

            vec3 reflected = reflect(dir, normal);
            vec4 surfaceColor = mix(prevColor, color, kk);
            vec4 reflectiveColor = mix(vec4(1.0), 1.5 * surfaceColor, colorScheme * 0.01);
            vec4 _reflBkg = vec4(0.0);
            if (backgroundStyle == 0) {
    vec3 _o_n = normalize(reflected);
    float _o_alpha = atan(_o_n.z, _o_n.x);
    float _o_beta = asin(_o_n.y);
    _reflBkg = __source__(vec2(-_o_alpha / PI * 2.0, 2.0 * _o_beta / PI));
}
else if (backgroundStyle == 1) {
    // Pap planeMap has its own darken factor based on texture coord distance from center
    vec2 _o_pos = vec2(-(reflected).x / (reflected).z * sourceDim.y / sourceDim.x, -(reflected).y / (reflected).z);
    float _o_m = max(abs(_o_pos.x), abs(_o_pos.y));
    float _o_darken = 4.0 / max(4.0, _o_m);
    _reflBkg = __source__(_o_pos) * vec4(_o_darken, _o_darken, _o_darken, 1.0);
}
else if (backgroundStyle == 2) {
    float _o_ratio = sourceDim.y / sourceDim.x;
    float _o_X = 0.5;
    float _o_Y = 0.5;
    if (abs((reflected).y) > abs((reflected).z) * _o_ratio && abs((reflected).y) > abs((reflected).x) * _o_ratio) {
        _o_X += -(reflected).x / (reflected).y * 0.5;
        _o_Y += -(reflected).z / (reflected).y * 0.5;
    }
    else if (abs((reflected).x) < abs((reflected).z)) {
        _o_X += (reflected).x / abs((reflected).z) * _o_ratio * 0.5 * -sign((reflected).z);
        _o_Y += (reflected).y / abs((reflected).z) * 0.5;
    }
    else {
        _o_X += (reflected).z / abs((reflected).x) * _o_ratio * 0.5 * -sign((reflected).x);
        _o_Y += (reflected).y / abs((reflected).x) * 0.5;
    }
    _reflBkg = __source__(vec2(_o_X, _o_Y) * 2.0 - 1.0);
}
else {
    _reflBkg = vec4((reflected) * 0.5 + 0.5, 1.0);
}
            vec4 reflectColor = reflectiveColor * _reflBkg;

            if (surfaceSmoothness < 100.0) {
                if (lighting < 0.5) lighting = pow(lighting * 2.0, 100.0 / surfaceSmoothness) / 2.0;
                else lighting = pow((lighting - 0.5) * 2.0, 0.01 * surfaceSmoothness) / 2.0 + 0.5;
            }

            float spec = 0.0;
            if (specular != 0.0) {
                vec3 reflectLightDir = reflect(lightDir, normal);
                spec = pow(clamp(dot(dir, reflectLightDir), 0.0, 1.0), 10.0 - specular * 0.1);
            }

            float shad = shadows * 0.01; // Pap u_Shadows is 0..100, *0.01 in shader
            if (shadowing != 0.0 && shad > 0.0 && intensity != 0.0) {
                p = p - 2.0 * step; // back off to avoid self-intersection
                vec3 lightStep = lightDir * dk;

                k1 = 0.0;
                float k2s = length(lightVec);
                if (lightDir.x != 0.0) {
                    float s = sign(lightDir.x);
                    float k3 = (-s * ratio - p.x) / lightDir.x;
                    float k4 = ( s * ratio - p.x) / lightDir.x;
                    if (k4 > 0.0) k2s = min(k2s, k4);
                    if (k3 > 0.0) k2s = min(k2s, k3);
                }
                if (lightDir.y != 0.0) {
                    float s = sign(lightDir.y);
                    float k3 = (-s - p.y) / lightDir.y;
                    float k4 = ( s - p.y) / lightDir.y;
                    if (k4 > 0.0) k2s = min(k2s, k4);
                    if (k3 > 0.0) k2s = min(k2s, k3);
                }
                float maxZ2s = maxZ + 0.0001;
                if (lightDir.z != 0.0) {
                    float s = sign(lightDir.z);
                    float k3 = (-s * maxZ2s - p.z) / lightDir.z;
                    float k4 = ( s * maxZ2s - p.z) / lightDir.z;
                    if (k4 > 0.0) k2s = min(k2s, k4);
                    if (k3 > 0.0) k2s = min(k2s, k3);
                }

                float ks = 0.0;
                h = 0.0; prevH = 0.0; dz = 0.0; prevDz = 0.0;
                bool sstop = false;
                do {
                    prevDz = dz;
                    prevH = h;
                    h = qsHeight(intensityScaled, __source__(p.xy));
                    dz = p.z - h;
                    p += lightStep;
                    ks += dk;
                    sstop = dz == 0.0 || (ks != 0.0 && sign(dz) == -sign(prevDz));
                } while (ks <= k2s && !sstop);
                if (sstop) {
                    lighting = min(1.0 - shad, lighting);
                    spec = 0.0;
                }
            }

            return qsApplyLighting(surfaceColor, reflectColor, lighting, spec, ambientColor, sourceColor, gamma);
        }

void main() {
    fragColor = quicksilverGl((inverse(u_viewTransform) * vec3(((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), 1.0)).xy, ((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), u_model3DTransform, u_sourceDim, u_intensity, u_colorScheme, u_gamma, u_specular, u_surfaceSmoothness, u_normalSmoothing, u_shadows, u_lightDistance, u_lightAngleX, u_lightAngleY, u_sourceColor, u_ambientColor, u_backgroundStyle);
}
