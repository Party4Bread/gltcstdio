vec4 arrayVarTest(vec2 pos, vec2 outPos, vec4 color1, vec4 color2, int[5] types, int types_size) {
    if (pos.x<0.0) return vec4(1., 0., 0., 1.);
    if (types[int(mod(floor(pos.y), float(types_size)))]>int(pos.x)) return color1; else return color2;   
    //if (int(mod(floor(pos.y), float(types_size)))>int(pos.x)) return color1; else return color2;   
}
