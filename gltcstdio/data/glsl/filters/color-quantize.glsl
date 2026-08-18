int imod(int x, int y) {
    return x - y * (x / y);
}

float rand(vec2 co) {
    return fract(sin(dot(co.xy, vec2(12.9898, 78.233))) * 43758.5453);
}

vec4 applyColorTransforms(vec4 color, float gamma, float contrast, float saturation) {
    vec3 rgb = color.rgb;

    // Gamma
    if (gamma != 1.0) {
        rgb = pow(rgb, vec3(gamma));
    }

    // Contrast
    if (contrast != 1.0) {
        rgb.r = rgb.r < 0.5 ? pow(rgb.r * 2.0, contrast) / 2.0 : 0.5 + pow((rgb.r - 0.5) * 2.0, 1.0 / contrast) / 2.0;
        rgb.g = rgb.g < 0.5 ? pow(rgb.g * 2.0, contrast) / 2.0 : 0.5 + pow((rgb.g - 0.5) * 2.0, 1.0 / contrast) / 2.0;
        rgb.b = rgb.b < 0.5 ? pow(rgb.b * 2.0, contrast) / 2.0 : 0.5 + pow((rgb.b - 0.5) * 2.0, 1.0 / contrast) / 2.0;
    }

    // Saturation
    if (saturation != 1.0) {
        float grey = 0.2126 * rgb.r + 0.7152 * rgb.g + 0.0722 * rgb.b;
        rgb = vec3(grey) + (rgb - vec3(grey)) * saturation;
    }

    return vec4(clamp(rgb, 0.0, 1.0), color.a);
}

        vec4 colorQuantize(vec2 pos, vec2 outPos, vec2 outDim, vec2 paletteDim, int quantizeMode, vec2 ditheringPatternDim, float dithering, float gamma, float contrast, float saturation, float noiseValue, float closenessFactor, int paletteStep) {
            vec4 color = __source__(pos);

            // Apply color transforms using the exact same function as ColorQuantizeGL
            vec4 transformed = applyColorTransforms(color, gamma, contrast, saturation);

            // Use output position for pixel coordinates (matching original gl_FragCoord behavior)
            vec2 pixelPos = outPos;
            float ar = outDim.x / outDim.y;
            int x = int((outPos.x+ar)*.5*outDim.y);
            int y = int((outPos.y+1.)*.5*outDim.y);

            vec4 processedColor = transformed;
            vec4 result;

            // ============== DEBUG: Hardcoded 3x3 Bayer dither ==============
            // Bypasses texture sampling to test if pattern logic works correctly
            // pattern3x3 = {-0.2, 0.2, -0.1, 0.1, -0.4, 0.4, -0.3, 0.3, 0.0}
            // Row 0: -0.2, 0.2, -0.1  (indices 0,1,2)
            // Row 1: 0.1, -0.4, 0.4   (indices 3,4,5)
            // Row 2: -0.3, 0.3, 0.0   (indices 6,7,8)
//            {
//                float debugPattern[9];
//                debugPattern[0] = -0.2;
//                debugPattern[1] = 0.2;
//                debugPattern[2] = -0.1;
//                debugPattern[3] = 0.1;
//                debugPattern[4] = -0.4;
//                debugPattern[5] = 0.4;
//                debugPattern[6] = -0.3;
//                debugPattern[7] = 0.3;
//                debugPattern[8] = 0.0;
//
//                int px = imod(x, 3);
//                int py = imod(y, 3);
//                int patternIndex = px + 3 * py;
//                float debugNoise = debugPattern[patternIndex] * dithering;
//
//                processedColor.rgb = clamp(transformed.rgb + debugNoise, 0.0, 1.0);
//                
            {
                float minDistance = 1000000.0;
                vec4 best = processedColor;
                int n = int(paletteDim.x);

                for (int i = 0; i < 4096; ++i) {
                    if (i >= n) break;

                    vec4 paletteColor = __palette__texelFetch__(ivec2(i, 0));

                    vec3 delta = paletteColor.rgb - processedColor.rgb;
                    float distance = dot(delta, delta);

                    if (distance < minDistance) {
                        minDistance = distance;
                        best = paletteColor;
                    }
                }

                result = best;
            }
    
//                //result = vec4(debugNoise, debugNoise, debugNoise, 1.);
//                return result;
//            }
            // ============== END DEBUG ==============

            // Mode constants
            int MODE_BASIC = 0;
            int MODE_EXTENDED = 1;
            int MODE_EXTENDED_FAVORING_CLOSENESS = 2;
            int MODE_NOISY = 3;
            int MODE_PATTERN3 = 4;
            int MODE_PATTERN4 = 5;
            int MODE_PATTERN4_OFFSET = 6;
            int MODE_PATTERN8 = 7;
            int MODE_INTERLACED_H = 8;
            int MODE_INTERLACED_V = 9;
            int MODE_PATTERN5 = 10;
            int MODE_PATTERN2 = 11;
            int MODE_PATTERN3x6 = 12;
            int MODE_PATTERN4x8 = 13;

            if (quantizeMode == MODE_NOISY) {
                // Random noise dithering
                float noise = (rand(pixelPos) * 2.0 - 1.0) * noiseValue / 255.0;
                processedColor.rgb = clamp(transformed.rgb + noise, 0.0, 1.0);
                
            {
                float minDistance = 1000000.0;
                vec4 best = processedColor;
                int n = int(paletteDim.x);

                for (int i = 0; i < 4096; ++i) {
                    if (i >= n) break;

                    vec4 paletteColor = __palette__texelFetch__(ivec2(i, 0));

                    vec3 delta = paletteColor.rgb - processedColor.rgb;
                    float distance = dot(delta, delta);

                    if (distance < minDistance) {
                        minDistance = distance;
                        best = paletteColor;
                    }
                }

                result = best;
            }
    
                return result;

            } else if (quantizeMode == MODE_PATTERN2 || quantizeMode == MODE_PATTERN3 || quantizeMode == MODE_PATTERN4 ||
                       quantizeMode == MODE_PATTERN5 || quantizeMode == MODE_PATTERN8 || quantizeMode == MODE_PATTERN3x6 ||
                       quantizeMode == MODE_PATTERN4x8) {
                // Pattern dithering using texture
                // Amplitude is pre-baked into texture: stored = pattern * amplitude * 255 + 128
                // So we just need to subtract 128/255 to recover pattern * amplitude
                int patternW = int(ditheringPatternDim.x);
                int patternH = int(ditheringPatternDim.y);
                ivec2 dPos = ivec2(imod(x, patternW), imod(y, patternH));
                vec4 patternCol = __ditheringPattern__texelFetch__(dPos);
                float patternNoise = patternCol.r - 128.0/255.0;
                processedColor.rgb = clamp(transformed.rgb + patternNoise, 0.0, 1.0);
                
            {
                float minDistance = 1000000.0;
                vec4 best = processedColor;
                int n = int(paletteDim.x);

                for (int i = 0; i < 4096; ++i) {
                    if (i >= n) break;

                    vec4 paletteColor = __palette__texelFetch__(ivec2(i, 0));

                    vec3 delta = paletteColor.rgb - processedColor.rgb;
                    float distance = dot(delta, delta);

                    if (distance < minDistance) {
                        minDistance = distance;
                        best = paletteColor;
                    }
                }

                result = best;
            }
    
                return result;

            } else if (quantizeMode == MODE_PATTERN4_OFFSET) {
                // 4x4 pattern with RGB channel offsets
                // Amplitude is pre-baked into texture
                int patternW = int(ditheringPatternDim.x);
                int patternH = int(ditheringPatternDim.y);
                ivec2 dPosR = ivec2(imod(x, patternW), imod(y, patternH));
                ivec2 dPosG = ivec2(imod(x + 1, patternW), imod(y + 2, patternH));
                ivec2 dPosB = ivec2(imod(x + 3, patternW), imod(y + 1, patternH));
                float noiseR = __ditheringPattern__texelFetch__(dPosR).r - 128.0/255.0;
                float noiseG = __ditheringPattern__texelFetch__(dPosG).r - 128.0/255.0;
                float noiseB = __ditheringPattern__texelFetch__(dPosB).r - 128.0/255.0;
                processedColor.r = clamp(transformed.r + noiseR, 0.0, 1.0);
                processedColor.g = clamp(transformed.g + noiseG, 0.0, 1.0);
                processedColor.b = clamp(transformed.b + noiseB, 0.0, 1.0);
                
            {
                float minDistance = 1000000.0;
                vec4 best = processedColor;
                int n = int(paletteDim.x);

                for (int i = 0; i < 4096; ++i) {
                    if (i >= n) break;

                    vec4 paletteColor = __palette__texelFetch__(ivec2(i, 0));

                    vec3 delta = paletteColor.rgb - processedColor.rgb;
                    float distance = dot(delta, delta);

                    if (distance < minDistance) {
                        minDistance = distance;
                        best = paletteColor;
                    }
                }

                result = best;
            }
    
                return result;

            } else if (quantizeMode == MODE_EXTENDED) {
                
            {
                float minDistance = 1000000.0;
                vec4 best = transformed;
                int n = int(paletteDim.x);

                for (int i = 0; i < 4096; ++i) {
                    if (i >= n) break;

                    for (int j = i; j >= 0; j -= paletteStep) {
                        vec4 color1 = __palette__texelFetch__(ivec2(i, 0));
                        vec4 color2 = __palette__texelFetch__(ivec2(j, 0));

                        vec3 avgColor = (color1.rgb + color2.rgb) / 2.0;
                        vec3 delta = avgColor - transformed.rgb;
                        float distance = dot(delta, delta);

                        if (distance < minDistance) {
                            minDistance = distance;

                            float lum1 = 0.2126 * color1.r + 0.7152 * color1.g + 0.0722 * color1.b;
                            float lum2 = 0.2126 * color2.r + 0.7152 * color2.g + 0.0722 * color2.b;

                            // Use corrected x, y from main function (not pixelPos)
                            bool checker = imod(x + y, 2) == 0;

                            if (lum1 > lum2) {
                                best = checker ? color1 : color2;
                            } else {
                                best = checker ? color2 : color1;
                            }
                        }
                    }
                }

                result = best;
            }
    
                return result;

            } else if (quantizeMode == MODE_EXTENDED_FAVORING_CLOSENESS) {
                
            {
                float minDistance = 1000000.0;
                vec4 best = transformed;
                int n = int(paletteDim.x);

                for (int i = 0; i < 4096; ++i) {
                    if (i >= n) break;

                    for (int j = i; j >= 0; j -= paletteStep) {
                        vec4 color1 = __palette__texelFetch__(ivec2(i, 0));
                        vec4 color2 = __palette__texelFetch__(ivec2(j, 0));

                        vec3 avgColor = (color1.rgb + color2.rgb) / 2.0;
                        vec3 delta = avgColor - transformed.rgb;

                        vec3 penalty = color1.rgb - color2.rgb;
                        float distance = dot(delta, delta) + dot(penalty, penalty) * closenessFactor;

                        if (distance < minDistance) {
                            minDistance = distance;

                            float lum1 = 0.2126 * color1.r + 0.7152 * color1.g + 0.0722 * color1.b;
                            float lum2 = 0.2126 * color2.r + 0.7152 * color2.g + 0.0722 * color2.b;

                            // Use corrected x, y from main function (not pixelPos)
                            bool checker = imod(x + y, 2) == 0;

                            if (lum1 > lum2) {
                                best = checker ? color1 : color2;
                            } else {
                                best = checker ? color2 : color1;
                            }
                        }
                    }
                }

                result = best;
            }
    
                return result;

            } else if (quantizeMode == MODE_INTERLACED_H) {
                
            {
                float minDistance = 1000000.0;
                vec4 best = transformed;
                int n = int(paletteDim.x);

                for (int i = 0; i < 4096; ++i) {
                    if (i >= n) break;

                    for (int j = i; j >= 0; j -= paletteStep) {
                        vec4 color1 = __palette__texelFetch__(ivec2(i, 0));
                        vec4 color2 = __palette__texelFetch__(ivec2(j, 0));

                        vec3 avgColor = (color1.rgb + color2.rgb) / 2.0;
                        vec3 delta = avgColor - transformed.rgb;

                        vec3 penalty = color1.rgb - color2.rgb;
                        float distance = dot(delta, delta) + dot(penalty, penalty) * closenessFactor;

                        if (distance < minDistance) {
                            minDistance = distance;

                            float lum1 = 0.2126 * color1.r + 0.7152 * color1.g + 0.0722 * color1.b;
                            float lum2 = 0.2126 * color2.r + 0.7152 * color2.g + 0.0722 * color2.b;

                            // Use corrected y from main function (not pixelPos)
                            bool evenRow = imod(y, 2) == 0;

                            if (lum1 > lum2) {
                                best = evenRow ? color1 : color2;
                            } else {
                                best = evenRow ? color2 : color1;
                            }
                        }
                    }
                }

                result = best;
            }
    
                return result;

            } else if (quantizeMode == MODE_INTERLACED_V) {
                
            {
                float minDistance = 1000000.0;
                vec4 best = transformed;
                int n = int(paletteDim.x);

                for (int i = 0; i < 4096; ++i) {
                    if (i >= n) break;

                    for (int j = i; j >= 0; j -= paletteStep) {
                        vec4 color1 = __palette__texelFetch__(ivec2(i, 0));
                        vec4 color2 = __palette__texelFetch__(ivec2(j, 0));

                        vec3 avgColor = (color1.rgb + color2.rgb) / 2.0;
                        vec3 delta = avgColor - transformed.rgb;

                        vec3 penalty = color1.rgb - color2.rgb;
                        float distance = dot(delta, delta) + dot(penalty, penalty) * closenessFactor;

                        if (distance < minDistance) {
                            minDistance = distance;

                            float lum1 = 0.2126 * color1.r + 0.7152 * color1.g + 0.0722 * color1.b;
                            float lum2 = 0.2126 * color2.r + 0.7152 * color2.g + 0.0722 * color2.b;

                            // Use corrected x from main function (not pixelPos)
                            bool evenCol = imod(x, 2) == 0;

                            if (lum1 > lum2) {
                                best = evenCol ? color1 : color2;
                            } else {
                                best = evenCol ? color2 : color1;
                            }
                        }
                    }
                }

                result = best;
            }
    
                return result;

            } else {
                // MODE_BASIC
                
            {
                float minDistance = 1000000.0;
                vec4 best = transformed;
                int n = int(paletteDim.x);

                for (int i = 0; i < 4096; ++i) {
                    if (i >= n) break;

                    vec4 paletteColor = __palette__texelFetch__(ivec2(i, 0));

                    vec3 delta = paletteColor.rgb - transformed.rgb;
                    float distance = dot(delta, delta);

                    if (distance < minDistance) {
                        minDistance = distance;
                        best = paletteColor;
                    }
                }

                result = best;
            }
    
                return result;
            }
        }
