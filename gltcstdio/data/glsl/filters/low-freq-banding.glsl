vec2 getPos(vec2 p, float ang, vec2 bottomLeft, vec2 topRight) {
    vec2 dir = vec2(cos(ang), sin(ang));
    float kx1 = dir.x==0.0 ? -1.0 : (bottomLeft.x-p.x)/dir.x;
    float kx2 = dir.x==0.0 ? -1.0 : (topRight.x-p.x)/dir.x;
    float ky1 = dir.y==0.0 ? -1.0 : (bottomLeft.y-p.y)/dir.y;
    float ky2 = dir.y==0.0 ? -1.0 : (topRight.y-p.y)/dir.y;
    float k = kx1;
    if (k<0.0 || kx2>=0.0 && kx2<k) k = kx2;
    if (k<0.0 || ky2>=0.0 && ky2<k) k = ky2;
    if (k<0.0 || ky1>=0.0 && ky1<k) k = ky1;
    return p+k*dir;
}

vec4 lowFreqBanding(vec2 pos, vec2 outPos, float intensity, int count, vec2 sourceDim, vec2 source2Dim, int source2_specified, float angle, mat3 modelTransform) {
    vec4 color = __source__(pos);
    vec4 bestColor = color;
    float bestDist = 100.0;

    float resolution = length(modelTransform[0].xy);
    float scale = 1.0/ resolution;
    vec2 p =  pos;

    vec2 dim = (source2_specified!=0) ? vec2(source2Dim.x/source2Dim.y-1.0/source2Dim.y, 1.0-1.0/source2Dim.y) : vec2(sourceDim.x/sourceDim.y-1.0/sourceDim.y, 1.0-1.0/sourceDim.y);
    vec2 orig = (modelTransform*vec3(0.0, 0.0, 1.0)).xy;

    vec2 scaledDim = mat2(modelTransform)*(2.0*dim);
    vec2 offset = scaledDim/2.0 - orig;
    vec2 bottomLeft = floor((p+offset)/scaledDim)*scaledDim - offset;
    vec2 topRight = ceil((p+offset)/scaledDim)*scaledDim - offset;

    for(int i=0; i<count; ++i) {
        float ang = float(i)/float(count)*PI + angle;

        vec2 pp = getPos(p, ang, bottomLeft, topRight);
        vec4 c = (source2_specified!=0) ? __source2__(pp) : __source__(pp);
        float dist = length(color-c);
        if (dist<bestDist) {
            bestDist = dist;
            bestColor = c;
        }
    }

    return mix(color, bestColor, intensity);

}
