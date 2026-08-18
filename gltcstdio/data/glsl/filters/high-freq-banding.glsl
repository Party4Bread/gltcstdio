vec4 highFreqBanding(vec2 pos, vec2 outPos, float intensity, int count, vec2 sourceDim, vec2 source2Dim, int source2_specified, float scaleX, float scaleY, mat3 modelTransform) {
    vec4 color = __source__(pos);
    vec4 bestColor = color;
    float bestDist = 1e9;        

    float resolution = length(modelTransform[0].xy);
    float scale = 1.0/ resolution;
    vec2 p =  pos;

    vec2 dim = (source2_specified!=0) ? vec2(source2Dim.x/source2Dim.y-1.0/source2Dim.y, 1.0-1.0/source2Dim.y) : vec2(sourceDim.x/sourceDim.y-1.0/sourceDim.y, 1.0-1.0/sourceDim.y);
    vec2 orig = (modelTransform*vec3(0.0, 0.0, 1.0)).xy;

    vec2 scaledDim = mat2(modelTransform)*(2.0*dim);
    vec2 offset = scaledDim/2.0 - orig;
    vec2 bottomLeft = floor((p+offset)/scaledDim)*scaledDim - offset;
    vec2 topRight = ceil((p+offset)/scaledDim)*scaledDim - offset;
//    vec2 bottomLeft = (floor((p+offset)/scaledDim+0.5)-0.5)*scaledDim - offset;
//    vec2 topRight = (ceil((p+offset)/scaledDim+0.5)-0.5)*scaledDim - offset;

    float dist;
    vec2 pp;
    vec4 c;

    float N = max(1.0, floor(float(count)/2.0)-1.0);
    for(float i=0.0; i<float(count); ++i) {
        float d = floor(i/2.0)/N;
        if (mod(i, 2.0)==0.0) {
            pp = vec2(bottomLeft.x + d*(topRight.x-bottomLeft.x), bottomLeft.y + mod(p.y*scaleY, topRight.y-bottomLeft.y));
            c = (source2_specified!=0) ? __source2__(pp) : __source__(pp);
            dist = length(color-c);
            if (dist<bestDist) {
                bestDist = dist;
                bestColor = c;
            }
        }
        else {
            pp = vec2(bottomLeft.x + mod(p.x*scaleX, topRight.x-bottomLeft.x), bottomLeft.y + d*(topRight.y-bottomLeft.y));
            c = (source2_specified!=0) ? __source2__(pp) : __source__(pp);
            dist = length(color-c);
            if (dist<bestDist) {
                bestDist = dist;
                bestColor = c;
            }
        }
    }

    return mix(color, bestColor, intensity);

}
