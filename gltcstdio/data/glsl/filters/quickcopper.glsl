vec2 reduce3_2(vec3 v, float k) {
    float a = 1.0/3.0;
    float b = 2.0/3.0;
    if (k<a) {
        float kk = k * 3.0;
        return vec2(mix(v.x, v.y, kk), mix(v.y, v.z, kk));
    }
    else if (k<b) {
        float kk = (k-a) * 3.0;
        return vec2(mix(v.y, v.z, kk), mix(v.z, v.x, kk));
    }
    else {
        float kk = (k-b) * 3.0;
        return vec2(mix(v.z, v.x, kk), mix(v.x, v.y, kk));
    }
}

vec4 quickcopper(vec2 pos, vec2 outPos, float balance, int source2_specified, mat3 modelTransform) {
    //vec4 col = source2_specified==0 ? __source1__(pos) : __source2__(pos);
    vec4 col = __source1__(pos);
    vec2 uv = (reduce3_2(col.rgb, balance)-.5) * 2.;
    return source2_specified==0 ? __source1__(tf(inverse(modelTransform), uv)) : __source2__(tf(inverse(modelTransform), uv));
}
