vec4 smoothen(vec2 pos, vec2 outPos, vec2 sourceDim, float dampening, float radius) {
    float pixel = 2.0 / sourceDim.y;
    radius = radius * 0.05; // max radius is 1/40th of image size
    int n = 50;
    int m = 10;

    vec4 c = __source__(pos);

    float div = 0.0;
    float N = 1.0;
    vec4 total = c;
    vec2 delta = rand2rel(pos);
    for(int i = 0; i<n; ++i)  {
        vec2 prnd = pos + 2.0*radius * delta;
        vec4 col = __source__(prnd);
        if (length(col-c)<=dampening) {
            total += col;
            ++N;
        }
        if (mod(float(i), 4.0)==3.0) {
            delta = vec2(delta.y, -delta.x);
        }
        else {
            delta = rand2rel(delta);
        }

        if (int(N)>=m) break;
    }

    return total/N;
}
